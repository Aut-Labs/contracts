// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../plugins/IPlugin.sol";
import "../plugins/registry/IPluginRegistry.sol";
import "../components/interfaces/get/INovaAdmin.sol";
import "../nova/interfaces/INova.sol";

/// @title PluginRegistry
/// @notice Stores all plugins available and allows them to be added to a dao
contract PluginRegistry is ERC721URIStorage, Ownable, ReentrancyGuard, IPluginRegistry {
    uint256 public _numPluginDefinitions;
    uint256 public _numPluginsMinted;

    uint256 public feeBase1000 = 1;
    address payable public feeReciever;
    address public oracleAddress;
    address public override modulesRegistry;
    address public defaultLRAddr;

    mapping(uint256 => PluginDefinition) public pluginDefinitionsById;
    mapping(uint256 => PluginInstance) public pluginInstanceByTokenId;

    mapping(address => uint256) public tokenIdByPluginAddress;

    mapping(address => mapping(uint256 => bool)) public override pluginDefinitionsInstalledByDAO;

    mapping(address => uint256[]) pluginIdsByDAO;

    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "AUT: Only oracle can call this function");
        _;
    }

    constructor(address _modulesRegistry) ERC721("Aut Plugin", "Aut Plugin") {
        feeReciever = payable(msg.sender);
        oracleAddress = msg.sender;
        modulesRegistry = _modulesRegistry;
    }

    // Plugin creation
    function addPluginToDAO(address pluginAddress, uint256 pluginDefinitionId) external payable override nonReentrant {
        address nova = IPlugin(pluginAddress).novaAddress();

        require(INovaAdmin(nova).isAdmin(msg.sender) == true, "Not an admin");
        PluginDefinition memory pluginDefinition = pluginDefinitionsById[pluginDefinitionId];

        require(pluginDefinition.canBeStandalone, "can't be standalone");
        require(msg.value >= pluginDefinition.price, "AUT: Insufficient price paid");
        require(!pluginDefinitionsInstalledByDAO[nova][pluginDefinitionId], "AUT: Plugin already installed on nova");

        pluginDefinitionsInstalledByDAO[nova][pluginDefinitionId] = true;

        uint256 tokenId = _mintPluginNFT(pluginDefinitionId, msg.sender);

        pluginIdsByDAO[nova].push(tokenId);

        uint256 fee = (pluginDefinition.price * feeBase1000) / 1000;

        feeReciever.transfer(fee);
        (bool s,) = pluginDefinition.creator.call{value: msg.value - fee}("");
        if (!s) revert("Value transfer failed");

        emit PluginAddedToDAO(tokenId, pluginDefinitionId, nova);

        pluginInstanceByTokenId[tokenId].pluginAddress = pluginAddress;

        tokenIdByPluginAddress[pluginAddress] = tokenId;

        IPlugin(pluginAddress).setPluginId(tokenId);

        if (IModule(pluginAddress).moduleId() == 1) {
            INova(nova).setOnboardingStrategy(pluginAddress);
        }

        emit PluginRegistered(tokenId, pluginAddress);
    }

    function _mintPluginNFT(uint256 pluginDefinitionId, address to) internal returns (uint256 tokenId) {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[pluginDefinitionId];

        _numPluginsMinted++;
        tokenId = _numPluginsMinted;

        pluginInstanceByTokenId[tokenId].pluginDefinitionId = pluginDefinitionId;

        _mint(to, tokenId);
        _setTokenURI(tokenId, pluginDefinition.metadataURI);

        return tokenId;
    }

    function getOwnerOfPlugin(address pluginAddress) external view override returns (address) {
        return ownerOf(tokenIdByPluginAddress[pluginAddress]);
    }

    function editPluginDefinitionMetadata(uint256 pluginDefinitionId, string memory url) external override onlyOwner {
        pluginDefinitionsById[pluginDefinitionId].metadataURI = url;
    }

    function setDefaulLRAddress(address LR) external onlyOwner {
        emit DefaultLRAlgoChanged(LR, defaultLRAddr);
        defaultLRAddr = LR;
    }

    // Plugin type management
    function addPluginDefinition(
        address payable creator,
        string memory metadataURI,
        uint256 price,
        bool canBeStandalone,
        uint256[] memory moduleDependencies
    ) external onlyOwner returns (uint256 pluginDefinitionId) {
        require(bytes(metadataURI).length > 0, "AUT: Metadata URI is empty");
        require(canBeStandalone || price == 0, "AUT: Should be free if not standalone");

        _numPluginDefinitions++;
        pluginDefinitionId = _numPluginDefinitions;

        pluginDefinitionsById[pluginDefinitionId] =
            PluginDefinition(metadataURI, price, creator, true, canBeStandalone, moduleDependencies);

        emit PluginDefinitionAdded(pluginDefinitionId);
    }

    function setPrice(uint256 pluginDefinitionId, uint256 newPrice) public {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[pluginDefinitionId];
        require(msg.sender == pluginDefinition.creator, "AUT: Only creator can set price");
        pluginDefinition.price = newPrice;
    }

    function setActive(uint256 pluginDefinitionId, bool newActive) public {
        PluginDefinition storage pluginDefinition = pluginDefinitionsById[pluginDefinitionId];
        require(msg.sender == pluginDefinition.creator, "AUT: Only creator can set active");
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

    function getPluginInstanceByTokenId(uint256 tokenId) public view override returns (PluginInstance memory) {
        return pluginInstanceByTokenId[tokenId];
    }

    function getPluginIdsByDAO(address dao) public view override returns (uint256[] memory) {
        return pluginIdsByDAO[dao];
    }

    function getDependencyModulesForPlugin(uint256 pluginDefinitionId) public view returns (uint256[] memory) {
        return pluginDefinitionsById[pluginDefinitionId].dependencyModules;
    }

    function tokenIdFromAddress(address pluginAddress_) external view override returns (uint256) {
        return tokenIdByPluginAddress[pluginAddress_];
    }

    function owner() public view override(Ownable, IPluginRegistry) returns (address) {
        return super.owner();
    }
}
