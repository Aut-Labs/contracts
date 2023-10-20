// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IAccessControl.sol";
import "./interfaces/INova.sol";
import "./base/ComponentProxy.sol";
import "./ComponentRegistry.sol";

contract Nova is INova, Ownable {
    event ComponentAdded(bytes32, address);
    event ComponentCalled(bytes32 key, bytes4 selector, bool success);

    address public accessControl;
    address public componentRegistry;
    mapping(bytes32 => address) public componentForKey; 

    constructor(
        address accessControl_,
        address componentRegistry_,
        address deployer
    )
    {
        require(componentRegistry_ != address(0), "Nova: component registry address zero");
        require(accessControl_ != address(0), "Nova: access control address zero");
        accessControl = accessControl_;
        componentRegistry = componentRegistry_;
        _transferOwnership(deployer);
    }

    function addComponent(
        bytes32 componentKey,
        bytes calldata initializerArgs
    )
        external 
        onlyOwner
    {
        require(componentForKey[componentKey] == address(0), "Nova: address zero");
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
            IAccessControl(accessControl).permitCall(
                msg.sender,
                componentKey,
                componentSelector
            ),
            "Nova: component call is not permited"
        );
        address component = componentForKey[componentKey];
        require(component != address(0), "Nova: component address zero");
        (success, response) = component.call(abi.encodeWithSelector(componentSelector, callData));
        emit ComponentCalled(componentKey, componentSelector, success);
    }
}
