//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./CommunityExtension.sol";

contract CommunityRegistry {
    event CommunityCreated(address newCommunityAddress);

    address[] public communities;
    uint256 public numOfCommunities;

    address public autIDAddr;
    address public membershipTypes;

    constructor(address _autIDAddr, address _membershipTypes) {
        require(_autIDAddr != address(0), "AutID Address not passed");
        require(_membershipTypes != address(0), "MemTypes Address not passed");

        autIDAddr = _autIDAddr;
        membershipTypes = _membershipTypes;
    }

    /**
     * @dev Deploys a community extension
     * @return _communityAddress the newly created Community address
     **/
    function createCommunity(
        uint256 contractType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) public returns (address _communityAddress) {
        require(
            MembershipTypes(membershipTypes).getMembershipExtensionAddress(
                contractType
            ) != address(0),
            "Membership Type incorrect"
        );
        require(daoAddr != address(0), "Missing DAO Address");
        require(market > 0 && market < 4, "Invalid market");
        require(bytes(metadata).length > 0, "Metadata URL empty");
        require(commitment > 0 && commitment < 11, "Invalid commitment");
        require(
            IMembershipChecker(
                MembershipTypes(membershipTypes).getMembershipExtensionAddress(
                    contractType
                )
            ).isMember(daoAddr, msg.sender),
            "AutID: Not a member of this DAO!"
        );
        CommunityExtension newCommunity = new CommunityExtension(
            msg.sender,
            autIDAddr,
            membershipTypes,
            contractType,
            daoAddr,
            market,
            metadata,
            commitment
        );
        address newCommunityAddress = address(newCommunity);
        communities.push(newCommunityAddress);

        numOfCommunities = numOfCommunities + 1;

        emit CommunityCreated(newCommunityAddress);

        return newCommunityAddress;
    }

    function getCommunities() public view returns (address[] memory) {
        return communities;
    }
}
