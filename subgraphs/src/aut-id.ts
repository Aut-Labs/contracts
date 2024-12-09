import { BigInt, Bytes, ipfs, json } from "@graphprotocol/graph-ts";
import {
  HubJoined,
  RecordCreated,
  TokenMetadataUpdated,
} from "../generated/AutID/AutID";
import { AutID, HubJoinedInfo } from "../generated/schema";
import { fetchMetadataFromIpfs } from "./fetch-metadata";

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
  // autID.metadataJson = fetchMetadataFromIpfs(event.params.uri);

  autID.save();
}
export function handleHubJoined(event: HubJoined): void {
  let id = event.params.account.toHexString();
  let autID = AutID.load(id);

  if (autID == null) {
    autID = new AutID(id);
  }

  // Create a new HubJoinedInfo entity
  let hubJoinedInfo = new HubJoinedInfo(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  hubJoinedInfo.autID = autID.id;
  hubJoinedInfo.role = event.params.role;
  hubJoinedInfo.commitment = BigInt.fromI32(event.params.commitmentLevel);
  hubJoinedInfo.hubAddress = event.params.hub as Bytes;
  hubJoinedInfo.save();
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
