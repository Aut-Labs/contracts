//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHub {
    error AdminCannotRenounceSelf();
    error AlreadyAdmin();
    error CannotRemoveNonAdmin();
    error NotDeployer();
    error NotAdmin();
    error NotMember();
    error MemberDoesNotExist();
    error SameCommitmentLevel();
    error InvalidCommitmentLevel();
    error InvalidTaskContributionPoints();
    error InvalidTaskQuantity();
    error InvalidTaskId();
    error InvalidTaskInteractionId();
    error InvalidPeriodId();
    error TaskNotActive();
    error MemberHasNotYetCommited();
    error PeriodAlreadySealed();
    error UnequalLengths();
    error ConstraintFactorOutOfRange();
    event SetConstraintFactor(uint128 oldConstraintFactor, uint128 newConstraintFactor);

    event AdminGranted(address to, address where);
    event AdminRenounced(address from, address where);
    event MemberGranted(address to, uint256 role);
    event ArchetypeSet(uint8 parameter);
    event ParameterSet(uint8 num, uint8 value);
    event UrlAdded(string);
    event UrlRemoved(string);
    event MetadataUriSet(string);
    event OnboardingSet(address);
    event MarketSet(uint256);
    event CommitmentSet(uint256);
    event ChangeCommitmentLevel(address indexed who, uint32 oldCommitmentLevel, uint32 newCommitmentLevelLevel);
    error PenaltyFactorOutOfRange();
    event SetPenaltyFactor(uint128 oldPenaltyFactor, uint128 newPenaltyFactor);

    function initialize(
        address _initialOwner,
        address _hubDomainsRegistry,
        address _taskRegistry,
        address _globalParameters,
        uint256[] calldata roles_,
        uint256 _market,
        uint256 _commitment,
        string memory _metadataUri
    ) external;

    function initialize2(
        address _taskFactory,
        address _taskManager,
        address _participation,
        address _membership
    ) external;

    // State variables

    function hubDomainsRegistry() external view returns (address);
    function taskRegistry() external view returns (address);
    function globalParameters() external view returns (address);
    function participation() external view returns (address);
    function membership() external view returns (address);
    function taskFactory() external view returns (address);
    function taskManager() external view returns (address);
    function archetype() external view returns (uint256);
    function commitmentLevel() external view returns (uint256);
    function market() external view returns (uint256);
    function uri() external view returns (string memory);

    // Mutative

    /// @notice Member joins a hub
    /// @dev must be called through AutID
    /// @dev modifies storage of Membership
    function join(address who, uint256 role, uint8 _commitment) external;

    // Admin-management

    /// @notice return the array of admins
    function admins() external view returns (address[] memory);

    /// @notice return true if address is an admin, else false
    function isAdmin(address who) external view returns (bool);

    /// @notice add an array of admins to the hub
    /// @dev must be called by an existing admin
    function addAdmins(address[] calldata whos) external;

    /// @notice add an admin to the hub
    /// @dev must be called by an existing admin
    function addAdmin(address who) external;

    /// @notice remove an admin from the hub
    /// @dev admin cannot remove self
    /// @dev must be called by an existing admin
    function removeAdmin(address who) external;

    // Views

    /// @notice return the number of members of the hub
    function membersCount() external view returns (uint256);

    /// @notice return true if an address is a member of the hub, else false
    function isMember(address who) external view returns (bool);

    /// @notice return the array of roles existing for the hub
    function roles() external view returns (uint256[] memory);

    /// @notice Get the current role value of a hub member
    function currentRole(address who) external view returns (uint256);

    /// @notice return true if the current role of a member matches the role queried
    function hasRole(address who, uint256 role) external view returns (bool);

    /// @notice utility to determine if an address is able to join the hub with the specified role
    /// TODO: can add an onboarding module to restrict/specify requirements in joining
    function canJoin(address who, uint256 role) external view returns (bool);

    /// @notice The constraint factor applied to a members score within Participation
    /// @dev defaults to the global constraint factor (set in GlobalParameters) if not set in the hub
    function constraintFactor() external view returns (uint128);

    /// @notice the penalty factor applied to a members score within Participation
    /// @dev defaults to the global penalty factor (set in GlobalParameters) if not set in the hub
    function penaltyFactor() external view returns (uint128);

    // Hub-management

    /// @notice set the hubs constraint factor
    // TODO: describe this in detail
    /// @dev must be called by a hub admin
    /// @dev zero-value defaults to the global constraint factor (set in GlobalParameters)
    function setConstraintFactor(uint128 newConstraintFactor) external;

    /// @notice set the hubs penalty factor
    // TODO: describe this in detail
    /// @dev must be called by a hub admin
    /// @dev zero-value defaults too the global penalty factor (set in GlobalParameters)
    function setPenaltyFactor(uint128 newPenaltyFactor) external;
}
