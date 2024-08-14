//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HubUpgradeable} from "./HubUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/*
TODO:
- Are market, commitment, metadataUri modifiable?
- Should the deployer be allowed to transfer their deployer role ownership?
- max/min values of parameters
*/

abstract contract Hub is HubUpgradeable {
    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant REPUTATION_PARAMETER = 2;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    address public onboarding;
    /// @dev these addrs are seen as immutable
    address public autID;
    address public hubDomainsRegistry;
    address public taskRegistry;

    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataUri;

    EnumerableSet.AddressSet internal _admins;

    string[] private _urls;
    mapping(bytes32 => uint256) private _urlHashIndex;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _autID,
        address _hubDomainsRegistry,
        address _novaRegistry,
        address _taskRegistry,
        uint256 _market,
        uint256 _commitment,
        string memory _metadataUri
    ) {
        __Ownable_init(_initialOwner);
        _admins.add(_initialOwner);

        autID = _autID;
        hubDomainsRegistry = _hubDomainsRegistry;
        taskRegistry = _taskRegistry;

        _setMarket(_market);
        _setCommitment(_commitment);
        _setMetadataUri(_metadataUri);
    }

    // -----------------------------------------------------------
    //                     ADMIN-MANAGEMENT
    // -----------------------------------------------------------

    function admins() external view return (address[] memory) {
        return _admins.values();
    }

    function isAdmin(address who) public view returns (bool) {
        return _admins.contains(who);
    }

    function addAdmins(address[] calldata whos) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        for (uint256 i=0; i<whos.length; i++) {
            _addAdmin(whos[i]);
        }
    }

    function addAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _addAdmin(who);
    }

    function _addAdmin(address who) internal {
        if (!isMember(who)) revert NotMember();
        if (!_admins.add(who)) revert AlreadyAdmin();

        emit AdminGranted(who);
    }

    function removeAdmin(address who) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        if (msg.sender == who) revert AdminCannotRenounceSelf();
        if (!_admins.remove(who)) revert CannotRemoveNonAdmin();

        emit AdminRenounced(who);

    // -----------------------------------------------------------
    //                        HUB-MANAGEMENT
    // -----------------------------------------------------------

    function registerDomain(
        string calldata domain_,
        address novaAddress_,
        string calldata metadataUri_
    ) external override onlyOwner {
        // also revert if not deployer
        IHubDomainsRegistry(hubDomainsRegistry).registerDomain(domain_, novaAddress_, metadataUri_);
    }

    function addUrl(string memory url) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _addUrl(url);
    }

    function removeUrl(string memory url) external {
        if (!isAdmin(msg.sender)) revert NotAdmin();
        _removeUrl(url);
    }

    function setArchetypeAndParameters(uint8[] calldata input) external {
        require(input.length == 6, "Nova: incorrect input length");
        if (!isAdmin(msg.sender)) revert NotAdmin();

        _revertForInvalidParameter(input[0]);
        archetype = input[0];
        for (uint256 i = 1; i != 6; ++i) {
            _revertForInvalidParameter(input[i]);
            parameterWeight[uint8(i)] = input[i];

            emit ParameterSet(uint8(i), input[i]);
        }

        emit ArchetypeSet(input[0]);
    }

    /// internal

    function _setMarket(uint256 market_) internal {
        _revertForInvalidMarket(market_);

        market = market_;

        emit MarketSet(market_);
    }

    function _setCommitment(uint256 commitment_) internal {
        _revertForInvalidCommitment(commitment_);

        commitment = commitment_;

        emit CommitmentSet(commitment_);
    }

    function _setMetadataUri(string memory metadataUri_) internal {
        _revertForInvalidMetadataUri(metadataUri_);

        metadataUri = metadataUri_;

        emit MetadataUriSet(metadataUri_);
    }

    function _addUrl(string memory url) internal {
        uint256 length = _urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        if (_urlHashIndex[urlHash] == 0) {
            _urlHashIndex[urlHash] = length + 1;
            _urls.push(url);

            emit UrlAdded(url);
        }

        // makes no effect on adding duplicated elements
    }

    function _removeUrl(string memory url) internal {
        uint256 length = _urls.length;
        bytes32 urlHash = keccak256(abi.encodePacked(url));
        uint256 index = _urlHashIndex[urlHash];

        if (index != 0) {
            if (index != length) {
                string memory lastUrl = _urls[length - 1];
                bytes32 lastUrlHash = keccak256(abi.encodePacked(lastUrl));
                _urls[index - 1] = lastUrl;
                _urlHashIndex[lastUrlHash] = index;
            }
            _urls.pop();
            delete _urlHashIndex[urlHash];

            emit UrlRemoved(url);
        }

        // makes no effect on removing nonexistent elements
    }

    // -----------------------------------------------------------
    //                           VIEWS
    // -----------------------------------------------------------

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return IHubDomainsRegistry(hubDomainsRegistry).getDomain(domain);
    }

    function getUrls() external view returns (string[] memory) {
        return _urls;
    }

    function isUrlListed(string memory url) external view returns (bool) {
        return _urlHashIndex[keccak256(abi.encodePacked(url))] != 0;
    }
}