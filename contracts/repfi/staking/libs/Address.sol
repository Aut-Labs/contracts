// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title Address
 * @notice A library for address-related utility functions.
 * @dev Provides functions to check if an address is a contract or a zero address.
*/

library Address {
    /**
     * @notice Checks if an address is a contract.
     * @dev This function returns true if the address contains contract code and is not the zero address.
     * @param _address The address to check.
     * @return bool True if the address is a contract, false otherwise.
     */
    function isContract(address _address) internal view returns(bool) {
        return _address.code.length > 0 && _address != address(0);
    }

    /**
     * @notice Checks if an address is the zero address.
     * @dev This function returns true if the address is the zero address.
     * @param _address The address to check.
     * @return bool True if the address is the zero address, false otherwise.
     */
    function isZeroAddress(address _address) internal pure returns(bool) {
        return _address == address(0);
    }
}