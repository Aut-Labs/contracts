# Interaction Tree: Technical Specifications

## Core Components

### 1. InteractionFactory.sol
```solidity
struct InteractionTemplate {
    string name;
    string description;
    string logo;
    string actionUrl;
    address contractAddress;
    string contractUri;
    uint256 networkId;
    address author;
    RoyaltyModel royalties;
}

struct RoyaltyModel {
    RoyaltyType rType;     // NONE, PER_INTEGRATION, PER_CALL, TIERED
    uint256 amount;
    address paymentToken;
    mapping(uint8 => uint256) tierAmounts;
}

contract InteractionFactory {
    // Create new interaction template
    function createInteraction(
        InteractionTemplate calldata template
    ) external returns (uint256 templateId);
    
    // Track action performance
    function recordAction(
        uint256 templateId,
        address performer
    ) external;
    
    // View functions
    function getPerformers(uint256 templateId) external view returns (address[] memory);
    function hasPerformed(uint256 templateId, address user) external view returns (bool);
}
```

### 2. OnboardingModule.sol
```solidity
contract OnboardingModule {
    struct Quest {
        uint256 role;
        uint256[] requiredInteractions;
        uint256[] requiredContributions;
        uint256 startTime;
        uint256 duration;
    }
    
    function createQuest(
        uint256 role,
        uint256[] calldata interactions,
        uint256[] calldata contributions,
        uint256 duration
    ) external onlyHubAdmin;
    
    function verifyCompletion(
        address user, 
        uint256 questId
    ) external view returns (bool);
}
```

## Required Functionality

1. **Interaction Creation & Tracking**
   - Create interaction templates
   - Track performers across chains
   - Store historical performance
   - Handle royalty configurations

2. **Quest-based Onboarding**
   - Multi-task requirements
   - Time-bound verification
   - Role-specific paths
   - Automatic verification

## Technical Requirements

1. Deploy on Polygon
2. Track actions across EVM chains
3. Non-transferable NFTs
4. Efficient storage patterns

## Integration Notes
- No approval system needed
- TaskRegistry addition handled by your team
- Focus on creation and tracking only

That's it. Simple, focused functionality that you can later add to TaskRegistry as needed.

