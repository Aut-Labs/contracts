//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/metatx/ERC2771Forwarder.sol";

contract TrustedForwarder is ERC2771Forwarder {
    constructor() ERC2771Forwarder("aut labs") {}
}
