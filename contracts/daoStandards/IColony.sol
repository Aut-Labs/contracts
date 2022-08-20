//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title IColony
/// @notice The minimal interface of the Colony contract needed for implementing IMembershipExtension
interface IColony {

    /// @notice ColonyNetwork contract is needed to get Colony members list (whitelist) extension
    function getColonyNetwork() external view returns (address);

    /// @notice Colony owner is also a member
    function owner() external view returns (address);
}

/// @title IColonyNetwork
interface IColonyNetwork {
    /// @notice Get an extension's installation. This function is needed to get Colony contract whitelist (members list)
    /// @param extensionId keccak256 hash of the extension name, used as an identifier
    /// @param colony Address of the colony the extension is installed in
    /// @return installation The address of the installed extension
    function getExtensionInstallation(bytes32 extensionId, address colony) external view returns (address installation);
}

/// @title IColonyNetwork
interface IColonyWhitelist {
    function isApproved(address _user) external view returns (bool);
}
