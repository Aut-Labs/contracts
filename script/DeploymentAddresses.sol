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
            return address(0x1E7b11371caD0A85aed497b3f2370c6bbFffbBF7); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

        function moduleRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xC97f141Dd7A4f46280F42B47B15d127667fb0B91); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }


    function novaFactoryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0xD92A40Bb378DF17Ca76d73a53211dFFE1Da66104); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x4444444444444444444444444444444444444444); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function novaRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x9fca98e6f64ebCeE8EEfa228B53D144F7CC304be); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x6666666666666666666666666666666666666666); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function pluginRegistryAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x371299E146aC62EAE44969055aCC14187a48Ec0C); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0x8888888888888888888888888888888888888888); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }

    function LocalReputationutationAddr(uint256 chainID) internal pure returns (address) {
        if (chainID == 80001) {
            return address(0x8FF74e53F6f8e6932421F65A454006f6FD2BD64C); // Replace with the actual address for chain ID 1
        } else if (chainID == 2) {
            return address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // Replace with the actual address for chain ID 2
        } else {
            revert("Unsupported chainID");
        }
    }
}
