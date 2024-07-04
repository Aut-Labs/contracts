import { Bytes } from "@graphprotocol/graph-ts";
import {
  HubJoined,
  RecordCreated,
  TokenMetadataUpdated,
} from "../generated/AutID/AutID";
import { AutID } from "../generated/schema";

export function handleRecordCreated(event: RecordCreated): void {
  let id = event.params.account.toHexString();

  let autID = AutID.load(id);
  if (autID == null) {
    autID = new AutID(id);
  }

  autID.tokenID = event.params.tokenId;
  autID.owner = event.params.account;
  autID.username = event.params.username;
  autID.metadataUri = event.params.uri;

  autID.blockNumber = event.block.number;
  autID.blockTimestamp = event.block.timestamp;
  autID.transactionHash = event.transaction.hash;

  autID.save();
}
export function handleHubJoined(event: HubJoined): void {
  let id = event.params.account.toHexString();

  let autID = AutID.load(id);
  if (autID == null) {
    autID = new AutID(id);
    autID.joinedHubs = [];
  }

  autID.role = event.params.role;
  autID.commitment = event.params.commitment;
  autID.hubAddress = event.params.hub as Bytes;

  if (autID.joinedHubs == null) {
    autID.joinedHubs = [];
  }

  let hubAddress = event.params.hub as Bytes;
  let hubs = autID.joinedHubs as Array<Bytes>;
  hubs.push(hubAddress);
  autID.joinedHubs = hubs;

  autID.save();
}

// export function handleCommitmentUpdated(event: CommitmentUpdated): void {
//   let id = event.params.member.toHexString();
//   let autID = AutID.load(id);
//   if (autID) {
//     autID.commitment = event.params.newCommitment;
//     autID.save();
//   }
// }

export function handleTokenMetadataUpdated(event: TokenMetadataUpdated): void {
  let txFrom = event.transaction.from; // hubAddress

  if (txFrom) {
    let id = txFrom.toHexString();
    let autID = AutID.load(id);
    if (autID) {
      autID.metadataUri = event.params.uri;
      autID.save();
    }
  }
}

// export function handleHubWithdrawn(event: HubWithdrawn): void {
//   let id = event.params.member.toHexString();
//   let autID = AutID.load(id);

//   if (autID) {
//     autID.commitment = BigInt.fromI32(0);
//     autID.hubAddress = Address.zero();
//     autID.save();
//   }
// }
