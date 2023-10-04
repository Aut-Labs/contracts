// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Multicall.sol";

import "./base/Upgradeable.sol";
import "./base/ComponentProxy.sol";
import "./ComponentRegistry.sol";


contract Nova is Multicall {
    event AdminAdded(address admin);
    event ComponentAdded(bytes32 componentId, address proxy);

    address public componentRegistry;
    mapping(bytes32 => address) public components;
    mapping(address => bool) public isAdmin;

    constructor(address initialAdmin, address componentRegistry_) {
        isAdmin[initialAdmin] = true;
        componentRegistry = componentRegistry_;
    }

    function addAdmin(address newAdmin) external {
        _requireAdmin();
        require(newAdmin != address(0));
        isAdmin[newAdmin] = true;
        emit AdminAdded(newAdmin);
    }

    function addComponent(
        bytes32 componentId,
        bytes calldata initializerArgs
    ) external {
        _requireAdmin();
        require(components[componentId] == address(0));

        address beacon = ComponentRegistry(componentRegistry).beaconFor(componentId);
        address proxy = address(new ComponentProxy(beacon, initializerArgs));
        components[componentId] = proxy;

        emit ComponentAdded(componentId, proxy);
    }

    function _requireAdmin() internal view {
        require(isAdmin[msg.sender]);
    }
}
