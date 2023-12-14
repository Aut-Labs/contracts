// //SPDX-License-Identifier: MIT

// pragma solidity 0.8.19;

// import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@opengsn/contracts/src/ERC2771Recipient.sol";

// import "./IAutID.sol";
// import "./components/interfaces/get/INovaCommitment.sol";
// import "./components/interfaces/set/INovaMembershipSet.sol";
// import "./components/interfaces/get/INovaMembership.sol";
// import "./membershipCheckers/IMembershipChecker.sol";

// import "./nova/interfaces/INova.sol";

// /// @title AutID
// /// @notice
// /// @dev
// contract AutID is ERC2771Recipient, ERC721URIStorageUpgradeable, ReentrancyGuard, IAutID {
//     using Counters for Counters.Counter;
//     /// @notice

//     Counters.Counter private _tokenIds;

//     // Mapping from token ID to an active  that the AutID holder is a part of
//     mapping(address => mapping(address => NovaMember)) private holderToMembershipData;
//     mapping(address => address[]) holderTos;

//     // Mapping from autIDOwner to token ID
//     mapping(address => uint256) private _autIDByOwner;

//     mapping(string => address) public autIDUsername;

//     /// @notice
//     mapping(uint256 => string) public override autIDToDiscordID;
//     mapping(string => address) public override discordIDToAddress;

//     function initialize(address trustedForwarder) public initializer {
//         __ERC721_init("AutID", "AUT");
//         _setTrustedForwarder(trustedForwarder);
//     }

//     /// @notice AutID holders can link their DiscordID to their AutID ID
//     /// @dev links the discord ID to the AutID token ID passed.
//     /// @param discordID the discord ID of the AutID holder
//     function addDiscordIDToAutID(string calldata discordID) external override {
//         uint256 autID = _autIDByOwner[_msgSender()];

//         autIDToDiscordID[autID] = discordID;
//         discordIDToAddress[discordID] = _msgSender();

//         emit DiscordIDConnectedToAutID();
//     }

//     /// @notice mints a new AutID NFT ID
//     /// @dev each AutID holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the  passed.
//     /// @param url the NFT metadata that holds username, avatar
//     /// @param role the role that the user has selected within the specified
//     /// @param commitment the commitment value that the user has selected for this
//     /// @param Address the address of the Expender contract
//     function mint(string memory username, string memory url, uint256 role, uint256 commitment, address Address)
//         nonReentrant
//         external
//         override
//     {
//         _validateUsername(username);
//         require(bytes(username).length < 17 && bytes(username).length > 0, "Username must be max 16 characters");
//         require(role > 0 && role < 4, "Role must be between 1 and 3");
//         require(commitment > 0 && commitment < 11, "AutID: Commitment should be between 1 and 10");
//         require(Address != address(0), "AutID: Missing ");
//         require(balanceOf(_msgSender()) == 0, "AutID: There is AutID already registered for this address.");
//         require(autIDUsername[username] == address(0), "AutID: Username already taken!");

//         require(INovaMembership(Address).canJoin(_msgSender(), role), "AutID: Not a member of this !");

//         uint256 tokenId = _tokenIds.current();

//         _safeMint(_msgSender(), tokenId);
//         _setTokenURI(tokenId, url);

//         holderToMembershipData[_msgSender()][Address] = NovaMember(Address, role, commitment, true);
//         holderTos[_msgSender()].push(Address);

//         _autIDByOwner[_msgSender()] = tokenId;
//         autIDUsername[username] = _msgSender();
//         _tokenIds.increment();

//         INovaMembershipSet(Address).join(_msgSender(), role);

//         emit AutIDCreated(_msgSender(), tokenId, username);
//         emit NovaJoined(Address, _msgSender());
//     }

//     /// @notice associates an AutID to a new
//     /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other communities
//     /// @param role the role that the user has selected within the specified
//     /// @param commitment the commitment value that the user has selected for this
//     /// @param Address the address of the Address contract
//     function joinNova(uint256 role, uint256 commitment, address Address) external override nonReentrant {
//         require(role > 0 && role < 4, "Role must be between 1 and 3");
//         ///@dev @todo consider if role commitment dependent as initial.
//         require(commitment > 0 && commitment < 11, "AutID: Commitment should be between 1 and 10");
//         require(Address != address(0), "AutID: Missing ");
//         require(balanceOf(_msgSender()) == 1, "AutID: There is no AutID registered for this address.");

//         address[] memory currentComs = holderTos[_msgSender()];
//         for (uint256 index = 0; index < currentComs.length; index++) {
//             require(currentComs[index] != Address, "AutID: Already a member");
//         }

//         require(commitment >= INovaCommitment(Address).getCommitment(), "Commitment lower than the s min commitment");

//         require(INovaMembership(Address).canJoin(_msgSender(), role), "AutID: Not a member of this !");

//         holderToMembershipData[_msgSender()][Address] = NovaMember(Address, role, commitment, true);
//         holderTos[_msgSender()].push(Address);

//         INovaMembershipSet(Address).join(_msgSender(), role);

//         emit NovaJoined(Address, _msgSender());
//     }

//     function withdraw(address Address) external override {
//         require(holderToMembershipData[_msgSender()][Address].isActive, "AutID: Not a member");
//         holderToMembershipData[_msgSender()][Address].isActive = false;
//         holderToMembershipData[_msgSender()][Address].commitment = 0;

//         /// @dev @todo this does not change Nova storage isMember[_msgSender] will still return true (has dos implications on admin check allowlist spec)

//         emit NovaWithdrawn(Address, _msgSender());
//     }

//     function editCommitment(address Address, uint256 newCommitment) external override {
//         require(holderToMembershipData[_msgSender()][Address].isActive, "AutID: Not a member");

//         require(newCommitment > 0 && newCommitment < 11, "AutID: Commitment should be between 1 and 10");

//         require(newCommitment >= INovaCommitment(Address).getCommitment(), "Commitment lower than the s min commitment");

//         holderToMembershipData[_msgSender()][Address].commitment = newCommitment;

//         emit CommitmentUpdated(Address, _msgSender(), newCommitment);
//     }

//     function setMetadataUri(string calldata metadataUri) public override {
//         require(balanceOf(_msgSender()) == 1, "AutID: There is no AutID registered for this address.");
//         uint256 tokenId = _autIDByOwner[_msgSender()];
//         _setTokenURI(tokenId, metadataUri);

//         emit MetadataUriSet(tokenId, metadataUri);
//     }

//     /// @notice gets all communities the AutID holder is a member of
//     /// @param autIDHolder the address of the AutID holder
//     /// @return s  expander addresses that the aut holder is a part of
//     function getHolderNovae(address autIDHolder) external view override returns (address[] memory s) {
//         require(balanceOf(autIDHolder) == 1, "AutID: There is no AutID registered for this address.");
//         return holderTos[autIDHolder];
//     }

//     function getMembershipData(address autIDHolder, address Address)
//         external
//         view
//         override
//         returns (NovaMember memory)
//     {
//         return holderToMembershipData[autIDHolder][Address];
//     }

//     /// @notice retieves all members with active status for provided nova address
//     /// @param nova_ target nova address
//     /// @return members array of addresses
//     function getAllActiveMembers(address nova_) public view returns (address[] memory members) {
//         uint256 i;
//         uint256 len;
//         members = INova(nova_).getAllMembers();
//         address[] memory actives = new address[](members.length);

//         for (i; i < members.length;) {
//             if (holderToMembershipData[members[i]][nova_].isActive) {
//                 actives[i] = members[i];
//             } else {
//                 ++len;
//             }
//             unchecked {
//                 ++i;
//             }
//         }
//         i = 0;
//         members = new address[](members.length - len);
//         len = 0;
//         for (i; i < actives.length;) {
//             if (actives[i] != address(0)) {
//                 members[len] = actives[i];
//                 unchecked {
//                     ++len;
//                 }
//             }
//             unchecked {
//                 ++i;
//             }
//         }
//     }

//     /// @notice returns NFT ID of the holder
//     /// @param autIDOwner the user address
//     /// @return the token ID of their NFT ID
//     function getAutIDByOwner(address autIDOwner) external view override returns (uint256) {
//         return _autIDByOwner[autIDOwner];
//     }

//     function getTotalCommitment(address autIDHolder) public view override returns (uint256) {
//         address[] memory users = holderTos[autIDHolder];

//         uint256 totalCommitment = 0;
//         for (uint256 index = 0; index < users.length; index++) {
//             totalCommitment += holderToMembershipData[autIDHolder][users[index]].commitment;
//         }
//         return totalCommitment;
//     }

//     /// @notice returns commitment levels for agents in a
//     /// @param agents address of agents
//     /// @param _nova commitment target
//     function getCommitmentsOfFor(address[] memory agents, address _nova)
//         external
//         view
//         returns (uint256[] memory commitments)
//     {
//         uint256 i;
//         if (agents.length == 0) agents = INovaMembership(_nova).getAllMembers();

//         commitments = new uint256[](agents.length);

//         for (i; i < agents.length;) {
//             commitments[i] = holderToMembershipData[agents[i]][_nova].commitment;
//             unchecked {
//                 ++i;
//             }
//         }
//     }

//     function getAutIDHolderByUsername(string memory username) public view override returns (address) {
//         return autIDUsername[username];
//     }

//     function getNextTokenID() public view override returns (uint256) {
//         return _tokenIds.current();
//     }

//     function _beforeTokenTransfer(address from, address, uint256) internal pure override {
//         require(from == address(0), "AutID: AutID transfer disabled");
//     }

//     function _msgSender() internal view override(ContextUpgradeable, ERC2771Recipient) returns (address) {
//         return ERC2771Recipient._msgSender();
//     }

//     function _msgData() internal view override(ContextUpgradeable, ERC2771Recipient) returns (bytes calldata) {
//         return ERC2771Recipient._msgData();
//     }

//     function _validateUsername(string memory username_) private pure {
//         bytes memory subj = bytes(username_);
//         for (uint256 i; i != subj.length; ++i) {
//             if (!(
//                 // 'a' <= _ <= 'z'
//                 (subj[i] >= 0x61 && subj[i] <= 0x7A) || 
//                 // '0' <= _ <= '9'
//                 (subj[i] >= 0x30 && subj[i] <= 0x39) ||
//                 // _ == '-'
//                 subj[i] == 0x2D
//             )) {
//                 revert("AutID: username: invalid character");
//             }
//         }
//     }

//     uint256[43] private __gap;
// }
