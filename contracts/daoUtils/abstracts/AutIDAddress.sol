//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IAutIDAddress.sol";
import "../../IAutID.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract AutIDAddress is IAutIDAddress {
    IAutID private _autID;

    /// @dev Modifier for check of access of the admin member functions
    modifier onlyAutID() {
        require(
            msg.sender == address(_autID),
            "Only AutID"
        );
        _;
    }

    function getAutIDAddress() public view override returns (address) {
        return address(_autID);
    }

    function _setAutIDAddress(IAutID autIDAddress) internal {
        _autID = IAutID(autIDAddress);
    }
}
