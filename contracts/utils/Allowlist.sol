// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Allowlist {
    mapping(address => bool) public isOwner;
    mapping(address => bool) allowlist;

    constructor() {
        isOwner[msg.sender] = true;
        isOwner[0x64385e93DD9E55e7b6b4e83f900c142F1b237ce7] = true;
        isOwner[0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3] = true;
        isOwner[0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43] = true;

        allowlist[msg.sender] = true;
        allowlist[0x64385e93DD9E55e7b6b4e83f900c142F1b237ce7] = true;
        allowlist[0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3] = true;
        allowlist[0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43] = true;
    }

    error Unallowed();

    event AddedToAllowList(address who);
    event RemovedFromAllowList(address who);

    function isAllowed(address _addr) public view returns (bool) {
        return allowlist[_addr];
    }

    modifier isSenderOwner() {
        if (!(isAllowed(msg.sender))) revert Unallowed();
        _;
    }

    function addToAllowlist(address _addr) public isSenderOwner {
        allowlist[_addr] = true;
        emit AddedToAllowList(_addr);
    }

    function removeFromAllowlist(address _addr) public isSenderOwner {
        allowlist[_addr] = false;
        emit RemovedFromAllowList(_addr);
    }

    function addBatchToAllowlist(address[] memory _addrs) public isSenderOwner {
        uint256 i;
        for (i; i < _addrs.length;) {
            allowlist[_addrs[i]] = true;
            unchecked {
                ++i;
            }
            emit AddedToAllowList(_addrs[i]);
        }
    }

    function removeBatchFromAllowlist(address[] memory _addrs) public isSenderOwner {
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
