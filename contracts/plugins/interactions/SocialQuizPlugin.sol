//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import "./SocialBotPlugin.sol";

contract SocialQuizPlugin is SocialBotPlugin {
    constructor(address nova_) SocialBotPlugin(nova_) {}
}
