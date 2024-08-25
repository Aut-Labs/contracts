//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IParticipation {
    function initialize(
        address _globalParameters,
        address _membership,
        address _taskManager,
        address _hub,
        address _autId,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external;
}
