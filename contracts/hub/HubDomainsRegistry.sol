// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Domain, IHubDomainsRegistry} from "./interfaces/IHubDomainsRegistry.sol";
import {IHubRegistry} from "./interfaces/IHubRegistry.sol";

contract HubDomainsRegistry is IHubDomainsRegistry, Initializable, ERC721Upgradeable {
    struct HubDomainsRegistryStorage {
        uint256 tokenId;
        address hubRegistry;
        mapping(address => Domain) domains;
        mapping(string => address) nameToHub;
        mapping(uint256 => address) tokenIdToHub;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.HubDomainsRegistry")) - 1))
    bytes32 private constant HubDomainsRegistryStorageLocation =
        0x7694591d4c1b0211f9ca2c8e969bcf5e9e81a833f253fd4748018791dadd2a28;

    function _getHubDomainsRegistryStorage() private pure returns (HubDomainsRegistryStorage storage $) {
        assembly {
            $.slot := HubDomainsRegistryStorageLocation
        }
    }

    function version() external view returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hubRegistry, string memory name_, string memory symbol_) external initializer {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        $.hubRegistry = _hubRegistry;

        __ERC721_init(name_, symbol_);
    }

    modifier onlyFromHub() {
        require(IHubRegistry(hubRegistry()).isHub(msg.sender));
        _;
    }

    /// @inheritdoc IHubDomainsRegistry
    function registerDomain(string calldata _name, string calldata _uri, address _owner) external onlyFromHub {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();

        require($.domains[msg.sender].tokenId == 0, "Domain already registered");
        require(_isValidDomain(_name), "Invalid _name format");

        uint256 tokenId_ = ++$.tokenId; // gas
        $.domains[msg.sender] = Domain({tokenId: tokenId_, name: _name, uri: _uri});
        $.nameToHub[_name] = msg.sender;
        $.tokenIdToHub[tokenId_] = msg.sender;

        _mint(_owner, tokenId_);

        emit DomainRegistered({hub: msg.sender, tokenId: tokenId_, name: _name, uri: _uri});
    }

    function _isValidDomain(string memory _name) internal pure returns (bool) {
        bytes memory b = bytes(_name);
        if (b.length == 0 || b.length > 20) return false; // Adjust length as needed
        if (!(_endsWithHub(_name))) return false; // Ends with ".hub"
        for (uint i; i < b.length - 4; i++) {
            // Skip ".hub"
            if (
                !(b[i] >= 0x30 && b[i] <= 0x39) && // 0-9
                !(b[i] >= 0x41 && b[i] <= 0x5A) && // A-Z
                !(b[i] >= 0x61 && b[i] <= 0x7A) // a-z
            ) {
                return false;
            }
        }
        return true;
    }

    function _endsWithHub(string memory _name) internal pure returns (bool) {
        bytes memory b = bytes(_name);
        return
            b.length > 4 &&
            b[b.length - 1] == "b" &&
            b[b.length - 2] == "u" &&
            b[b.length - 3] == "h" &&
            b[b.length - 4] == ".";
    }

    function tokenId() external view returns (uint256) {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        return $.tokenId;
    }

    function hubRegistry() public view returns (address) {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        return $.hubRegistry;
    }

    function domains(address hub) external view returns (Domain memory) {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        return $.domains[hub];
    }

    function nameToHub(string memory _name) external view returns (address hub) {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        return $.nameToHub[_name];
    }

    function tokenIdToHub(uint256 _tokenId) external view returns (address hub) {
        HubDomainsRegistryStorage storage $ = _getHubDomainsRegistryStorage();
        return $.tokenIdToHub[_tokenId];
    }
}
