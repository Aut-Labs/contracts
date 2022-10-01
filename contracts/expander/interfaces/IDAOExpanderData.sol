//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpanderData
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpanderData {
    event MetadataUriUpdated();
    event DiscordServerSet();

    struct DAOData {
        uint256 contractType;
        address daoAddress;
        string metadata;
        uint256 commitment;
        uint256 market;
        string discordServer;
    }

    /// @notice The DAO can connect a discord server to their DAO extension contract
    /// @dev Can be called only by the admin members
    /// @param discordServer the URL of the discord server
    function setDiscordServer(string calldata discordServer) external;

    function setMetadataUri(string calldata metadata) external;

    function getDAOData() external view returns (DAOData memory data);

    function autIDAddr() external view returns (address);

}
