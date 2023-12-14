// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Nova {
    error WrongParameter();

    event AdminGranted(address to);
    event AdminRenounced(address from);
    event MemberGranted(address to, uint256 role);
    event ArchetypeSet(uint8 parameter);
    event ParameterSet(uint8 num, uint8 value);

    uint256 public constant SIZE_PARAMETER = 1;
    uint256 public constant REPUTATION_PARAMETER = 2;
    uint256 public constant CONVICTION_PARAMETER = 3;
    uint256 public constant PERFORMANCE_PARAMETER = 4;
    uint256 public constant GROWTH_PARAMETER = 5;

    uint256 public constant MIN_COMMITMENT = 1;
    uint256 public constant MAX_COMMITMENT = 10;

    uint256 public constant MEMBER_MASK_POSITION = 0;
    uint256 public constant ADMIN_MASK_POSITION = 1;

    address public autID;
    address public pluginRegistry;
    uint256 public archetype;
    uint256 public commitment;
    uint256 public market;
    string public metadataURI;

    mapping(address => uint256) public roles;
    mapping(uint256 => uint256) public parameterWeight;
    mapping(address => uint256) public accountMasks;

    /// @custom:sdk-legacy-interface-compatibility
    address[] public members;
    /// @custom:sdk-legacy-interface-compatibility
    address[] public admins;

    function join(address who, uint256 role) external {
        require(msg.sender == autID, "caller not AutID contract");
        require(canJoin(who, role), "can not join");

        roles[who] = role;

        emit MemberGranted(who, role);
    }

    function canJoin(address who, uint256 role) public view returns(bool result) {
        result = true;
        result = result && !_checkMaskPosition(who, uint8(MEMBER_MASK_POSITION));

    }

    function addAdmin(address who) public {
        require(_checkMaskPosition(msg.sender, uint8(ADMIN_MASK_POSITION)), "caller not an admin");
        
        _addAdmin(who);
    }

    /// @custom:sdk-legacy-interface-compatibility
    function addAdmins(address[] calldata admins_) external {
        require(_checkMaskPosition(msg.sender, uint8(ADMIN_MASK_POSITION)), "caller not an admin");

        for (uint256 i; i != admins_.length; ++i) {
            _addAdmin(admins_[i]);
        }
    }

    function setArchetypeAndParameters(uint8[] calldata input) external {
        require(input.length == 6, "Nova: incorrect input length");
        require(_checkMaskPosition(msg.sender, uint8(ADMIN_MASK_POSITION)), "caller not an admin");

        _validateParameter(input[0]);
        archetype = input[0];
        for (uint256 i = 1; i != 6; ++i) {
            _validateParameter(input[i]);
            parameterWeight[uint8(i)] = input[i];

            emit ParameterSet(uint8(i), input[i]);
        }
        emit ArchetypeSet(input[0]);
    }

    function removeAdmin(address from) external {
        require(from != address(0), "zero address");
        require(_checkMaskPosition(msg.sender, uint8(ADMIN_MASK_POSITION)), "caller not an admin");
        require(msg.sender != from, "admin can not renounce himself");

        _unsetMaskPosition(from, uint8(ADMIN_MASK_POSITION));

        emit AdminRenounced(from);
    }

    function isMember(address who) public view returns(bool) {
        return _checkMaskPosition(who, uint8(MEMBER_MASK_POSITION));
    }

    function isAdmin(address who) public view returns(bool) {
        return _checkMaskPosition(who, uint8(ADMIN_MASK_POSITION));
    }

    function _validateParameter(uint8 parameter) internal pure {
        if (parameter > 5 || parameter == 0) {
            revert WrongParameter();
        }
    }

    /// PRIVATE

    function _addAdmin(address who) internal {
        require(who != address(0), "zero address");
        require(_checkMaskPosition(who, uint8(MEMBER_MASK_POSITION)), "target is not a member");

        _setMaskPosition(who, uint8(ADMIN_MASK_POSITION));
        /// @custom:sdk-legacy-interface-compatibility
        admins.push(who);

        emit AdminGranted(who);
    }
    
    function _checkMaskPosition(address who, uint8 maskPosition) private view returns(bool) {
        return (accountMasks[who] & (1 << maskPosition)) != 0;
    }

    function _setMaskPosition(address to, uint8 maskPosition) private {
        accountMasks[to] |= (1 << maskPosition);
    }

    function _unsetMaskPosition(address to, uint8 maskPosition) private {
        accountMasks[to] |= ~(1 << maskPosition);
    }
}
