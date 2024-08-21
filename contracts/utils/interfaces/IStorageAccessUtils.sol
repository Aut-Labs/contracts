//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IStorageAccessUtils {
    function hub() external view returns (address);
    function autID() external view returns (address);
    function isAdmin(address) external view returns (bool);
}