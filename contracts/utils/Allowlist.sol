pragma solidity 0.8.18;

contract Allowlist {
    address private owner;
    mapping(address => bool) private allowlist;

    constructor() {
        owner = msg.sender;
    }

    function isAllowed(address _addr) public view returns (bool) {
        return allowlist[_addr];
    }

    function addToAllowlist(address _addr) public {
        require(
            msg.sender == owner,
            "Only the owner can add to the allowlist."
        );
        allowlist[_addr] = true;
    }

    function removeFromAllowlist(address _addr) public {
        require(
            msg.sender == owner,
            "Only the owner can remove from the allowlist."
        );
        allowlist[_addr] = false;
    }

    function addBatchToAllowlist(address[] memory _addrs) public {
        require(
            msg.sender == owner,
            "Only the owner can add to the allowlist."
        );
        for (uint256 i = 0; i < _addrs.length; i++) {
            allowlist[_addrs[i]] = true;
        }
    }

    function removeBatchFromAllowlist(address[] memory _addrs) public {
        require(
            msg.sender == owner,
            "Only the owner can remove from the allowlist."
        );
        for (uint256 i = 0; i < _addrs.length; i++) {
            allowlist[_addrs[i]] = false;
        }
    }
}
