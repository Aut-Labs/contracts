//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OnboardingModule} from "../modules/onboarding/OnboardingModule.sol";
import {NovaUpgradeable} from "./NovaUpgradeable.sol";
import {NovaUtils} from "./NovaUtils.sol";
import {INova} from "./INova.sol";
import {INovaRegistry} from "./INovaRegistry.sol";

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
    address public pluginRegistry;
    address public onboarding;

    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataUri;

    mapping(address => uint256) public roles;
    mapping(address => uint256) public joinedAt;
    mapping(address => uint256) public commitmentLevels;
    mapping(uint256 => uint256) public parameterWeight;
    mapping(address => uint256) public accountMasks;

    string[] private _urls;
    mapping(bytes32 => uint256) private _urlHashIndex;

    /// @custom:sdk-legacy-interface-compatibility
    address[] public members;
    /// @custom:sdk-legacy-interface-compatibility
    address[] public admins;

    function initialize(
        address deployer,
        address autID_,
        address novaRegistry_,
        address pluginRegistry_,
        uint256 market_,
        uint256 commitment_,
        string memory metadataUri_
    ) external initializer {
        _setMaskPosition(deployer, ADMIN_MASK_POSITION);
        /// @custom:sdk-legacy-interface-compatibility
        admins.push(deployer);
        _setMarket(market_);
        _setCommitment(commitment_);
        _setMetadataUri(metadataUri_);
        pluginRegistry = pluginRegistry_;
        autID = autID_;
        novaRegistry = novaRegistry_;
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

    function join(address who, uint256 role, uint256 commitmentLevel) external {
        require(msg.sender == autID, "caller not AutID contract");
        require(canJoin(who, role), "can not join");

        roles[who] = role;
        commitmentLevels[who] = commitmentLevel;
        members.push(who);
        joinedAt[who] = block.timestamp;

        INovaRegistry(novaRegistry).joinNovaHook(who);

        emit MemberGranted(who, role);
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

    function isMember(address who) public view returns (bool) {
        return _checkMaskPosition(who, MEMBER_MASK_POSITION);
    }

    function isAdmin(address who) public view returns (bool) {
        return _checkMaskPosition(who, ADMIN_MASK_POSITION);
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

    function _revertForNotMember(address who) internal view {
        if (!isMember(who)) {
            revert NotMember();
        }
    }

    uint256[86] private __gap;
}
