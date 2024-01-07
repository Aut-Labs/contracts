// SPDX
pragma solidity 0.8.21;

interface IInteractionTracker {
    function processInteraction(address sender, bytes4 selector, bytes calldata args) external;
}

interface INova {
    function interactionTracker() external view returns(IInteractionTracker);
    function accountMasks(address account) external view returns(uint256 mask);
}

abstract contract Application {
    address nova;
}

interface IIApplicationCore {
    function nova() external view returns(address);
}

abstract contract InteractionTarget is Application{
    event InteractionMade(address sender, bytes4 selector, bytes args);
    modifier interaction() {
        _;
        _notifyTracker();
    }
    function _notifyTracker() internal {
        INova(nova).interactionTracker().processInteraction(
            msg.sender,
            msg.sig,
            msg.data
        );
        emit InteractionMade(msg.sender, msg.sig, msg.data);
    }
}

abstract contract ACL is Application {
    modifier requirePermission(uint8 n) {
        uint256 mask = INova(nova).accountMasks(msg.sender);
        require((1 << n) & mask != 0, "unauthorized");
        _;
    }
}

abstract contract LocalACL {
    mapping(address => uint256) internal localAccountMasks;

    modifier requireLocalPermission(uint8 n) {
        require(_hasLocalPermission(n), "locally unauthorized");
        _;
    }

    function _hasLocalPermission(uint8 n) internal view returns(bool) {
        return ((1 << n) & localAccountMasks[msg.sender] != 0);
    }
}

contract CheckInApplication is InteractionTarget, ACL {
    event CheckedIn(address who);
    uint8 private constant MEMBER_PERMISSION = 0;
    uint8 private constant ADMIN_PERMISSION = 1;

    bool isActive;
    mapping(address => bool) public finishedCheckIn;

    constructor() {}

    function setActive(bool status) external requirePermission(ADMIN_PERMISSION) {
        isActive = status;
    }

    function checkIn() external interaction requirePermission(MEMBER_PERMISSION) {
        require(!finishedCheckIn[msg.sender], "already checked-in");

        finishedCheckIn[msg.sender] = true;

        emit CheckedIn(msg.sender);
    }
}


contract ApplicationRegistry {
    mapping(address nova => mapping(bytes32 applicationType => address)) internal _novaAppDeployments;
    mapping(address application => address) internal _novaByApp;

    // invar: app is connected to one and only one nova
    
    function addApplicationType(string memory applicationTypeName, address implementation) external {
        // auth
    }

    function deployNovaApplication(string memory applicationTypeName, bytes calldata initArgs) external {

    }

    function declareAppDiscoveryAlias(address nova, string memory applicationTypeName, string memory applicationAliasName) external {

    }

    function exposeAliasTo(address toApp, bytes32 asAliasHash) external {

    }

    function discover(bytes32 aliasHash) external view returns(address, bytes4) {

    }

    function _nova() internal view returns(address) {
        return _novaByApp[msg.sender];
    }
}