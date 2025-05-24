// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IInteractionFactory.sol";
import "../autid/IAutID.sol";

/**
 * @title InteractionFactory
 * @author Āut Labs
 * @notice This contract creates context-agnostic, non-transferable Interaction NFTs.
 *         Each Interaction NFT includes a unique hash computed from its core parameters
 *         (targetContract, functionABI, networkId) to ensure that identical on-chain actions are aggregated off-chain.
 *         Only addresses that own an AutID can create interaction templates.
 */
contract InteractionFactory is ERC721, Ownable, IInteractionFactory {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    // Storage for interaction templates
    mapping(uint256 => InteractionTemplate) private _templates;

    // Mapping from unique hash to token ID for deduplication
    mapping(bytes32 => uint256) private _hashToTokenId;

    // Mapping from creator address to their created token IDs
    mapping(address => EnumerableSet.UintSet) private _creatorTokens;

    // Token ID counter for new mints
    uint256 private _nextTokenId = 1;

    // AutID registry contract
    IAutID private _autID;

    // Contract is initially paused until AutID registry is set
    bool private _paused = true;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    /**
     * @notice Constructor
     * @param initialOwner The initial owner of the contract
     */
    constructor(address initialOwner) ERC721("Aut Interaction Template", "AIT") Ownable(initialOwner) {}

    /**
     * @notice Modifier to check if an address owns an AutID
     */
    modifier onlyAutIDOwner() {
        require(hasAutID(msg.sender), "InteractionFactory: caller does not own an AutID");
        _;
    }

    /**
     * @notice Modifier to check if the contract is not paused
     */
    modifier whenNotPaused() {
        require(!_paused, "InteractionFactory: contract is paused");
        _;
    }

    /// @inheritdoc IInteractionFactory
    function hasAutID(address account) public view override returns (bool) {
        if (address(_autID) == address(0)) return false;
        return _autID.balanceOf(account) > 0;
    }

    /**
     * @notice Sets the AutID registry address
     * @param autIDAddress The address of the AutID registry contract
     */
    function setAutIDRegistry(address autIDAddress) external onlyOwner {
        require(autIDAddress != address(0), "InteractionFactory: zero address");
        _autID = IAutID(autIDAddress);
        _paused = false;

        emit AutIDRegistrySet(autIDAddress);
    }

    /**
     * @notice Allows the owner to pause the contract
     * @param paused Whether to pause or unpause the contract
     */
    function setPaused(bool paused) external onlyOwner {
        _paused = paused;
    }

    /// @inheritdoc IInteractionFactory
    function createInteractionTemplates(
        InteractionTemplateParams[] calldata allParams
    ) external override whenNotPaused onlyAutIDOwner returns (uint256[] memory) {
        uint256 length = allParams.length;
        require(length > 0, "InteractionFactory: empty params array");

        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            tokenIds[i] = _createInteractionTemplate(allParams[i]);
        }

        return tokenIds;
    }

    /// @inheritdoc IInteractionFactory
    function createInteractionTemplate(
        InteractionTemplateParams calldata params
    ) external override whenNotPaused onlyAutIDOwner returns (uint256) {
        return _createInteractionTemplate(params);
    }

    /**
     * @notice Internal function to create an interaction template
     * @param params Parameters for the template
     * @return tokenId Token ID of the created template
     */
    function _createInteractionTemplate(InteractionTemplateParams calldata params) private returns (uint256) {
        // Input validation
        require(bytes(params.name).length > 0, "InteractionFactory: name cannot be empty");
        require(bytes(params.description).length > 0, "InteractionFactory: description cannot be empty");
        require(params.targetContract != address(0), "InteractionFactory: targetContract cannot be zero address");
        require(bytes(params.functionABI).length > 0, "InteractionFactory: functionABI cannot be empty");
        require(params.royaltyRecipient != address(0), "InteractionFactory: royaltyRecipient cannot be zero address");

        // Validate royalty model and price
        if (params.royaltiesModel == RoyaltiesModel.IntegrationFee) {
            require(params.price > 0, "InteractionFactory: price must be greater than zero for IntegrationFee model");
        }

        // Compute unique hash for deduplication
        bytes32 uniqueHash = computeTemplateHash(params.targetContract, params.functionABI, params.networkId);

        // Check for existing template with the same hash
        uint256 existingTokenId = _hashToTokenId[uniqueHash];
        if (existingTokenId != 0) {
            return existingTokenId; // Return existing token ID if template already exists
        }

        // Mint new token
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // Create and store the template
        InteractionTemplate memory template = InteractionTemplate({
            name: params.name,
            description: params.description,
            protocol: params.protocol,
            logo: params.logo,
            actionUrl: params.actionUrl,
            targetContract: params.targetContract,
            functionABI: params.functionABI,
            networkId: params.networkId,
            uniqueHash: uniqueHash,
            royaltyRecipient: params.royaltyRecipient,
            royaltiesModel: params.royaltiesModel,
            price: params.price,
            creator: msg.sender,
            createdAt: block.timestamp
        });

        // Store template data
        _templates[tokenId] = template;
        _hashToTokenId[uniqueHash] = tokenId;

        // Add to creator's tokens
        _creatorTokens[msg.sender].add(tokenId);

        // Emit events
        emit InteractionTemplateCreated(tokenId, msg.sender, uniqueHash);
        emit InteractionCreatedByAutID(msg.sender, tokenId);

        return tokenId;
    }

    /// @inheritdoc IInteractionFactory
    function totalTemplates() external view override returns (uint256) {
        return _nextTokenId - 1;
    }

    /// @inheritdoc IInteractionFactory
    function getInteractionTemplate(uint256 tokenId) external view override returns (InteractionTemplate memory) {
        require(_exists(tokenId), "InteractionFactory: nonexistent token");
        return _templates[tokenId];
    }

    /// @inheritdoc IInteractionFactory
    function getTokenIdByHash(bytes32 hash) external view override returns (uint256) {
        return _hashToTokenId[hash];
    }

    /// @inheritdoc IInteractionFactory
    function computeTemplateHash(
        address targetContract,
        string calldata functionABI,
        uint256 networkId
    ) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(targetContract, functionABI, networkId));
    }

    /// @inheritdoc IInteractionFactory
    function getInteractionsByCreator(address creator) external view override returns (uint256[] memory) {
        uint256 count = _creatorTokens[creator].length();
        uint256[] memory tokenIds = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = _creatorTokens[creator].at(i);
        }

        return tokenIds;
    }

    /**
     * @notice Returns the URI for a given token ID
     * @param tokenId The token ID to query
     * @return uri The token URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "InteractionFactory: nonexistent token");

        InteractionTemplate memory template = _templates[tokenId];

        string memory json = string(
            abi.encodePacked(
                "{",
                '"name":"',
                template.name,
                '",',
                '"description":"',
                template.description,
                '",',
                '"protocol":"',
                template.protocol,
                '",'
            )
        );
        json = string(
            abi.encodePacked(
                json,
                '"image":"',
                template.logo,
                '",',
                '"external_url":"',
                template.actionUrl,
                '",',
                '"attributes":['
            )
        );
        json = string(
            abi.encodePacked(
                json,
                "{",
                '"trait_type":"Target Contract",',
                '"value":"',
                _addressToString(template.targetContract),
                '"',
                "},",
                "{",
                '"trait_type":"Network ID",',
                '"value":"',
                Strings.toString(template.networkId),
                '"',
                "},",
                "{",
                '"trait_type":"Royalty Model",',
                '"value":"',
                template.royaltiesModel == RoyaltiesModel.PublicGood ? "Public Good" : "Integration Fee",
                '"',
                "}"
            )
        );
        json = string(
            abi.encodePacked(
                json,
                "{",
                '"trait_type":"Creator",',
                '"value":"',
                _addressToString(template.creator),
                '"',
                "},",
                "{",
                '"trait_type":"Created At",',
                '"value":"',
                Strings.toString(template.createdAt),
                '"',
                "}",
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", _toBase64(bytes(json))));
    }

    /**
     * @notice Checks if a token exists
     * @param tokenId The token ID to check
     * @return exists True if the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId < _nextTokenId;
    }

    /**
     * @notice Override _update to make tokens soulbound
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);

        // Only allow transfers from zero address (new mints)
        if (from != address(0)) {
            revert("InteractionFactory: tokens are soulbound");
        }

        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Helper function to convert address to string
     * @param addr The address to convert
     */
    function _addressToString(address addr) private pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(addr);
        bytes memory stringBytes = new bytes(42);

        stringBytes[0] = "0";
        stringBytes[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            uint8 leftValue = uint8(addressBytes[i]) / 16;
            uint8 rightValue = uint8(addressBytes[i]) % 16;

            stringBytes[2 + i * 2] = _toHexChar(leftValue);
            stringBytes[2 + i * 2 + 1] = _toHexChar(rightValue);
        }

        return string(stringBytes);
    }

    /**
     * @dev Helper function to convert uint8 to hex character
     * @param value The value to convert
     */
    function _toHexChar(uint8 value) private pure returns (bytes1) {
        if (value < 10) {
            return bytes1(uint8(bytes1("0")) + value);
        } else {
            return bytes1(uint8(bytes1("a")) + value - 10);
        }
    }

    /**
     * @dev Helper function to Base64 encode
     * @param data The data to encode
     */
    function _toBase64(bytes memory data) private pure returns (string memory) {
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 len = data.length;
        if (len == 0) return "";

        // Calculate output length
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Create output buffer
        bytes memory result = new bytes(encodedLen);

        uint256 i;
        uint256 j = 0;

        // Process 3 bytes at a time
        for (i = 0; i + 3 <= len; i += 3) {
            uint256 val = (uint256(uint8(data[i])) << 16) |
                (uint256(uint8(data[i + 1])) << 8) |
                uint256(uint8(data[i + 2]));

            result[j++] = bytes(table)[(val >> 18) & 63];
            result[j++] = bytes(table)[(val >> 12) & 63];
            result[j++] = bytes(table)[(val >> 6) & 63];
            result[j++] = bytes(table)[val & 63];
        }

        // Handle remaining bytes
        if (i + 2 == len) {
            uint256 val = (uint256(uint8(data[i])) << 16) | (uint256(uint8(data[i + 1])) << 8);

            result[j++] = bytes(table)[(val >> 18) & 63];
            result[j++] = bytes(table)[(val >> 12) & 63];
            result[j++] = bytes(table)[(val >> 6) & 63];
            result[j++] = bytes(table)[64]; // Padding
        } else if (i + 1 == len) {
            uint256 val = uint256(uint8(data[i])) << 16;

            result[j++] = bytes(table)[(val >> 18) & 63];
            result[j++] = bytes(table)[(val >> 12) & 63];
            result[j++] = bytes(table)[64]; // Padding
            result[j++] = bytes(table)[64]; // Padding
        }

        return string(result);
    }
}
