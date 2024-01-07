// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract GlobalParameters is OwnableUpgradeable {
    /// @dev parameters aren't generalised so each parameter is handled separately 
    /// the reason is that they use multiple data types so 
    /// it would be painful to manage them without generics
    /// although errors are generic 
    error StageFailed(string parameter, string reason);
    error UnstageFailed(string parameter, string reason);
    error ReplaceFailed(string parameter, string reason);

    event PeriodDurationStaged(uint32 valueStaged, uint64 delayedUntil);
    event PeriodDurationUnstaged();
    event PeriodDurationReplaced();

    event SteepnessDegree3ExpStaged (uint32 valueStaged, uint64 delayedUntil);
    event SteepnessDegree3ExpUnstaged();
    event SteepnessDegree3ExpReplaced();

    event PenaltyFactor3ExpStaged (uint16 valueStaged, uint64 delayedUntil);
    event PenaltyFactor3ExpUnstaged();
    event PenaltyFactor3ExpReplaced();


    event ConstrainingFactor6ExpStaged(uint32 valueStaged, uint64 delayedUntil);
    event ConstrainingFactor6ExpUnstaged();
    event ConstrainingFactor6ExpReplaced();

    event CredibleNeutrality6ExpStaged(uint32 valueStaged, uint64 delayedUntil);
    event CredibleNeutrality6ExpUnstaged();
    event CredibleNeutrality6ExpReplaced();

    // value pairs, sorted to be aligned with storage layout
    uint16 public steepnessDegree3Exp;
    uint16 public steepnessDegree3ExpStaged;

    uint16 public penaltyFactor3Exp;
    uint16 public penaltyFactor3ExpStaged;

    uint32 public periodDuration;
    uint32 public periodDurationStaged;

    uint32 public constrainingFactor6Exp;
    uint32 public constrainingFactor6ExpStaged;

    uint32 public credibleNeutrality6Exp;
    uint32 public credibleNeutrality6ExpStaged;

    // timestamps 
    uint64 public steepnessDegree3ExpExpiresAt;
    uint64 public penaltyFactor3ExpExpiresAt;
    uint64 public periodDurationExpiresAt;
    uint64 public constrainingFactor6ExpExpiresAt;
    uint64 public credibleNeutrality6ExpExpiresAt;

    constructor() {}

    /// @dev fill with default values
    function initialize() external initializer {
        periodDuration = 30 * 24 * 60 * 60;
        steepnessDegree3Exp = 300;
        penaltyFactor3Exp = 500;
        constrainingFactor6Exp = 1_400_000;
        credibleNeutrality6Exp = 1_300_000;
    }

    function stagePeriodDuration(uint32 nextPeriodDuration) external {
        _checkOwner();
        if (periodDurationExpiresAt != 0) {
            revert StageFailed("periodDuration", "already staged");
        }

        periodDurationStaged = nextPeriodDuration;
        uint64 delayedUntil = uint64(block.timestamp) + periodDuration;
        periodDurationExpiresAt = delayedUntil;

        emit PeriodDurationStaged(nextPeriodDuration, delayedUntil);
    }

    function unstagePeriodDuration() external {
        _checkOwner();
        uint64 delayedUntil = periodDurationExpiresAt;
        if (delayedUntil == 0) {
            revert UnstageFailed("periodDuration", "nothing staged");
        }
        if (block.timestamp > periodDurationExpiresAt) {
            revert UnstageFailed("periodDuration", "too late");  
        }

        periodDurationExpiresAt = 0;

        emit PeriodDurationUnstaged();
    }

    function replacePeriodDuration() external {
        uint64 delayedUntil = periodDurationExpiresAt;
        if (delayedUntil == 0) {
            revert ReplaceFailed("periodDuration", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert ReplaceFailed("periodDuration", "delay not expired");
        }

        periodDuration = periodDurationStaged;
        periodDurationExpiresAt = 0;

        emit PeriodDurationReplaced();
    }

    function stageSteepnessDegree3Exp(uint16 nextSteepnessDegree3Exp) external {
        _checkOwner();
        if (steepnessDegree3ExpExpiresAt != 0) {
            revert StageFailed("steepnessDegree3Exp", "already staged");
        }

        steepnessDegree3ExpStaged = nextSteepnessDegree3Exp;
        uint64 delayedUntil = uint64(block.timestamp) + periodDuration;
        steepnessDegree3ExpExpiresAt = delayedUntil;

        emit SteepnessDegree3ExpStaged(nextSteepnessDegree3Exp, delayedUntil);
    }

    function unstageSteepnessDegree3Exp() external {
        _checkOwner();
        uint64 delayedUntil = steepnessDegree3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert UnstageFailed("steepnessDegree3Exp", "nothin to unstage");
        }
        if (uint64(block.timestamp) > steepnessDegree3ExpExpiresAt) {
            revert UnstageFailed("steepnessDegree3Exp", "already expired");
        }

        steepnessDegree3ExpExpiresAt = 0;

        emit SteepnessDegree3ExpUnstaged();
    }

    function replaceSteepnessDegree3Exp() external {
        uint64 delayedUntil = steepnessDegree3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert ReplaceFailed("steepnessDegree3Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert ReplaceFailed("steepnessDegree3Exp", "delay not expired");
        }

        steepnessDegree3Exp = steepnessDegree3ExpStaged;
        steepnessDegree3ExpExpiresAt = 0;

        emit SteepnessDegree3ExpReplaced();
    }
    
    function stagePenaltyFactor3Exp(uint16 nextPenaltyFactor3Exp) external {
        _checkOwner();
        if (penaltyFactor3ExpExpiresAt != 0) {
            revert StageFailed("penaltyFactor3Exp", "already staged");
        }

        penaltyFactor3ExpStaged = nextPenaltyFactor3Exp;
        uint64 delayedUntil = uint64(block.timestamp) + periodDuration;
        penaltyFactor3ExpExpiresAt = delayedUntil;

        emit PenaltyFactor3ExpStaged(nextPenaltyFactor3Exp, delayedUntil);
    }

    function unstagePenaltyFactor3Exp() external {
        _checkOwner();
        uint64 delayedUntil = penaltyFactor3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert UnstageFailed("penaltyFactor3Exp", "nothing staged");
        }
        if (uint64(block.timestamp) > delayedUntil) {
            revert UnstageFailed("penaltyFactor3Exp", "too late");
        }

        penaltyFactor3ExpExpiresAt = 0;

        emit PenaltyFactor3ExpUnstaged();
    }

    function replacePenaltyFactor3Exp() external {
        uint64 delayedUntil = penaltyFactor3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert ReplaceFailed("penaltyFactor3Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert ReplaceFailed("penaltyFactor3Exp", "delay not expired");
        }

        penaltyFactor3Exp = penaltyFactor3ExpStaged;
        penaltyFactor3ExpExpiresAt = 0;

        emit PenaltyFactor3ExpReplaced();
    }

    function stageConstrainingFactor6Exp(uint32 valueToStage) external {
        _checkOwner();
        if (constrainingFactor6ExpExpiresAt != 0) {
            revert StageFailed("constrainingFactor6Exp", "already staged");
        }
        
        constrainingFactor6ExpStaged = valueToStage;
        uint64 delayedUntil = uint64(block.timestamp) + periodDuration;
        constrainingFactor6ExpExpiresAt = delayedUntil;

        emit ConstrainingFactor6ExpStaged(valueToStage, delayedUntil);
    }

    function unstageConstrainingFactor6Exp() external {
        _checkOwner();
        uint64 delayedUntil = constrainingFactor6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert UnstageFailed("constrainingFactor6Exp", "nothing to unstage");
        }
        if (uint64(block.timestamp) > delayedUntil) {
            revert UnstageFailed("constrainingFactor6Exp", "too late");
        }

        constrainingFactor6ExpExpiresAt = 0;

        emit ConstrainingFactor6ExpUnstaged();
    }

    function replaceConstrainingFactor6Exp() external {
        uint64 delayedUntil = constrainingFactor6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert ReplaceFailed("constrainingFactor6Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert ReplaceFailed("constrainingFactor6Exp", "delay not expired");
        }

        constrainingFactor6Exp = constrainingFactor6ExpStaged;
        constrainingFactor6ExpExpiresAt = 0;

        emit ConstrainingFactor6ExpReplaced();
    }

    function stageCredibleNeutrality6Exp(uint32 valueToStage) external {
        _checkOwner();
        if (credibleNeutrality6ExpExpiresAt != 0) {
            revert StageFailed("credibleNeutrality6Exp", "already staged");
        }

        credibleNeutrality6ExpStaged = valueToStage;
        uint64 delayedUntil = uint64(block.timestamp) + periodDuration;
        credibleNeutrality6ExpExpiresAt = delayedUntil;

        emit CredibleNeutrality6ExpStaged(valueToStage, delayedUntil);
    }

    function unstageCredibleNeutrality6Exp() external {
        _checkOwner();
        uint64 delayedUntil = credibleNeutrality6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert UnstageFailed("credibleNeutrality6Exp", "nothing staged");
        }
        if (uint64(block.timestamp) > delayedUntil) {
            revert UnstageFailed("credibleNeutrality6Exp", "too late");
        }

        credibleNeutrality6ExpExpiresAt = 0;

        emit CredibleNeutrality6ExpUnstaged();
    }

    function replaceCredibleNeutrality6Exp() external {
        uint64 delayedUntil = credibleNeutrality6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert ReplaceFailed("credibleNeutrality6Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert ReplaceFailed("credibleNeutrality6Exp", "delay not expired");
        }

        credibleNeutrality6Exp = credibleNeutrality6ExpStaged;
        credibleNeutrality6ExpExpiresAt = 0;

        emit CredibleNeutrality6ExpReplaced();
    }
}
