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

contract Hub is IHub, HubUtils, OwnableUpgradeable, HubUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // TODO: validate these
    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    struct HubStorage {
        // address public onboarding;
        /// @dev these addrs are seen as immutable
        address hubDomainsRegistry;
        address taskRegistry;
        address globalParameters;
        address participation;
        address membership;
        address taskFactory;
        address taskManager;
        uint128 localConstraintFactor;
        uint128 localPenaltyFactor;
        // TODO: these 4 variables to be defined
        uint256 commitment;
        uint256 archetype;
        uint256 market;
        string uri;
        uint32 initTimestamp;
        uint32 initPeriodId;
        uint32 period0Start;
        EnumerableSet.AddressSet admins;
        EnumerableSet.UintSet roles;
        string[] urls;
        mapping(bytes32 => uint256) urlHashIndex;
        mapping(uint256 => uint256) parameterWeight;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.Hub")) - 1));
    bytes32 private constant HubStorageLocation = 0x38d9e3740f833eae7a0ec62c2a0498ec128d42d8d77ddd0d4b2b946b8261d5a4;

    function _getHubStorage() private pure returns (HubStorage storage $) {
        assembly {
            $.slot := HubStorageLocation
        }
    }

    function version() external view returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

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
        HubStorage storage $ = _getHubStorage();

        // ownership
        __Ownable_init(_initialOwner);
        $.admins.add(_initialOwner);

        // set addrs
        $.hubDomainsRegistry = _hubDomainsRegistry;
        $.taskRegistry = _taskRegistry;
        $.globalParameters = _globalParameters;

        // set vars
        _setRoles(roles_);
        _setMarket(_market);
        _setCommitment(_commitment);
        _setUri(_uri);

        $.initTimestamp = uint32(block.timestamp);
        $.period0Start = IGlobalParameters(_globalParameters).period0Start();
        $.initPeriodId = TimeLibrary.periodId({period0Start: $.period0Start, timestamp: uint32(block.timestamp)});
    }

    /// @dev contracts specific to this hub
    function initialize2(
        address _taskFactory,
        address _taskManager,
        address _participation,
        address _membership
    ) external reinitializer(2) {
        HubStorage storage $ = _getHubStorage();

        $.taskFactory = _taskFactory;
        $.taskManager = _taskManager;
        $.participation = _participation;
        $.membership = _membership;
    }

    // -----------------------------------------------------------
    //                         MUTATIVE
    // -----------------------------------------------------------

    /// @inheritdoc IHub
    function join(address who, uint256 role, uint8 _commitment) external {
        IMembership(membership()).join(who, role, _commitment);
    }

    // -----------------------------------------------------------
    //                     ADMIN-MANAGEMENT
    // -----------------------------------------------------------

    /// @inheritdoc IHub
    function admins() external view returns (address[] memory) {
        HubStorage storage $ = _getHubStorage();
        return $.admins.values();
    }

    /// @inheritdoc IHub
    function isAdmin(address who) public view returns (bool) {
        HubStorage storage $ = _getHubStorage();
        return $.admins.contains(who);
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

        HubStorage storage $ = _getHubStorage();
        if (!$.admins.add(who)) revert AlreadyAdmin();

        emit AdminGranted(who, address(this));
    }

    /// @inheritdoc IHub
    function removeAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (msg.sender == who) revert AdminCannotRenounceSelf();

        HubStorage storage $ = _getHubStorage();
        if (!$.admins.remove(who)) revert CannotRemoveNonAdmin();

        emit AdminRenounced(who, address(this));
    }

    // -----------------------------------------------------------
    //                        VIEWS
    // -----------------------------------------------------------

    function hubDomainsRegistry() public view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.hubDomainsRegistry;
    }

    function taskRegistry() external view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.taskRegistry;
    }

    function globalParameters() external view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.globalParameters;
    }

    function participation() external view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.participation;
    }

    function membership() public view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.membership;
    }

    function taskFactory() external view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.taskFactory;
    }

    function taskManager() external view returns (address) {
        HubStorage storage $ = _getHubStorage();
        return $.taskManager;
    }

    function localConstraintFactor() external view returns (uint128) {
        HubStorage storage $ = _getHubStorage();
        return $.localConstraintFactor;
    }

    function localPenaltyFactor() external view returns (uint128) {
        HubStorage storage $ = _getHubStorage();
        return $.localPenaltyFactor;
    }

    function commitment() external view returns (uint256) {
        HubStorage storage $ = _getHubStorage();
        return $.commitment;
    }

    function archetype() external view returns (uint256) {
        HubStorage storage $ = _getHubStorage();
        return $.archetype;
    }

    function market() external view returns (uint256) {
        HubStorage storage $ = _getHubStorage();
        return $.market;
    }

    function uri() external view returns (string memory) {
        HubStorage storage $ = _getHubStorage();
        return $.uri;
    }

    function initTimestamp() external view returns (uint32) {
        HubStorage storage $ = _getHubStorage();
        return $.initTimestamp;
    }

    function initPeriodId() external view returns (uint32) {
        HubStorage storage $ = _getHubStorage();
        return $.initPeriodId;
    }

    function period0Start() external view returns (uint32) {
        HubStorage storage $ = _getHubStorage();
        return $.period0Start;
    }

    /// @inheritdoc IHub
    function membersCount() external view returns (uint256) {
        return IMembership(membership()).membersCount();
    }

    /// @inheritdoc IHub
    function isMember(address who) public view override returns (bool) {
        return IMembership(membership()).isMember(who);
    }

    /// @inheritdoc IHub
    function roles() external view returns (uint256[] memory) {
        HubStorage storage $ = _getHubStorage();
        return $.roles.values();
    }

    /// @inheritdoc IHub
    function currentRole(address who) public view returns (uint256) {
        return IMembership(membership()).currentRole(who);
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
        if (IMembership(membership()).currentRole(who) != 0) {
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
        HubStorage storage $ = _getHubStorage();
        return
            $.localConstraintFactor == 0
                ? IGlobalParameters($.globalParameters).constraintFactor()
                : $.localConstraintFactor;
    }

    /// @inheritdoc IHub
    function penaltyFactor() external view returns (uint128) {
        HubStorage storage $ = _getHubStorage();
        return $.localPenaltyFactor == 0 ? IGlobalParameters($.globalParameters).penaltyFactor() : $.localPenaltyFactor;
    }

    // -----------------------------------------------------------
    //                        HUB-MANAGEMENT
    // -----------------------------------------------------------

    function registerDomain(string calldata _name, string calldata _uri) external onlyOwner {
        // also revert if not deployer
        IHubDomainsRegistry(hubDomainsRegistry()).registerDomain(_name, _uri, owner());
    }

    /// @inheritdoc IHub
    function setConstraintFactor(uint128 newConstraintFactor) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();

        HubStorage storage $ = _getHubStorage();

        if (newConstraintFactor != 0 && (newConstraintFactor < 1e16 || newConstraintFactor > 1e18))
            revert ConstraintFactorOutOfRange();
        uint128 oldConstraintFactor = $.localConstraintFactor;
        $.localConstraintFactor = newConstraintFactor;
        emit SetConstraintFactor(oldConstraintFactor, newConstraintFactor);
    }

    /// @inheritdoc IHub
    function setPenaltyFactor(uint128 newPenaltyFactor) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();

        HubStorage storage $ = _getHubStorage();

        if (newPenaltyFactor != 0 && (newPenaltyFactor < 1e16 || newPenaltyFactor < 1e18))
            revert PenaltyFactorOutOfRange();
        uint128 oldPenaltyFactor = $.localPenaltyFactor;
        $.localPenaltyFactor = newPenaltyFactor;
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

        HubStorage storage $ = _getHubStorage();

        $.archetype = input[0];
        for (uint256 i = 1; i != 6; ++i) {
            _revertForInvalidParameter(input[i]);
            $.parameterWeight[uint8(i)] = input[i];

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
        HubStorage storage $ = _getHubStorage();
        for (uint256 i = 0; i < roles_.length; i++) {
            require($.roles.add(roles_[i]), "Cannot add duplicate roles");
        }
    }

    function _setMarket(uint256 market_) internal {
        _revertForInvalidMarket(market_);

        HubStorage storage $ = _getHubStorage();

        $.market = market_;

        emit MarketSet(market_);
    }

    function _setCommitment(uint256 commitment_) internal {
        _revertForInvalidCommitment(commitment_);

        HubStorage storage $ = _getHubStorage();

        $.commitment = commitment_;

        emit CommitmentSet(commitment_);
    }

    function _setUri(string memory _uri) internal {
        _revertForInvalidMetadataUri(_uri);

        HubStorage storage $ = _getHubStorage();

        $.uri = _uri;

        emit MetadataUriSet(_uri);
    }

    function _addUrl(string memory url) internal {
        HubStorage storage $ = _getHubStorage();

        uint256 length = $.urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        if ($.urlHashIndex[urlHash] == 0) {
            $.urlHashIndex[urlHash] = length + 1;
            $.urls.push(url);

            emit UrlAdded(url);
        }

        // makes no effect on adding duplicated elements
    }

    function _removeUrl(string memory url) internal {
        HubStorage storage $ = _getHubStorage();

        uint256 length = $.urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        uint256 index = $.urlHashIndex[urlHash];

        if (index != 0) {
            if (index != length) {
                string memory lastUrl = $.urls[length - 1];
                bytes32 lastUrlHash = keccak256(abi.encodePacked(lastUrl));
                $.urls[index - 1] = lastUrl;
                $.urlHashIndex[lastUrlHash] = index;
            }
            $.urls.pop();
            delete $.urlHashIndex[urlHash];

            emit UrlRemoved(url);
        }

        // makes no effect on removing nonexistent elements
    }

    // -----------------------------------------------------------
    //                           VIEWS
    // -----------------------------------------------------------

    function getUrls() external view returns (string[] memory) {
        HubStorage storage $ = _getHubStorage();
        return $.urls;
    }

    function isUrlListed(string memory url) external view returns (bool) {
        HubStorage storage $ = _getHubStorage();
        return $.urlHashIndex[keccak256(abi.encodePacked(url))] != 0;
    }
}
