pragma solidity >=0.8.0;

import {Contribution} from "./ITaskFactory.sol";

enum Status {
    None,
    Open,
    Inactive,
    Complete
}

struct ContributionStatus {
    Status status;
    uint32 points;
    uint128 quantityRemaining;
}

struct PointSummary {
    bool isSealed;
    uint128 pointsActive;
    uint128 pointsGiven;
    uint128 pointsRemoved;
}

struct MemberActivity {
    uint128 pointsGiven;
    bytes32[] contributionIds;
}

interface ITaskManager {
    error UnequalLengths();
    error MemberAlreadyContributed();
    error ContributionNotOpen();
    error AlreadyContributionManager();
    error NotContributionManager();
    error UnauthorizedContributionManager();

    event AddContributionManager(address who);
    event RemoveContributionManager(address who);
    event AddContribution(bytes32 indexed contributionId, bytes encodedContributionStatus);
    event RemoveContribution(bytes32 indexed contributionId, bytes encodedContributionStatus);
    event CommitContribution(bytes32 indexed contributionId, address indexed sender, address indexed who, bytes data);
    event GiveContribution(
        bytes32 indexed contributionId,
        address indexed who,
        uint32 periodId,
        bytes encodedContributionStatus
    );

    /// @notice Get the amount of outstanding contribution points for the current period
    function pointsActive() external view returns (uint128);

    /// @notice Get the amount of contribution points given for the current period
    function periodPointsGiven() external view returns (uint128);

    /// @notice Get the amount of contribution points removed for the current period
    function periodPointsRemoved() external view returns (uint128);

    function addContributionManager(address who) external;

    function removeContributionManager(address who) external;

    function isContributionManager(address who) external view returns (bool);

    function contributionManagers() external view returns (address[] memory);

    /// @notice Add a contribution to the manager
    /// @dev is called via TaskFactory
    function addContribution(bytes32 contributionId, Contribution calldata contribution) external;

    /// @notice Remove outstanding contributions from being completed, deeming them Inactive
    function removeContributions(bytes32[] memory contributionIds) external;

    /// @notice Remove an outstanding contribution from being completed, deeming it Inactive
    function removeContribution(bytes32 contributionId) external;

    /// @notice Commit to a set of open contributions with associated data
    function commitContributions(
        bytes32[] calldata contributionIds,
        address[] calldata whos,
        bytes[] calldata datas
    ) external;

    /// @notice Commit to an open contribution with associated data
    function commitContribution(bytes32 contributionId, address who, bytes calldata data) external;

    /// @notice Give contribution points to members who have completed the contribution requirements
    function giveContributions(bytes32[] calldata contributionIds, address[] calldata whos) external;

    /// @notice Give contribution points to a member who has completed the contribution requirements
    function giveContribution(bytes32 contributionId, address who) external;

    /// @notice Open method to seal the point summary of a previous period
    function writePointSummary() external;

    function getContributionStatus(bytes32 contributionId) external view returns (ContributionStatus memory);
    function getContributionPoints(bytes32 contributionId) external view returns (uint128);
    function getMemberPointsGiven(address who, uint32 periodId) external view returns (uint128);
    function getMemberContributionIds(address who, uint32 periodId) external view returns (bytes32[] memory);
    function getPointsActive(uint32 periodId) external view returns (uint128);
    function getPointsGiven(uint32 periodId) external view returns (uint128);
}
