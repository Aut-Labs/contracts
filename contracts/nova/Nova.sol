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

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// todo: admin retro onboarding
contract Nova is INova, NovaUtils, NovaUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;

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
    address public membership;
    address public deployer;

    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataUri;

    uint32 public initTimestamp;
    uint32 public initPeriodId;

    mapping(uint256 => uint256) public parameterWeight;

    string[] private _urls;
    mapping(bytes32 => uint256) private _urlHashIndex;

    EnumerableSet.AddressSet internal _admins;

    function initialize(
        address deployer_,
        address autID_,
        address novaRegistry_,
        address pluginRegistry_,
        uint256 market_,
        uint256 commitment_,
        string memory metadataUri_,
        address hubDomainsRegistry_,
        address membership_
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
        membership = membership_;
        deployer = deployer_;

        initTimestamp = uint32(block.timestamp);
        initPeriodId = IGlobalParametersAlpha(novaRegistry_).currentPeriodId();
    }

    // -----------------------------------------------------------
    //                     ADMIN-MANAGEMENT
    // -----------------------------------------------------------

    function admins() external view return (address[] memory) {
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

    function isMember(address who) public view returns (bool) {
        return IMembership(membership).isMember(who);
    }

    // -----------------------------------------------------------

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

        uint256 length = _urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        if (_urlHashIndex[urlHash] == 0) {
            _urlHashIndex[urlHash] = length + 1;
            _urls.push(url);

            emit UrlAdded(url);
        }

        // makes no effect on adding duplicated elements
    }

    function removeUrl(string memory url) external {
        _revertForNotAdmin(msg.sender);

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

    function join(address who, uint256 role, uint8 commitmentLevel) external {
        require(msg.sender == autID, "caller not AutID contract");
        require(canJoin(who, role), "can not join");

        IMembership(membership).join(who, role, commitmentLevel);
        INovaRegistry(novaRegistry).joinNovaHook(who);

        emit MemberGranted(who, role);
    }

    function canJoin(address who, uint256 role) public view returns (bool) {
        if (IMembership(membership).roles(who) != 0) {
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

    function isDeployer(address who) public view returns (bool) {
        return deployer == who;
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

    }

    function _removeUrl(string memory url) internal {

    }

    function _revertForNotAdmin(address who) internal view {
        if (!IMembership(membership).isAdmin(who)) {
            revert NotAdmin();
        }
    }

    function _revertForNotDeployer(address who) internal view {
        if (!isDeployer(who)) {
            revert NotDeployer();
        }
    }


    uint256[86] private __gap;
}
