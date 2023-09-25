// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract Allowlist {
    mapping(address => bool) public isOwner;
    mapping(address => bool) allowlist;
    mapping(address => address) plusOne;

    /// @dev @todo
    /// nested - RSPV + 1 limit
    /// admins can

    constructor() {
        isOwner[msg.sender] = true;
        isOwner[0x64385e93DD9E55e7b6b4e83f900c142F1b237ce7] = true;
        isOwner[0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3] = true;
        isOwner[0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43] = true;
    }

    error Unallowed();
    error AlreadyPlusOne();

    event AddedToAllowList(address who);
    event RemovedFromAllowList(address who);

    function isAllowed(address _addr) public view returns (bool) {
        return allowlist[_addr];
    }

    /////////// Modifiers
    //////////////////////////////////////
    modifier isSenderOwner() {
        if (allowlist[msg.sender] && msg.sig == this.addToAllowlist.selector) {
            if (plusOne[msg.sender] != address(0)) revert AlreadyPlusOne();
            _;
        } else {
            if (!isOwner[msg.sender]) revert Unallowed();
            _;
        }
    }

    /////////// External
    //////////////////////////////////////

    function addToAllowlist(address addrToAdd_) external isSenderOwner {
        allowlist[addrToAdd_] = true;
        plusOne[msg.sender] = addrToAdd_;
        plusOne[addrToAdd_] = msg.sender;

        emit AddedToAllowList(addrToAdd_);
    }

    function removeFromAllowlist(address addrToAdd_) external isSenderOwner {
        allowlist[addrToAdd_] = false;
        emit RemovedFromAllowList(addrToAdd_);
    }

    function addBatchToAllowlist(address[] memory addrsToAdd_) external isSenderOwner {
        uint256 i;
        for (i; i < addrsToAdd_.length;) {
            allowlist[addrsToAdd_[i]] = true;
            unchecked {
                ++i;
            }
            emit AddedToAllowList(addrsToAdd_[i]);
        }
    }

    function removeBatchFromAllowlist(address[] memory _addrs) external isSenderOwner {
        uint256 i;
        for (i; i < _addrs.length;) {
            allowlist[_addrs[i]] = false;
            unchecked {
                ++i;
            }
            emit RemovedFromAllowList(_addrs[i]);
        }
    }
}
