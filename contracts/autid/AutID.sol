// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {ERC721URIStorageUpgradeable, ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract AutID is ERC721URIStorageUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    event RecordCreated(uint256 tokenId, address account, string username, string uri);

    error NullArgument();
    error InvalidUsername();
    error ConflictingRecord();
    error UntransferableToken();

    mapping(bytes32 => uint256) public tokenIdForUsername;
    mapping(address => uint256) public tokenIdForAccount;
    uint256 private _tokenId;

    function initialize() public initializer {
        __ERC721_init("AutID", "AUT");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
    }

    function transferFrom(address, address, uint256) public pure override(ERC721Upgradeable, IERC721) {
        revert UntransferableToken();
    }

    function _createRecord(address account, string memory username_, string memory optionalURI) internal {
        _revertForInvalidUsername(username_);
        if (account == address(0)) {
            revert NullArgument();
        }
        bytes32 username;
        assembly {
            username := mload(add(username_, 32))
        }
        if (tokenIdForUsername[username] != 0 || tokenIdForAccount[account] != 0) {
            revert ConflictingRecord();
        }

        uint256 tokenId = ++_tokenId;
        _mint(account, tokenId);
        _setTokenURI(tokenId, optionalURI);
        tokenIdForUsername[username] = tokenId;
        tokenIdForAccount[account] = tokenId;

        emit RecordCreated(tokenId, account, username_, optionalURI);
    }

    function _revertForInvalidUsername(string memory username_) private pure {
        bytes memory username = bytes(username_);
        uint256 i;
        for (; i != username.length; ++i) {
            if (!(
                // 'a' <= ... <= 'z'
                (username[i] >= 0x61 && username[i] <= 0x7A) || 
                // '0' <= ... <= '9'
                (username[i] >= 0x30 && username[i] <= 0x39) ||
                // '-' == ...
                username[i] == 0x2D
            )) {
                revert InvalidUsername();
            }
        }
        if (i == 0 || i > 32) {
            revert InvalidUsername();
        }
    }

    uint256[47] private __gap;
}
