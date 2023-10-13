// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

//// @dev generated placeholder - add a function for each address
library DeploymentAddresses {
    function autIDAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x429857e088e9Ca8067805c31942dD6a9E1D1fE5B); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x2222222222222222222222222222222222222222); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    /// module registry 0x0D6b0826CA305F54255531C742e3781F442f57CA
    /// Allowlist 

    function allowListAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x235d9a420857F085BA1d339F0bFf906281B24E9a); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

        function moduleRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x7d8B9B8170BA2739270039cE5b75B1C5D4952e08); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }


    function novaFactoryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xa7BD9F8678e36AFa08e38f6e9f9e40AF5DE82Eae); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x34deE105084eB37d7d48bD5A152CF21836cd14eC); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x6666666666666666666666666666666666666666); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function pluginRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x34B8e4A8eFb14eD784e106eb507e06cf3F89470B); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x8888888888888888888888888888888888888888); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function LocalReputationutationAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x16333BBb94E8f24056d04c1da13D22a696089818); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }
}
