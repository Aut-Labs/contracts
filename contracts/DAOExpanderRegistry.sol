//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./DAOExpander.sol";

contract DAOExpanderRegistry {
    event DAOExpanderDeployed(address newDAOExpander);

    mapping(address => address[]) daoExpanderDeployers;
     
    address[] public daoExpanders;
    address public autIDAddr;
    address public daoTypes;

    constructor(address _autIDAddr, address _daoTypes) {
        require(_autIDAddr != address(0), "AutID Address not passed");
        require(_daoTypes != address(0), "DAOTypes Address not passed");

        autIDAddr = _autIDAddr;
        daoTypes = _daoTypes;
    }

    /**
     * @dev Deploys a community extension
     * @return _communityAddress the newly created Community address
     **/
    function deployDAOExpander(
        uint256 daoType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) public returns (address _communityAddress) {
        require(
            DAOTypes(daoTypes).getMembershipCheckerAddress(
                daoType
            ) != address(0),
            "DAO Type incorrect"
        );
        require(daoAddr != address(0), "Missing DAO Address");
        require(market > 0 && market < 4, "Invalid market");
        require(bytes(metadata).length > 0, "Metadata URL empty");
        require(commitment > 0 && commitment < 11, "Invalid commitment");
        require(
            IMembershipChecker(
                DAOTypes(daoTypes).getMembershipCheckerAddress(
                    daoType
                )
            ).isMember(daoAddr, msg.sender),
            "AutID: Not a member of this DAO!"
        );
        DAOExpander newDAOExpander = new DAOExpander(
            msg.sender,
            autIDAddr,
            daoTypes,
            daoType,
            daoAddr,
            market,
            metadata,
            commitment
        );
        address newDAOExpanderAddress = address(newDAOExpander);
        daoExpanders.push(newDAOExpanderAddress);
        daoExpanderDeployers[msg.sender].push(newDAOExpanderAddress);

        emit DAOExpanderDeployed(newDAOExpanderAddress);

        return newDAOExpanderAddress;
    }

    function getDAOExpanders() public view returns (address[] memory) {
        return daoExpanders;
    }

    function getDAOExpandersByDeployer(address deployer) public view returns(address[] memory) {
        return daoExpanderDeployers[deployer];
    }
}
