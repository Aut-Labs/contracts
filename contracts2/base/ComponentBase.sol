// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Upgradeable.sol";


abstract contract Component is Upgradeable, Initializable {
    event Initialized(address nova, uint8 version);

    uint8 public version;
    address public nova;
    // mapping(bytes32 => uint256) internal _properties;

    // function getPropertyKey(bytes32 key) external view returns(uint256) {
    //     return _properties[key];
    // }

    function _initialize(
        uint8 version_,
        address nova_
        // bytes32[] calldata keys,
        // uint256[] calldata values
    )
        internal
        onlyInitializing 
    {
        version = version_;
        nova = nova_;

        // require(keys.length == values.length);
        // for (uint256 i; i != keys.length; ++i) {
        //     _properties[keys[i]] = values[i];
        // }

        emit Initialized(nova, version);
    }

}
