//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDAOTypes.sol";
/// @title DAOTypes
/// @notice DAOTypes has a mapping between type and MembershipChecker deployed for all DAO standards that are supported by AutID
/// @dev The contract is Ownable to ensure that only the AutID team can add new types.

contract DAOTypes is Ownable, IDAOTypes {
    using Counters for Counters.Counter;
    /// @notice

    Counters.Counter private _types;

    /// @notice
    mapping(uint256 => address) public typeToMembershipChecker;
    mapping(address => bool) public isMembershipChecker;

    /// @notice Returns the address of the MembershipChecker implementation for a given type
    /// @param daoType the type of the Membership Checker DAO
    /// @return the address of the contract that implements IMembershipChecker
    function getMembershipCheckerAddress(uint256 daoType) public view override returns (address) {
        return typeToMembershipChecker[daoType];
    }

    /// @notice Adds a new type and contract address in the types
    /// @dev Can be called only by the AutID contracts deployer
    /// @param membershipChecker the new contract address that is supported now
    function addNewMembershipChecker(address membershipChecker) public override onlyOwner {
        require(membershipChecker != address(0), "MembershipChecker contract address must be provided");
        require(!isMembershipChecker[membershipChecker], "MembershipChecker already added");
        _types.increment();
        typeToMembershipChecker[_types.current()] = membershipChecker;
        isMembershipChecker[membershipChecker] = true;
        emit DAOTypeAdded(_types.current(), membershipChecker);
    }

    function typesCount() public view override returns (uint256) {
        return _types.current();
    }
}
