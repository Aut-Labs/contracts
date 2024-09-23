//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../IModule.sol";
/* 
The OnboardingModule aims to give the most general structure for onboarding members.  
The required functions are only two - check if an address has been onboarded, and onboard() function that marks them as onboarded. 
If an OnboardingPlugin needs off-chain flow, like social verification, 
this contract can implement additional functions for this off-chain flow using oracles or backends.
*/

/// @title OnboardingModule - interaface
/// @notice Every onboarding plugin must implement this interface
interface OnboardingModule is IModule {
    // emitted when a member is Onboarded
    event Onboarded(address member, address Hub);

    /// @notice Checks if a member is onboarded for a specific role
    /// @param member The address for whom the check is made
    /// @param role The role for which the member is checked
    /// @return Returns bool, true if the member is onboarded, false - otherwise
    function isOnboarded(address member, uint256 role) external view returns (bool);

    /* 
        The onboard function, marks a member of the community as onboarded. 
        Not every onboarding module would need this implemented. 
        For instance if the onboading strategy is based on holding certain token - there is no need for having this function implemented
        In such cases - Implement by just reverting it.
    */
    /// @notice Onboards a new member if needed.
    /// @param member The member to be onboarded
    /// @param role The role for which the member is onboarded
    function onboard(address member, uint256 role) external;
}
