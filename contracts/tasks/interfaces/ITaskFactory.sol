pragma solidity >=0.8.0;

struct Contribution {
    bytes32 taskId;
    uint256 role;
    uint32 startDate;
    uint32 endDate;
    uint32 points;
    uint128 quantity;
    string description;
    // TODO: further identifiers
}

interface ITaskFactory {
    error NotContributionId();
    error TaskIdNotRegistered();
    error ContributionIdAlreadyExists();
    error InvalidContributionQuantity();
    error InvalidContributionPoints();

    event CreateContribution(address indexed sender, bytes32 indexed contributionId, bytes memory encodedContribution);

    /// @notice Create contributions to be tracked by the TaskManager
    /// @return Array of new bytes32 contributionIds (1:1 with contributions)
    function createContributions(Contribution[] calldata contributions) external returns (bytes32[] memory);

    /// @notice Create contribution to be tracked by the TaskManager
    /// @return bytes32 contributionId of the contribution
    function createContribution(Contribution calldata contribution) external returns (bytes32);

    /// @notice Take a Contribution and return its' encoded value for hashing / events
    function encodeContribution(Contribution memory contribution) external pure returns (bytes memory);

    /// @notice Using the unique identifier of a contribution, get the data associated to it
    function getContributionById(bytes32 contributionId) external view returns (Contribution memory);

    /// @notice same as getContributionById but without requiring tuple support for external contracts
    function getContributionByIdEncoded(
        bytes32 contributionId
    )
        external
        view
        returns (
            bytes32 taskId,
            uint256 role,
            uint32 startDate,
            uint32 endDate,
            uint32 points,
            uint128 quantity,
            string memory description
        );

    /// @notice Return true of a unique contribution identifier has been created, else false
    function isContributionId(bytes32 contributionId) external view returns (bool);

    /// @notice return all created contribution identifiers
    function contributionIds() external view returns (bytes32[] memory);
}
