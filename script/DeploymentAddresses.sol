// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

//// @dev generated placeholder - add a function for each address
library DeploymentAddresses {
    function autIDAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x7F84b39477Cb4b51D0Ad866eC04C98396ab3FFF9); // Replace with the actual address for chain ID 1
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
            return address(0x395C4251A51f790C8B0D935B4D08Fa1cA3F7E280); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function moduleRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x2707e75B7Bf5b5EDe1Ef9519BDF66f8CD3f78072); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaFactoryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xC89A92A62DffF5F72e85B7aFaf885E2E2462F846); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xCA2057B3c946dA49697702960556099be0B9fCC6); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x6666666666666666666666666666666666666666); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function pluginRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x1eEcfE9A1C0feB5654B94b6582Ab379e8A6a793d); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x8888888888888888888888888888888888888888); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function LocalReputationutationAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x857Bcf94a7e3D228a56563Bb7392CF556032ca3c); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }
}
