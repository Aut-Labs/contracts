// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title InteractionFactory
 * @notice This contract creates context-agnostic, non-transferable Interaction NFTs.
 *         Each Interaction NFT includes a unique hash computed from its core parameters
 *         (targetContract, contractURI, networkId) to ensure that identical on-chain actions are aggregated off-chain.
 */

contract InteractionFactory is ERC721, Ownable {
    // Royalty models: PublicGood, IntegrationFee, UsageTier.
    enum RoyaltiesModel { PublicGood, IntegrationFee, UsageTier }

    struct InteractionTemplate {
        string name;
        string description;
        string logo;
        string actionUrl;
        address targetContract;
        string contractURI;
        uint256 networkId;
        address author;
        uint256 price;
        RoyaltiesModel royaltiesModel;
        bytes32 uniqueHash; // Unique hash for deduplication.
    }

    uint256 private _tokenIds;
    mapping(uint256 => InteractionTemplate) public templates;

    event InteractionTemplateCreated(uint256 indexed tokenId, address indexed creator, bytes32 uniqueHash);

    /**
     * @notice Constructor.
     */
    constructor() ERC721("InteractionFactory", "INTF") {}

    /**
     * @notice Creates a new Interaction NFT.
     * @dev Computes a unique hash from targetContract, contractURI, and networkId.
     * @return newTokenId The ID of the newly minted Interaction NFT.
     */
    function createInteractionTemplate(
        string calldata name_,
        string calldata description_,
        string calldata logo_,
        string calldata actionUrl_,
        address targetContract_,
        string calldata contractURI_,
        uint256 networkId_,
        uint256 price_,
        RoyaltiesModel royaltiesModel_
    ) external returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        // Compute the unique hash based on core parameters.
        bytes32 uniqueHash = keccak256(abi.encodePacked(targetContract_, contractURI_, networkId_));
        templates[newTokenId] = InteractionTemplate({
            name: name_,
            description: description_,
            logo: logo_,
            actionUrl: actionUrl_,
            targetContract: targetContract_,
            contractURI: contractURI_,
            networkId: networkId_,
            author: msg.sender,
            price: price_,
            royaltiesModel: royaltiesModel_,
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
        require(_exists(tokenId), "Template does not exist");
        return templates[tokenId];
    }
}
