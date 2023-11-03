//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

    function getCommitment() external view returns (uint256 commitment);

    function addAdmin(address member) external;
    function addAdmins(address[] memory adminAddr) external returns (address[] memory);

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
    function isMember(address) external view returns (bool);
    function isAdmin(address) external returns (bool);
    function join(address newMember, uint256 role) external;
    function getAllMembers() external view returns (address[] memory);
    function getAdmins() external view returns (address[] memory);

    /////////////OnboardingModule /////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    function isModuleActivated(uint256 moduleId) external view returns (bool);

    function pluginRegistry() external returns (address);

    function market() external returns (uint256);

    function getURLs() external view returns (string[] memory);

    function memberCount() external view returns (uint256);
}
