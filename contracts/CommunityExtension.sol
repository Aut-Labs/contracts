//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ICommunityExtension.sol";
import "./Interaction.sol";
import "./membershipCheckers/MembershipTypes.sol";
import "./membershipCheckers/IMembershipChecker.sol";

/// @title CommunityExtension
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract CommunityExtension is ICommunityExtension {
    event OnboardingPassed(address member);

    /// @notice the basic community data
    CommunityData comData;

    /// @notice all urls listed for the DAuth
    string[] private urls;

    /// @notice url ids
    mapping(bytes32 => uint256) private urlIds;

    address[] private members;

    mapping(address => bool) public isMemberOfTheCom;

    mapping(address => bool) private passedOnboarding;

    /// @notice all the core team members
    address[] private coreTeam;
    /// @notice mapping with the core team members
    mapping(address => bool) public override isCoreTeam;

    /// @notice Activities Whitelist
    Activity[] activitiesWhitelist;
    /// @notice Activities Whitelist
    mapping(address => bool) public override isActivityWhitelisted;

    /// @notice the address of the MembershipTypes.sol contract
    address private membershipTypes;

    address public override autIDAddr;
    address private interactionAddr;

    /// @dev Modifier for check of access of the core team member functions
    modifier onlyCoreTeam() {
        require(isCoreTeam[msg.sender], "Not a core team member!");
        _;
    }

    /// @dev Modifier for check of access of the core team member functions
    modifier onlyAutID() {
        require(msg.sender == autIDAddr, "Only AutID Contract can call this!");
        _;
    }

    /// @notice Sets the initial details of the DAO
    /// @dev all parameters are required.
    /// @param memTypes the address of the MembershipTypes.sol contract
    /// @param contractType the type of the membership. It should exist in MembershipTypes.sol
    /// @param daoAddr the address of the original DAO contract
    /// @param market one of the 3 markets
    /// @param metadata url with metadata of the community - name, description, logo
    /// @param commitment minimum commitment that the community requires
    constructor(
        address deployer,
        address autAddr,
        address memTypes,
        uint256 contractType,
        address daoAddr,
        uint256 market,
        string memory metadata,
        uint256 commitment
    ) {
        require(daoAddr != address(0), "Missing DAO Address");
        require(memTypes != address(0), "Missing memTypes address");
        require(market > 0 && market < 4, "Invalid market");
        require(bytes(metadata).length > 0, "Missing Metadata URL");
        require(
            commitment > 0 && commitment < 11,
            "Commitment should be between 1 and 10"
        );
        require(
            MembershipTypes(memTypes).getMembershipExtensionAddress(
                contractType
            ) != address(0),
            "Invalid membership type"
        );
         require(
            IMembershipChecker(
                MembershipTypes(memTypes).getMembershipExtensionAddress(
                    contractType
                )
            ).isMember(daoAddr, deployer),
            "AutID: Not a member of this DAO!"
        );
        comData = CommunityData(
            contractType,
            daoAddr,
            metadata,
            commitment,
            market,
            ""
        );
        isCoreTeam[deployer] = true;
        coreTeam.push(deployer);
        membershipTypes = memTypes;
        autIDAddr = autAddr;
        interactionAddr = address(new Interaction());
    }

    function hasPassedOnboarding(address member)
        public
        view
        override
        returns (bool)
    {
        return passedOnboarding[member];
    }

    function passOnboarding(address[] calldata members) public onlyCoreTeam {
        for (uint256 index = 0; index < members.length; index++) {
            passedOnboarding[members[index]] = true;
            emit OnboardingPassed(members[index]);
        }
    }

    function join(address newMember) public override onlyAutID {
        require(!isMemberOfTheCom[newMember], "Already a member");
        require(
            isMemberOfOriginalDAO(newMember) || hasPassedOnboarding(newMember),
            "Has not passed onboarding yet."
        );
        isMemberOfTheCom[newMember] = true;
        members.push(newMember);
        emit MemberAdded();
    }

    /// @notice The DAO can connect a discord server to their community extension contract
    /// @dev Can be called only by the core team members
    /// @param discordServer the URL of the discord server
    function setDiscordServer(string calldata discordServer) public override {
        require(bytes(discordServer).length > 0, "DiscordServer Link Empty!");
        require(isCoreTeam[msg.sender], "Only owner can edit discord server");
        comData.discordServer = discordServer;
        emit DiscordServerSet();
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @return true if they're a member, false otherwise
    function getAllMembers() public view override returns (address[] memory) {
        return members;
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfOriginalDAO(address member)
        public
        view
        override
        returns (bool)
    {
        return
            IMembershipChecker(
                MembershipTypes(membershipTypes).getMembershipExtensionAddress(
                    comData.contractType
                )
            ).isMember(comData.daoAddress, member);
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfExtendedDAO(address member)
        public
        view
        override
        returns (bool)
    {
        return
            IMembershipChecker(
                MembershipTypes(membershipTypes).getMembershipExtensionAddress(
                    comData.contractType
                )
            ).isMember(comData.daoAddress, member) || isMemberOfTheCom[member];
    }

    // URLs
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function addURL(string memory _url) public override onlyCoreTeam {
        bytes32 urlHash = keccak256(bytes(_url));
        bool exists = false;
        if (urls.length != 0) {
            if (urlIds[urlHash] != 0 || keccak256(bytes(urls[0])) == urlHash) {
                exists = true;
            }
        }
        require(!exists, "url already exists");

        urlIds[urlHash] = urls.length;
        urls.push(_url);

        emit UrlAdded(_url);
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev removes URL from the listed ones
    /// @param _url the URL that's going to be removed
    function removeURL(string memory _url) public override onlyCoreTeam {
        require(isURLListed(_url), "url doesnt exist");

        bytes32 urlHash = keccak256(bytes(_url));
        uint256 urlId = urlIds[urlHash];

        if (urlId != urls.length - 1) {
            string memory lastUrl = urls[urls.length - 1];
            bytes32 lastUrlHash = keccak256(bytes(lastUrl));

            urlIds[lastUrlHash] = urlId;
            urls[urlId] = lastUrl;
        }

        urls.pop();
        delete urlIds[urlHash];
        emit UrlRemoved(_url);
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev returns an array with all the listed urls
    /// @return returns all the urls listed for the community
    function getURLs() public view override returns (string[] memory) {
        return urls;
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this community
    /// @param _url the url that will be listed
    /// @return true if listed, false otherwise
    function isURLListed(string memory _url)
        public
        view
        override
        returns (bool)
    {
        if (urls.length == 0) return false;

        bytes32 urlHash = keccak256(bytes(_url));

        if (urlIds[urlHash] != 0) return true;
        if (keccak256(bytes(urls[0])) == urlHash) return true;

        return false;
    }

    function getInteractionsAddr() public view override returns (address) {
        return interactionAddr;
    }

    function getInteractionsPerUser(address member)
        public
        view
        override
        returns (uint256)
    {
        return
            Interaction(interactionAddr).getInteractionsIndexPerAddress(member);
    }

    function getComData()
        public
        view
        override
        returns (CommunityData memory data)
    {
        return comData;
    }

    function getActivitiesWhitelist()
        public
        view
        override
        returns (Activity[] memory)
    {
        return activitiesWhitelist;
    }

    function addActivitiesAddress(address activityAddr, uint actType)
        public
        override
        onlyCoreTeam
    {
        activitiesWhitelist.push(Activity(activityAddr, actType));
        isActivityWhitelisted[activityAddr] = true;
        emit ActivitiesAddressAdded();
    }

    function setMetadataUri(string calldata metadata) public override onlyCoreTeam {
        require(bytes(metadata).length > 0, "metadata uri missing");

        comData.metadata = metadata;
        emit MetadataUriUpdated();
    }

    function addToCoreTeam(address member) public onlyCoreTeam override {
        require(isMemberOfTheCom[member], "Not a member");
        isCoreTeam[member] = true;
        coreTeam.push(member);
        emit CoreTeamMemberAdded(member);
    }
}
