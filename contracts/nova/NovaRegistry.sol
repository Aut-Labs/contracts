//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/INovaFactory.sol";
import "./interfaces/INovaRegistry.sol";
import "../utils/IAllowlist.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

contract NovaRegistry is ERC2771Recipient, INovaRegistry {
    event NovaDeployed(address nova);

    mapping(address => address[]) novaDeployers;

    address[] public novas;
    address public autIDAddr;
    address public pluginRegistry;
    address deployerAddress;
    INovaFactory private novaFactory;
    IAllowlist AllowList;

    constructor(address trustedForwarder, address _autIDAddr, address _novaFactory, address _pluginRegistry) {
        require(_autIDAddr != address(0), "AutID Address not passed");
        require(_novaFactory != address(0), "NovaFactory address not passed");
        require(_pluginRegistry != address(0), "PluginRegistry address not passed");

        autIDAddr = _autIDAddr;
        novaFactory = INovaFactory(_novaFactory);
        _setTrustedForwarder(trustedForwarder);
        pluginRegistry = _pluginRegistry;
        deployerAddress = msg.sender;
    }

    /// @notice Deploys a new Nova
    /// @dev guarded by allowlist if allowlist address is not address(0)
    /// @return _nova the newly created Nova address

    function deployNova(uint256 market, string calldata metadata, uint256 commitment) public returns (address _nova) {
        require(market > 0 && market < 4, "Market invalid");
        require(bytes(metadata).length > 0, "Missing Metadata URL");
        require(commitment > 0 && commitment < 11, "Invalid commitment");
        if (address(AllowList) != address(0)) {
            if (!AllowList.isAllowed(_msgSender())) revert IAllowlist.Unallowed("Not on list");
            if (!(novaDeployers[_msgSender()].length > 0)) revert IAllowlist.Unallowed("Already Deployed a Nova");
        }
        address novaAddr = novaFactory.deployNova(_msgSender(), autIDAddr, market, metadata, commitment, pluginRegistry);
        novas.push(novaAddr);
        novaDeployers[_msgSender()].push(novaAddr);

        emit NovaDeployed(novaAddr);

        return novaAddr;
    }

    /// @notice changes, activates or deactivates allowlist for deploying new Novae
    /// @param allowListAddress_ in-use allowlist contract address
    /// @dev only deployer can modify allowlist address
    function setAllowListAddress(address allowListAddress_) external {
        if (msg.sender != deployerAddress) revert OnlyDeployer();
        AllowList = IAllowlist(allowListAddress_);
    }

    function getNovas() public view returns (address[] memory) {
        return novas;
    }

    function getNovaByDeployer(address deployer) public view returns (address[] memory) {
        return novaDeployers[deployer];
    }
}
