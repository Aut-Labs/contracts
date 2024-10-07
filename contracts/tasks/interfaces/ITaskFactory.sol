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
    error DescriptionAlreadyRegistered();

    event CreateContribution(bytes32 indexed contributionId, address indexed sender, bytes encodedContribution);
    event RegisterDescription(bytes32 indexed descriptionId);

    function registerDescriptions(Description[] calldata descriptions) external returns (bytes32[] memory);
    function registerDescription(Description calldata description) external returns (bytes32);

    /// @notice Create contributions to be tracked by the TaskManager
    /// @return Array of new bytes32 contributionIds (1:1 with contributions)
    function createContributions(Contribution[] calldata contributions) external returns (bytes32[] memory);

    /// @notice Create contribution to be tracked by the TaskManager
    /// @return bytes32 contributionId of the contribution
    function createContribution(Contribution calldata contribution) external returns (bytes32);

    function getContributionIdsBeforeEndDate(uint32 timestamp) external view returns (bytes32[] memory);
    function getContributionIdsActive(uint32 timestamp) external view returns (bytes32[] memory);

    function getDescriptionById(bytes32 descriptionId) external view returns (Description memory);

    /// @notice Using the unique identifier of a contribution, get the data associated to it
    function getContributionById(bytes32 contributionId) external view returns (Contribution memory);

    function getDescriptionByIdEncoded(bytes32 descriptionId) external view returns (bytes memory);

    /// @notice same as getContributionById but without requiring tuple support for external contracts
    function getContributionByIdEncoded(bytes32 contributionId) external view returns (bytes memory);

    function isDescriptionId(bytes32 descriptionId) external view returns (bool);

    /// @notice Return true of a unique contribution identifier has been created, else false
    function isContributionId(bytes32 contributionId) external view returns (bool);

    function descriptionIds() external view returns (bytes32[] memory);

    /// @notice return all created contribution identifiers
    function contributionIds() external view returns (bytes32[] memory);

    /// @notice return all contributions created within a given period
    function contributionsInPeriod(uint32 periodId) external view returns (bytes32[] memory);

    function encodeDescription(Description memory description) external pure returns (bytes memory);

    /// @notice convert a Contribution struct to its' encoded type to hash / events
    function encodeContribution(Contribution memory contribution) external pure returns (bytes memory);

    function calcDescriptionId(Description memory description) external pure returns (bytes32);

    /// @notice hash an encoded contribution to get it's unique identifier
    function calcContributionId(Contribution memory contribution) external pure returns (bytes32);
}
