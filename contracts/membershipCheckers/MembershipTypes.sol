//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title MembershipTypes
/// @notice MembershipTypes has a mapping between type and MembershipExtension deployed for all DAO standards that are supported by SW 
/// @dev The contract is Ownable to ensure that only the SW team can add new types. 
contract MembershipTypes is Ownable {
    using Counters for Counters.Counter;
    /// @notice
    Counters.Counter private _types;

    event MembershipTypeAdded(uint memType, address membershipExtContract);

    /// @notice
    mapping(uint => address) public typeToMembershipChecker;
    mapping(address => bool) public isMembershipChecker;

    /// @notice Returns the address of the MembershipExtension implementation for a given type
    /// @param membershipType the type of the Membership Extension DAO
    /// @return the address of the contract that implements IMembershipExtension
    function getMembershipExtensionAddress(uint membershipType)
        public
        view
        returns (address)
    {
        return typeToMembershipChecker[membershipType];
    }

    /// @notice Adds a new type and contract address in the types
    /// @dev Can be called only by the SW contracts deployer
    /// @param membershipExtContract the new contract address that is supported now
    function addNewMembershipExtension(address membershipExtContract) onlyOwner public {
        require(membershipExtContract != address(0), "MembershipChecker contract address must be provided");
        require(!isMembershipChecker[membershipExtContract], "MembershipChecker already added");
        _types.increment();
        typeToMembershipChecker[_types.current()] = membershipExtContract;
        isMembershipChecker[membershipExtContract] = true;
        emit MembershipTypeAdded(_types.current(), membershipExtContract);
    }

    function typesCount() public view returns(uint) {
        return _types.current();
    }
}
