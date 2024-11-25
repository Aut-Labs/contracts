# 1. Consent Management Backend

## Data Structure
```typescript
// Core Tables
interface ConsentRecord {
    walletAddress: string;     // Primary key
    autId: string;            // AutID reference
    interactions: {           // Map of interaction consents
        interactionId: string;
        showInMap: boolean;
        lastUpdated: timestamp;
        signature: string;    // Signed message proving ownership
    }[];
}

// PostgreSQL Structure
CREATE TABLE consent_records (
    wallet_address VARCHAR(42) PRIMARY KEY,
    aut_id VARCHAR NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE interaction_consents (
    wallet_address VARCHAR(42) REFERENCES consent_records(wallet_address),
    interaction_id VARCHAR NOT NULL,
    show_in_map BOOLEAN DEFAULT false,
    signature VARCHAR NOT NULL,
    last_updated TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (wallet_address, interaction_id)
);
```

## Consent Flow
1. User signs message: "I consent to show interaction {interactionId} on map"
2. Backend verifies signature matches wallet
3. Stores consent with timestamp
4. Updates if consent changes

## API Endpoints
```typescript
// Store consent
POST /api/consent
{
    walletAddress: string;
    interactionId: string;
    showInMap: boolean;
    signature: string;
}

// Fetch user consents
GET /api/consent/{walletAddress}

// Update consent
PUT /api/consent
{
    walletAddress: string;
    interactionId: string;
    showInMap: boolean;
    signature: string;
}
```

# 2. Moralis Integration

## Purpose
- Efficiently track cross-chain interactions
- Avoid full chain scanning
- Real-time updates
- Historical data access

## Setup Requirements

### 1. Stream Configuration
```typescript
interface MoralisStream {
    chainId: number;
    contractAddress: string;    // InteractionFactory address
    topic: string;             // Action performed event
    webhookUrl: string;        // Your backend endpoint
    tag: string;               // "interaction-tracking"
}
```

### 2. Event Tracking
```solidity
// Event to track in InteractionFactory
event ActionPerformed(
    uint256 indexed templateId,
    address indexed performer,
    uint256 indexed chainId,
    uint256 timestamp
);
```

## Data Processing Flow

1. **Real-time Actions**
```typescript
interface ActionData {
    templateId: string;
    performer: string;
    chainId: number;
    blockNumber: number;
    transactionHash: string;
    timestamp: number;
}

// Moralis webhook handler
async function handleActionWebhook(data: ActionData) {
    // 1. Validate event
    // 2. Store in database
    // 3. Update interaction stats
}
```

2. **Historical Scanning**
```typescript
interface ScanConfig {
    startBlock: number;
    endBlock: number;
    chainId: number;
    templateId?: string;      // Optional filter
}

// Get past actions
async function getHistoricalActions(config: ScanConfig) {
    return await Moralis.Web3API.native.getContractEvents({
        chain: config.chainId,
        address: FACTORY_ADDRESS,
        topic: ACTION_TOPIC,
        fromBlock: config.startBlock,
        toBlock: config.endBlock
    });
}
```

## Cost Analysis

1. **API Usage**
- Stream cost: Free up to 10M requests/month
- Historical queries: Rate limited by plan
- Recommended plan: Growth ($49/month)
  - 100M requests/month
  - Historical data access
  - Multiple streams

2. **Data Storage**
```typescript
// Average event size
interface EventSize {
    rawData: ~500 bytes,
    processedData: ~200 bytes,
    indexData: ~100 bytes
}

// Monthly storage (100K actions)
totalStorage = eventsCount * (rawData + processedData + indexData)
             = 100000 * (500 + 200 + 100)
             = ~80MB/month
```

## Data Structure

### 1. Moralis Database
```typescript
interface ActionRecord {
    templateId: string;
    performer: string;
    chainId: number;
    blockNumber: number;
    transactionHash: string;
    timestamp: number;
    verified: boolean;
}

// Indexes
- templateId
- performer
- chainId
- timestamp
```

### 2. Local Cache
```typescript
interface TemplateStats {
    templateId: string;
    totalPerformers: number;
    performersByChain: {
        [chainId: number]: number;
    };
    lastAction: timestamp;
}
```

## Integration Steps

1. **Setup**
```typescript
// 1. Configure Moralis
await Moralis.start({
    apiKey: MORALIS_API_KEY,
});

// 2. Create streams
await Moralis.Streams.add({
    chains: [1, 137, ...SUPPORTED_CHAINS],
    address: FACTORY_ADDRESS,
    topic: ACTION_TOPIC,
    webhookUrl: WEBHOOK_URL,
});

// 3. Initialize database indexes
```

2. **Event Processing**
```typescript
// Process new action
async function processAction(event: ActionEvent) {
    // 1. Validate event data
    const isValid = await validateEvent(event);
    
    // 2. Store action
    await storeAction(event);
    
    // 3. Update stats
    await updateTemplateStats(event.templateId);
    
    // 4. Trigger notifications
    await notifySubscribers(event);
}
```

3. **Data Retrieval**
```typescript
// Get template performers
async function getTemplatePerformers(
    templateId: string,
    chainId?: number
): Promise<string[]> {
    return performersByTemplate[templateId];
}

// Check if address performed action
async function hasPerformed(
    templateId: string,
    address: string
): Promise<boolean> {
    return await checkActionExists(templateId, address);
}
```

This setup provides efficient cross-chain action tracking with reasonable costs and good scalability.