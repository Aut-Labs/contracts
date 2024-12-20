//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/*
TODO
- should an onboarding task completion still require commit/give flow?
- Should TaskFactory create onboarding contributions? Or OnboardingFactory? Or something else?

*/
contract OnboardingManager {
    // Contributions available for a role to be completed
    mapping(uint256 role => EnumerableSet.Bytes32Set) public roleContributionIds;
    // Amount of contribution points required to accumulate to be onboarded
    mapping(uint256 role => uint256 requiredContributionPoints) public roleRequiredContributionPoints;

    mapping(address user => EnumerableSet.Bytes32Set) private userContributionsCommitted;
    mapping(address user => EnumerableSet.Bytes32Set) private userContributionsGiven;

    function addContribution(
        uint256 role,
        bytes32 contributionId,
        Contribution memory contribution
    ) external pure {}

    function removeContribution(
        uint256 role,
        bytes32 contributionId,
        Contribution memory contribution
    ) external pure {}

    function commitContribution(
        uint256 role,
        bytes32 contributionId,
        address who,
        bytes calldata data
    ) external pure {}

    function giveContribution(
        uint256 role,
        bytes32 contributionId,
        address who
    ) external pure {}

    function isOnboarded(address user, uint256 role) external view returns (bool) {
        return true;
    }
}