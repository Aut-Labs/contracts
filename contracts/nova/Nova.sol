//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OnboardingModule} from "../modules/onboarding/OnboardingModule.sol";
import {NovaUpgradeable} from "./NovaUpgradeable.sol";
import {NovaUtils} from "./NovaUtils.sol";
import {INova} from "./INova.sol";
import {INovaRegistry} from "./INovaRegistry.sol";
import "../hubContracts/IHubDomainsRegistry.sol";
import {IGlobalParametersAlpha} from "../globalParameters/IGlobalParametersAlpha.sol";
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

    struct Participation {
        uint32 commitmentLevel;
        uint32 givenContributionPoints;
    }
    mapping(
        address who => mapping(
            uint32 periodId =>
                Participation participation
        )
    ) public participations;
    
    mapping(
        uint32 periodId =>
            uint128 sumCommitmentLevel
    ) public historicalSumCommitmentLevel;
    uint128 currentSumCommitmentLevel;

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
        participations[who][currentPeriodId].commitmentLevel = commitmentLevel;
        currentCommitmentLevels[who] = commitmentLevel;

        _writeHistoricalSumCommitmentLevel(currentPeriodId);
        currentSumCommitmentLevel += uint128(commitmentLevel);

        INovaRegistry(novaRegistry).joinNovaHook(who);

        emit MemberGranted(who, role);
    }

    /// @notice get the commitment level of a member at a particular period id
    function getCommitmentLevel(address who, uint32 periodId) external view returns (uint32) {
        if (periodId < getPeriodIdJoined(who)) revert UserHasNotYetCommited();

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
        if (periodIdJoined == 0) revert MemberHasNotJoinedHub();
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
        for (uint32 i=currentPeriodId; i>periodIdJoined - 1; i--) {
            Participation storage participation = participations[msg.sender][i];
            if (participation.commitmentLevel == 0) {
                participation.commitmentLevel = oldCommitmentLevel;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        currentCommitmentLevels[msg.sender] = newCommitmentLevel;
        
        _writeHistoricalSumCommitmentLevel(currentPeriodId);
        currentSumCommitmentLevel = currentSumCommitmentLevel - oldCommitmentLevel + newCommitmentLevel;

        emit ChangeCommitmentLevel({
            who: msg.sender,
            oldCommitmentLevel: oldCommitmentLevel,
            newCommitmentLevel: newCommitmentLevel
        });
    }


    /// @notice write sumCommitmentLevel to history when needed
    function writeHistoricalSumCommitmentLevel() public {
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        _writeHistoricalSumCommitmentLevel(currentPeriodId);
    }

    function _writeHistoricalSumCommitmentLevel(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId; // gas
        for (uint32 i=_currentPeriodId - 1; i>initPeriodId_ - 1; i--) {
            if (historicalSumCommitmentLevel[i] == 0) {
                // write current sum of commitment to storage as there is currently no stored value
                historicalSumCommitmentLevel[i] = currentSumCommitmentLevel;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }
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
    function registerDomain(string calldata domain_, address novaAddress_, string calldata metadataUri_) external override {
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
