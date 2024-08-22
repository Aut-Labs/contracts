// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    ERC2771ContextUpgradeable,
    ContextUpgradeable
} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {IModuleRegistry} from "../modules/registry/IModuleRegistry.sol";
import {IHubRegistry} from "./IHubRegistry.sol";
import {IInteractionRegistry} from "../interactions/InteractionRegistry.sol";
import {IGlobalParametersAlpha} from "../globalParameters/IGlobalParametersAlpha.sol";
import {IAllowlist} from "../utils/IAllowlist.sol";

import {IHub, Hub} from "../hub/Hub.sol";
import {ParticipationScore} from "../participation/ParticipationScore.sol";

/// @title HubRegistry
contract HubRegistry is IHubRegistry, ERC2771ContextUpgradeable, OwnableUpgradeable {
    event HubCreated(address deployer, address hubAddress, uint256 market, uint256 commitment, string metadata);
    event AllowlistSet(address allowlist);

    // just for interface compatibility
    // actually there is no need to store it in the contract
    mapping(address => address[]) public hubDeployers;
    mapping(address => address[]) internal _userHubList;
    mapping(address => mapping(address => uint256)) internal _userHubListIds;
    mapping(address => bool) public checkHub;
    address[] public hubs;

    address public deployerAddress;
    address public autIDAddr;
    address public pluginRegistry;
    address public hubDomainsRegistry;
    address public interactionRegistry;
    address public globalParameters;
    UpgradeableBeacon public upgradeableBeacon;
    IAllowlist public allowlist;

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {}

    function initialize(
        address autIDAddr_,
        address hubLogic,
        address pluginRegistry_,
        address hubDomainsRegistry_,
        address interactionRegistry_,
        address globalParameters_
    ) external initializer {
        require(autIDAddr_ != address(0), "HubRegistry: AutID address zero");
        require(hubLogic != address(0), "HubRegistry: Hub logic address zero");
        require(pluginRegistry_ != address(0), "HubRegistry: PluginRegistry address zero");
        __Ownable_init(msg.sender);

        deployerAddress = msg.sender;
        autIDAddr = autIDAddr_;
        pluginRegistry = pluginRegistry_;
        hubDomainsRegistry = hubDomainsRegistry_;
        interactionRegistry = interactionRegistry_;
        globalParameters = globalParameters_;
        upgradeableBeacon = new UpgradeableBeacon(hubLogic, address(this));
        // allowlist =
        // IAllowlist(IModuleRegistry(IPluginRegistry(pluginRegistry_).modulesRegistry()).getAllowListAddress());
    }

    function currentPeriodId() public view returns (uint32) {
        return IGlobalParametersAlpha(globalParameters).currentPeriodId();
    }

    function period0Start() public view returns (uint32) {
        return IGlobalParametersAlpha(globalParameters).period0Start();
    }

    function isInteractionId(bytes32 interactionId) external view returns (bool) {
        return IInteractionRegistry(interactionRegistry).isInteractionId(interactionId);
    }

    // the only reason for this function is to keep interface compatible with sdk
    // `hubs` variable is public anyway
    // the only reason for `hubs` variable is that TheGraph is not connected
    function getHubs() public view returns (address[] memory) {
        return hubs;
    }

    // the same comment as for `getHubs` method
    function getHubByDeployer(address deployer) public view returns (address[] memory) {
        return hubDeployers[deployer];
    }

    /// @dev depoloy beacon proxy for a new hub
    function deployHub(
        uint256[] calldata roles,
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) external returns (address hub) {
        _validateHubDeploymentParams(market, metadata, commitment);
        // _checkAllowlist(); // TODO: how should allowlist be designed?

        ParticipationScore participationScore = new ParticipationScore();
        bytes memory data = abi.encodeWithSelector(
            Hub.initialize.selector,
            _msgSender(),
            // humDomainsRegistry,
            globalParameters,
            participation,
            // prestige,
            taskRegistry,
            roles,
            market,
            commitment,
            metadata
        );
        hub = address(new BeaconProxy(address(upgradeableBeacon), data));
        participationScore.initialize({
            _globalParameters: globalParameters,
            _hub: hub,
            _autId: autId,
            _period0Start: period0Start(),
            _initPeriodId: currentPeriodId()
        });
        hubDeployers[_msgSender()].push(hub);
        hubs.push(hub);
        checkHub[hub] = true;

        emit HubCreated(_msgSender(), hub, market, commitment, metadata);
    }

    function listUserHubs(address user) external view returns (address[] memory) {
        return _userHubList[user];
    }

    function join(address hub, address member, uint256 role, uint8 commitment) external {
        require(checkHub[hub], "HubRegistry: sender not a hub");

        IHub(hub).join({who: member, role: role, commitmentLevel: commitment});

        uint256 position = _userHubList[member].length;
        _userHubList[member].push(hub);
        _userHubListIds[member][hub] = position;
    }

    /// @dev upgrades hub beacon to the new logic contract
    function upgradeHub(address newLogic) external {
        _checkOwner();
        require(newLogic != address(0), "HubRegistry: address zero");
        upgradeableBeacon.upgradeTo(newLogic);
    }

    /// @dev sets a new allowlist
    function setAllowlistAddress(address newAllowlist) external onlyOwner {
        // inactive, if set to `address(0)`
        allowlist = IAllowlist(newAllowlist);

        emit AllowlistSet(newAllowlist);
    }

    /// @dev transfer beacon ownership (hopefuly to a new and better-implemented registry)
    function tranferBeaconOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "HubRegistry: address zero");
        upgradeableBeacon.transferOwnership(newOwner);
    }

    function _checkAllowlist() internal view {
        if (_msgSender() == deployerAddress || _msgSender() == upgradeableBeacon.owner()) return;
        if (address(allowlist) != address(0)) {
            // if (!allowlist.isAllowed(_msgSender())) {
            //     revert IAllowlist.Unallowed();
            // }
            if ((hubDeployers[_msgSender()].length != 0)) {
                revert IAllowlist.AlreadyDeployedAHub();
                // `hubDeployers` state is not stored within allowlist,
                //  although the error belongs to allowlist
            }
        }
    }

    function _validateHubDeploymentParams(uint256 market, string memory metadata, uint256 commitment) internal pure {
        require(market > 0 && market < 6, "HubRegistry: invalid market value");
        require(bytes(metadata).length != 0, "HubRegistry: metadata empty");
        require(commitment > 0 && commitment < 11, "HubRegistry: invalid commitment value");
    }

    function _msgSender() internal view override(ERC2771ContextUpgradeable, ContextUpgradeable) returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view override(ERC2771ContextUpgradeable, ContextUpgradeable) returns (bytes calldata) {
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
