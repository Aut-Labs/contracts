//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {ITaskManager} from "./interfaces/ITaskManager.sol";
import {Contribution, Description, ITaskFactory} from "./interfaces/ITaskFactory.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TaskFactory is ITaskFactory, Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _descriptionIds;
    mapping(bytes32 => Description) private _descriptions;

    EnumerableSet.Bytes32Set private _contributionIds;
    mapping(bytes32 => Contribution) public _contributions;
    mapping(uint32 periodId => bytes32[] contributionIds) public _contributionIdsInPeriod;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    /// @inheritdoc ITaskFactory
    function registerDescriptions(Description[] calldata descriptions) external returns (bytes32[] memory) {
        _revertIfNotAdmin();
        uint256 length = descriptions.length;
        bytes32[] memory newDescriptionIds = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            newDescriptionIds[i] = _registerDescription(descriptions[i]);
        }

        return newDescriptionIds;
    }

    /// @inheritdoc ITaskFactory
    function registerDescription(Description calldata description) external returns (bytes32) {
        _revertIfNotAdmin();
        return _registerDescription(description);
    }

    function _registerDescription(Description memory description) internal returns (bytes32) {
        bytes32 descriptionId = calcDescriptionId(description);

        if (!_descriptionIds.add(descriptionId)) revert DescriptionAlreadyRegistered();

        _descriptions[descriptionId] = description;

        emit RegisterDescription(descriptionId);
    }

    /// @inheritdoc ITaskFactory
    function createContributions(Contribution[] calldata contributions) external returns (bytes32[] memory) {
        _revertIfNotAdmin();
        uint256 length = contributions.length;
        bytes32[] memory newContributionIds = new bytes32[](length);
        for (uint256 i = 0; i < length; ) {
            newContributionIds[i] = _createContribution(contributions[i]);
            unchecked {
                ++i;
            }
        }

        return newContributionIds;
    }

    /// @inheritdoc ITaskFactory
    function createContribution(Contribution calldata contribution) external returns (bytes32) {
        _revertIfNotAdmin();
        return _createContribution(contribution);
    }

    function _createContribution(Contribution memory contribution) internal returns (bytes32) {
        if (!ITaskRegistry(taskRegistry()).isTaskId(contribution.taskId)) revert TaskIdNotRegistered();
        if (contribution.quantity == 0) revert InvalidContributionQuantity(); // TODO: max quantity?
        if (contribution.points == 0 || contribution.points > 10) revert InvalidContributionPoints();
        /// @dev: startDate can be in the past but endDate must be in the future
        if (block.timestamp > contribution.endDate || contribution.startDate >= contribution.endDate)
            revert InvalidContributionPeriod();
        // TODO: additional contribution checks

        bytes memory encodedContribution = encodeContribution(contribution);
        bytes32 contributionId = keccak256(encodedContribution);
        if (!_contributionIds.add(contributionId)) revert ContributionIdAlreadyExists();

        _contributions[contributionId] = contribution;
        // TODO: for each period contribution is active, push
        _contributionIdsInPeriod[currentPeriodId()].push(contributionId);

        ITaskManager(taskManager()).addContribution(contributionId, contribution);

        emit CreateContribution({
            contributionId: contributionId,
            sender: msg.sender,
            hub: hub(),
            taskId: contribution.taskId,
            descriptionId: contribution.descriptionId,
            role: contribution.role,
            startDate: contribution.startDate,
            endDate: contribution.endDate,
            points: contribution.points,
            quantity: contribution.quantity
        });

        return contributionId;
    }

    /// @inheritdoc ITaskFactory
    function getContributionIdsBeforeEndDate(uint32 timestamp) external view returns (bytes32[] memory) {
        uint256 length = _contributionIds.length();
        bytes32[] memory tempContributionIds = new bytes32[](length);
        uint256 count;

        for (uint256 i = 0; i < length; i++) {
            bytes32 contributionId = _contributionIds.at(i);
            Contribution storage contribution = _contributions[contributionId];
            if (timestamp < contribution.endDate) {
                tempContributionIds[count++] = contributionId;
            }
        }

        bytes32[] memory result = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = tempContributionIds[i];
        }
        return result;
    }

    /// @inheritdoc ITaskFactory
    function getContributionIdsActive(uint32 timestamp) external view returns (bytes32[] memory) {
        uint256 length = _contributionIds.length();
        bytes32[] memory tempContributionIds = new bytes32[](length);
        uint256 count;

        for (uint256 i = 0; i < length; i++) {
            bytes32 contributionId = _contributionIds.at(i);
            Contribution storage contribution = _contributions[contributionId];
            if (timestamp > contribution.startDate && timestamp < contribution.endDate) {
                tempContributionIds[count++] = contributionId;
            }
        }

        bytes32[] memory result = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = tempContributionIds[i];
        }
        return result;
    }

    /// @inheritdoc ITaskFactory
    function getDescriptionById(bytes32 descriptionId) external view returns (Description memory) {
        return _descriptions[descriptionId];
    }

    /// @inheritdoc ITaskFactory
    function getContributionById(bytes32 contributionId) external view returns (Contribution memory) {
        return _contributions[contributionId];
    }

    /// @inheritdoc ITaskFactory
    function getDescriptionByIdEncoded(bytes32 descriptionId) external view returns (bytes memory) {
        Description memory description = _descriptions[descriptionId];
        return encodeDescription(description);
    }

    /// @inheritdoc ITaskFactory
    function getContributionByIdEncoded(bytes32 contributionId) external view returns (bytes memory) {
        Contribution memory contribution = _contributions[contributionId];
        return encodeContribution(contribution);
    }

    /// @inheritdoc ITaskFactory
    function isDescriptionId(bytes32 descriptionId) public view returns (bool) {
        return _descriptionIds.contains(descriptionId);
    }

    /// @inheritdoc ITaskFactory
    function isContributionId(bytes32 contributionId) public view returns (bool) {
        return _contributionIds.contains(contributionId);
    }

    /// @inheritdoc ITaskFactory
    function descriptionIds() external view returns (bytes32[] memory) {
        return _descriptionIds.values();
    }

    /// @inheritdoc ITaskFactory
    function contributionIds() external view returns (bytes32[] memory) {
        return _contributionIds.values();
    }

    /// @inheritdoc ITaskFactory
    function contributionIdsInPeriod(uint32 periodId) external view returns (bytes32[] memory) {
        return _contributionIdsInPeriod[periodId];
    }

    /// @inheritdoc ITaskFactory
    function encodeDescription(Description memory description) public pure returns (bytes memory) {
        return abi.encodePacked(description.uri);
    }

    /// @inheritdoc ITaskFactory
    function encodeContribution(Contribution memory contribution) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                contribution.taskId,
                contribution.descriptionId,
                contribution.role,
                contribution.startDate,
                contribution.endDate,
                contribution.points,
                contribution.quantity
            );
    }

    /// @inheritdoc ITaskFactory
    function calcDescriptionId(Description memory description) public pure returns (bytes32) {
        return keccak256(encodeDescription(description));
    }

    /// @inheritdoc ITaskFactory
    function calcContributionId(Contribution memory contribution) public pure returns (bytes32) {
        return keccak256(encodeContribution(contribution));
    }
}
