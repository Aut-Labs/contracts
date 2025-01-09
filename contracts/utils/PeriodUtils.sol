//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {IPeriodUtils} from "./interfaces/IPeriodUtils.sol";

contract PeriodUtils is IPeriodUtils {
    struct PeriodUtilsStorage {
        uint32 initTimestamp;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.PeriodUtils")) - 1))
    bytes32 private constant PeriodUtilsStorageLocation =
        0xbb30d154f2784c70f43e6e03f8bf8078407501460b7616d04bf445b7588c175a;

    function _getPeriodUtilsStorage() private pure returns (PeriodUtilsStorage storage $) {
        assembly {
            $.slot := PeriodUtilsStorageLocation
        }
    }

    function _init_PeriodUtils() internal {
        PeriodUtilsStorage storage $ = _getPeriodUtilsStorage();
        $.initTimestamp = uint32(block.timestamp);
    }

    /// @inheritdoc IPeriodUtils
    function currentPeriodStart() public view returns (uint32) {
        return TimeLibrary.periodStart({currentTimestamp: uint32(block.timestamp), initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function currentPeriodEnd() public view returns (uint32) {
        return TimeLibrary.periodEnd({currentTimestamp: uint32(block.timestamp), initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function currentPeriodId() public view returns (uint32) {
        return TimeLibrary.periodId({currentTimestamp: uint32(block.timestamp), initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function periodStart(uint32 timestamp) public view returns (uint32) {
        return TimeLibrary.periodStart({currentTimestamp: timestamp, initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function periodEnd(uint32 timestamp) public view returns (uint32) {
        return TimeLibrary.periodEnd({currentTimestamp: timestamp, initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function periodId(uint32 timestamp) public view returns (uint32) {
        return TimeLibrary.periodId({currentTimestamp: timestamp, initTimestamp: initTimestamp()});
    }

    /// @inheritdoc IPeriodUtils
    function initTimestamp() public view returns (uint32) {
        PeriodUtilsStorage storage $ = _getPeriodUtilsStorage();
        return $.initTimestamp;
    }
}
