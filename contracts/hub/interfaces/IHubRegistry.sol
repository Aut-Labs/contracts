//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubRegistry {
    function initialize(
        address autId_,
        address hubLogic,
        address hubDomainsRegistry_,
        address taskRegistry_,
        address globalParameters_,
        address _membershipImplementation,
        address _participationImplementation,
        address _taskFactoryImplementation,
        address _taskManagerImplementation
    ) external;

    function checkHub(address) external view returns (bool);

    // function deployHub(uint256 market, string memory metadata, uint256 commitment) external returns (address hub);

    function join(address hub, address member, uint256 role, uint8 commitment) external;

    function listUserHubs(address user) external view returns (address[] memory);
}
