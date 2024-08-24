//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HubUpgradeable} from "./HubUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {IMembership} from "../membership/IMembership.sol";
import {OnboardingModule} from "../modules/onboarding/OnboardingModule.sol";
import {HubUtils} from "./HubUtils.sol";
import {IHub} from "./interfaces/IHub.sol";
import {ITaskManager} from "../tasks/ITaskManager.sol";
import {IHubDomainsRegistry} from "./interfaces/IHubDomainsRegistry.sol";

/*
TODO:
- Are market, commitment, metadataUri modifiable?
- Should the deployer be allowed to transfer their deployer role ownership?
- max/min values of parameters
*/


contract Hub is IHub, HubUtils, OwnableUpgradeable, HubUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant REPUTATION_PARAMETER = 2;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    address public onboarding;
    /// @dev these addrs are seen as immutable
    address public hubDomainsRegistry;
    address public globalParameters;
    address public participation;
    address public membership;
    address public taskManager;
    // address public prestige;
    // address public taskRegistry;

    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataUri;

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
        address _globalParameters,
        uint256[] calldata roles_,
        uint256 _market,
        uint256 _commitment,
        string memory _metadataUri
    ) external initializer {
        // ownership
        __Ownable_init(_initialOwner);
        _admins.add(_initialOwner);

        // set addrs
        hubDomainsRegistry = _hubDomainsRegistry;
        globalParameters = _globalParameters;

        // set vars
        _setRoles(roles_);
        _setMarket(_market);
        _setCommitment(_commitment);
        _setMetadataUri(_metadataUri);

        initTimestamp = uint32(block.timestamp);
        period0Start = IGlobalParameters(_globalParameters).period0Start();
        initPeriodId = TimeLibrary.periodId({
            period0Start: period0Start,
            timestamp: uint32(block.timestamp)
        });
    }

    function initialize2(
        address _participation,
        address _membership,
        address _taskManager
        // address _prestige,
        // address _taskRegistry
    ) external reinitializer(2) {
        participation = _participation;
        membership = _membership;
        taskManager = _taskManager;
        // prestige = _prestige;
        // taskRegistry = _taskRegistry;
    }

    // -----------------------------------------------------------
    //                         MUTATIVE
    // -----------------------------------------------------------

    function join(address who, uint256 role, uint8 _commitment) external {
        IMembership(participation).join(who, role, _commitment);
        ITaskManager(taskManager).join(who);
    }

    // -----------------------------------------------------------
    //                     ADMIN-MANAGEMENT
    // -----------------------------------------------------------

    function admins() external view returns (address[] memory) {
        return _admins.values();
    }

    function isAdmin(address who) public view returns (bool) {
        return _admins.contains(who);
    }

    function addAdmins(address[] calldata whos) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        for (uint256 i=0; i<whos.length; i++) {
            _addAdmin(whos[i]);
        }
    }

    function addAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _addAdmin(who);
    }

    function _addAdmin(address who) internal {
        if (!isMember(who)) revert NotMember();
        if (!_admins.add(who)) revert AlreadyAdmin();

        emit AdminGranted(who);
    }

    function removeAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (msg.sender == who) revert AdminCannotRenounceSelf();
        if (!_admins.remove(who)) revert CannotRemoveNonAdmin();

        emit AdminRenounced(who);
    }

    // -----------------------------------------------------------
    //                        VIEWS
    // -----------------------------------------------------------

    function membersCount() external view returns (uint256) {
        return IMembership(participation).membersCount();
    }

    function isMember(address who) public view returns (bool) {
        return IMembership(participation).isMember(who);
    }

    function periodCount() external view returns (uint32) {
        return TimeLibrary.periodId({
            period0Start: period0Start,
            timestamp: uint32(block.timestamp)
        });
    }

    function roles() external view returns (uint256[] memory) {
        return _roles.values();
    }

    function roleOf(address who) external view returns (uint256) {
        return IMembership(participation).currentRole(who);
    }

    function hasRole(address who, uint256 role) external view returns (bool) {
        // TODO
    }

    function hadRole(address who, uint256 role, uint32 periodId) external view returns (bool) {
        // TODO
    }

    function roleAtPeriod(address who, uint32 periodId) public view returns (uint256) {
        // TODO
    }

    function canJoin(address who, uint256 role) public view returns (bool) {
        if (IMembership(participation).currentRole(who) != 0) {
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

    function constraintFactor() external pure returns (uint128) {
        return 4e17; // TODO: setters in here vs. calling globalParameters
    }

    function penaltyFactor() external pure returns (uint128) {
        return 4e17; // TODO
    }

    // -----------------------------------------------------------
    //                        HUB-MANAGEMENT
    // -----------------------------------------------------------

    function registerDomain(
        string calldata domain_,
        address hubAddress_,
        string calldata metadataUri_
    ) external onlyOwner {
        // also revert if not deployer
        IHubDomainsRegistry(hubDomainsRegistry).registerDomain(domain_, hubAddress_, metadataUri_);
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

    /// internal

    function _setRoles(uint256[] memory roles_) internal {
        for (uint256 i=0; i<roles_.length; i++) {
            _roles.add(roles_[i]);
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

    // -----------------------------------------------------------
    //                           VIEWS
    // -----------------------------------------------------------

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return IHubDomainsRegistry(hubDomainsRegistry).getDomain(domain);
    }

    function getUrls() external view returns (string[] memory) {
        return _urls;
    }

    function isUrlListed(string memory url) external view returns (bool) {
        return _urlHashIndex[keccak256(abi.encodePacked(url))] != 0;
    }
}