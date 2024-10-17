//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HubUpgradeable} from "./HubUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {IMembership} from "../membership/IMembership.sol";
// import {OnboardingModule} from "../modules/onboarding/OnboardingModule.sol";
import {HubUtils} from "./HubUtils.sol";
import {IHub} from "./interfaces/IHub.sol";
import {ITaskManager} from "../tasks/interfaces/ITaskManager.sol";
import {Domain, IHubDomainsRegistry} from "./interfaces/IHubDomainsRegistry.sol";

/*
TODO:
- Are market, commitment, uri modifiable?
- Should the deployer be allowed to transfer their deployer role ownership?
- max/min values of parameters
*/

contract Hub is IHub, HubUtils, OwnableUpgradeable, HubUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // TODO: validate these
    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    address public onboarding;
    /// @dev these addrs are seen as immutable
    address public hubDomainsRegistry;
    address public taskRegistry;
    address public globalParameters;
    address public participation;
    address public membership;
    address public taskFactory;
    address public taskManager;

    uint128 public localConstraintFactor;
    uint128 public localPenaltyFactor;

    // TODO: these 4 variables to be defined
    uint256 public commitment;
    uint256 public archetype;
    uint256 public market;
    string public uri;

    uint32 public initTimestamp;
    uint32 public initPeriodId;
    uint32 public period0Start;

    EnumerableSet.AddressSet internal _admins;
    EnumerableSet.UintSet internal _roles;

    string[] private _urls;
    mapping(bytes32 => uint256) private _urlHashIndex;

    mapping(uint256 => uint256) public parameterWeight;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _hubDomainsRegistry,
        address _taskRegistry,
        address _globalParameters,
        uint256[] calldata roles_,
        uint256 _market,
        uint256 _commitment,
        string memory _uri
    ) external initializer {
        // ownership
        __Ownable_init(_initialOwner);
        _admins.add(_initialOwner);

        // set addrs
        hubDomainsRegistry = _hubDomainsRegistry;
        taskRegistry = _taskRegistry;
        globalParameters = _globalParameters;

        // set vars
        _setRoles(roles_);
        _setMarket(_market);
        _setCommitment(_commitment);
        _setUri(_uri);

        initTimestamp = uint32(block.timestamp);
        period0Start = IGlobalParameters(_globalParameters).period0Start();
        initPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
    }

    /// @dev contracts specific to this hub
    function initialize2(
        address _taskFactory,
        address _taskManager,
        address _participation,
        address _membership
    ) external reinitializer(2) {
        taskFactory = _taskFactory;
        taskManager = _taskManager;
        participation = _participation;
        membership = _membership;
    }

    // -----------------------------------------------------------
    //                         MUTATIVE
    // -----------------------------------------------------------

    /// @inheritdoc IHub
    function join(address who, uint256 role, uint8 _commitment) external {
        IMembership(membership).join(who, role, _commitment);
    }

    // -----------------------------------------------------------
    //                     ADMIN-MANAGEMENT
    // -----------------------------------------------------------

    /// @inheritdoc IHub
    function admins() external view returns (address[] memory) {
        return _admins.values();
    }

    /// @inheritdoc IHub
    function isAdmin(address who) public view returns (bool) {
        return _admins.contains(who);
    }

    /// @inheritdoc IHub
    function addAdmins(address[] calldata whos) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        for (uint256 i = 0; i < whos.length; i++) {
            _addAdmin(whos[i]);
        }
    }

    /// @inheritdoc IHub
    function addAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _addAdmin(who);
    }

    function _addAdmin(address who) internal {
        if (!isMember(who)) revert NotMember();
        if (!_admins.add(who)) revert AlreadyAdmin();

        emit AdminGranted(who, address(this));
    }

    /// @inheritdoc IHub
    function removeAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (msg.sender == who) revert AdminCannotRenounceSelf();
        if (!_admins.remove(who)) revert CannotRemoveNonAdmin();

        emit AdminRenounced(who, address(this));
    }

    // -----------------------------------------------------------
    //                        VIEWS
    // -----------------------------------------------------------

    /// @inheritdoc IHub
    function membersCount() external view returns (uint256) {
        return IMembership(membership).membersCount();
    }

    /// @inheritdoc IHub
    function isMember(address who) public view override returns (bool) {
        return IMembership(membership).isMember(who);
    }

    /// @inheritdoc IHub
    function roles() external view returns (uint256[] memory) {
        return _roles.values();
    }

    /// @inheritdoc IHub
    function currentRole(address who) public view returns (uint256) {
        return IMembership(membership).currentRole(who);
    }

    /// @inheritdoc IHub
    function hasRole(address who, uint256 role) external view returns (bool) {
        return currentRole(who) == role;
    }

    function hadRole(address who, uint256 role, uint32 periodId) external view returns (bool) {
        // TODO
    }

    function roleAtPeriod(address who, uint32 periodId) public view returns (uint256) {
        // TODO
    }

    /// @inheritdoc IHub
    function canJoin(address who, uint256 role) public view returns (bool) {
        if (IMembership(membership).currentRole(who) != 0) {
            return false;
        }

        // TODO: onboarding module
        // if (onboarding != address(0)) {
        //     if (OnboardingModule(onboarding).isActive()) {
        //         return OnboardingModule(onboarding).isOnboarded(who, role);
        //     }
        //     return false;
        // }
        return true;
    }

    /// @inheritdoc IHub
    function constraintFactor() external view returns (uint128) {
        return
            localConstraintFactor == 0 ? IGlobalParameters(globalParameters).constraintFactor() : localConstraintFactor;
    }

    /// @inheritdoc IHub
    function penaltyFactor() external view returns (uint128) {
        return localPenaltyFactor == 0 ? IGlobalParameters(globalParameters).penaltyFactor() : localPenaltyFactor;
    }

    // -----------------------------------------------------------
    //                        HUB-MANAGEMENT
    // -----------------------------------------------------------

    function registerDomain(string calldata _name, string calldata _uri) external onlyOwner {
        // also revert if not deployer
        IHubDomainsRegistry(hubDomainsRegistry).registerDomain(_name, _uri);
    }

    /// @inheritdoc IHub
    function setConstraintFactor(uint128 newConstraintFactor) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (newConstraintFactor != 0 && (newConstraintFactor < 1e16 || newConstraintFactor > 1e18))
            revert ConstraintFactorOutOfRange();
        uint128 oldConstraintFactor = localConstraintFactor;
        localConstraintFactor = newConstraintFactor;
        emit SetConstraintFactor(oldConstraintFactor, newConstraintFactor);
    }

    /// @inheritdoc IHub
    function setPenaltyFactor(uint128 newPenaltyFactor) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (newPenaltyFactor != 0 && (newPenaltyFactor < 1e16 || newPenaltyFactor < 1e18))
            revert PenaltyFactorOutOfRange();
        uint128 oldPenaltyFactor = localPenaltyFactor;
        localPenaltyFactor = newPenaltyFactor;
        emit SetPenaltyFactor(oldPenaltyFactor, newPenaltyFactor);
    }

    function addUrl(string memory url) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _addUrl(url);
    }

    function removeUrl(string memory url) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _removeUrl(url);
    }

    function setArchetypeAndParameters(uint8[] calldata input) external {
        require(input.length == 6, "Hub: incorrect input length");
        if (!isAdmin(msg.sender)) revert NotAdmin();

        _revertForInvalidParameter(input[0]);
        archetype = input[0];
        for (uint256 i = 1; i != 6; ++i) {
            _revertForInvalidParameter(input[i]);
            parameterWeight[uint8(i)] = input[i];

            emit ParameterSet(uint8(i), input[i]);
        }

        emit ArchetypeSet(input[0]);
    }

    function setUri(string memory _uri) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _setUri(_uri);
    }

    /// internal

    function _setRoles(uint256[] memory roles_) internal {
        for (uint256 i = 0; i < roles_.length; i++) {
            require(_roles.add(roles_[i]), "Cannot add duplicate roles");
        }
    }

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

    function _setUri(string memory _uri) internal {
        _revertForInvalidMetadataUri(_uri);

        uri = _uri;

        emit MetadataUriSet(_uri);
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

    // -----------------------------------------------------------
    //                           VIEWS
    // -----------------------------------------------------------

    function getDomain() external view returns (Domain memory) {
        return IHubDomainsRegistry(hubDomainsRegistry).getDomain(address(this));
    }

    function getUrls() external view returns (string[] memory) {
        return _urls;
    }

    function isUrlListed(string memory url) external view returns (bool) {
        return _urlHashIndex[keccak256(abi.encodePacked(url))] != 0;
    }
}
