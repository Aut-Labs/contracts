//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IDAOExpanderFactory.sol";
import "../membershipCheckers/IDAOTypes.sol";
import "../membershipCheckers/IMembershipChecker.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

contract DAOExpanderRegistry is ERC2771Recipient {
    event DAOExpanderDeployed(address newDAOExpander);

    mapping(address => address[]) daoExpanderDeployers;

    address[] public daoExpanders;
    address public autIDAddr;
    address public pluginRegistryAddr;
    IDAOTypes public daoTypes;
    IDAOExpanderFactory private daoExpanderFactory;

    constructor(
        address trustedForwarder,
        address _autIDAddr,
        address _daoTypes,
        address _daoExpanderFactory,
        address _pluginRegistryAddr
    ) {
        require(_autIDAddr != address(0), "AutID Address not passed");
        require(_daoTypes != address(0), "DAOTypes Address not passed");
        require(_daoExpanderFactory != address(0), "DAOExpanderFactory address not passed");
        require(_pluginRegistryAddr != address(0), "PluginRegistry address not passed");

        autIDAddr = _autIDAddr;
        pluginRegistryAddr = _pluginRegistryAddr;
        daoTypes = IDAOTypes(_daoTypes);
        daoExpanderFactory = IDAOExpanderFactory(_daoExpanderFactory);
        _setTrustedForwarder(trustedForwarder);
    }

    /**
     * @dev Deploys a DAO Expander
     * @return _daoExpanderAddress the newly created DAO Expander address
     *
     */
    function deployDAOExpander(
        uint256 daoType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) public returns (address _daoExpanderAddress) {
        require(IDAOTypes(daoTypes).getMembershipCheckerAddress(daoType) != address(0), "DAO Type incorrect");
        require(daoAddr != address(0), "Missing DAO Address");
        require(market > 0 && market < 4, "Market invalid");
        require(bytes(metadata).length > 0, "Missing Metadata URL");
        require(commitment > 0 && commitment < 11, "Invalid commitment");
        require(
            IMembershipChecker(IDAOTypes(daoTypes).getMembershipCheckerAddress(daoType)).isMember(daoAddr, _msgSender()),
            "AutID: Not a member of this DAO!"
        );
        address newDAOExpanderAddress = daoExpanderFactory.deployDAOExpander(
            _msgSender(),
            autIDAddr,
            address(daoTypes),
            daoType,
            daoAddr,
            market,
            metadata,
            commitment,
            pluginRegistryAddr
        );
        daoExpanders.push(newDAOExpanderAddress);
        daoExpanderDeployers[_msgSender()].push(newDAOExpanderAddress);

        emit DAOExpanderDeployed(newDAOExpanderAddress);

        return newDAOExpanderAddress;
    }

    function getDAOExpanders() public view returns (address[] memory) {
        return daoExpanders;
    }

    function getDAOExpandersByDeployer(address deployer) public view returns (address[] memory) {
        return daoExpanderDeployers[deployer];
    }
}
