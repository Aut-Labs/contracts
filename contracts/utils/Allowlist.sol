// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./IAllowlist.sol";

contract Allowlist is IAllowlist {
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isAllowListed;
    mapping(address => address) public plusOne;

    address deployer;

    constructor() {
        isOwner[msg.sender] = true;
        isAllowListed[msg.sender] = true;
    }

    function isAllowed(address _addr) public view returns (bool) {
        return isAllowListed[_addr];
    }

    /////////// Modifiers
    //////////////////////////////////////
    modifier isSenderOwner() {
        if (msg.sig == this.addToAllowlist.selector && isAllowListed[msg.sender]) {
            if (plusOne[msg.sender] != address(0)) revert AlreadyPlusOne();
            _;
        } else {
            if (!isOwner[msg.sender]) revert Unallowed();
            _;
        }
    }

    /////////// External
    //////////////////////////////////////

    /// @notice adds address to allowlist if user is on the allowlist or owner
    /// @notice allowlisted addresses can only allowlist once and their target cannot allow another in turn
    function addToAllowlist(address addrToAdd_) external isSenderOwner {
        if (isAllowListed[addrToAdd_]) revert isAlreadyAllowed();
        isAllowListed[addrToAdd_] = true;
        if (!isOwner[msg.sender]) {
            plusOne[addrToAdd_] = msg.sender;
            plusOne[msg.sender] = addrToAdd_;
                    emit AddedToAllowList(addrToAdd_);
        }

        emit AddedToAllowList(addrToAdd_);
    }

    //// @notice remvoes address from allowlist if sender is owner
    //// @param addrsToAdd_ addresses to remove
    function removeFromAllowlist(address addrToAdd_) external isSenderOwner {
        isAllowListed[addrToAdd_] = false;
        emit RemovedFromAllowList(addrToAdd_);
    }

    //// @notice adds addresses to allowlist if sender is owner
    //// @param addrsToAdd_ addresses to add
    function addBatchToAllowlist(address[] memory addrsToAdd_) external isSenderOwner {
        uint256 i;
        for (i; i < addrsToAdd_.length;) {
            unchecked {
                ++i;
            }
            if (isAllowListed[addrsToAdd_[i - 1]]) continue;
            isAllowListed[addrsToAdd_[i - 1]] = true;
            emit AddedToAllowList(addrsToAdd_[i - 1]);
        }
    }

    //// @notice removes addresses from allowlist if sender is owner
    //// @param addrs_ addresses to remove
    function removeBatchFromAllowlist(address[] memory addrs_) external isSenderOwner {
        uint256 i;
        for (i; i < addrs_.length;) {
            isAllowListed[addrs_[i]] = false;
            unchecked {
                ++i;
            }
            emit RemovedFromAllowList(addrs_[i]);
        }
    }

    /// @notice add as owner. owner can grant unlimited allowlists
    /// @param owner_ address to add as owner
    function addOwner(address owner_) external isSenderOwner {
        isOwner[owner_] = !isOwner[owner_];
        isAllowListed[owner_] = true;
    }

    /// @notice checks if is owner for protocol maintainance priviledges
    /// @param subject address to check
    function isAllowedOwner(address subject) external view returns (bool) {
        return isOwner[subject];
    }

    /// @notice checks if subject can allowlist another address. It can do so if owner or on allowlist and not already allowlisted another address
    /// @param subject address to check if it can allowlist
    function canAllowList(address subject) external view returns (bool) {
        return (isOwner[subject] || (isAllowListed[subject] && (plusOne[subject] == address(0))));
    }
}
