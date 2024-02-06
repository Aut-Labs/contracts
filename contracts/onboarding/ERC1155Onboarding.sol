//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IOnboarding {
    function isOnboarded(address who, uint256 role) external view returns (bool);
}

interface IRoleOnboarding {
    function isOnboarded(address who) external view returns (bool);
}

contract BasicScoreOnboarding is IOnboarding {
    address[] public roles;

    constructor(address[] memory byRole) {
        for (uint256 i; i != byRole.length; ++i) {
            require(byRole[i] != address(0), "zero address");
            roles.push(byRole[i]);
        }
    }

    function isOnboarded(address who, uint256 roleId) external view returns (bool) {
        address callee = roles[roleId];
        if (roleId < roles.length) {
            return IRoleOnboarding(callee).isOnboarded(who);
        }
        return false;
    }
}

interface IERC1155OnboardingScoreCalculator {
    function calcScoreStatic(
        uint256[] memory ids,
        uint256[] memory params,
        uint256[] memory values
    ) external pure returns (uint256);
}

contract BasicStaticScoreCalculator {
    function calcScoreStatic(
        uint256[] memory,
        uint256[] memory params,
        uint256[] memory values
    ) external pure returns (uint256 result) {
        for (uint256 i; i != values.length; ++i) {
            result += values[i] * params[i];
        }
    }
}

contract ERC1155RoleScoreOnboarding is IRoleOnboarding, Ownable {
    event ActivityStatusSwitched(bool to);
    event InteractionIdAdded(uint256 indexId, uint256 interactionId);
    event InteractionParameterSet(uint256 indexId, uint256 interactionId, uint256 parameterValue);
    event QualifyThresholdSet(uint256 value);

    IERC1155 public immutable globalInteractionsToken;
    IERC1155OnboardingScoreCalculator public scoreCalculator;

    uint256[] public interactionIds;
    uint256[] public interactionParams;

    uint256 public qualifyThreshold;
    bool public isActive;

    constructor(address globalInteractionsToken_, address scoreCalculator_) Ownable(msg.sender) {
        globalInteractionsToken = IERC1155(globalInteractionsToken_);
        scoreCalculator = IERC1155OnboardingScoreCalculator(scoreCalculator_);
    }

    function isOnboarded(address account) external view returns (bool) {
        if (!isActive) {
            return false;
        }
        uint256 cnt = interactionIds.length;
        address[] memory accounts = new address[](cnt);
        for (uint256 i; i != cnt; ++i) {
            accounts[i] = account;
        }
        uint256[] memory ids = interactionIds;
        uint256[] memory values = globalInteractionsToken.balanceOfBatch(accounts, ids);
        // todo: ensure staticcall (or use nonReentrant modifier)
        uint256 score = scoreCalculator.calcScoreStatic(ids, interactionParams, values);
        return score >= qualifyThreshold;
    }

    function switchActivityStatus() external {
        _checkOwner();
        bool toStatus = !isActive;
        require(!toStatus || (qualifyThreshold != 0 && interactionIds.length != 0), "unable to activate");
        isActive = toStatus;
        emit ActivityStatusSwitched(toStatus);
    }

    function setQualifyThreshold(uint256 newThreshold) external {
        _checkOwner();
        require(newThreshold != 0, "zero");
        qualifyThreshold = newThreshold;
        emit QualifyThresholdSet(newThreshold);
    }

    function addInteractionId(uint256 interactionId, uint256 parameterOptional) external {
        _checkOwner();
        uint256 indexId = interactionIds.length + 1;
        interactionIds.push(interactionId);
        interactionParams.push(parameterOptional);
        emit InteractionIdAdded(indexId, interactionId);
        if (parameterOptional != 0) {
            emit InteractionParameterSet(indexId, interactionId, parameterOptional);
        }
    }

    function setInteractionParameterAtIndex(uint256 indexId, uint256 parameterValue) external {
        _checkOwner();
        interactionParams[indexId] = parameterValue;
        uint256 interactionId = interactionIds[indexId];
        emit InteractionParameterSet(indexId, interactionId, parameterValue);
    }
}
