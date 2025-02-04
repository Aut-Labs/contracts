// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CustomOwnable
 * @dev Extension of OpenZeppelin's Ownable contract that disables the renounceOwnership function.
 */
contract CustomOwnable is Ownable {

    error ThisFeatureIsDisabled();
    /**
     * @dev Overrides the renounceOwnership function to disable it.
     * This function will revert with a custom error message when called.
     * This is done to ensure the contract always has an owner.
     */

    constructor(address initialOwner) Ownable(initialOwner){
        
    }

    function renounceOwnership() public view override onlyOwner {
        revert ThisFeatureIsDisabled();
    }
}