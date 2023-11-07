// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Nova as N} from "../contracts/nova/Nova.sol";
import {INova} from "../contracts/nova/interfaces/INova.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";

import {INova} from "../contracts/nova/interfaces/INova.sol";

import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";

import {IAllowlist, Allowlist} from "../contracts/utils/Allowlist.sol";

//// @notice Tests Basic Deployment attainable
contract DeploysInit is Test {
    IAutID aID;
    INovaRegistry INR;
    IPluginRegistry IPR;
    IModuleRegistry IMR;
    SWLegacyDAO LegacyDAO;
    INova NovaLogic;
    ILocalReputation iLR;
    IAllowlist AList;
    INova Nova;

    address A0 = address(uint160(uint256(keccak256("Account0 Deployer"))));

    address A1;
    address A2;
    address A3;
    address A4_outsider;

    uint256 A1role;
    uint256 A2role;

    function setUp() public virtual {
        A1 = address(uint160(uint256(keccak256("Account1"))));
        vm.label(address(A1), "Account1");

        A2 = address(uint160(uint256(keccak256("Account2"))));
        vm.label(address(A2), "Account2");

        A3 = address(uint160(uint256(keccak256("Account3"))));
        vm.label(address(A3), "Account3");

        A4_outsider = address(uint160(uint256(keccak256("Account4_out"))));
        vm.label(address(A3), "Account4_out");

        vm.startPrank(A0);

        LegacyDAO = new SWLegacyDAO();
        vm.label(address(LegacyDAO), "LegacyDAOI");

        AList = IAllowlist(address(new Allowlist()));
        vm.label(address(AList), "allowlist");

        aID = IAutID(address(new AutID()));
        vm.label(address(aID), "AutIDI");

        NovaLogic = INova(address(new N()));
        vm.label(address(NovaLogic), "NovaLogicI");

        IMR = IModuleRegistry(address(new ModuleRegistry(address(AList))));
        vm.label(address(IMR), "ModuleRegistryI");

        IPR = IPluginRegistry(address(new PluginRegistry(address(IMR))));
        vm.label(address(IPR), "PluginRegistryI");

        iLR = ILocalReputation(address(new LocalReputation()));

        IPR.setDefaulLRAddress(address(iLR));

        INR = INovaRegistry(address(new NovaRegistry(address(12345),address(aID), address(NovaLogic), address(IPR))));
        vm.label(address(INR), "NovaRegistryI");

        address NovaAddr = INR.deployNova(1, "metadataCID", 1);
        Nova = INova(NovaAddr);
        vm.stopPrank();
    }

    function testAreDeployedContracts() public {
        assertTrue(address(aID).code.length > 1, "expected aID contract");
        assertTrue(address(NovaLogic).code.length > 2, "expected Nova contract");
        assertTrue(address(IMR).code.length > 4, "expected IMR contract");
        assertTrue(address(IPR).code.length > 5, "expected IPR contract");
        assertTrue(address(INR).code.length > 6, "expected INRcontract");
        assertTrue(Nova.pluginRegistry() == address(IPR), "expected another plugin registry address");
        //////////////////
        assertTrue(IMR.isProtocolMaintaier(A0), "deployer not maintainer");
        assertTrue(IPR.defaultLRAddr() != address(0), "no LR address set");
    }
}
