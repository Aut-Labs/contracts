//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../plugins/IPlugin.sol";
import "../plugins/registry/IPluginRegistry.sol";
import "../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../daoUtils/interfaces/get/IDAOAdmin.sol";
import "../daoUtils/interfaces/get/IDAOModules.sol";
import "../nova/interfaces/INova.sol";
import "../IInteraction.sol";

/// @title PluginRegistry
/// @notice Stores all plugins available and allows them to be added to a dao
contract PluginRegistry is
    ERC721URIStorage,
    Ownable,
    ReentrancyGuard,
    IPluginRegistry
{
    uint256 public _numPluginDefinitions;
    uint256 public _numPluginsMinted;

    uint256 public feeBase1000 = 1;
    address payable public feeReciever;
    address public oracleAddress;
    address public override modulesRegistry;

    mapping(uint256 => PluginDefinition) public pluginDefinitionsById;
    mapping(uint256 => PluginInstance) public pluginInstanceByTokenId;

    mapping(address => uint256) public tokenIdByPluginAddress;

    mapping(address => mapping(uint256 => bool))
        public
        override pluginDefinitionsInstalledByDAO;

    mapping(address => uint256[]) pluginIdsByDAO;

    modifier onlyOracle() {
        require(
            msg.sender == oracleAddress,
            "AUT: Only oracle can call this function"
        );
        _;
    }

    constructor(address _modulesRegistry) ERC721("Aut Plugin", "Aut Plugin") {
        feeReciever = payable(msg.sender);
        oracleAddress = msg.sender;
        modulesRegistry = _modulesRegistry;
    }

    // Plugin creation
    function addPluginToDAO(
        address pluginAddress,
        uint256 pluginDefinitionId
    ) external override payable nonReentrant {
        IModule plugin = IModule(pluginAddress);
        address dao = plugin.daoAddress();

        require(IDAOAdmin(dao).isAdmin(msg.sender) == true, "Not an admin");

        PluginDefinition storage pluginDefinition = pluginDefinitionsById[
            pluginDefinitionId
        ];
        require(pluginDefinition.canBeStandalone, "can't be standalone");
        require(
            msg.value >= pluginDefinition.price,
            "AUT: Insufficient price paid"
        );
        require(
            !pluginDefinitionsInstalledByDAO[dao][pluginDefinitionId],
            "AUT: Plugin already installed on dao"
        );

        pluginDefinitionsInstalledByDAO[dao][pluginDefinitionId] = true;

        uint256 tokenId = _mintPluginNFT(pluginDefinitionId, msg.sender);

        pluginIdsByDAO[dao].push(tokenId);

        uint256 fee = (pluginDefinition.price * feeBase1000) / 1000;

        feeReciever.transfer(fee);
        pluginDefinitionsById[pluginDefinitionId].creator.transfer(
            msg.value - fee
        );

        emit PluginAddedToDAO(tokenId, pluginDefinitionId, dao);

        pluginInstanceByTokenId[tokenId].pluginAddress = pluginAddress;

        tokenIdByPluginAddress[pluginAddress] = tokenId;

        IPlugin(pluginAddress).setPluginId(tokenId);
        // allow interactions to be used from plugin
        address interactions = IDAOInteractions(dao).getInteractionsAddr();
        IInteraction(interactions).allowAccess(pluginAddress);

        if (IModule(pluginAddress).moduleId() == 1)
            INova(dao).setOnboardingStrategy(pluginAddress);

        emit PluginRegistered(tokenId, pluginAddress);
    }

    function _mintPluginNFT(
        uint256 pluginDefinitionId,
        address to
    ) internal returns (uint256 tokenId) {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[
            pluginDefinitionId
        ];

        _numPluginsMinted++;
        tokenId = _numPluginsMinted;

        pluginInstanceByTokenId[tokenId]
            .pluginDefinitionId = pluginDefinitionId;

        _mint(to, tokenId);
        _setTokenURI(tokenId, pluginDefinition.metadataURI);

        return tokenId;
    }

    function getOwnerOfPlugin(
        address pluginAddress
    ) external view override returns (address owner) {
        uint256 tokenId = tokenIdByPluginAddress[pluginAddress];
        owner = ownerOf(tokenId);
        return owner;
    }

    function editPluginDefinitionMetadata(
        uint pluginDefinitionId,
        string memory url
    ) external onlyOwner override {
        pluginDefinitionsById[pluginDefinitionId].metadataURI = url;
    }

    // Plugin type management
    function addPluginDefinition(
        address payable creator,
        string memory metadataURI,
        uint256 price,
        bool canBeStandalone,
        uint[] memory moduleDependencies
    ) external onlyOwner {
        require(bytes(metadataURI).length > 0, "AUT: Metadata URI is empty");
        require(canBeStandalone || price == 0, "AUT: Should be free if not standalone");

        _numPluginDefinitions++;
        uint256 pluginDefinitionId = _numPluginDefinitions;

        pluginDefinitionsById[pluginDefinitionId] = PluginDefinition(
            metadataURI,
            price,
            creator,
            true,
            canBeStandalone,
            moduleDependencies
        );

        emit PluginDefinitionAdded(pluginDefinitionId);
    }

    function setPrice(uint256 pluginDefinitionId, uint256 newPrice) public {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[
            pluginDefinitionId
        ];
        require(
            msg.sender == pluginDefinition.creator,
            "AUT: Only creator can set price"
        );
        pluginDefinition.price = newPrice;
    }

    function setActive(uint256 pluginDefinitionId, bool newActive) public {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[
            pluginDefinitionId
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

    function getPluginInstanceByTokenId(
        uint256 tokenId
    ) public view override returns (PluginInstance memory) {
        return pluginInstanceByTokenId[tokenId];
    }

    function getPluginIdsByDAO(
        address dao
    ) public view override returns (uint256[] memory) {
        return pluginIdsByDAO[dao];
    }

    function getDependencyModulesForPlugin(uint pluginDefinitionId) public view returns(uint[] memory) {
        return pluginDefinitionsById[pluginDefinitionId].dependencyModules;
    }
}
