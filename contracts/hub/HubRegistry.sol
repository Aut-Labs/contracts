// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AutProxy} from "../proxy/AutProxy.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    ERC2771ContextUpgradeable,
    ContextUpgradeable
} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {IHubRegistry, HubContracts} from "./interfaces/IHubRegistry.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {ITaskManager} from "../tasks/interfaces/ITaskManager.sol";

import {IHub} from "./interfaces/IHub.sol";
import {IHubModule} from "./interfaces/IHubModule.sol";

/// @title HubRegistry
contract HubRegistry is IHubRegistry, ERC2771ContextUpgradeable, OwnableUpgradeable {
    struct HubRegistryStorage {
        address autId;
        address hubDomainsRegistry;
        address taskRegistry;
        address globalParameters;
        address initialContributionManager;
        address membershipImplementation;
        address participationImplementation;
        address taskFactoryImplementation;
        address taskManagerImplementation;
        UpgradeableBeacon upgradeableBeacon;
        mapping(address => address[]) hubsDeployed;
        mapping(address => address[]) userHubs;
        mapping(address => bool) isHub;
        address[] hubs;
        mapping(address => HubContracts) hubContracts;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.HubRegistry")) - 1))
    bytes32 private constant HubRegistryStorageLocation =
        0x727f424ed6c063e8eb22b4a2326d196d9bec1426b5bc51f44ac7675f301c5064;

    function _getHubRegistryStorage() private pure returns (HubRegistryStorage storage $) {
        assembly {
            $.slot := HubRegistryStorageLocation
        }
    }

    function version() external pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {
        _disableInitializers();
    }

    /// @inheritdoc IHubRegistry
    function initialize(
        address autId_,
        address hubLogic,
        address hubDomainsRegistry_,
        address taskRegistry_,
        address globalParameters_,
        address _initialContributionManager,
        address _membershipImplementation,
        address _participationImplementation,
        address _taskFactoryImplementation,
        address _taskManagerImplementation
    ) external initializer {
        require(autId_ != address(0), "HubRegistry: AutID address zero");
        require(hubLogic != address(0), "HubRegistry: Hub logic address zero");
        __Ownable_init(msg.sender);

        HubRegistryStorage storage $ = _getHubRegistryStorage();

        $.autId = autId_;
        $.hubDomainsRegistry = hubDomainsRegistry_;
        $.taskRegistry = taskRegistry_;
        $.globalParameters = globalParameters_;
        $.upgradeableBeacon = new UpgradeableBeacon(hubLogic, address(this));

        setInitialContributionManager(_initialContributionManager);

        $.membershipImplementation = _membershipImplementation;
        $.participationImplementation = _participationImplementation;
        $.taskFactoryImplementation = _taskFactoryImplementation;
        $.taskManagerImplementation = _taskManagerImplementation;
    }

    /// @inheritdoc IHubRegistry
    function setInitialContributionManager(address _initialContributionManager) public onlyOwner {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        $.initialContributionManager = _initialContributionManager;
    }

    /// @inheritdoc IHubRegistry
    function deployHub(
        uint256[] calldata roles,
        uint256 market,
        string memory metadata,
        uint256 commitmentLevel
    ) external returns (address hub) {
        _validateHubDeploymentParams(market, metadata, commitmentLevel);

        HubRegistryStorage storage $ = _getHubRegistryStorage();

        // deploy hub w/ beacon
        bytes memory data = abi.encodeCall(
            IHub.initialize,
            (
                _msgSender(),
                $.hubDomainsRegistry,
                $.taskRegistry,
                $.globalParameters,
                roles,
                market,
                commitmentLevel,
                metadata
            )
        );
        hub = address(new BeaconProxy(address($.upgradeableBeacon), data));

        // data for all hub-owned modules
        data = abi.encodeCall(IHubModule.initialize, (hub));

        // deploy taskFactory
        address taskFactory = address(new AutProxy($.taskFactoryImplementation, _msgSender(), data));

        // deploy taskManager
        address taskManager = address(new AutProxy($.taskManagerImplementation, _msgSender(), data));

        // deploy membership
        address membership = address(new AutProxy($.membershipImplementation, _msgSender(), data));

        // deploy participation
        address participation = address(new AutProxy($.participationImplementation, _msgSender(), data));

        // Finish initializing the hub
        IHub(hub).initialize2({
            _taskFactory: taskFactory,
            _taskManager: taskManager,
            _participation: participation,
            _membership: membership
        });

        // Set the initial contribution manager as stored in this contract
        ITaskManager(taskManager).initialize2($.initialContributionManager);

        $.hubsDeployed[_msgSender()].push(hub);
        $.hubs.push(hub);
        $.isHub[hub] = true;
        $.hubContracts[hub] = HubContracts({
            taskFactory: taskFactory,
            taskManager: taskManager,
            membership: membership,
            participation: participation
        });

        emit HubCreated(_msgSender(), hub, market, commitmentLevel, metadata);
    }

    /// @inheritdoc IHubRegistry
    function join(address hub, address who, uint256 role, uint8 commitmentLevel) external {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        require(msg.sender == $.autId, "HubRegistry: sender not autId");
        require($.isHub[hub], "HubRegistry: hub does not exist");

        IHub(hub).join({who: who, role: role, _commitment: commitmentLevel});

        $.userHubs[who].push(hub);
    }

    /// @dev upgrades hub beacon to the new logic contract
    function upgradeHub(address newLogic) external {
        _checkOwner();
        require(newLogic != address(0), "HubRegistry: address zero");

        HubRegistryStorage storage $ = _getHubRegistryStorage();
        $.upgradeableBeacon.upgradeTo(newLogic);
    }

    /// @dev transfer beacon ownership
    function transferBeaconOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "HubRegistry: address zero");

        HubRegistryStorage storage $ = _getHubRegistryStorage();
        $.upgradeableBeacon.transferOwnership(newOwner);
    }

    function _validateHubDeploymentParams(
        uint256 market,
        string memory metadata,
        uint256 commitmentLevel
    ) internal pure {
        require(market > 0 && market < 6, "HubRegistry: invalid market value");
        require(bytes(metadata).length != 0, "HubRegistry: metadata empty");
        require(commitmentLevel > 0 && commitmentLevel < 11, "HubRegistry: invalid commitmentLevel value");
    }

    function autId() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.autId;
    }

    function hubDomainsRegistry() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.hubDomainsRegistry;
    }

    function taskRegistry() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.taskRegistry;
    }

    function globalParameters() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.globalParameters;
    }

    function initialContributionManager() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.initialContributionManager;
    }

    function membershipImplementation() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.membershipImplementation;
    }

    function participationImplementation() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.participationImplementation;
    }

    function taskFactoryImplementation() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.taskFactoryImplementation;
    }

    function taskManagerImplementation() external view returns (address) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.taskManagerImplementation;
    }

    function upgradeableBeacon() external view returns (UpgradeableBeacon) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.upgradeableBeacon;
    }

    function hubsDeployed(address who) external view returns (address[] memory) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.hubsDeployed[who];
    }

    function userHubs(address who) external view returns (address[] memory) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.userHubs[who];
    }

    function isHub(address hub) external view returns (bool) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.isHub[hub];
    }

    function hubs() external view returns (address[] memory) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.hubs;
    }

    function hubContracts(address hub) external view returns (HubContracts memory) {
        HubRegistryStorage storage $ = _getHubRegistryStorage();
        return $.hubContracts[hub];
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
