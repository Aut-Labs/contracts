//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IDAOExpander.sol";

import "../membershipCheckers/IDAOTypes.sol";
import "../membershipCheckers/IMembershipChecker.sol";

import "../daoUtils/abstracts/DAOUrls.sol";
import "../daoUtils/abstracts/DAOMembers.sol";
import "../daoUtils/abstracts/DAOModules.sol";
import "../daoUtils/abstracts/DAOMetadata.sol";
import "../daoUtils/abstracts/DAOCommitment.sol";
import "../daoUtils/abstracts/DAOMarket.sol";
import "../daoUtils/abstracts/DAOInteractions.sol";
import "../daoUtils/abstracts/AutIDAddress.sol";
import "../expander/interfaces/IDAOExpander.sol";
import "../modules/onboarding/OnboardingModule.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract DAOExpander is
    AutIDAddress,
    DAOMembers,
    DAOUrls,
    DAOMetadata,
    DAOInteractions,
    DAOCommitment,
    DAOMarket,
    DAOModules,
    IDAOExpander
{
    /// @notice the basic DAO data
    DAOExpanssionData daoData;

    /// @notice the address of the DAOTypes.sol contract
    IDAOTypes private daoTypes;
    address private onboardingAddr;

    /// @notice Sets the initial details of the DAO
    /// @dev all parameters are required.
    /// @param _deployer the address of the DAOTypes.sol contract
    /// @param _autAddr the address of the DAOTypes.sol contract
    /// @param _daoTypes the address of the DAOTypes.sol contract
    /// @param _daoType the type of the membership. It should exist in DAOTypes.sol
    /// @param _daoAddr the address of the original DAO contract
    /// @param _market one of the 3 markets
    /// @param _metadata url with metadata of the DAO - name, description, logo
    /// @param _commitment minimum commitment that the DAO requires
    constructor(
        address _deployer,
        address _autAddr,
        address _daoTypes,
        uint256 _daoType,
        address _daoAddr,
        uint256 _market,
        string memory _metadata,
        uint256 _commitment,
        address _pluginRegistry
    ) {
        require(_daoAddr != address(0), "Missing DAO Address");
        require(address(_daoTypes) != address(0), "Missing DAO Types address");
        require(
            IDAOTypes(_daoTypes).getMembershipCheckerAddress(_daoType) !=
                address(0),
            "Invalid membership type"
        );
        require(
            IMembershipChecker(
                IDAOTypes(_daoTypes).getMembershipCheckerAddress(_daoType)
            ).isMember(_daoAddr, _deployer),
            "AutID: Not a member of this DAO!"
        );
        daoData = DAOExpanssionData(_daoType, _daoAddr);

        isAdmin[_deployer] = true;
        admins.push(_deployer);
        daoTypes = IDAOTypes(_daoTypes);

        super._setMarket(_market);
        super._setAutIDAddress(IAutID(_autAddr));
        super._setCommitment(_commitment);
        super._setMetadataUri(_metadata);
        super._deployInteractions();
        super._setPluginRegistry(_pluginRegistry);
    }

    function setOnboardingStrategy(address onboardingPlugin) public onlyAdmin {
        onboardingAddr = onboardingPlugin;
    }

    function join(address newMember, uint256 role) public override onlyAutID {
        require(canJoin(newMember, role), "not allowed");
        super.join(newMember, role);
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfOriginalDAO(
        address member
    ) public view override returns (bool) {
        return
            IMembershipChecker(
                IDAOTypes(daoTypes).getMembershipCheckerAddress(
                    daoData.contractType
                )
            ).isMember(daoData.daoAddress, member);
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function canJoin(
        address member,
        uint256 role
    ) public view override(IDAOMembership) returns (bool) {
        if (onboardingAddr == address(0)) {
            return
                isMemberOfOriginalDAO(member) ||
                (onboardingAddr != address(0) &&
                    OnboardingModule(onboardingAddr).isActive() &&
                    OnboardingModule(onboardingAddr).isOnboarded(member, role));
        } else {
            if (
                onboardingAddr != address(0) &&
                OnboardingModule(onboardingAddr).isActive()
            ) return false;
            else
                return
                    OnboardingModule(onboardingAddr).isOnboarded(member, role);
        }
    }

    function activateModule(uint moduleId) public override onlyAdmin {
        _activateModule(moduleId);
    }

    function getDAOData()
        public
        view
        override
        returns (DAOExpanssionData memory data)
    {
        return daoData;
    }

    function addURL(string memory url) external override onlyAdmin {
        _addURL(url);
    }

    function removeURL(string memory url) external override onlyAdmin {
        _removeURL(url);
    }

    function setCommitment(uint256 commitment) external override onlyAdmin {
        _setCommitment(commitment);
    }

    function setMetadataUri(
        string memory metadata
    ) external override onlyAdmin {
        _setMetadataUri(metadata);
    }
}
