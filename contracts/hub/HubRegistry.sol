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

import {IHubRegistry} from "./interfaces/IHubRegistry.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {ITaskManager} from "../tasks/interfaces/ITaskManager.sol";

import {IHub} from "./interfaces/IHub.sol";
import {IHubModule} from "./interfaces/IHubModule.sol";

/// @title HubRegistry
contract HubRegistry is IHubRegistry, ERC2771ContextUpgradeable, OwnableUpgradeable {
    event HubCreated(address deployer, address hubAddress, uint256 market, uint256 commitment, string metadata);

    mapping(address => address[]) public hubsDeployed;
    mapping(address => address[]) public userHubs;
    mapping(address => bool) public isHub;
    address[] public hubs;

    struct HubContracts {
        address taskFactory;
        address taskManager;
        address membership;
        address participation;
    }
    mapping(address => HubContracts) public hubContracts;

    address public deployerAddress;
    address public autId;
    address public hubDomainsRegistry;
    address public taskRegistry;
    address public globalParameters;
    address public initialContributionManager;
    address public membershipImplementation;
    address public participationImplementation;
    address public taskFactoryImplementation;
    address public taskManagerImplementation;
    UpgradeableBeacon public upgradeableBeacon;

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {}

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

        deployerAddress = msg.sender;
        autId = autId_;
        hubDomainsRegistry = hubDomainsRegistry_;
        taskRegistry = taskRegistry_;
        globalParameters = globalParameters_;
        upgradeableBeacon = new UpgradeableBeacon(hubLogic, address(this));

        setInitialContributionManager(_initialContributionManager);

        membershipImplementation = _membershipImplementation;
        participationImplementation = _participationImplementation;
        taskFactoryImplementation = _taskFactoryImplementation;
        taskManagerImplementation = _taskManagerImplementation;
    }

    /// @inheritdoc IHubRegistry
    function setInitialContributionManager(address _initialContributionManager) public onlyOwner {
        initialContributionManager = _initialContributionManager;
    }

    /// @inheritdoc IHubRegistry
    function currentPeriodId() public view returns (uint32) {
        return IGlobalParameters(globalParameters).currentPeriodId();
    }

    /// @inheritdoc IHubRegistry
    function period0Start() public view returns (uint32) {
        return IGlobalParameters(globalParameters).period0Start();
    }

    /// @inheritdoc IHubRegistry
    function getHubs() public view returns (address[] memory) {
        return hubs;
    }

    /// @inheritdoc IHubRegistry
    function getHubsDeployed(address who) public view returns (address[] memory) {
        return hubsDeployed[who];
    }

    /// @inheritdoc IHubRegistry
    function getUserHubs(address who) external view returns (address[] memory) {
        return userHubs[who];
    }

    /// @inheritdoc IHubRegistry
    function deployHub(
        uint256[] calldata roles,
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) external returns (address hub) {
        _validateHubDeploymentParams(market, metadata, commitment);
        // _checkAllowlist(); // TODO: how should allowlist be designed?

        // deploy hub w/ beacon
        bytes memory data = abi.encodeCall(
            IHub.initialize,
            (_msgSender(), hubDomainsRegistry, taskRegistry, globalParameters, roles, market, commitment, metadata)
        );
        hub = address(new BeaconProxy(address(upgradeableBeacon), data));

        // data for all hub-owned modules
        data = abi.encodeCall(IHubModule.initialize, (hub, period0Start(), currentPeriodId()));

        // deploy taskFactory
        address taskFactory = address(new AutProxy(taskFactoryImplementation, _msgSender(), data));

        // deploy taskManager
        address taskManager = address(new AutProxy(taskManagerImplementation, _msgSender(), data));

        // deploy membership
        address membership = address(new AutProxy(membershipImplementation, _msgSender(), data));

        // deploy participation
        address participation = address(new AutProxy(participationImplementation, _msgSender(), data));

        // Finish initializing the hub
        IHub(hub).initialize2({
            _taskFactory: taskFactory,
            _taskManager: taskManager,
            _participation: participation,
            _membership: membership
        });

        // Set the initial contribution manager as stored in this contract
        ITaskManager(taskManager).initialize2(initialContributionManager);

        hubsDeployed[_msgSender()].push(hub);
        hubs.push(hub);
        isHub[hub] = true;
        hubContracts[hub] = HubContracts({
            taskFactory: taskFactory,
            taskManager: taskManager,
            membership: membership,
            participation: participation
        });

        emit HubCreated(_msgSender(), hub, market, commitment, metadata);
    }

    /// @inheritdoc IHubRegistry
    function join(address hub, address who, uint256 role, uint8 commitment) external {
        require(msg.sender == autId, "HubRegistry: sender not autId");
        require(isHub[hub], "HubRegistry: hub does not exist");

        IHub(hub).join({who: who, role: role, _commitment: commitment});

        userHubs[who].push(hub);
    }

    /// @dev upgrades hub beacon to the new logic contract
    function upgradeHub(address newLogic) external {
        _checkOwner();
        require(newLogic != address(0), "HubRegistry: address zero");
        upgradeableBeacon.upgradeTo(newLogic);
    }

    /// @dev transfer beacon ownership
    function transferBeaconOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "HubRegistry: address zero");
        upgradeableBeacon.transferOwnership(newOwner);
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
