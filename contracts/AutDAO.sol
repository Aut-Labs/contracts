//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./daoUtils/abstracts/DAOMembers.sol";
import "./daoUtils/abstracts/DAOInteractions.sol";
import "./daoUtils/abstracts/DAOUrls.sol";
import "./daoUtils/abstracts/AutIDAddress.sol";
import "./daoUtils/abstracts/DAOMetadata.sol";
import "./daoUtils/abstracts/DAOMarket.sol";
import "./daoUtils/abstracts/DAOCommitment.sol";


/// @title AutDAO
/// @notice
/// @dev
contract AutDAO is
    DAOMembers,
    DAOInteractions,
    DAOMetadata,
    DAOUrls,
    DAOMarket,
    DAOCommitment
{
    address private deployer;

    /// @notice Sets the initial details of the DAO
    /// @dev all parameters are required.
    /// @param _deployer the address of the DAOTypes.sol contract
    /// @param _autAddr the address of the DAOTypes.sol contract
    /// @param _market one of the 3 markets
    /// @param _metadata url with metadata of the DAO - name, description, logo
    /// @param _commitment minimum commitment that the DAO requires
    constructor(
        address _deployer,
        address _autAddr,
        uint256 _market,
        string memory _metadata,
        uint256 _commitment
    ) {
        require(_market > 0 && _market < 4, "Invalid market");
        require(bytes(_metadata).length > 0, "Missing Metadata URL");
        require(
            _commitment > 0 && _commitment < 11,
            "Commitment should be between 1 and 10"
        );

        deployer = _deployer;
        isAdmin[_deployer] = true;
        admins.push(_deployer);

        setMarket(_market);
        setAutIDAddress(_autAddr);
        deployInteractions();
        setCommitment(_commitment);
        super.setMetadataUri(_metadata);
    }

    function setMetadataUri(string memory metadata) public override onlyAdmin {
        super.setMetadataUri(metadata);
    }

    function addURL(string calldata _url) public override onlyAdmin {
        super.addURL(_url);
    }

    function setCommitment(uint commitment) public override onlyAdmin {
        super.setCommitment(commitment);
    }
}
