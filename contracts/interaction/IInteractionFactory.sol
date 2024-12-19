pragma solidity >=0.8.0;

struct Interaction {
    // TODO
    address placeholder;
}

interface IInteractionFactory {
    /// @notice Return true if the id corresponds to an existing interactionId
    function isInteractionId(uint256 interactionId) external view returns (bool);
}
