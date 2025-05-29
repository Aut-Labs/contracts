// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../InteractionFactory.sol"; // Adjust path as necessary

interface IInteractionFactory {
    enum RoyaltiesModel {
        PublicGood,
        IntegrationFee
    }

    struct InteractionTemplate {
        string name;
        string description;
        string protocol;
        string logo;
        string actionUrl;
        address targetContract;
        string functionABI;
        uint256 networkId;
        bytes32 uniqueHash;
        address royaltyRecipient;
        RoyaltiesModel royaltiesModel;
        uint256 price;
        address creator;
        uint256 createdAt;
    }

    struct InteractionTemplateParams {
        string name;
        string description;
        string protocol;
        string logo;
        string actionUrl;
        address targetContract;
        string functionABI;
        uint256 networkId;
        address royaltyRecipient;
        RoyaltiesModel royaltiesModel;
        uint256 price;
    }

    event AutIDRegistrySet(address indexed registryAddress);
    event InteractionTemplateCreated(uint256 indexed tokenId, address indexed creator, bytes32 indexed uniqueHash);
    event InteractionCreatedByAutID(address indexed autIDOwner, uint256 indexed tokenId);

    function hasAutID(address account) external view returns (bool);
    function setAutIDRegistry(address autIDAddress) external;
    function setPaused(bool paused) external;
    function createInteractionTemplates(InteractionTemplateParams[] calldata allParams) external returns (uint256[] memory);
    function createInteractionTemplate(InteractionTemplateParams calldata params) external returns (uint256);
    function totalTemplates() external view returns (uint256);
    function getInteractionTemplate(uint256 tokenId) external view returns (InteractionTemplate memory);
    function getTokenIdByHash(bytes32 hash) external view returns (uint256);
    function computeTemplateHash(address targetContract, string calldata functionABI, uint256 networkId) external pure returns (bytes32);
    function getInteractionsByCreator(address creator) external view returns (uint256[] memory);
} 