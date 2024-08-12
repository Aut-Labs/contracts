//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OnboardingModule} from "../modules/onboarding/OnboardingModule.sol";
import {NovaUpgradeable} from "./NovaUpgradeable.sol";
import {NovaUtils} from "./NovaUtils.sol";
import {INova} from "./INova.sol";
import {INovaRegistry} from "./INovaRegistry.sol";
import "../hubContracts/IHubDomainsRegistry.sol";
import {IGlobalParametersAlpha} from "../globalParameters/IGlobalParametersAlpha.sol";
import {IInteractionRegistry} from "../interactions/InteractionRegistry.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";

// todo: admin retro onboarding
contract Nova is INova, NovaUtils, NovaUpgradeable {
    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant REPUTATION_PARAMETER = 2;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    uint256 public constant MIN_COMMITMENT = 1;
    uint256 public constant MAX_COMMITMENT = 10;

    uint8 public constant MEMBER_MASK_POSITION = 0;
    uint8 public constant ADMIN_MASK_POSITION = 1;

    address public autID;
    address public novaRegistry;
    address public hubDomainsRegistry;
    address public pluginRegistry;
    address public onboarding;
    address public deployer;

    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataUri;

    uint32 public initTimestamp;
    uint32 public initPeriodId;

    mapping(address => uint256) public roles;
    mapping(address => uint32) public joinedAt;
    mapping(address => uint8) public currentCommitmentLevels;
    mapping(uint256 => uint256) public parameterWeight;
    mapping(address => uint256) public accountMasks;

    struct Task {
        uint32 contributionPoints;
        uint128 quantity;
        bytes32 interactionId;
        // TODO: further identifiers
    }
    Task[] public tasks;

    struct Participation {
        uint32 commitmentLevel;
        uint128 givenContributionPoints;
        uint96 score;
        uint128 performance;
        // TODO: array of completed tasks
    }
    mapping(address who => mapping(uint32 periodId => Participation participation)) public participations;

    struct PeriodSummary {
        bool inactive;
        uint128 sumCommitmentLevel;
        uint128 sumCreatedContributionPoints;
        uint128 sumActiveContributionPoints;
        uint128 sumGivenContributionPoints;
        uint128 sumRemovedContributionPoints;
    }
    mapping(uint32 periodId => PeriodSummary periodSummary) public periodSummaries;

    uint128 currentSumCommitmentLevel;
    uint128 currentSumCreatedContributionPoints;
    uint128 currentSumActiveContributionPoints;
    uint128 currentSumGivenContributionPoints;
    uint128 currentSumRemovedContributionPoints;

    string[] private _urls;
    mapping(bytes32 => uint256) private _urlHashIndex;

    /// @custom:sdk-legacy-interface-compatibility
    address[] public members;
    /// @custom:sdk-legacy-interface-compatibility
    address[] public admins;

    function initialize(
        address deployer_,
        address autID_,
        address novaRegistry_,
        address pluginRegistry_,
        uint256 market_,
        uint256 commitment_,
        string memory metadataUri_,
        address hubDomainsRegistry_
    ) external initializer {
        _setMaskPosition(deployer_, ADMIN_MASK_POSITION);
        /// @custom:sdk-legacy-interface-compatibility
        admins.push(deployer_);
        _setMarket(market_);
        _setCommitment(commitment_);
        _setMetadataUri(metadataUri_);
        pluginRegistry = pluginRegistry_;
        autID = autID_;
        novaRegistry = novaRegistry_;
        hubDomainsRegistry = hubDomainsRegistry_;
        deployer = deployer_;

        initTimestamp = uint32(block.timestamp);
        initPeriodId = IGlobalParametersAlpha(novaRegistry_).currentPeriodId();
    }

    function setMetadataUri(string memory uri) external {
        _revertForNotAdmin(msg.sender);
        _setMetadataUri(uri);
    }

    function setOnboarding(address onboardingAddress) external {
        _revertForNotAdmin(msg.sender);

        onboarding = onboardingAddress;

        emit OnboardingSet(onboardingAddress);

        // onboardingAddress allowed to be zero
    }

    /// @custom:sdk-legacy-interface-compatibility
    function getUrls() external view returns (string[] memory) {
        return _urls;
    }

    function isUrlListed(string memory url) external view returns (bool) {
        return _urlHashIndex[keccak256(abi.encodePacked(url))] != 0;
    }

    function addUrl(string memory url) external {
        _revertForNotAdmin(msg.sender);

        _addUrl(url);
    }

    function removeUrl(string memory url) external {
        _revertForNotAdmin(msg.sender);

        _removeUrl(url);
    }

    function join(address who, uint256 role, uint8 commitmentLevel) external {
        require(msg.sender == autID, "caller not AutID contract");
        require(canJoin(who, role), "can not join");

        roles[who] = role;
        members.push(who);
        joinedAt[who] = uint32(block.timestamp);

        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        participations[who][currentPeriodId] = Participation({
            commitmentLevel: commitmentLevel,
            givenContributionPoints: 0,
            performance: 0,
            score: 1e18
        });
        currentCommitmentLevels[who] = commitmentLevel;

        _writePeriodSummary(currentPeriodId);
        currentSumCommitmentLevel += uint128(commitmentLevel);

        INovaRegistry(novaRegistry).joinNovaHook(who);

        emit MemberGranted(who, role);
    }

    /// @notice get the commitment level of a member at a particular period id
    function getCommitmentLevel(address who, uint32 periodId) public view returns (uint32) {
        if (periodId < getPeriodIdJoined(who)) revert MemberHasNotYetCommited();

        Participation memory participation = participations[who][periodId];
        if (participation.commitmentLevel != 0) {
            // user has changed their commitmentLevel in a period following `periodId`.  We know this becuase
            // participation.commitmentLevel state is non-zero as it is written following a commitmentLevel change.
            return participation.commitmentLevel;
        } else {
            // User has *not* changed their commitment level: meaning their commitLevel is sync to current
            return currentCommitmentLevels[who];
        }
    }

    /// @notice return the period id the member joined the hub
    function getPeriodIdJoined(address who) public view returns (uint32) {
        uint32 periodIdJoined = TimeLibrary.periodId({
            period0Start: IGlobalParametersAlpha(novaRegistry).period0Start(),
            timestamp: joinedAt[who]
        });
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }

    function changeCommitmentLevel(uint8 newCommitmentLevel) external {
        uint8 oldCommitmentLevel = currentCommitmentLevels[msg.sender];
        if (newCommitmentLevel == oldCommitmentLevel) revert SameCommitmentLevel();

        // TODO: globalParam
        if (newCommitmentLevel == 0 || newCommitmentLevel > 10) revert InvalidCommitmentLevel();

        uint32 periodIdJoined = getPeriodIdJoined(msg.sender);
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();

        // write to storage for all 0 values- as the currentCommitmentLevels is now different
        for (uint32 i = currentPeriodId; i > periodIdJoined - 1; i--) {
            Participation storage participation = participations[msg.sender][i];
            if (participation.commitmentLevel == 0) {
                participation.commitmentLevel = oldCommitmentLevel;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        currentCommitmentLevels[msg.sender] = newCommitmentLevel;

        _writePeriodSummary(currentPeriodId);
        currentSumCommitmentLevel = currentSumCommitmentLevel - oldCommitmentLevel + newCommitmentLevel;

        emit ChangeCommitmentLevel({
            who: msg.sender,
            oldCommitmentLevel: oldCommitmentLevel,
            newCommitmentLevel: newCommitmentLevel
        });
    }

    function writeParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        _writePeriodSummary(currentPeriodId);

        for (uint256 i=0; i<whos.length; i++) {
            _writeParticipation(whos[i], currentPeriodId);
        }
    }

    function writeParticipation(address who) external {
        // update historical periods if necessary
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        _writePeriodSummary(currentPeriodId);

        _writeParticipation(who, currentPeriodId);
    }


    // TODO: visibility?
    function _writeParticipation(address who, uint32 currentPeriodId) public {

        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i=currentPeriodId-1; i>periodIdJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if (participations[who][i].score == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participation score to use as a starting weight
        uint96 previousScore = participations[who][periodToStartWrite - 1].score;

        // Start at the first empty period and write the participation score given the previous score and c
        // TODO: c from globalParameters
        uint96 constraintFactor = 4e17; // 40%
        uint96 penaltyFactor = 4e17; // 40%
        for (uint32 i=periodToStartWrite; i<currentPeriodId; i++) {
            Participation storage participation = participations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitmentLevel: getCommitmentLevel({ who: who, periodId: i }),
                givenContributionPoints: participation.givenContributionPoints,
                periodId: i
            });

            uint96 delta;
            uint96 score;
            // TODO: precision
            if (performance > 1e18) {
                // exceeded expectations: raise participation score
                delta = uint96(performance) - 1e18;
                if (delta > constraintFactor) delta = constraintFactor;
                score =
                    previousScore * (1e18 + delta) / delta;
            } else {
                // underperformed: lower participation score
                delta = 1e18 - uint96(performance);
                if (delta > penaltyFactor) delta = penaltyFactor;
                score = 
                    previousScore * (1e18 - delta) / delta;
            }

            // write to storage
            participation.score = score;
            participation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }

    /// @notice helper to predict performance score for any user
    function calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 givenContributionPoints,
        uint32 periodId
    ) public view returns (uint128) {
       uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
       if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
       return _calcPerformanceInPeriod({
            commitmentLevel: commitmentLevel,
            givenContributionPoints: givenContributionPoints,
            periodId: periodId
       });
    }

    function _calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 givenContributionPoints,
        uint32 periodId
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedContributionPoints({
            commitmentLevel: commitmentLevel,
            periodId: periodId
        });
        uint128 performance = 1e18 * givenContributionPoints / expectedContributionPoints;
        return performance;
    }

    /// @dev returned with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
       _revertForNotMember(who);
       uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
       if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
       return _calcPerformanceInPeriod(who, periodId);
    }

    function _calcPerformanceInPeriod(address who, uint32 periodId) internal view returns (uint128) {
        return _calcPerformanceInPeriod({
            commitmentLevel: getCommitmentLevel(who, periodId),
            givenContributionPoints: participations[who][periodId].givenContributionPoints,
            periodId: periodId
        });
    }

    // fiCL * TCP
    function calcExpectedContributionPoints(uint32 commitmentLevel, uint32 periodId) public view returns (uint128) {
       if (commitmentLevel < 1 || commitmentLevel > 10) revert InvalidCommitmentLevel();
       uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
       if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
       return _calcExpectedContributionPoints(commitmentLevel, periodId); 
    }

    function _calcExpectedContributionPoints(uint32 commitmentLevel, uint32 periodId) internal view returns (uint128) {
        PeriodSummary memory periodSummary = periodSummaries[periodId];
        uint256 numScaled = 1e18 * uint256(commitmentLevel) * periodSummary.sumActiveContributionPoints;
        uint256 expectedContributionPoints = numScaled / periodSummary.sumCommitmentLevel / 1e18;
        return uint128(expectedContributionPoints);
    }

    /// @notice write sums to history when needed
    function writePeriodSummary() public {
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        _writePeriodSummary(currentPeriodId);
    }

    function _writePeriodSummary(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId; // gas
        uint32 lastPeriodId = _currentPeriodId - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriodId; i > initPeriodId_ - 1; i--) {
            PeriodSummary storage periodSummary = periodSummaries[i];
            if (periodSummary.sumCommitmentLevel == 0) {
                writeToHistory = true;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            periodSummaries[i] = PeriodSummary({
                inactive: false,
                sumCommitmentLevel: currentSumCommitmentLevel,
                sumActiveContributionPoints: currentSumActiveContributionPoints,
                sumCreatedContributionPoints: currentSumCreatedContributionPoints,
                sumGivenContributionPoints: currentSumGivenContributionPoints,
                sumRemovedContributionPoints: currentSumRemovedContributionPoints
            });

            // if there's a gap in data- we have inactive periods. Fill up with inactive flag and empty values where possible
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    periodSummaries[j] = PeriodSummary({
                        inactive: true,
                        sumCommitmentLevel: currentSumCommitmentLevel,
                        sumCreatedContributionPoints: 0,
                        sumActiveContributionPoints: currentSumActiveContributionPoints,
                        sumGivenContributionPoints: 0,
                        sumRemovedContributionPoints: 0
                    });
                }
            }

            // Still in writeToHistory conditional: clear out storage where applicable
            delete currentSumCreatedContributionPoints;
            delete currentSumGivenContributionPoints;
            delete currentSumRemovedContributionPoints;
        }
    }

    function currentTaskId() public view returns (uint256) {
        return tasks.length - 1;
    }

    function addTasks(Task[] calldata _tasks) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();

        uint256 length = _tasks.length;
        for (uint256 i = 0; i < length; i++) {
            _addTask(_tasks[i]);
        }
    }

    function addTask(Task calldata _task) public {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();

        _addTask(_task);
    }

    function _addTask(Task memory _task) internal {
        if (_task.contributionPoints == 0 || _task.contributionPoints > 10) revert InvalidTaskContributionPoints();
        if (_task.quantity == 0 || _task.quantity > members.length + 100) revert InvalidTaskQuantity();
        if (!IInteractionRegistry(novaRegistry).isInteractionId(_task.interactionId)) revert InvalidTaskInteractionId();

        uint128 sumTaskContributionPoints = _task.contributionPoints * _task.quantity;
        currentSumActiveContributionPoints += sumTaskContributionPoints;
        currentSumCreatedContributionPoints += sumTaskContributionPoints;

        tasks.push(_task);
        // TODO: events
    }

    function removeTasks(uint256[] memory _taskIds) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();
        for (uint256 i = 0; i < _taskIds.length; i++) {
            _removeTask(_taskIds[i]);
        }
    }

    function removeTask(uint256 _taskId) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();
        _removeTask(_taskId);
    }

    function _removeTask(uint256 _taskId) internal {
        Task memory task = tasks[_taskId];
        if (task.quantity == 0) revert TaskNotActive();
        // NOTE: does not subtract from created tasks

        uint128 sumTaskContributionPoints = task.contributionPoints * task.quantity;
        currentSumActiveContributionPoints -= sumTaskContributionPoints;
        currentSumRemovedContributionPoints += sumTaskContributionPoints;

        delete tasks[_taskId];
        // TODO: event
    }

    function giveTasks(uint256[] memory _taskIds, address[] memory _members) external {
        _revertForNotAdmin(msg.sender);
        uint256 length = _taskIds.length;
        if (length != _members.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _giveTask(_taskIds[i], _members[i]);
        }
    }

    function giveTask(uint256 _taskId, address _member) external {
        _revertForNotAdmin(msg.sender);
        _giveTask(_taskId, _member);
    }

    function _giveTask(uint256 _taskId, address _member) internal {
        Task storage task = tasks[_taskId];
        if (task.quantity == 0) revert TaskNotActive();
        if (joinedAt[_member] == 0) revert MemberDoesNotExist();

        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        Participation storage participation = participations[_member][currentPeriodId];

        uint128 contributionPoints = task.contributionPoints;
        participation.givenContributionPoints += contributionPoints;

        currentSumGivenContributionPoints += contributionPoints;
        currentSumActiveContributionPoints -= contributionPoints;

        task.quantity--;

        // TODO: push task to user balance (as nft)
    }

    /// @custom:sdk-legacy-interface-compatibility
    function addAdmins(address[] calldata admins_) external {
        _revertForNotAdmin(msg.sender);

        for (uint256 i; i != admins_.length; ++i) {
            _addAdmin(admins_[i]);
        }
    }

    function canJoin(address who, uint256 role) public view returns (bool) {
        if (roles[who] != 0) {
            return false;
        }
        if (onboarding != address(0)) {
            if (OnboardingModule(onboarding).isActive()) {
                return OnboardingModule(onboarding).isOnboarded(who, role);
            }
            return false;
        }
        return true;
    }

    function addAdmin(address who) public {
        _revertForNotAdmin(msg.sender);
        _addAdmin(who);
    }

    function setArchetypeAndParameters(uint8[] calldata input) external {
        require(input.length == 6, "Nova: incorrect input length");
        _revertForNotAdmin(msg.sender);

        _revertForInvalidParameter(input[0]);
        archetype = input[0];
        for (uint256 i = 1; i != 6; ++i) {
            _revertForInvalidParameter(input[i]);
            parameterWeight[uint8(i)] = input[i];

            emit ParameterSet(uint8(i), input[i]);
        }

        emit ArchetypeSet(input[0]);
    }

    function removeAdmin(address from) external {
        require(from != address(0), "zero address");
        require(isAdmin(msg.sender), "caller not an admin");
        require(msg.sender != from, "admin can not renounce himself");

        _unsetMaskPosition(from, ADMIN_MASK_POSITION);

        emit AdminRenounced(from);
    }

    function isDeployer(address who) public view returns (bool) {
        return deployer == who;
    }

    function isMember(address who) public view returns (bool) {
        return _checkMaskPosition(who, MEMBER_MASK_POSITION);
    }

    function isAdmin(address who) public view returns (bool) {
        return _checkMaskPosition(who, ADMIN_MASK_POSITION);
    }

    // this function registers a new .hub domain through the Nova contract.
    // It's called when the user submits their custom domain part and metadata URI.
    // It forwards the request to the HubDomainsRegistry.
    function registerDomain(
        string calldata domain_,
        address novaAddress_,
        string calldata metadataUri_
    ) external override {
        _revertForNotDeployer(msg.sender);
        // also revert if not deployer
        IHubDomainsRegistry(hubDomainsRegistry).registerDomain(domain_, novaAddress_, metadataUri_);
    }

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return IHubDomainsRegistry(hubDomainsRegistry).getDomain(domain);
    }

    /// internal

    function _setMarket(uint256 market_) internal {
        _revertForInvalidMarket(market_);

        market = market_;

        emit MarketSet(market_);
    }

    function _setCommitment(uint256 commitment_) internal {
        _revertForInvalidCommitment(commitment_);

        commitment = commitment_;

        emit CommitmentSet(commitment_);
    }

    function _setMetadataUri(string memory metadataUri_) internal {
        _revertForInvalidMetadataUri(metadataUri_);

        metadataUri = metadataUri_;

        emit MetadataUriSet(metadataUri_);
    }

    function _addUrl(string memory url) internal {
        uint256 length = _urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        if (_urlHashIndex[urlHash] == 0) {
            _urlHashIndex[urlHash] = length + 1;
            _urls.push(url);

            emit UrlAdded(url);
        }

        // makes no effect on adding duplicated elements
    }

    function _removeUrl(string memory url) internal {
        uint256 length = _urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        uint256 index = _urlHashIndex[urlHash];

        if (index != 0) {
            if (index != length) {
                string memory lastUrl = _urls[length - 1];
                bytes32 lastUrlHash = keccak256(abi.encodePacked(lastUrl));
                _urls[index - 1] = lastUrl;
                _urlHashIndex[lastUrlHash] = index;
            }
            _urls.pop();
            delete _urlHashIndex[urlHash];

            emit UrlRemoved(url);
        }

        // makes no effect on removing nonexistent elements
    }

    function _addAdmin(address who) private {
        _revertForZeroAddress(who);
        _revertForNotMember(who);

        _setMaskPosition(who, ADMIN_MASK_POSITION);
        /// @custom:sdk-legacy-interface-compatibility
        admins.push(who);

        emit AdminGranted(who);
    }

    function _checkMaskPosition(address who, uint8 maskPosition) internal view returns (bool) {
        return (accountMasks[who] & (1 << maskPosition)) != 0;
    }

    function _setMaskPosition(address to, uint8 maskPosition) internal {
        accountMasks[to] |= (1 << maskPosition);
    }

    function _unsetMaskPosition(address to, uint8 maskPosition) internal {
        accountMasks[to] &= ~(1 << maskPosition);
    }

    function _revertForNotAdmin(address who) internal view {
        if (!isAdmin(who)) {
            revert NotAdmin();
        }
    }

    function _revertForNotDeployer(address who) internal view {
        if (!isDeployer(who)) {
            revert NotDeployer();
        }
    }

    function _revertForNotMember(address who) internal view {
        if (!isMember(who)) {
            revert NotMember();
        }
    }

    uint256[86] private __gap;
}
