//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpander {
    event UrlAdded(string url);
    event UrlRemoved(string url);
    event MetadataUriUpdated();
    event ActivitiesAddressAdded();
    event ActivitiesAddressRemoved();
    event DiscordServerSet();
    event MemberAdded();
    event CoreTeamMemberAdded(address member);
    event CoreTeamMemberRemoved(address member);

    struct Activity {
        address actAddr;
        uint256 actType;
    }

    struct DAOData {
        uint256 contractType;
        address daoAddress;
        string metadata;
        uint256 commitment;
        uint256 market;
        string discordServer;
    }

    /// @notice The DAO can connect a discord server to their DAO extension contract
    /// @dev Can be called only by the core team members
    /// @param discordServer the URL of the discord server
    function setDiscordServer(string calldata discordServer) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function addURL(string memory _url) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev removes URL from the listed ones
    /// @param _url the URL that's going to be removed
    function removeURL(string memory _url) external;

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev returns an array with all the listed urls
    /// @return returns all the urls listed for the DAO
    function getURLs() external view returns (string[] memory);

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this DAO
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url) external view returns (bool);

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfExtendedDAO(address member) external view returns (bool);

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfOriginalDAO(address member) external view returns (bool);

    /// @notice Checks if the passed member is a core team member within the AutID extension of the membership
    /// @param member the address of the member that's checked
    /// @return true if they're a core team member, false otherwise
    function isCoreTeam(address member) external view returns (bool);

    function addToCoreTeam(address member) external;

    function removeFromCoreTeam(address member) external;

    /// @notice Checks if a specific contract address is listed as Activity
    /// @dev Activity contracts can increase the interaction index of the AutID holders
    /// @param activity the address of the activity that's checked
    /// @return true if the address is listed, false otherwise
    function isActivityWhitelisted(address activity)
        external
        view
        returns (bool);

    function join(address newMember) external;

    function hasPassedOnboarding(address member) external view returns (bool);

    function getAllMembers() external view returns (address[] memory);

    function getInteractionsAddr() external view returns (address);

    function getInteractionsPerUser(address member)
        external
        view
        returns (uint256);

    function getDAOData() external view returns (DAOData memory data);

    function autIDAddr() external view returns (address);

    function getActivitiesWhitelist()
        external
        view
        returns (Activity[] calldata);

    function addActivitiesAddress(address activityAddr, uint256 activityType)
        external;

    function removeActivitiesAddress(address activityAddr) external;

    function setMetadataUri(string calldata metadata) external;

    function getCoreTeamWhitelist() external view returns (address[] memory);
}
