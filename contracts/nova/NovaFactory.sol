//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/INovaFactory.sol";
import "./Nova.sol";

contract NovaFactory is INovaFactory {
    function deployNova(
        address deployer,
        address autIDAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment,
        address pluginRegistry
    ) public override returns (address _nova) {
        Nova nova = new Nova(
            deployer,
            IAutID(autIDAddr),
            market,
            metadata,
            commitment,
            pluginRegistry
        );
        return address(nova);
    }
}
