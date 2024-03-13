// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ContractDiscovery {
    event ContractAdded(
        bytes32 contractId,
        address deploymentAddress,
        address deployerAddress,
        string contractName
    );

    struct ContractData {
        address deploymentAddress;
        uint64 updatedAt;
    }

    string public constant HASH_PREFIX_URN="urn:autlabs:deployments";

    mapping(bytes32 => ContractData) internal _router;

    function contractIdForName(string memory contractName) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(HASH_PREFIX_URN, contractName));
    }

    function getContractAddress(bytes32 contractId) external view returns(address) {
        return _router[contractId].deploymentAddress;
    }

    function addContract(address deploymentAddress, string memory contractName) external {
        require(deploymentAddress != address(0), "invalid deployment address");
        require(bytes(contractName).length != 0, "invalid contract name");

        bytes32 contractId = contractIdForName(contractName);
        _router[contractId] = ContractData({
            deploymentAddress: deploymentAddress,
            createdAt: uint64(block.timestamp)
        });

        emit ContractAdded(contractId, deploymentAddress, msg.sender, contractName);
    }
}
