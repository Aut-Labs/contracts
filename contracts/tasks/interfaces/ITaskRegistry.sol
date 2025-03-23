pragma solidity >=0.8.0;

import {RoyaltiesModel} from "contracts/interactions/IInteractionFactory.sol";

// Enum to differentiate task types.
enum TaskType {
    Standard,
    Interaction
}

struct Task {
    uint256 taskId; // Unique identifier for the task.
    TaskType taskType; // Indicates whether the task is Standard or Interaction.
    // For standard tasks:
    string uri; // URI pointing to the task metadata (e.g., IPFS link).
    // For interaction tasks (core metadata only, per original design):
    address sourceInteractionContract; // Address of the InteractionFactory contract.
    uint256 sourceInteractionId; // Token ID of the Interaction NFT.
    uint256 networkId; // Network identifier (e.g., Polygon Mainnet).
    uint256 price; // Fee for integrating this Interaction Task into a Hub.
    RoyaltiesModel royaltiesModel; // Royalty model: PublicGood, IntegrationFee, or UsageTier.
}

interface ITaskRegistry {
    error TaskAlreadyRegistered();
    error TaskNotRegistered();

    // Event emitted when a standard task is registered.
    event StandardTaskRegistered(uint256 indexed taskId, string uri);

    // Event emitted when an Interaction Task is registered.
    event InteractionTaskRegistered(
        uint256 indexed taskId,
        address sourceInteractionContract,
        uint256 sourceInteractionId,
        uint256 networkId,
        uint256 price,
        RoyaltiesModel royaltiesModel
    );

    /**
     * @notice Registers a standard task in the global registry.
     * @dev This function remains unchanged from the original design.
     * @param _uri A URI pointing to the task’s metadata (typically on IPFS).
     * @return taskId The newly registered task's ID.
     */
    function registerStandardTask(string calldata _uri) external returns (uint256 taskId);

    /**
     * @notice Registers an approved Interaction Task in the global registry.
     * @dev This function allows the owner to append an approved Interaction Task.
     * It stores only the core metadata from the Interaction NFT.
     * @param _sourceInteractionContract The address of the InteractionFactory contract.
     * @param _sourceInteractionId The NFT token ID representing the Interaction.
     * @param _networkId The network identifier (e.g., Polygon Mainnet).
     * @param _price The fee (in POL tokens) required for a Hub to integrate this Interaction Task.
     * @param _royaltiesModel The royalty model (PublicGood, IntegrationFee, or UsageTier).
     * @return taskId The newly registered task's ID.
     */
    function registerInteractionTask(
        address _sourceInteractionContract,
        uint256 _sourceInteractionId,
        uint256 _networkId,
        uint256 _price,
        RoyaltiesModel _royaltiesModel
    ) external returns (uint256 taskId);

    /// @notice return the global tracking value of nextTaskId
    function nextTaskId() external view returns (uint256);

    /// @notice Return true if the id exists, else false
    function isTaskId(uint256 taskId) external view returns (bool);

    /**
     * @notice Retrieves the details of a specific task.
     * @param taskId The unique identifier of the task.
     * @return The Task struct containing all details for the task.
     */
    function getTask(uint256 taskId) external view returns (Task memory);

    /**
     * @notice Retrieves all tasks from the global registry.
     * @dev This function returns an array of all tasks. For very large datasets, pagination is recommended.
     * @return An array of Task structs.
     */
    function getAllTasks() external view returns (Task[] memory);

    /**
     * @notice Retrieves a number of tasks starting at a specific id from the global registry
     */
    function getSomeTasks(uint256 startTaskId, uint256 numTasks) external view returns (Task[] memory);
}
