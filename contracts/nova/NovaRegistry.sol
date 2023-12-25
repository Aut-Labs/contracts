// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {Ownable, Context} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2771Recipient} from "@opengsn/contracts/src/ERC2771Recipient.sol";

import {IModuleRegistry} from "../modules/registry/IModuleRegistry.sol";
import {IPluginRegistry} from "../plugins/registry/IPluginRegistry.sol";
import {INovaRegistry} from "./interfaces/INovaRegistry.sol";
import {IAllowlist} from "../utils/IAllowlist.sol";
import {Nova} from "../nova/Nova.sol";

/// @title NovaRegistry
contract NovaRegistry is INovaRegistry, ERC2771Recipient, Ownable {
    event NovaDeployed(address);

    // just for interface compatibility
    // actually there is no need to store it in the contract
    mapping(address => address[]) novaDeployers;
    mapping(address => bool) checkNova;
    address[] public novas;

    address public immutable autIDAddr;
    address public immutable pluginRegistry;
    UpgradeableBeacon public immutable upgradeableBeacon;
    IAllowlist public allowlist;

    // don't know why it's here but it was in the previous version
    address deployerAddress;

    constructor(address trustedForewarder, address autIDAddr_, address novaLogic, address pluginRegistry_) Ownable() {
        require(trustedForewarder != address(0), "NovaRegistry: trustedForewarder address zero");
        require(autIDAddr_ != address(0), "NovaRegistry: AutID address zero");
        require(novaLogic != address(0), "NovaRegistry: Nova logic address zero");
        require(pluginRegistry_ != address(0), "NovaRegistry: PluginRegistry address zero");

        autIDAddr = autIDAddr_;
        pluginRegistry = pluginRegistry_;
        deployerAddress = msg.sender;
        upgradeableBeacon = new UpgradeableBeacon(novaLogic);
        _setTrustedForwarder(trustedForewarder);
        allowlist =
            IAllowlist(IModuleRegistry(IPluginRegistry(pluginRegistry_).modulesRegistry()).getAllowListAddress());
    }

    // the only reason for this function is to keep interface compatible with sdk
    // `novas` variable is public anyway
    // the only reason for `novas` variable is that TheGraph is not connected
    function getNovas() public view returns (address[] memory) {
        return novas;
    }

    // the same comment as for `getNovas` method
    function getNovaByDeployer(address deployer) public view returns (address[] memory) {
        return novaDeployers[deployer];
    }

    /// @dev depoloy beacon proxy for a new nova
    function deployNova(uint256 market, string memory metadata, uint256 commitment) external returns (address nova) {
        _validateNovaDeploymentParams(market, metadata, commitment);
        _checkAllowlist();

        bytes memory data = abi.encodeWithSelector(
            Nova.initialize.selector, _msgSender(), autIDAddr, market, metadata, commitment, pluginRegistry
        );
        nova = address(new BeaconProxy(address(upgradeableBeacon), data));
        novaDeployers[_msgSender()].push(nova);
        novas.push(nova);
        checkNova[nova] = true;

        emit NovaDeployed(nova);
    }

    /// @dev upgrades nova beacon to the new logic contract
    function upgradeNova(address newLogic) external onlyOwner {
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
        if (_msgSender() == deployerAddress || _msgSender() == upgradeableBeacon.owner()) return;
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

    // no idea why `autIDAddr` and `pluginRegistrty` are passed
    // i'm leavin it as it is in order to maintain compativility with sdk
    function _validateNovaDeploymentParams(uint256 market, string memory metadata, uint256 commitment) internal pure {
        require(market > 0 && market < 4, "NovaRegistry: invalid market value");
        require(bytes(metadata).length != 0, "NovaRegistry: metadata empty");
        require(commitment > 0 && commitment < 11, "NovaRegistry: invalid commitment value");
    }

    function _msgSender() internal view override(ERC2771Recipient, Context) returns (address) {
        return ERC2771Recipient._msgSender();
    }

    function _msgData() internal view override(ERC2771Recipient, Context) returns (bytes calldata) {
        return ERC2771Recipient._msgData();
    }
}
