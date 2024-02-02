// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "../contracts/autid/AutID.sol";
import "../contracts/nova/NovaRegistry.sol";

contract AutDeployedSetup is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    AutID autID;
    NovaRegistry novaRegistry;
    UpgradeableBeacon upgradeableBeacon;
    address owner = address(this);
    address pluginRegistry = address(1);
    address trustedForwarder = address(2);

    function setUp() public {
        autID = new AutID(trustedForwarder);
        novaRegistry = new NovaRegistry(trustedForwarder);
        Nova novaLogic = new Nova();

        address autIdAddress = address(autID);
        address novaRegistryAddress = address(novaRegistry);
        address novaAddress = address(novaLogic);

        autID.initialize(owner);
        novaLogic.initialize(
            owner,
            autIdAddress, // AutID address
            address(novaRegistry),
            pluginRegistry, // plugin registry address
            1, // Market
            1, // Commitment
            "metadata" // Metadata Uri
        );

        novaRegistry.initialize(
            autIdAddress,
            novaAddress,
            pluginRegistry
        );

        autID.setNovaRegistry(novaRegistryAddress);
    }

    function testDeployNovaAndCreateRecord() public {
        vm.startPrank(owner);
        uint256 market = 1;
        string memory metadata = "novaMetadata";
        uint256 minCommitment = 5;

        address novaAddress = novaRegistry.deployNova(
            market,
            metadata,
            minCommitment
        );
        assertEq(
            Nova(novaAddress).market(),
            market,
            "Nova market should match the input market"
        );
        assertEq(
            Nova(novaAddress).metadataUri(),
            metadata,
            "Nova metadataUri should match the input metadataUri"
        );
        string memory username = "testuser";
        string memory optionalUri = "testuri";
        uint256 role = 1;
        uint256 commitment = 5;
        autID.createRecordAndJoinNova(
            role,
            commitment,
            novaAddress,
            username,
            optionalUri
        );

        bytes32 usernameHash;
        assembly {
            usernameHash := mload(add(username, 32))
        }
        uint256 tokenId = autID.tokenIdForUsername(usernameHash);
        assertTrue(
            tokenId != 0,
            "Token ID should be non-zero after record creation"
        );
        vm.stopPrank();
    }
}
