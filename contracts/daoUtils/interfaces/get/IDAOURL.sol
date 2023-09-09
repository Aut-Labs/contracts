//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IDAOURL
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOURL {
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev returns an array with all the listed urls
    /// @return returns all the urls listed for the DAO
    function getURLs() external view returns (string[] memory);

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this DAO
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url) external view returns (bool);
}
