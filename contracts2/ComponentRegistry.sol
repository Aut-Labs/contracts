// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract ComponentRegistry is Ownable {
    mapping(bytes32 => address) public beaconFor;

    function upgradeComponent(bytes32 componentKey, address newImplementation) external onlyOwner {
        UpgradeableBeacon(beaconFor[componentKey]).upgradeTo(newImplementation);
    }

    function registerComponent(bytes32 componentKey, address implementation) external onlyOwner {
        beaconFor[componentKey] = address(new UpgradeableBeacon(implementation));
    }
}

