// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.19;

// import {Nova} from "../contracts/nova/Nova.sol";
// import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
// import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
// import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
// import {AutID, IAutID} from "../contracts/AutID.sol";
// import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";
// import {LocalReputation} from "../contracts/LocalReputation.sol";
// import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";

// import {IAllowlist, Allowlist} from "../contracts/utils/Allowlist.sol";

// // import {AddToAllowList} from "./AddToAllowList.s.sol";

// import "forge-std/Script.sol";

// contract DeployMockAutIDsScript is Script {

//     constructor(address AutID, uint256 howMany) {
//         for (uint256 i = uint256(type(uint160).max - type(uint32).max);  i < howMany; i++) {
            
//             address user= address(uint160(i));

//             IAutID(AutID).mint(
//                 string.concat("mockAutID", uint2str(i)),
//                 string.concat("mockAutID", uint2str(i)),
//                 0,
//                 0,
//                 address(this)
//             );
//         }
//     }

// }