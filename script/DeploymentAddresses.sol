// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

//// @dev generated placeholder - add a function for each address
library DeploymentAddresses {
    function autIDAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 1) {
            return address(0x1111111111111111111111111111111111111111); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x2222222222222222222222222222222222222222); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaFactoryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 1) {
            return address(0x3333333333333333333333333333333333333333); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 1) {
            return address(0x5555555555555555555555555555555555555555); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x6666666666666666666666666666666666666666); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function pluginRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 1) {
            return address(0x7777777777777777777777777777777777777777); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x8888888888888888888888888888888888888888); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function LocalReputationutationAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 1) {
            return address(0x9999999999999999999999999999999999999999); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }
}
