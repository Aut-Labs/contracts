// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {RoyaltiesModel, InteractionTemplate, InteractionTemplateParams} from "./IInteractionFactory.sol";

/**
 * @title InteractionFactory
 * @notice This contract creates context-agnostic, non-transferable Interaction NFTs.
 *         Each Interaction NFT includes a unique hash computed from its core parameters
 *         (targetContract, contractURI, networkId) to ensure that identical on-chain actions are aggregated off-chain.
 */
contract InteractionFactory is ERC721, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => InteractionTemplate) public templates;

    event InteractionTemplateCreated(uint256 indexed tokenId, address indexed creator, bytes32 uniqueHash);

    /**
     * @notice Constructor.
     */
    constructor(address _owner) ERC721("InteractionFactory", "INTF") Ownable(_owner) {}

    function createInteractionTemplates(
        InteractionTemplateParams[] calldata allParams
    ) external onlyOwner returns (uint256[] memory) {
        uint256[] memory tokenIdsMinted = new uint256[](allParams.length);

        for (uint256 i = 0; i < allParams.length; i++) {
            tokenIdsMinted[i] = createInteractionTemplate(allParams[i]);
        }

        return tokenIdsMinted;
    }

    /**
     * @notice Creates a new Interaction NFT.
     * @dev Computes a unique hash from targetContract, contractURI, and networkId.
     * @return newTokenId The ID of the newly minted Interaction NFT.
     */
    function createInteractionTemplate(InteractionTemplateParams memory params) public onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        // Compute the unique hash based on core parameters.
        bytes32 uniqueHash = keccak256(abi.encodePacked(params.targetContract, params.contractURI, params.networkId));
        templates[newTokenId] = InteractionTemplate({
            name: params.name,
            description: params.description,
            logo: params.logo,
            actionUrl: params.actionUrl,
            targetContract: params.targetContract,
            contractURI: params.contractURI,
            networkId: params.networkId,
            price: params.price,
            royaltiesModel: params.royaltiesModel,
            author: msg.sender,
            uniqueHash: uniqueHash
        });
        _mint(msg.sender, newTokenId);
        emit InteractionTemplateCreated(newTokenId, msg.sender, uniqueHash);
        return newTokenId;
    }

    /**
     * @notice Returns the total number of Interaction NFTs minted.
     */
    function totalTemplates() external view returns (uint256) {
        return _tokenIds;
    }

    /**
     * @notice Returns the metadata (including uniqueHash) for a given Interaction NFT.
     * @param tokenId The NFT's identifier.
     */
    function getInteractionTemplate(uint256 tokenId) external view returns (InteractionTemplate memory) {
        require(tokenId > 0 && tokenId <= _tokenIds, "Template does not exist");
        return templates[tokenId];
    }
}
