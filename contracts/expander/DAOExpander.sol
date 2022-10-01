//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IDAOExpander.sol";
import "../Interaction.sol";
import "../membershipCheckers/IDAOTypes.sol";
import "../membershipCheckers/IMembershipChecker.sol";

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

    mapping(address => bool) public override isMember;

    /// @notice all the admin members
    address[] private admins;
    /// @notice mapping with the admin members
    mapping(address => bool) public override isAdmin;

    /// @notice the address of the DAOTypes.sol contract
    IDAOTypes private daoTypes;

    address public override autIDAddr;
    
    Interaction public interactions;

    /// @dev Modifier for check of access of the admin member functions
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Not an admin!");
        _;
    }

    /// @dev Modifier for check of access of the admin member functions
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
        require(address(_daoTypes) != address(0), "Missing DAO Types address");
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
        isAdmin[_deployer] = true;
        admins.push(_deployer);
        daoTypes = IDAOTypes(_daoTypes);
        autIDAddr = _autAddr;
        interactions = new Interaction();
    }

    function join(address newMember) public override onlyAutID {
        require(!isMember[newMember], "Already a member");
        require(
            isMemberOfOriginalDAO(newMember),
            "Not a member of the DAO."
        );
        isMember[newMember] = true;
        members.push(newMember);
        emit MemberAdded();
    }

    /// @notice The DAO can connect a discord server to their DAOExpander contract
    /// @dev Can be called only by the admin members
    /// @param discordServer the URL of the discord server
    function setDiscordServer(string calldata discordServer) public onlyAdmin override {
        require(bytes(discordServer).length > 0, "DiscordServer Link Empty!");
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

    // URLs
    /// @notice The listed URLs are the only ones that can be used for the DAuth
    /// @dev adds a URL in the listed ones
    /// @param _url the URL that's going to be added
    function addURL(string memory _url) public override onlyAdmin {
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
    function removeURL(string memory _url) public override onlyAdmin {
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
        return address(interactions);
    }

    function getInteractionsPerUser(address member)
        public
        view
        override
        returns (uint256)
    {
        return
            interactions.getInteractionsIndexPerAddress(member);
    }

    function getDAOData()
        public
        view
        override
        returns (DAOData memory data)
    {
        return daoData;
    }
    function setMetadataUri(string calldata metadata)
        public
        override
        onlyAdmin
    {
        require(bytes(metadata).length > 0, "metadata uri missing");

        daoData.metadata = metadata;
        emit MetadataUriUpdated();
    }


    /// Admins
    function addAdmin(address member) public override onlyAdmin {
        require(isMember[member], "Not a member");
        isAdmin[member] = true;
        admins.push(member);
        emit AdminMemberAdded(member);
    }

    function removeAdmin(address member) public override onlyAdmin {
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == member) {
                admins[i] = address(0);
            }
        }
        isAdmin[member] = false;
        emit AdminMemberRemoved(member);
    }

    function getAdmins() public view override returns (address [] memory ) {
        return admins;
    }
}
