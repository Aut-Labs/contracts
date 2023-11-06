// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IAllowlist {
    error Unallowed();
    error AlreadyPlusOne();
    error AlreadyDeployedANova();
    error isAlreadyAllowed();

    event AddedToAllowList(address who);
    event RemovedFromAllowList(address who);

    function isAllowed(address _addr) external view returns (bool);
    function addToAllowlist(address addrToAdd_) external;
    function removeFromAllowlist(address addrToAdd_) external;
    function addBatchToAllowlist(address[] memory addrsToAdd_) external;
    function removeBatchFromAllowlist(address[] memory _addrs) external;
    function addOwner(address owner_) external;
    function isAllowedOwner(address subject) external view returns (bool);
    function plusOne(address) external view returns (address);
    function canAllowList(address subject) external view returns (bool);
    function isOwner(address subject) external view returns (bool);
    function isAllowListed(address subject) external view returns (bool);
}
