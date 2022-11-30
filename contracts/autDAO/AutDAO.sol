//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../daoUtils/abstracts/DAOMembers.sol";
import "../daoUtils/abstracts/DAOInteractions.sol";
import "../daoUtils/abstracts/DAOUrls.sol";
import "../daoUtils/abstracts/AutIDAddress.sol";
import "../daoUtils/abstracts/DAOMetadata.sol";
import "../daoUtils/abstracts/DAOMarket.sol";
import "../daoUtils/abstracts/DAOCommitment.sol";
import "./interfaces/IAutDAO.sol";

/// @title AutDAO
/// @notice
/// @dev
contract AutDAO is
    DAOMembers,
    DAOInteractions,
    DAOMetadata,
    DAOUrls,
    DAOMarket,
    DAOCommitment,
    IAutDAO
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
        IAutID _autAddr,
        uint256 _market,
        string memory _metadata,
        uint256 _commitment
    ) {
        require(_market > 0 && _market < 4, "Market invalid");
        require(bytes(_metadata).length > 0, "Missing Metadata URL");
        require(
            _commitment > 0 && _commitment < 11,
            "Commitment should be between 1 and 10"
        );

        deployer = _deployer;
        isAdmin[_deployer] = true;
        admins.push(_deployer);

        super._setMarket(_market);
        super._setAutIDAddress(_autAddr);
        super._setCommitment(_commitment);
        super._setMetadataUri(_metadata);
        super._deployInteractions();
    }

    function setMetadataUri(string memory metadata) public override onlyAdmin {
        _setMetadataUri(metadata);
    }
    function addURL(string memory url)
        external
        override
        onlyAdmin
    {
        _addURL(url);
    }

    function removeURL(string memory url)
        external
        override
        onlyAdmin
    {
        _removeURL(url);
    }

    function setCommitment(uint256 commitment)
        external
        override
        onlyAdmin
    {
        _setCommitment(commitment);
    }

    function canJoin(address member)
        external
        view
        override
        returns (bool)
    {
        // check onboarding
        return true;
    }

    
}
