// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

//// @dev generated placeholder - add a function for each address
library DeploymentAddresses {
    function autIDAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x6E1ea384ED25d67D2C68cE27D6A9Ac49f8488133); // Replace with the actual address for chain ID 1
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
            return address(0x1a21e5C95464226a949Df3c7aC4Ffe0Ee4AF7A0d); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function moduleRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x7954d0980471CEDbb35b3be38fF5A160e7B4155B); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaLogicAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xf1B5428c862910dA31C7142DF0bd4d0e4937aA19); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xB7690209e09A6C00F25a8cBa722152c0F2e804c7); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x6666666666666666666666666666666666666666); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function pluginRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x3C01725f56651348bca3BAE5a7711ebab080aC74); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x8888888888888888888888888888888888888888); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function LocalReputationutationAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x8CEdbc66e8b67A39b6eB2a5a058c87323411615f); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }
}
