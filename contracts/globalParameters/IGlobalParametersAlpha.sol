//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGlobalParametersAlpha {
    error StageFailed(string parameter, string reason);
    error UnstageFailed(string parameter, string reason);
    error CommitFailed(string parameter, string reason);

    event PeriodDurationStaged(uint32 valueStaged, uint64 delayedUntil);
    event PeriodDurationUnstaged();
    event PeriodDurationCommitted();

    event SteepnessDegree3ExpStaged(uint32 valueStaged, uint64 delayedUntil);
    event SteepnessDegree3ExpUnstaged();
    event SteepnessDegree3ExpCommitted();

    event PenaltyFactor3ExpStaged(uint16 valueStaged, uint64 delayedUntil);
    event PenaltyFactor3ExpUnstaged();
    event PenaltyFactor3ExpCommitted();

    event ConstrainingFactor6ExpStaged(uint32 valueStaged, uint64 delayedUntil);
    event ConstrainingFactor6ExpUnstaged();
    event ConstrainingFactor6ExpCommitted();

    event CredibleNeutrality6ExpStaged(uint32 valueStaged, uint64 delayedUntil);
    event CredibleNeutrality6ExpUnstaged();
    event CredibleNeutrality6ExpCommitted();

    event LocalReputationForPeriod0Staged(uint256 valueStaged, uint64 delayedUntil);
    event LocalReputationForPeriod0Unstaged();
    event LocalReputationForPeriod0Committed();

    event PrestigeForPeriod0Staged(uint256 valueStaged, uint64 delayedUntil);
    event PrestigeForPeriod0Unstaged();
    event PrestiveForPeriod0Committed();

    function period0Start() external view returns (uint32);
    function currentPeriodId() external view returns (uint32);

    function steepnessDegree3Exp() external view returns (uint16);
    function penaltyFactor3Exp() external view returns (uint16);
    function periodDuration() external view returns (uint32);
    function constrainingFactor6Exp() external view returns (uint32);
    function credibleNeutrality6Exp() external view returns (uint32);

    function steepnessDegree3ExpStaged() external view returns (uint16);
    function penaltyFactor3ExpStaged() external view returns (uint16);
    function periodDurationStaged() external view returns (uint32);
    function constrainingFactor6ExpStaged() external view returns (uint32);
    function credibleNeutrality6ExpStaged() external view returns (uint32);

    function steepnessDegree3ExpExpiresAt() external view returns (uint64);
    function penaltyFactor3ExpExpiresAt() external view returns (uint64);
    function periodDurationExpiresAt() external view returns (uint64);
    function constrainingFactor6ExpExpiresAt() external view returns (uint64);
    function credibleNeutrality6ExpExpiresAt() external view returns (uint64);

    function stageSteepnessDegree3Exp(uint16) external;
    function stagePenaltyFactor3Exp(uint16) external;
    function stagePeriodDuration(uint32) external;
    function stageConstrainingFactor6Exp(uint32) external;
    function stageCredibleNeutrality6Exp(uint32) external;

    function unstageSteepnessDegree3Exp() external;
    function unstagePenaltyFactor3Exp() external;
    function unstagePeriodDuration() external;
    function unstageConstrainingFactor6Exp() external;
    function unstageCredibleNeutrality6Exp() external;

    function commitSteepnessDegree3Exp() external;
    function commitPenaltyFactor3Exp() external;
    function commitPeriodDuration() external;
    function commitConstrainingFactor6Exp() external;
    function commitCredibleNeutrality6Exp() external;
}
