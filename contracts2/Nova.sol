// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./base/ComponentProxy.sol";
import "./interfaces/INova.sol";
import "./ComponentRegistry.sol";

abstract contract Admin {
    event AdminSet(address);
    event AdminRemoved(address);

    mapping(address => bool) public isAdmin;

    modifier adminCall() {
        require(isAdmin[msg.sender]);
        _;
    }

    function _setAdmin(address newAdmin) internal adminCall {
        require(newAdmin != address(0), "Admin: address zero");
        isAdmin[newAdmin] = true;
        emit AdminSet(newAdmin);
    }

    function _removeAdmin(address exAdmin) internal adminCall {
        require(exAdmin != address(0), "Admin: address zero");
        isAdmin[exAdmin] = false;
        emit AdminRemoved(exAdmin);
    }
}

contract Nova is INova, Admin {
    event ComponentAdded(bytes32, address);
    event ComponentCalled(bytes32 key, bytes4 selector, bool success);

    address immutable public componentRegistry;
    mapping(bytes32 => address) public componentForKey;

    constructor(address admin, address componentRegistry_) {
        require(componentRegistry_ != address(0), "Nova: address zero");
        componentRegistry = componentRegistry_;
        _setAdmin(admin);
    }

    function addComponent(
        bytes32 componentKey,
        bytes calldata initializerArgs
    )
        external
        adminCall 
    {
        require(componentForKey[componentKey] != address(0), "Nova: address zero");
        address beacon = ComponentRegistry(componentRegistry).beaconFor(componentKey);
        address proxy = address(new ComponentProxy(beacon, initializerArgs, address(this)));
        componentForKey[componentKey] = proxy;
        emit ComponentAdded(componentKey, proxy);
    }

    function callComponent(
        bytes32 componentKey,
        bytes4 componentSelector,
        bytes calldata callData
    )
        external
        adminCall
        returns (bool success, bytes memory response)
    {
        address component = componentForKey[componentKey];
        require(component != address(0), "Nova: address zero");
        (success, response) = component.call(abi.encodeWithSelector(componentSelector, callData));
        emit ComponentCalled(componentKey, componentSelector, success);
    }
}
