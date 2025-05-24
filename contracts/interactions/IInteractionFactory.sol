pragma solidity >=0.8.0;

// Royalty models: PublicGood, IntegrationFee, UsageTier.
enum RoyaltiesModel {
    PublicGood,
    IntegrationFee,
    UsageTier
}

// Same as InteractionTemplate minus "creator", "createdAt", and "uniqueHash".
struct InteractionTemplateParams {
    string name;
    string description;
    string protocol;
    string logo;
    string actionUrl;
    address targetContract;
    string functionABI;
    uint256 networkId;
    uint256 price;
    address royaltyRecipient;
    RoyaltiesModel royaltiesModel;
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

interface IInteractionFactory {
    event InteractionTemplateCreated(uint256 indexed tokenId, address indexed creator, bytes32 indexed uniqueHash);

    event InteractionCreatedByAutID(address indexed creator, uint256 indexed tokenId);

    /**
     * @notice Emitted when the AutID registry is set
     * @param registryAddress The address of the AutID registry
     */
    event AutIDRegistrySet(address indexed registryAddress);

    /**
     * @notice Checks if an address owns an AutID
     * @param account The address to check
     * @return True if the address owns an AutID
     */
    function hasAutID(address account) external view returns (bool);

    /**
     * @notice Creates a batch of interaction templates
     * @param allParams Array of parameters for each template
     * @return tokenIds Array of token IDs for the created templates
     */
    function createInteractionTemplates(
        InteractionTemplateParams[] calldata allParams
    ) external returns (uint256[] memory);

    /**
     * @notice Creates a single interaction template
     * @param params Parameters for the template
     * @return tokenId Token ID of the created template
     */
    function createInteractionTemplate(InteractionTemplateParams calldata params) external returns (uint256);

    /**
     * @notice Returns the total number of templates
     * @return count The total count of templates
     */
    function totalTemplates() external view returns (uint256);

    /**
     * @notice Gets the template data for a given token ID
     * @param tokenId The token ID to query
     * @return template The complete template data
     */
    function getInteractionTemplate(uint256 tokenId) external view returns (InteractionTemplate memory);

    /**
     * @notice Gets the token ID for a given hash
     * @param hash The unique hash to query
     * @return tokenId The token ID (0 if not found)
     */
    function getTokenIdByHash(bytes32 hash) external view returns (uint256);

    /**
     * @notice Computes the unique hash for a template
     * @param targetContract The contract address
     * @param functionABI The function ABI or signature
     * @param networkId The network ID
     * @return hash The computed hash
     */
    function computeTemplateHash(
        address targetContract,
        string calldata functionABI,
        uint256 networkId
    ) external pure returns (bytes32);

    /**
     * @notice Gets all templates created by a specific address
     * @param creator The creator address
     * @return tokenIds Array of token IDs created by the address
     */
    function getInteractionsByCreator(address creator) external view returns (uint256[] memory);
}
