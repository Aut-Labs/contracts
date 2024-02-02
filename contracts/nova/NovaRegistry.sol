// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC2771ContextUpgradeable, ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {IModuleRegistry} from "../modules/registry/IModuleRegistry.sol";
import {INovaRegistry} from "./INovaRegistry.sol";
import {IAllowlist} from "../utils/IAllowlist.sol";
import {Nova} from "../nova/Nova.sol";

/// @title NovaRegistry
contract NovaRegistry is
    INovaRegistry,
    ERC2771ContextUpgradeable,
    OwnableUpgradeable
{
    event NovaCreated(
        address deployer,
        address novaAddress,
        uint256 market,
        uint256 commitment,
        string metadata
    );

    // just for interface compatibility
    // actually there is no need to store it in the contract
    mapping(address => address[]) public novaDeployers;
    mapping(address => address[]) internal _userNovaList;
    mapping(address => mapping(address => uint256)) internal _userNovaListIds;
    mapping(address => bool) public checkNova;
    address[] public novas;

    address public deployerAddress;
    address public autIDAddr;
    address public pluginRegistry;
    UpgradeableBeacon public upgradeableBeacon;
    IAllowlist public allowlist;

    constructor(
        address trustedForwarder_
    ) ERC2771ContextUpgradeable(trustedForwarder_) {}

    function initialize(
        address autIDAddr_,
        address novaLogic,
        address pluginRegistry_
    ) external initializer {
        require(autIDAddr_ != address(0), "NovaRegistry: AutID address zero");
        require(
            novaLogic != address(0),
            "NovaRegistry: Nova logic address zero"
        );
        require(
            pluginRegistry_ != address(0),
            "NovaRegistry: PluginRegistry address zero"
        );

        __Ownable_init(msg.sender);

        deployerAddress = msg.sender;
        autIDAddr = autIDAddr_;
        pluginRegistry = pluginRegistry_;
        upgradeableBeacon = new UpgradeableBeacon(novaLogic, address(this));
        // allowlist =
        // IAllowlist(IModuleRegistry(IPluginRegistry(pluginRegistry_).modulesRegistry()).getAllowListAddress());
    }

    // the only reason for this function is to keep interface compatible with sdk
    // `novas` variable is public anyway
    // the only reason for `novas` variable is that TheGraph is not connected
    function getNovas() public view returns (address[] memory) {
        return novas;
    }

    // the same comment as for `getNovas` method
    function getNovaByDeployer(
        address deployer
    ) public view returns (address[] memory) {
        return novaDeployers[deployer];
    }

    /// @dev depoloy beacon proxy for a new nova
    function deployNova(
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) external returns (address nova) {
        _validateNovaDeploymentParams(market, metadata, commitment);
        _checkAllowlist();

        bytes memory data = abi.encodeWithSelector(
            Nova.initialize.selector,
            _msgSender(),
            autIDAddr,
            address(this),
            pluginRegistry,
            market,
            commitment,
            metadata
        );
        nova = address(new BeaconProxy(address(upgradeableBeacon), data));
        novaDeployers[_msgSender()].push(nova);
        novas.push(nova);
        checkNova[nova] = true;

        emit NovaCreated(_msgSender(), nova, market, commitment, metadata);
    }

    function listUserNovas(
        address user
    ) external view returns (address[] memory) {
        return _userNovaList[user];
    }

    function joinNovaHook(address member) external {
        address nova = msg.sender;
        require(checkNova[nova], "NovaRegistry: sender not a nova");
        uint256 position = _userNovaList[member].length;
        _userNovaList[member].push(nova);
        _userNovaListIds[member][nova] = position;
    }

    /// @dev upgrades nova beacon to the new logic contract
    function upgradeNova(address newLogic) external {
        _checkOwner();
        require(newLogic != address(0), "NovaRegistry: address zero");
        upgradeableBeacon.upgradeTo(newLogic);
    }

    /// @dev sets a new allowlist
    function setAllowlistAddress(address newAllowlist) external onlyOwner {
        // inactive, if set to `address(0)`
        allowlist = IAllowlist(newAllowlist);
    }

    /// @dev transfer beacon ownership (hopefuly to a new and better-implemented registry)
    function tranferBeaconOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "NovaRegistry: address zero");
        upgradeableBeacon.transferOwnership(newOwner);
    }

    function _checkAllowlist() internal view {
        if (
            _msgSender() == deployerAddress ||
            _msgSender() == upgradeableBeacon.owner()
        ) return;
        if (address(allowlist) != address(0)) {
            if (!allowlist.isAllowed(_msgSender())) {
                revert IAllowlist.Unallowed();
            }
            if ((novaDeployers[_msgSender()].length != 0)) {
                revert IAllowlist.AlreadyDeployedANova();
                // `novaDeployers` state is not stored within allowlist,
                //  although the error belongs to allowlist
            }
        }
    }

    function _validateNovaDeploymentParams(
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) internal pure {
        require(market > 0 && market < 4, "NovaRegistry: invalid market value");
        require(bytes(metadata).length != 0, "NovaRegistry: metadata empty");
        require(
            commitment > 0 && commitment < 11,
            "NovaRegistry: invalid commitment value"
        );
    }

    function _msgSender()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (address)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    function _contextSuffixLength()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (uint256)
    {
        return ERC2771ContextUpgradeable._contextSuffixLength();
    }
}
