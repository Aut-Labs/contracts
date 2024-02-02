//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IGlobalParameters.sol";

contract GlobalParameters is IGlobalParameters, OwnableUpgradeable {
    // slot 1
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
    // end of slot 1

    // timestamps
    // slots 2-3
    uint64 public steepnessDegree3ExpExpiresAt;
    uint64 public penaltyFactor3ExpExpiresAt;
    uint64 public periodDurationExpiresAt;
    uint64 public constrainingFactor6ExpExpiresAt;
    uint64 public credibleNeutrality6ExpExpiresAt;
    // slot 3

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

    function commitPeriodDuration() external {
        uint64 delayedUntil = periodDurationExpiresAt;
        if (delayedUntil == 0) {
            revert CommitFailed("periodDuration", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert CommitFailed("periodDuration", "delay not expired");
        }

        periodDuration = periodDurationStaged;
        periodDurationExpiresAt = 0;

        emit PeriodDurationCommitted();
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

    function commitSteepnessDegree3Exp() external {
        uint64 delayedUntil = steepnessDegree3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert CommitFailed("steepnessDegree3Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert CommitFailed("steepnessDegree3Exp", "delay not expired");
        }

        steepnessDegree3Exp = steepnessDegree3ExpStaged;
        steepnessDegree3ExpExpiresAt = 0;

        emit SteepnessDegree3ExpCommitted();
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

    function commitPenaltyFactor3Exp() external {
        uint64 delayedUntil = penaltyFactor3ExpExpiresAt;
        if (delayedUntil == 0) {
            revert CommitFailed("penaltyFactor3Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert CommitFailed("penaltyFactor3Exp", "delay not expired");
        }

        penaltyFactor3Exp = penaltyFactor3ExpStaged;
        penaltyFactor3ExpExpiresAt = 0;

        emit PenaltyFactor3ExpCommitted();
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
            revert UnstageFailed(
                "constrainingFactor6Exp",
                "nothing to unstage"
            );
        }
        if (uint64(block.timestamp) > delayedUntil) {
            revert UnstageFailed("constrainingFactor6Exp", "too late");
        }

        constrainingFactor6ExpExpiresAt = 0;

        emit ConstrainingFactor6ExpUnstaged();
    }

    function commitConstrainingFactor6Exp() external {
        uint64 delayedUntil = constrainingFactor6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert CommitFailed("constrainingFactor6Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert CommitFailed("constrainingFactor6Exp", "delay not expired");
        }

        constrainingFactor6Exp = constrainingFactor6ExpStaged;
        constrainingFactor6ExpExpiresAt = 0;

        emit ConstrainingFactor6ExpCommitted();
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

    function commitCredibleNeutrality6Exp() external {
        uint64 delayedUntil = credibleNeutrality6ExpExpiresAt;
        if (delayedUntil == 0) {
            revert CommitFailed("credibleNeutrality6Exp", "nothing staged");
        }
        if (uint64(block.timestamp) <= delayedUntil) {
            revert CommitFailed("credibleNeutrality6Exp", "delay not expired");
        }

        credibleNeutrality6Exp = credibleNeutrality6ExpStaged;
        credibleNeutrality6ExpExpiresAt = 0;

        emit CredibleNeutrality6ExpCommitted();
    }

    uint256[47] private __gap;
}
