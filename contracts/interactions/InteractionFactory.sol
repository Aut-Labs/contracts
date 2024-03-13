// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IInteractionRegistry} from "./IInteractionRegistry.sol";
import {ContractDiscoveryBase} from "./discover/ContractDiscoveryBase.sol";

contract InteractionFactory is ERC721URIStorage, AccessControl, ContractDiscoveryBase {
    event InteractionTypeNftMinted (
        address indexed owner;
        uint256 indexed tokenId;
        bytes32 indexed interactionType;
        string metadataUri;
    )

    struct TokenData {
        uint64 mintedAt;
        bytes32 interactionType;
        string metadataUri;
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER(MINTER)_ROLE");

    mapping(uint256 => TokenData) public tokenDataFor;
    uint256 public tokenId;

    constructor(address initialCreatorManager) ERC721URIStorage("INT-F", "Interaction Factory") {
        require(initialCreatorManager != address(0), "should set initial owner");

        _constructor();

        _setRoleAdmin(MINTER_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialCreatorManager);
        _grantRole(MINTER_ROLE, initialCreatorManager);
    }

    function mintInteractionType(IInteractionRegistry.InteractionData memory data, string memory metadataUri_) {
        IInteractionRegistry interactionRegistry = IInteractionRegistry(_discover(INTERACTION_REGISTRY));
        interactionRegistry.createInteractionType(
            data.chainId,
            data.recipient,
            data.functionSelector
        );
        bytes32 interactionType_ = interactionRegistry.interactionType(
            data.chainId,
            data.recipient,
            data.functionSelector
        );

        uint256 tokenId_ = ++tokenId;
        _mint(msg.sender, tokenId_);
        tokenDataFor[tokenId_] = TokenData({
            mintedAt: block.timestamp,
            interactionType: interactionType_,
            metadataUri: metadataUri_
        });

        emit InteractionTypeNftMinted(
            msg.sender,
            tokenId_,
            interactionType_,
            metadataUri_
        );
    }
}
