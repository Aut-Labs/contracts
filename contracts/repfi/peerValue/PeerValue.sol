// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRandomNumberGenerator} from "../../randomNumberGenerator/IRandomNumberGenerator.sol";
import {IPeerValue} from "./IPeerValue.sol";

contract PeerValue is IPeerValue {
    uint256 constant DEFAULT_LOWER_BOUND = 60;
    uint256 constant DEFAULT_UPPER_BOUND = 200;
    uint256 constant DENOMINATOR = 1000;

    IRandomNumberGenerator public randomNumberGenerator;
    mapping(address account => mapping(uint256 period => PeerValueParams)) private peerValueParams;
    mapping(address account => mapping(uint256 period => uint256 peerValue)) public peerValues;
    mapping(address account => uint256[] periods) periodsForAccount;

    constructor(IRandomNumberGenerator _randomNumberGenerator) {
        randomNumberGenerator = _randomNumberGenerator;
    }

    function getPeerValueParams(address account, uint256 period) external returns (PeerValueParams memory) {
        require(period > 0, "period must be greater than zero");
        require(account != address(0), "account must be valid address");

        // if these values already exist, return them
        if (peerValues[account][period] > 0) {
            return peerValueParams[account][period];
        }

        // check if there is a previous period available for this account
        if (peerValues[account][period - 1] > 0) {
            // if there already is a previous period available, generate the values for this period using the range between +20% and -20% of the previous period and store it
            PeerValueParams memory previousParams = peerValueParams[account][period - 1];
            (uint256 participationScore, uint256 prestige, uint256 a_ring) = randomNumberGenerator
                .getRandomPeerValueParametersForAccount(
                    account,
                    previousParams.participationScore - (((previousParams.participationScore * 20) / 100)),
                    previousParams.participationScore + (((previousParams.participationScore * 20) / 100)),
                    previousParams.prestige - (((previousParams.prestige * 20) / 100)),
                    previousParams.prestige + (((previousParams.prestige * 20) / 100)),
                    previousParams.a_ring - (((previousParams.a_ring * 20) / 100)),
                    previousParams.a_ring + (((previousParams.a_ring * 20) / 100))
                );

            PeerValueParams memory newParams = PeerValueParams(participationScore, prestige, a_ring);
            peerValueParams[account][period] = newParams;
            return newParams;
        } else {
            // if no previous period is available, generate the first parameters using rng contract
            (uint256 participationScore, uint256 prestige, uint256 a_ring) = randomNumberGenerator
                .getRandomPeerValueParametersForAccount(
                    account,
                    DEFAULT_LOWER_BOUND,
                    DEFAULT_UPPER_BOUND,
                    DEFAULT_LOWER_BOUND,
                    DEFAULT_UPPER_BOUND,
                    DEFAULT_LOWER_BOUND,
                    DEFAULT_UPPER_BOUND
                );

            PeerValueParams memory newParams = PeerValueParams(participationScore, prestige, a_ring);
            peerValueParams[account][period] = newParams;
            return newParams;
        }
    }

    function getPeerValue(address account, uint256 period) external returns (uint256) {
        require(period > 0, "period must be greater than zero");
        require(account != address(0), "account must be valid address");
        require(peerValueParams[account][period].participationScore != 0, "peerValueParams do not exist yet");

        // if the peer value already exists, return it
        if (peerValues[account][period] > 0) {
            return peerValues[account][period];
        }

        // calculate peer value, save it and return it
        PeerValueParams memory params = peerValueParams[account][period];
        uint256 peerValue = ((params.participationScore + params.prestige + params.a_ring) * 100) / 3;

        peerValues[account][period] = peerValue;
        periodsForAccount[account].push(period);
        return peerValue;
    }

    function getAge(address account) public view returns (uint256) {
        // return the amount of periods there's a peer value available for this account
        return periodsForAccount[account].length;
    }

    function getGrowthLikelyhood(
        address account,
        int256 estimatedGrowth,
        uint256 duration
    ) external view returns (uint256 highestContinuousSegment, uint256 gLi) {
        uint256 segments = 0;
        uint256 age = getAge(account);
        // ToDo: restrict duration to avoid DOS?
        // we want to check "duration" amount of periods but have to compare to the previous period so we're adding 1 to make sure we don't go out of bounds
        require(age >= duration + 1, "duration is too long compared to the autID age");
        uint256 continuousSegments = 0;

        // take D amount of random segments for the duration and count how many times the growth was equal to or higher than the estimated growth
        for (uint i; i < duration; i++) {
            // using age - duration -1 because we start counting from 0 in the array
            uint256 randomIndex = randomNumberGenerator.getRandomNumberForAccount(account, 0, age - duration - 1);
            uint256 firstPeriod = periodsForAccount[account][randomIndex];
            uint256 lastPeriod = periodsForAccount[account][randomIndex + duration];

            uint256 firstPeerValue = peerValues[account][firstPeriod];
            uint256 lastPeerValue = peerValues[account][lastPeriod];

            if (int256(((lastPeerValue - firstPeerValue) * 100) / firstPeerValue) >= estimatedGrowth) {
                segments++;
                continuousSegments++;
            } else {
                if (continuousSegments > highestContinuousSegment) {
                    highestContinuousSegment = continuousSegments;
                    continuousSegments = 0;
                }
            }
        }

        // check again if the amount of continuous segments is greater than the higestContinuousSegment value
        if (continuousSegments > highestContinuousSegment) {
            highestContinuousSegment = continuousSegments;
        }

        // amount of continuous segments of T of the same extension of D
        // fDgj = (age * DENOMINATOR) / highestContinuousSegment;

        // number of continious segments / total amount of segments where the PeerValue was greater than or equal to the estimatedPeerValue
        gLi = ((age * DENOMINATOR) / highestContinuousSegment) / segments;
    }
}
