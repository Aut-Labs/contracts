//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../components/abstracts/NovaUrls.sol";
import "../components/abstracts/NovaMarket.sol";
import "../components/abstracts/NovaMembers.sol";
import "../components/abstracts/NovaModules.sol";
import "../components/abstracts/NovaMetadata.sol";
import "../components/abstracts/AutIDAddress.sol";
import "../components/abstracts/NovaCommitment.sol";
import "./NovaUpgradeable.sol";

import "../modules/onboarding/OnboardingModule.sol";
import "./interfaces/INova.sol";

/// @title Nova
/// @notice
/// @dev
contract Nova is NovaUpgradeable, NovaMembers, NovaMetadata, NovaUrls, NovaMarket, NovaModules, NovaCommitment {
    uint256[50] private __basesGap;

    address public deployer;
    address public onboardingAddr;

    /// @notice Sets the initial details of the DAO
    /// @dev all parameters are required.
    /// @param _deployer the address of the DAOTypes.sol contract
    /// @param _autAddr the address of the DAOTypes.sol contract
    /// @param _market one of the 3 markets
    /// @param _metadata url with metadata of the DAO - name, description, logo
    /// @param _commitment minimum commitment that the DAO requires
    function initialize(
        address _deployer,
        IAutID _autAddr,
        uint256 _market,
        string memory _metadata,
        uint256 _commitment,
        address _pluginRegistry
    ) external initializer {
        deployer = _deployer;
        isAdmin[_deployer] = true;
        admins.push(_deployer);
        _setMarket(_market);
        _setAutIDAddress(_autAddr);
        _setCommitment(_commitment);
        _setMetadataUri(_metadata);
        _setPluginRegistry(_pluginRegistry);
    }

    function join(address newMember, uint256 role) public override onlyAutID {
        require(this.canJoin(newMember, role), "not allowed");
        super.join(newMember, role);
    }

    function setOnboardingStrategy(address onboardingPlugin) public {
        require(IModule(onboardingPlugin).moduleId() == 1, "Only Onboarding Plugin");

        if (onboardingAddr == address(0)) {
            require(msg.sender == pluginRegistry, "Only Plugin Registry");
        } else {
            require(NovaMembers(this).isAdmin(msg.sender), "Only Admin");
        }

        onboardingAddr = onboardingPlugin;
    }

    function activateModule(uint256 moduleId) public onlyAdmin {
        _activateModule(moduleId);
    }

    function setMetadataUri(string memory metadata) public onlyAdmin {
        _setMetadataUri(metadata);
    }

    function addURL(string memory url) external onlyAdmin {
        _addURL(url);
    }

    function removeURL(string memory url) external onlyAdmin {
        _removeURL(url);
    }

    function setCommitment(uint256 commitment) external onlyAdmin {
        _setCommitment(commitment);
    }

    function canJoin(address member, uint256 role) external view returns (bool) {
        if (onboardingAddr == address(0)) return true;
        if (onboardingAddr != address(0) && !OnboardingModule(onboardingAddr).isActive()) return false;
        else return OnboardingModule(onboardingAddr).isOnboarded(member, role);
    }

    // 10 total - 2 used slots for this contract itself
    // 50 more for the future abstract base contracts 10 slots each
    // https://en.wikipedia.org/wiki/C3_linearization
    uint256[50 - 2] private __gap;
}
