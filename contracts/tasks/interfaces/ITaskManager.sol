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
    error ContributionNotOpen();
    error AlreadyContributionManager();
    error NotContributionManager();
    error UnauthorizedContributionManager();
    error ContributionAlreadyCommitted();
    error ContributionAlreadyGiven();
    error ContributionNotCommitted();

    event AddContributionManager(address who);
    event RemoveContributionManager(address who);
    event AddContribution(
        bytes32 indexed contributionId,
        address indexed sender,
        address indexed hub,
        Status status,
        uint32 points,
        uint128 quantityRemaining
    );
    event RemoveContribution(
        bytes32 indexed contributionId,
        address indexed sender,
        address indexed hub,
        Status status,
        uint32 points,
        uint128 quantityRemaining
    );
    event CommitContribution(
        bytes32 indexed contributionId,
        address indexed sender,
        address indexed hub,
        address who,
        bytes data
    );
    event RevokeContribution(
        bytes32 indexed contributionId,
        address indexed sender,
        address indexed hub,
        address who,
        bytes data
    );
    event GiveContribution(
        bytes32 indexed contributionId,
        address indexed sender,
        address indexed hub,
        uint32 periodId,
        address who,
        Status status,
        uint32 points,
        uint128 quantityRemaining
    );

    /// @notice Set the initial contribution manager from the hub registry
    function initialize2(address _initialContributionManager) external;

    /// @notice Get the amount of outstanding Contribution points for the current period
    function pointsActive() external view returns (uint128);

    /// @notice Get the amount of Contribution points given for the current period
    function periodPointsGiven() external view returns (uint128);

    /// @notice Get the amount of Contribution points removed for the current period
    function periodPointsRemoved() external view returns (uint128);

    // ContributionManager-management

    /// @notice Approve an address to call `commitContribution` and `giveContribution` on behalf of members
    function addContributionManager(address who) external;

    /// @notice Remove an approved address from calling `commitContribution` and `giveContribution` on behalf of members
    function removeContributionManager(address who) external;

    /// @notice Return true if an address is an approved Contribution manager, else false
    function isContributionManager(address who) external view returns (bool);

    /// @notice Return the array of approved Contribution managers
    function contributionManagers() external view returns (address[] memory);

    // Contribution-management

    /// @notice Add a Contribution to the manager
    /// @dev is called via TaskFactory
    function addContribution(bytes32 contributionId, Contribution calldata Contribution) external;

    /// @notice Remove outstanding Contributions from being completed, deeming them Inactive
    function removeContributions(bytes32[] memory contributionIds) external;

    /// @notice Remove an outstanding Contribution from being completed, deeming it Inactive
    function removeContribution(bytes32 contributionId) external;

    /// @notice Commit to a set of open Contributions with associated data
    function commitContributions(
        bytes32[] calldata contributionIds,
        address[] calldata whos,
        bytes[] calldata datas
    ) external;

    /// @notice Commit to an open Contribution with associated data
    function commitContribution(bytes32 contributionId, address who, bytes calldata data) external;

    /// @notice Revoke a set of commits to contributions(commitContribution(s))
    function revokeContributions(
        bytes32[] calldata contributionIds,
        address[] calldata wwhos,
        bytes[] calldata datas
    ) external;

    /// @notice Revoke a commit to contribution (commitContribution())
    function revokeContribution(bytes32 contributionId, address who, bytes calldata data) external;

    /// @notice Give Contribution points to members who have completed the Contribution requirements
    function giveContributions(bytes32[] calldata contributionIds, address[] calldata whos) external;

    /// @notice Give Contribution points to a member who has completed the Contribution requirements
    function giveContribution(bytes32 contributionId, address who) external;

    /// @notice Open method to seal the point summary of a previous period
    function writePointSummary() external;

    /// @notice return the ContributionStatus of a given contributionId
    function getContributionStatus(bytes32 contributionId) external view returns (ContributionStatus memory);

    /// @notice Return the MemberActivity of a given address and periodId
    function getMemberActivity(address who, uint32 periodId) external view returns (MemberActivity memory);

    /// @notice return the amount of points associated to a contributionId
    function getContributionPoints(bytes32 contributionId) external view returns (uint128);

    /// @notice return the amount of points a member has been given for a provided periodId
    function getMemberPointsGiven(address who, uint32 periodId) external view returns (uint128);

    /// @notice return true if a member has been given a specific contributionId
    /// @dev each member can only receive a unique contributionId once
    function isMemberGivenContributionId(address who, bytes32 contributionId) external view returns (bool);

    /// @notice return the contributionId's given to a member across all periods
    function getMemberContributionIds(address who) external view returns (bytes32[] memory);

    /// @notice return the contributionId's given to a member for a provided periodId
    function getMemberContributionIds(address who, uint32 periodId) external view returns (bytes32[] memory);

    /// @notice return the amount of outstanding contribution points for a provided periodId
    function getPointsActive(uint32 periodId) external view returns (uint128);

    /// @notice return the amount of given contribution points for a provided periodId
    function getPointsGiven(uint32 periodId) external view returns (uint128);

    /// @notice return the contributionId's given for the whole hub for a provided periodId
    function getGivenContributions(uint32 periodId) external view returns (bytes32[] memory);
}
