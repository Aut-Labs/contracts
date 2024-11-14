//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct HubContracts {
    address taskFactory;
    address taskManager;
    address membership;
    address participation;
}

interface IHubRegistry {
    event HubCreated(address deployer, address hubAddress, uint256 market, uint256 commitment, string metadata);

    /// @notice return true if a given address is a hub
    function isHub(address) external view returns (bool);

    /// @notice initialize the hubRegistry through the proxy
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
    ) external;

    /// @notice set the initial contribution manager, who will be added to each new hub deployment
    /// @dev only callable by Hub owner
    function setInitialContributionManager(address _initialContributionManager) external;

    /// @notice return the current period id (as stored globally)
    function currentPeriodId() external view returns (uint32);

    /// @notice return the timestamp of when period id 0 begins (as stored globally)
    function period0Start() external view returns (uint32);

    /// @notice return the array of hubs created through the registry
    /// @dev supports subgraph queries
    function hubs() external view returns (address[] memory);

    /// @notice return the array of hubs deployed by an address
    /// @dev supports subgraph queries
    function hubsDeployed(address who) external view returns (address[] memory);

    /// @notice return the array of hubs a user is a member of
    function userHubs(address who) external view returns (address[] memory);

    /// @notice deploy a beacon proxy hub with its' associated contracts
    /// @dev deploys a TaskFactory, TaskManager, Membership, and Participation contract with the hub
    function deployHub(
        uint256[] calldata roles,
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) external returns (address hub);

    /// @notice join a hub for a member
    /// @dev must be called through AutId.joinHub()
    function join(address hub, address member, uint256 role, uint8 commitment) external;
}
