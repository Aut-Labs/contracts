//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../interfaces/modules/onboarding/ICooldownOnbaordingPeriod.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract CooldownOnboardingPeriod is ICooldownOnbaordingPeriod {

    uint _cooldownPeriod;

    function _setCooldownPeriod(uint cooldownPeriod)
        internal
    {
         require(
            cooldownPeriod > 0,
            "Cooldown Period should be > 0"
        );

        _cooldownPeriod = cooldownPeriod;
        emit CooldownPeriodSet();
    }

    function getCooldownPeriod() public view override returns(uint) {
        return _cooldownPeriod;
    }


}
