// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IAuthorization.sol";
import "./base/ComponentProxy.sol";
import "./interfaces/INova.sol";
import "./ComponentRegistry.sol";

interface INovaComponentDiscovery {
    function componentRegistry() external view returns(address);
    function componentAddressForKey(bytes32) external view returns(address);
    function addComponent(bytes32, bytes calldata initializerArgs) external;
}

contract NovaComponentDiscovery {
    event ComponentAdded(bytes32, address);

    mapping(bytes32 => address) public componentAddressForKey;
    address immutable public componentRegistry;

    constructor(address componentRegistry_) {
        componentRegistry = componentRegistry_;
    }

    function addComponent(
        bytes32 componentKey,
        bytes calldata initializerArgs
    )
        external
    {
        require(componentAddressForKey[componentKey] == address(0), "Nova: component exists");
        address beacon = ComponentRegistry(componentRegistry).beaconFor(componentKey);
        address proxy = address(new ComponentProxy(beacon, initializerArgs, address(this)));
        componentAddressForKey[componentKey] = proxy;
        emit ComponentAdded(componentKey, proxy);
    }
}

contract Nova is INova, Ownable {
    event ComponentAdded(bytes32, address);
    event ComponentCalled(bytes32 key, bytes4 selector, bool success);

    address public authorization;
    address immutable public componentRegistry;
    mapping(bytes32 => address) public componentForKey; 

    constructor(
        address deployer,
        address componentRegistry_,
        address authorization_
    )
    {
        require(componentRegistry_ != address(0), "Nova: address zero");
        componentRegistry = componentRegistry_;
        authorization = authorization_;
        _transferOwnership(deployer);
    }

    function addComponent(
        bytes32 componentKey,
        bytes calldata initializerArgs
    )
        external 
        onlyOwner
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
        returns (bool success, bytes memory response)
    {
        require(
            IAuthorization(authorization).authCall(
                msg.sender,
                componentKey,
                componentSelector
            ),
            "Nova: component call unauthorized"
        );
        address component = componentForKey[componentKey];
        require(component != address(0), "Nova: address zero");
        (success, response) = component.call(abi.encodeWithSelector(componentSelector, callData));
        emit ComponentCalled(componentKey, componentSelector, success);
    }
}

