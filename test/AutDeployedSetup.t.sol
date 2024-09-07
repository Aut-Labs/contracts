// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// import "ds-test/test.sol";
// import "forge-std/Vm.sol";
// import "../contracts/autid/AutID.sol";
// import "../contracts/hub/HubRegistry.sol";
// import "../contracts/hubContracts/HubDomainsRegistry.sol";

// contract AutDeployedSetup is DSTest {
//     Vm vm = Vm(HEVM_ADDRESS);
//     AutID autID;
//     HubRegistry hubRegistry;
//     HubDomainsRegistry hubDomainsRegistry;
//     Hub hubLogic;
//     UpgradeableBeacon upgradeableBeacon;
//     address owner = address(this);
//     address pluginRegistry = address(1);
//     address trustedForwarder = address(2);

//     function setUp() public {
//         autID = new AutID(trustedForwarder);
//         hubRegistry = new HubRegistry(trustedForwarder);
//         hubLogic = new Hub();
//         hubDomainsRegistry = new HubDomainsRegistry(address(hubLogic));

//         address autIdAddress = address(autID);
//         address hubRegistryAddress = address(hubRegistry);
//         address hubAddress = address(hubLogic);
//         address hubDomainsRegistryAddress = address(hubDomainsRegistry);

//         autID.initialize(owner);
//         hubLogic.initialize(
//             owner,
//             autIdAddress, // AutID address
//             address(hubRegistry),
//             pluginRegistry, // plugin registry address
//             1, // Market
//             1, // Commitment
//             "metadata", // Metadata Uri
//             hubDomainsRegistryAddress
//         );

//         hubRegistry.initialize(
//             autIdAddress,
//             hubAddress,
//             pluginRegistry,
//             hubDomainsRegistryAddress
//         );

//         autID.setHubRegistry(hubRegistryAddress);
//     }

//     function testDeployHubAndCreateRecord() public {
//         vm.startPrank(owner);
//         uint256 market = 4;
//         string memory metadata = "hubMetadata";
//         uint256 minCommitment = 5;

//         address hubAddress = hubRegistry.deployHub(
//             market,
//             metadata,
//             minCommitment
//         );
//         assertEq(
//             Hub(hubAddress).market(),
//             market,
//             "Hub market should match the input market"
//         );
//         assertEq(
//             Hub(hubAddress).metadataUri(),
//             metadata,
//             "Hub metadataUri should match the input metadataUri"
//         );
//         string memory username = "testuser";
//         string memory optionalUri = "testuri";
//         uint256 role = 1;
//         uint256 commitment = 5;
//         autID.createRecordAndJoinHub(
//             role,
//             commitment,
//             hubAddress,
//             username,
//             optionalUri
//         );

//         bytes32 usernameHash;
//         assembly {
//             usernameHash := mload(add(username, 32))
//         }
//         uint256 tokenId = autID.tokenIdForUsername(usernameHash);
//         assertTrue(
//             tokenId != 0,
//             "Token ID should be non-zero after record creation"
//         );

//         // register domain from hub
//         string memory domain = "testdomain.hub";
//         string memory domainMetadata = "testdomainmetadata";
//         hubLogic.registerDomain(domain, hubAddress, domainMetadata);
//         (address domainHubAddress, string memory domainMetadataResult) = hubDomainsRegistry.getDomain(
//             domain
//         );

//         assertEq(
//             domainHubAddress,
//             hubAddress,
//             "Domain owner should be the hub contract"
//         );

//         assertEq(
//             domainMetadataResult,
//             domainMetadata,
//             "Domain metadata should match the input metadata"
//         );

//         // try register directly from hubDomainsRegistry
//         string memory domain2 = "testdomain2.hub";
//         string memory domainMetadata2 = "testdomainmetadata2";
//         vm.expectRevert("Caller is not the permitted contract");
//         hubDomainsRegistry.registerDomain(domain2, hubAddress, domainMetadata2);

//         vm.stopPrank();
//     }
// }
