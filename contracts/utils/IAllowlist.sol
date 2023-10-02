// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IAllowlist {
    error Unallowed(string);
    error AlreadyPlusOne();
    error AlreadyDepolyedANova();

    event AddedToAllowList(address who);
    event RemovedFromAllowList(address who);

    function isAllowed(address _addr) external view returns (bool);
    function addToAllowlist(address addrToAdd_) external;
    function removeFromAllowlist(address addrToAdd_) external;
    function addBatchToAllowlist(address[] memory addrsToAdd_) external;
    function removeBatchFromAllowlist(address[] memory _addrs) external;
    function addOwner(address owner_) external;
}