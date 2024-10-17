pragma solidity >=0.8.0;

struct Contribution {
    bytes32 taskId;
    bytes32 descriptionId;
    uint256 role;
    uint32 startDate;
    uint32 endDate;
    uint32 points;
    uint128 quantity;
}

struct Description {
    string uri;
}

interface ITaskFactory {
    error NotContributionId();
    error TaskIdNotRegistered();
    error ContributionIdAlreadyExists();
    error InvalidContributionQuantity();
    error InvalidContributionPoints();
    error InvalidContributionPeriod();
    error DescriptionAlreadyRegistered();

    event CreateContribution(bytes32 indexed contributionId, address indexed sender, bytes encodedContribution);
    event RegisterDescription(bytes32 indexed descriptionId);

    /// @notice register descriptions of contributions to be used in `createContribution(s)`
    /// @dev wraps the string uri into a bytes32 for predictable lengths
    function registerDescriptions(Description[] calldata descriptions) external returns (bytes32[] memory);

    /// @notice register description of a contribution to be used in `createContribution(s)`
    /// @dev wraps the string uri into a bytes32 for predictable lengths
    function registerDescription(Description calldata description) external returns (bytes32);

    /// @notice Create contributions to be tracked by the TaskManager
    /// @return Array of new bytes32 contributionIds (1:1 with contributions)
    function createContributions(Contribution[] calldata contributions) external returns (bytes32[] memory);

    /// @notice Create contribution to be tracked by the TaskManager
    /// @return bytes32 contributionId of the contribution
    function createContribution(Contribution calldata contribution) external returns (bytes32);

    /// @notice Off-chain helper to display contributions where timestamp < endDate
    function getContributionIdsBeforeEndDate(uint32 timestamp) external view returns (bytes32[] memory);

    /// @notice Off-chain helper to display contributions where startDate < timestamp & timestamp < endDate
    function getContributionIdsActive(uint32 timestamp) external view returns (bytes32[] memory);

    /// @notice return a description struct based on its' identifier
    function getDescriptionById(bytes32 descriptionId) external view returns (Description memory);

    /// @notice Using the unique identifier of a contribution, get the data associated to it
    function getContributionById(bytes32 contributionId) external view returns (Contribution memory);

    /// @notice same as getDescriptionById except returns bytes instead of struct
    function getDescriptionByIdEncoded(bytes32 descriptionId) external view returns (bytes memory);

    /// @notice same as getContributionById but without requiring tuple support for external contracts
    function getContributionByIdEncoded(bytes32 contributionId) external view returns (bytes memory);

    /// @notice return true if the Description identifier exists
    function isDescriptionId(bytes32 descriptionId) external view returns (bool);

    /// @notice Return true if a unique Contribution identifier has been created, else false
    function isContributionId(bytes32 contributionId) external view returns (bool);

    /// @notice return the array of all existing Description identifiers
    function descriptionIds() external view returns (bytes32[] memory);

    /// @notice return all created Contribution identifiers
    function contributionIds() external view returns (bytes32[] memory);

    /// @notice return all Contribution ids created within a given period
    function contributionIdsInPeriod(uint32 periodId) external view returns (bytes32[] memory);

    /// @notice convert a Description struct into its' respective bytes
    function encodeDescription(Description memory description) external pure returns (bytes memory);

    /// @notice convert a Contribution struct to its' encoded type to hash / events
    function encodeContribution(Contribution memory contribution) external pure returns (bytes memory);

    /// Hash a Description to get its' unique identifier
    function calcDescriptionId(Description memory description) external pure returns (bytes32);

    /// @notice hash a Contribution to get it's unique identifier
    function calcContributionId(Contribution memory contribution) external pure returns (bytes32);
}
