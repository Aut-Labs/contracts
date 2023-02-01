//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../../interfaces/modules/IModule.sol";
import "../../interfaces/registry/IPluginRegistry.sol";
import "../../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../../daoUtils/interfaces/get/IDAOAdmin.sol";
import "../../../IInteraction.sol";

/// @title PluginRegistry
/// @notice Stores all plugins available and allows them to be added to a dao
contract PluginRegistry is
    ERC721URIStorage,
    Ownable,
    ReentrancyGuard,
    IPluginRegistry
{
    uint256 public _numPluginTypes;
    uint256 public _numPluginsMinted;

    uint256 public feeBase1000 = 1;
    address payable public feeReciever;
    address public oracleAddress;

    mapping(uint256 => PluginDefinition) public pluginTypesById;
    mapping(uint256 => PluginInstance) public pluginInstanceByTokenId;
    mapping(address => uint256) public tokenIdByPluginAddress;
    mapping(address => mapping(uint256 => bool))
        public override pluginTypesInstalledByDAO;
    mapping(address => uint[]) pluginIdsByDAO;

    modifier onlyOracle() {
        require(
            msg.sender == oracleAddress,
            "AUT: Only oracle can call this function"
        );
        _;
    }

    constructor() ERC721("Aut Plugin", "Aut Plugin") {
        feeReciever = payable(msg.sender);
        oracleAddress = msg.sender;
    }

    // Plugin creation
    function addPluginToDAO(uint256 pluginTypeId, address dao)
        external
        payable
        nonReentrant
    {
        PluginDefinition storage pluginDefinition = pluginTypesById[
            pluginTypeId
        ];

        require(pluginDefinition.active, "AUT: Plugin not active");
        require(
            msg.value >= pluginDefinition.price,
            "AUT: Insufficient price paid"
        );
        require(
            pluginTypesInstalledByDAO[dao][pluginTypeId] == false,
            "AUT: Plugin already installed on dao"
        );

        pluginTypesInstalledByDAO[dao][pluginTypeId] = true;

        uint256 tokenId = _mintPluginNFT(pluginTypeId, msg.sender);
        
        pluginIdsByDAO[dao].push(tokenId);

        uint256 fee = (pluginDefinition.price * feeBase1000) / 1000;

        feeReciever.transfer(fee);
        pluginTypesById[pluginTypeId].creator.transfer(msg.value - fee);

        emit PluginAddedToDAO(tokenId, pluginTypeId, dao);
    }

    function _mintPluginNFT(uint256 pluginTypeId, address to)
        internal
        returns (uint256 tokenId)
    {
        PluginDefinition storage pluginDefinition = pluginTypesById[
            pluginTypeId
        ];

        _numPluginsMinted++;
        tokenId = _numPluginsMinted;

        pluginInstanceByTokenId[tokenId].pluginTypeId = pluginTypeId;

        _mint(to, tokenId);
        _setTokenURI(tokenId, pluginDefinition.metadataURI);

        return tokenId;
    }


    function registerPlugin(uint256 tokenId, IModule plugin) public {
        require(ownerOf(tokenId) == msg.sender, " Not the owner of the plugin");
        require(
            IDAOAdmin(plugin.daoAddress()).isAdmin(msg.sender) == true,
            "Not an admin"
        );
        pluginInstanceByTokenId[tokenId].pluginAddress = address(plugin);
        tokenIdByPluginAddress[address(plugin)] = tokenId;
        address dao = plugin.daoAddress();
        address interactions = IDAOInteractions(dao).getInteractionsAddr();
        IInteraction(interactions).allowAccess(address(plugin));
        emit PluginRegistered(tokenId, address(plugin));
    }

    function getOwnerOfPlugin(address pluginAddress)
        external
        view
        override
        returns (address owner)
    {
        uint256 tokenId = tokenIdByPluginAddress[pluginAddress];
        owner = ownerOf(tokenId);
        return owner;
    }

    // Plugin type management
    function addPluginDefinition(
        address payable creator,
        string memory metadataURI,
        uint256 price
    ) external onlyOwner {
        require(bytes(metadataURI).length > 0, "AUT: Metadata URI is empty");

        _numPluginTypes++;
        uint256 pluginTypeId = _numPluginTypes;

        pluginTypesById[pluginTypeId] = PluginDefinition(
            metadataURI,
            price,
            creator,
            true
        );

        emit PluginDefinitionAdded(pluginTypeId);
    }

    function setPrice(uint256 pluginTypeId, uint256 newPrice) public {
        PluginDefinition storage pluginDefinition = pluginTypesById[
            pluginTypeId
        ];
        require(
            msg.sender == pluginDefinition.creator,
            "AUT: Only creator can set price"
        );
        pluginDefinition.price = newPrice;
    }

    function setActive(uint256 pluginTypeId, bool newActive) public {
        PluginDefinition storage pluginDefinition = pluginTypesById[
            pluginTypeId
        ];
        require(
            msg.sender == pluginDefinition.creator,
            "AUT: Only creator can set active"
        );
        pluginDefinition.active = newActive;
    }

    // Admin
    function setFeeBase1000(uint256 newFeeBase1000) public onlyOwner {
        feeBase1000 = newFeeBase1000;
    }

    function setFeeReciever(address payable newFeeReciever) public onlyOwner {
        feeReciever = newFeeReciever;
    }

    function setOracleAddress(address newOracleAddress) public onlyOwner {
        oracleAddress = newOracleAddress;
    }

    function getPluginInstanceByTokenId(uint256 tokenId)
        public
        view
        override
        returns (PluginInstance memory)
    {
        return pluginInstanceByTokenId[tokenId];
    }

    function getPluginIdsByDAO(address dao) public view override returns(uint[] memory) {
        return pluginIdsByDAO[dao];
    }
}
