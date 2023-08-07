pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 totalSupply
    ) payable ERC20(name, symbol) {
        _mint(initialAccount, totalSupply);
    }

    function transferInternal(
        address from,
        address to,
        uint256 value
    ) public {
        _transfer(from, to, value);
    }
}
