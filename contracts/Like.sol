//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@opengsn/contracts/src/ERC2771Recipient.sol";

contract Like is ERC2771Recipient {
    event Liked();

    mapping(address => bool) public isLiked;

    constructor(address trustedForwared) {
        _setTrustedForwarder(trustedForwared);
    }

    function like() public {
        isLiked[_msgSender()] = true;
        emit Liked();
    }
}
