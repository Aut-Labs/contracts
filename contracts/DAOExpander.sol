//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDAOExpander.sol";
import "./Interaction.sol";
import "./membershipCheckers/IDAOTypes.sol";
import "./membershipCheckers/IMembershipChecker.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract DAOExpander is IDAOExpander {

    /// @notice the basic DAO data
    DAOData daoData;

    /// @notice all urls listed for the DAuth
    string[] private urls;

    /// @notice url ids
    mapping(bytes32 => uint256) private urlIds;

    address[] private members;

    mapping(address => bool) public isMemberOfTheDAO;

    /// @notice all the core team members
    address[] private coreTeam;
    /// @notice mapping with the core team members
    mapping(address => bool) public override isCoreTeam;

    /// @notice the address of the DAOTypes.sol contract
    address private daoTypes;
    /// @notice Activities Whitelist
    Activity[] activitiesWhitelist;
    /// @notice Activities Whitelist
    mapping(address => bool) public override isActivityWhitelisted;

    address public override autIDAddr;
    
    address public interactionAddr;

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
        uint256 _commitment
    ) {
        require(_daoAddr != address(0), "Missing DAO Address");
        require(_daoTypes != address(0), "Missing DAO Types address");
        require(_market > 0 && _market < 4, "Invalid market");
        require(bytes(_metadata).length > 0, "Missing Metadata URL");
        require(
            _commitment > 0 && _commitment < 11,
            "Commitment should be between 1 and 10"
        );
        require(
            IDAOTypes(_daoTypes).getMembershipCheckerAddress(
                _daoType
            ) != address(0),
            "Invalid membership type"
        );
        require(
            IMembershipChecker(
                IDAOTypes(_daoTypes).getMembershipCheckerAddress(
                    _daoType
                )
            ).isMember(_daoAddr, _deployer),
            "AutID: Not a member of this DAO!"
        );
        daoData = DAOData(
            _daoType,
            _daoAddr,
            _metadata,
            _commitment,
            _market,
            ""
        );
        isCoreTeam[_deployer] = true;
        coreTeam.push(_deployer);
        daoTypes = _daoTypes;
        autIDAddr = _autAddr;
        interactionAddr = address(new Interaction());
    }

    function join(address newMember) public override onlyAutID {
        require(!isMemberOfTheDAO[newMember], "Already a member");
        require(
            isMemberOfOriginalDAO(newMember),
            "Not a member of the DAO."
        );
        isMemberOfTheDAO[newMember] = true;
        members.push(newMember);
        emit MemberAdded();
    }

    /// @notice The DAO can connect a discord server to their DAOExpander contract
    /// @dev Can be called only by the core team members
    /// @param discordServer the URL of the discord server
    function setDiscordServer(string calldata discordServer) public override {
        require(bytes(discordServer).length > 0, "DiscordServer Link Empty!");
        require(isCoreTeam[msg.sender], "Only owner can edit discord server");
        daoData.discordServer = discordServer;
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
                IDAOTypes(daoTypes).getMembershipCheckerAddress(
                    daoData.contractType
                )
            ).isMember(daoData.daoAddress, member);
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
                IDAOTypes(daoTypes).getMembershipCheckerAddress(
                    daoData.contractType
                )
            ).isMember(daoData.daoAddress, member) || isMemberOfTheDAO[member];
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
    /// @return returns all the urls listed for the DAO
    function getURLs() public view override returns (string[] memory) {
        return urls;
    }

    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev a checker if a url has been listed for this DAO
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

    function getDAOData()
        public
        view
        override
        returns (DAOData memory data)
    {
        return daoData;
    }

    function getActivitiesWhitelist()
        public
        view
        override
        returns (Activity[] memory)
    {
        return activitiesWhitelist;
    }

    function addActivitiesAddress(address activityAddr, uint256 actType)
        public
        override
        onlyCoreTeam
    {
        activitiesWhitelist.push(Activity(activityAddr, actType));
        isActivityWhitelisted[activityAddr] = true;
        emit ActivitiesAddressAdded();
    }

    function removeActivitiesAddress(address activityAddr)
        public
        override
        onlyCoreTeam
    {
        for (uint256 i = 0; i < activitiesWhitelist.length; i++) {
            if (activitiesWhitelist[i].actAddr == activityAddr) {
                activitiesWhitelist[i] = Activity(address(0), 0);
            }
        }
        isActivityWhitelisted[activityAddr] = false;
        emit ActivitiesAddressRemoved();
    }

    function setMetadataUri(string calldata metadata)
        public
        override
        onlyCoreTeam
    {
        require(bytes(metadata).length > 0, "metadata uri missing");

        daoData.metadata = metadata;
        emit MetadataUriUpdated();
    }

    function addToCoreTeam(address member) public override onlyCoreTeam {
        require(isMemberOfTheDAO[member], "Not a member");
        isCoreTeam[member] = true;
        coreTeam.push(member);
        emit CoreTeamMemberAdded(member);
    }

    function removeFromCoreTeam(address member) public override onlyCoreTeam {
        for (uint256 i = 0; i < coreTeam.length; i++) {
            if (coreTeam[i] == member) {
                coreTeam[i] = address(0);
            }
        }
        isCoreTeam[member] = false;
        emit CoreTeamMemberRemoved(member);
    }

    function getCoreTeamWhitelist() public view override returns (address [] memory ) {
        return coreTeam;
    }
}
