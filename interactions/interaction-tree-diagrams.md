# Interaction Tree: System Architecture

## Core System Architecture
```mermaid
graph TD
    A[InteractionFactory] --> B[InteractionNFT]
    A --> C[Action Tracking]
    D[OnboardingModule] --> B
    E[Moralis] --> C
```

## Contract Relationships
```mermaid
graph LR
    A[InteractionFactory] --> B[Template Creation]
    A --> C[Action Tracking]
    D[OnboardingModule] --> E[Quest Management]
    B --> F[InteractionNFT]
    C --> G[Performance History]
```

## Data Flow Architecture
```mermaid
graph TD
    A[User Action] --> B[Cross-Chain Tracking]
    B --> C[Moralis Indexing]
    C --> D[Performance History]
    D --> E[Hub Integration]
    D --> F[Map Display]
```

## Template Creation Flow
```mermaid
graph LR
    A[Creator] --> B[Template Metadata]
    B --> C[InteractionFactory]
    C --> D[NFT Minting]
    D --> E[Action Tracking]
```

## Onboarding Architecture
```mermaid
graph TD
    A[Hub Admin] --> B[Quest Creation]
    B --> C[Requirements]
    C --> D[Interactions]
    C --> E[Contributions]
    D --> F[Verification]
    E --> F
```

## Cross-Chain Tracking
```mermaid
graph LR
    A[Action] --> B[Moralis Stream]
    B --> C[Indexing]
    C --> D[Storage]
    D --> E[Verification]
```

## Integration Points
```mermaid
graph TD
    A[Interaction Tree] --> B[Hub System]
    A --> C[AutID]
    A --> D[Task Registry]
    B --> E[Member Actions]
    C --> F[Network Display]
```

## Storage Architecture
```mermaid
graph LR
    A[Template Data] --> B[IPFS/Arweave]
    C[Performance Data] --> D[Moralis]
    E[Consent Data] --> F[Backend DB]
```

## User Flow
```mermaid
graph TD
    A[Create Template] --> B[Track Actions]
    B --> C[Record Performance]
    C --> D[Hub Usage]
    C --> E[Map Display]
```

## Permission Structure
```mermaid
graph TD
    A[Template Creator] --> B[Create/Edit Template]
    C[Performer] --> D[Execute Action]
    E[Hub Admin] --> F[Configure Usage]
```

