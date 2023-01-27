//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAutDAOFactory.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

contract AutDAORegistry is ERC2771Recipient {
    event AutDAODeployed(address newAutDAO);

    mapping(address => address[]) autDAODeployers;
     
    address[] public autDAOs;
    address public autIDAddr;
    IAutDAOFactory private autDAOFactory;
    address public pluginRegistry;

    constructor(address trustedForwarder, address _autIDAddr, address _autDAOFactory, address _pluginRegistry) {
        require(_autIDAddr != address(0), "AutID Address not passed");
        require(_autDAOFactory != address(0), "AutDAOFactory address not passed");
        require(_pluginRegistry != address(0), "PluginRegistry address not passed");

        autIDAddr = _autIDAddr;
        autDAOFactory = IAutDAOFactory(_autDAOFactory);
        _setTrustedForwarder(trustedForwarder);
        pluginRegistry = _pluginRegistry;
    }

    /**
     * @dev Deploys a DAO Expander
     * @return _newAutDAO the newly created DAO Expander address
     **/
    function deployAutDAO(
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) public returns (address _newAutDAO) {
        require(market > 0 && market < 4, "Market invalid");
        require(bytes(metadata).length > 0, "Missing Metadata URL");
        require(commitment > 0 && commitment < 11, "Invalid commitment");
        address newAutDAOAddress = autDAOFactory.deployAutDAO(
            _msgSender(),
            autIDAddr,
            market,
            metadata,
            commitment,
            pluginRegistry
        );
        autDAOs.push(newAutDAOAddress);
        autDAODeployers[_msgSender()].push(newAutDAOAddress);

        emit AutDAODeployed(newAutDAOAddress);

        return newAutDAOAddress;
    }

    function getAutDAOs() public view returns (address[] memory) {
        return autDAOs;
    }

    function getAutDAOByDeployer(address deployer) public view returns(address[] memory) {
        return autDAODeployers[deployer];
    }
}
