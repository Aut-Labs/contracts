//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IDAOURL
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOURLSet {
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function addURL(string memory _url) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev removes URL from the listed ones
    /// @param _url the URL that's going to be removed
    function removeURL(string memory _url) external;
}
