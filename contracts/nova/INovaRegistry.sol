// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INovaRegistry {
    function checkNova(address) external view returns(bool);
}
