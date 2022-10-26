//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpanderData
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpanderData {
    event DiscordServerSet();

    struct DAOExpanssionData {
        uint256 contractType;
        address daoAddress;
    }

    function getDAOData() external view returns (DAOExpanssionData memory data);

}
