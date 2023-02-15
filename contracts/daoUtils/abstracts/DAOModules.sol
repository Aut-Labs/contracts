//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IDAOModules.sol";

/// @title DAOModules
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOModules is IDAOModules {
    address public override pluginRegistry;

    function _setPluginRegistry(address _pluginRegistry) internal {
        require(_pluginRegistry != address(0), "invalid pluginRegistry");
        pluginRegistry = _pluginRegistry;
    }
}
