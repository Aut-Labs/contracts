//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface INova {
    event AdminMemberAdded(address member);
    event AdminMemberRemoved(address member);
    event MetadataUriUpdated();
    // emitted when a member is Onboarded
    event Onboarded(address member, address dao);
    event MarketSet();

    function setOnboardingStrategy(address onboardingPlugin) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this DAO
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url) external view returns (bool);

    function getAutIDAddress() external view returns (address);

    function getInteractionsAddr() external view returns (address);

    function getInteractionsPerUser(address member) external view returns (uint256);

    function getCommitment() external view returns (uint256 commitment);

    function addAdmin(address member) external;

    function removeAdmin(address member) external;
    function setCommitment(uint256 commitment) external;
    function setMetadataUri(string calldata metadata) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function addURL(string memory _url) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev removes URL from the listed ones
    /// @param _url the URL that's going to be removed
    function removeURL(string memory _url) external;

    /////////////////////

    function activateModule(uint256 moduleId) external;
    function canJoin(address member, uint256 role) external view returns (bool);

    //////
    function deployer() external view returns (address);
    function onboardingAddr() external view returns (address);
    function members() external returns (address[] memory);
    function isMember(address) external view returns (bool);
    function admins() external view returns (address[] memory);
    function isAdmin(address) external returns (bool);
    function join(address newMember, uint256 role) external;
    function getAllMembers() external view returns (address[] memory);
    function getAdmins() external view returns (address[] memory);

    //// IModule
    function moduleId() external view returns (uint256);

    function isActive() external view returns (bool);

    /// @notice A plugin contract is deployed for each daoExpander that uses it. When a plugin is associated to a daoExpander, the address is set by the DAOExpander.
    /// @return the address of the daoExpander contract that uses this module.
    function daoAddress() external view returns (address);

    /////////////OnboardingModule /////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice Checks if a member is onboarded for a specific role
    /// @param member The address for whom the check is made
    /// @param role The role for which the member is checked
    /// @return Returns bool, true if the member is onboarded, false - otherwise
    function isOnboarded(address member, uint256 role) external view returns (bool);

    /* 
        The onboard function, marks a member of the community as onboarded. 
        Not every onboarding module would need this implemented. 
        For instance if the onboading strategy is based on holding certain token - there is no need for having this function implemented
        In such cases - Implement by just reverting it.
    */
    /// @notice Onboards a new member if needed.
    /// @param member The member to be onboarded
    /// @param role The role for which the member is onboarded
    function onboard(address member, uint256 role) external;

    function isModuleActivated(uint256 moduleId) external view returns (bool);

    function pluginRegistry() external returns (address);

    function activatedModules() external view returns (uint256[] memory);

    function market() external returns (uint256);

    function getURLs() external view returns (string[] memory);
}
