// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AutIdClaimAllowlist is Ownable {
    event Claimed(address who);
    event ClaimInvitationTransferred(address from, address to);
    event ClaimInvitationIssued(address to, uint256 amount);

    address public immutable controller;
    mapping(address => bool) public hasClaimed;
    mapping(address => uint256) public claimCapacityOf;

    constructor(address controller_) Ownable() {
        controller = controller_;
    }

    function confirmClaim() external {
        require(msg.sender == controller, "Allowlist: only authorized by controller");
        require(
            claimCapacityOf[msg.sender] != 0 && !hasClaimed[msg.sender], "Allowlist: no capacity or has claimed already"
        );
        claimCapacityOf[msg.sender]--;
        hasClaimed[msg.sender] = true;
        emit Claimed(msg.sender);
    }

    function transferClaimInvitationTo(address to) external {
        require(claimCapacityOf[msg.sender] != 0, "Allowlist: nothing to send");
        require(claimCapacityOf[to] == 0 && !hasClaimed[to], "Allowlist: recipient should become eligible in result");
        claimCapacityOf[msg.sender]--;
        claimCapacityOf[to]++;
        emit ClaimInvitationTransferred(msg.sender, to);
    }

    function issueClaimInvitationsBulk(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Allowlist: lengths mismatch");
        for (uint256 i; i != recipients.length; ++i) {
            issueClaimInvitations(recipients[i], amounts[i]);
        }
    }

    function issueClaimInvitations(address to, uint256 amount) public onlyOwner {
        claimCapacityOf[to] += amount;
        emit ClaimInvitationIssued(to, amount);
    }
}
