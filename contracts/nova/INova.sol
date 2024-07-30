//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../hubContracts/IHubDomainsRegistry.sol";

interface INova {
    error NotDeployer();
    error NotAdmin();
    error NotMember();
    error MemberHasNotYetCommitted();
    error MemberHasNotJoinedHub();
    error SameCommitmentLevel();
    error InvalidCommitmentLevel();
    error InvalidTaskContributionPoints();
    error InvalidTaskQuantity();
    error InvalidTaskId();
    error TaskNotActive();
    error UserHasNotYetCommited();

    event AdminGranted(address to);
    event AdminRenounced(address from);
    event MemberGranted(address to, uint256 role);
    event ArchetypeSet(uint8 parameter);
    event ParameterSet(uint8 num, uint8 value);
    event UrlAdded(string);
    event UrlRemoved(string);
    event MetadataUriSet(string);
    event OnboardingSet(address);
    event MarketSet(uint256);
    event CommitmentSet(uint256);
    event ChangeCommitmentLevel(address indexed who, uint32 oldCommitmentLevel, uint32 newCommitmentLevel);

    function registerDomain(string calldata domain, address novaAddress, string calldata metadataUri) external;
    function getDomain(string calldata domain) external view returns (address, string memory);
    function autID() external view returns (address);
    function pluginRegistry() external view returns (address);
    function onboarding() external view returns (address);

    function archetype() external view returns (uint256);
    function commitment() external view returns (uint256);
    function market() external view returns (uint256);
    function metadataUri() external view returns (string memory);

    function roles(address) external view returns (uint256);
    function currentCommitmentLevels(address) external view returns (uint8);
    function joinedAt(address) external view returns (uint32);
    function parameterWeight(uint256) external view returns (uint256);
    function accountMasks(address) external view returns (uint256);

    function setMetadataUri(string memory) external;

    function setOnboarding(address) external;

    function isUrlListed(string memory) external view returns (bool);

    function addUrl(string memory) external;

    function removeUrl(string memory) external;

    function join(address who, uint256 role, uint8 commitmentLevel) external;

    function canJoin(address who, uint256 role) external view returns (bool);

    function setArchetypeAndParameters(uint8[] calldata input) external;

    function isMember(address who) external view returns (bool);
}
