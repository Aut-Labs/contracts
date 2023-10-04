// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Multicall.sol";

import "./base/Upgradeable.sol";
import "./base/ComponentProxy.sol";
import "./ComponentRegistry.sol";


contract Nova is Multicall {
    event ComponentAdded(bytes32 componentId, address proxy);

    address public componentRegistry;
    mapping(bytes32 => address) public components;
    mapping(address => bool) public isAdmin;

    constructor(address initialAdmin, address componentRegistry_) {
        isAdmin[initialAdmin] = true;
        componentRegistry = componentRegistry_;
    }

    function addComponent(
        bytes32 componentId,
        bytes calldata initializerArgs
    ) external {
        require(components[componentId] == address(0));

        address beacon = ComponentRegistry(componentRegistry).beaconFor(componentId);
        address proxy = address(new ComponentProxy(beacon, initializerArgs));
        components[componentId] = proxy;

        emit ComponentAdded(componentId, proxy);
    }
}
