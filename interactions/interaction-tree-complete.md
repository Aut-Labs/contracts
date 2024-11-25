# Interaction Tree System Overview

## Context-Agnostic Interaction Templates

These are NFTs that represent standardized on-chain actions. Think of them as universal building blocks for any web3 community. When someone creates an interaction template through the factory, they're defining an action that can be:
- Tracked across any EVM chain
- Used by any Hub
- Displayed (with consent) in any interface
- Part of any onboarding quest

Each template contains:
- What the action is (name, description, logo)
- Where it happens (action URL, contract, network)
- How to verify it (contract calls/events to check)
- Who created it
- Whether/how it's monetized (royalty model)

The "context-agnostic" part means these templates exist independently of how they're used. The same "Github Contribution" template could be:
- Part of a developer onboarding quest in one Hub
- A high-reward task in another Hub
- A connection point between members in the map
- A requirement for a role in another community

The NFT isn't received by users who perform the action - it just serves as the immutable definition of what constitutes that action, who created it, and how to verify it happened. The factory mints these NFTs to template creators, but they're non-transferable since they're just action definitions.

## Onboarding

The onboarding module is a simple contract deployed alongside each Hub during Hub creation. It lets Hub admins create "quests" - essentially multi-step onboarding requirements for different roles.

For now, we only need the "Quest" type of onboarding, where admins can specify which interactions and/or contributions a user needs to complete to qualify for a specific role. For example, to join as a Developer (Role 2), they might need to have completed a GitHub contribution and joined the Discord.

Each quest has:
- Which role it's for
- What interactions/contributions are required
- How long the quest is valid for
- When it starts being available

When someone wants to join the Hub in a specific role, the module automatically checks if they completed the required interactions and contributions, either in the past or after the quest was created.

## Backend for Consent Storage

The backend needs a simple database (PostgreSQL is fine) to store whether an AutID holder wants to show a specific interaction in the map visualization. For each wallet address (which is mapped to their AutID), we store which interactions they want to show. When they decide to show or hide an interaction, they sign a message with their wallet to prove ownership, and we store this preference with the signature.

When the map needs to display connections, it queries this database to know which interactions each user has consented to show. This keeps the map privacy-friendly, as users control what's displayed about their activity.

## Moralis Integration for Action Tracking

Rather than scanning entire blockchains to find who performed which interactions, we use Moralis to efficiently track and index this data. Here's how:

When an interaction template is created in the InteractionFactory, we set up a Moralis stream to track the "action performed" events for that template. These streams work across all EVM chains, so we catch the action whether it happened on Ethereum, Polygon, or other networks.

For historical data (actions that happened before we set up the stream), Moralis can quickly query past events using their indexed data, much faster and cheaper than doing it ourselves.

The integration is straightforward:
1. We tell Moralis which event to track (when someone performs an interaction)
2. Moralis indexes these events across chains
3. We can query Moralis to know:
   - Who performed a specific interaction
   - When they did it
   - On which chain it happened

Cost-wise, Moralis is efficient because we only pay for the API calls we need, and their basic plan (around $50/month) should handle thousands of interactions easily. This is much cheaper than running our own indexing infrastructure.

The data we get from Moralis maps directly to our InteractionFactory's needs - we know exactly who performed what and when, making it simple to verify actions and track participation across the ecosystem.

