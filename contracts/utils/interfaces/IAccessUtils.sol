//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IAccessUtils {
    function hub() external view returns (address);
    function autId() external view returns (address);
    function isAdmin(address) external view returns (bool);
}
