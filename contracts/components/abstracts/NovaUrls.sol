//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/INovaUrls.sol";

/// @title Nova
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract NovaUrls is INovaUrls {
    event UrlAdded(string url);
    event UrlRemoved(string url);

    /// @notice all urls listed for the DAuth
    string[] private urls;

    /// @notice url ids
    mapping(bytes32 => uint256) private urlIds;

    // URLs
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function _addURL(string memory _url) internal {
        bytes32 urlHash = keccak256(bytes(_url));
        bool exists = false;
        if (urls.length != 0) {
            if (urlIds[urlHash] != 0 || keccak256(bytes(urls[0])) == urlHash) {
                exists = true;
            }
        }
        require(!exists, "url already exists");

        urlIds[urlHash] = urls.length;
        urls.push(_url);

        emit UrlAdded(_url);
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev removes URL from the listed ones
    /// @param _url the URL that's going to be removed
    function _removeURL(string memory _url) internal {
        require(isURLListed(_url), "url doesnt exist");

        bytes32 urlHash = keccak256(bytes(_url));
        uint256 urlId = urlIds[urlHash];

        if (urlId != urls.length - 1) {
            string memory lastUrl = urls[urls.length - 1];
            bytes32 lastUrlHash = keccak256(bytes(lastUrl));

            urlIds[lastUrlHash] = urlId;
            urls[urlId] = lastUrl;
        }

        urls.pop();
        delete urlIds[urlHash];
        emit UrlRemoved(_url);
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev returns an array with all the listed urls
    /// @return returns all the urls listed for the DAO
    function getURLs() public view override returns (string[] memory) {
        return urls;
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this DAO
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url) public view override returns (bool) {
        if (urls.length == 0) return false;

        bytes32 urlHash = keccak256(bytes(_url));

        if (urlIds[urlHash] != 0) return true;
        if (keccak256(bytes(urls[0])) == urlHash) return true;

        return false;
    }
}
