// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vesting Claiming Contract Interface
 * @notice Interface for the VestingClaimingContract
 */
interface IVestingClaimingContract {
    /**
     * @notice Sets the working status of the contract
     * @param isWorking The updated working status
     */
    function setWorking(bool isWorking) external;

    /**
     * @notice Claims tokens for the caller based on the specified template name
     * @param templateName The name of the template used for claiming
     */
    function claimTokensForBeneficiary(string memory templateName) external;

    /**
     * @notice Claims tokens for ICO
     */
    function claimTokensForICO() external;
}