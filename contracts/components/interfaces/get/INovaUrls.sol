//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaUrls {
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev returns an array with all the listed urls
    /// @return returns all the urls listed for the Nova
    function getURLs() external view returns (string[] memory);

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this Nova
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url) external view returns (bool);
}
