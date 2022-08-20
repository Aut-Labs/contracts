//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../daoStandards/IColony.sol";

/// @title Colony
/// @notice Mock Colony DAO for testing
contract Colony is IColony {

    address _owner;
    address colonyNetwork;

    constructor(address _colonyNetwork) {
        colonyNetwork = _colonyNetwork;
        _owner = msg.sender;
    }

    function getColonyNetwork() external view override returns (address) {
        return colonyNetwork;
    }

    function owner() external view override returns (address) {
        return _owner;
    }
}

/// @title ColonyNetwork
/// @notice Mock ColonyNetwork for testing
contract ColonyNetwork is IColonyNetwork {

    mapping (address => mapping(bytes32 => address)) extensions; // Colony address > (extension id > extension address)

    function setExtension(bytes32 extensionId, address extension, address colony) external {
        extensions[colony][extensionId] = extension;
    }

    function getExtensionInstallation(bytes32 extensionId, address colony) external override view returns (address) {
        return extensions[colony][extensionId];
    }
}

/// @title ColonyWhitelist
/// @notice Mock ColonyWhitelist for testing
contract ColonyWhitelist is IColonyWhitelist {

    mapping (address => bool) _isApproved;

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        _isApproved[member] = true;
    }

    function isApproved(address member) external view override returns (bool) {
        return _isApproved[member];
    }
}
