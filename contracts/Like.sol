//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Like {

    event Liked();

    mapping(address => bool) public isLiked;
   
    function like() public {
        isLiked[msg.sender] = true;
        emit Liked();
    }
}
