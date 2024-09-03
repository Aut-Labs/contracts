import { Bytes } from "@graphprotocol/graph-ts";
import {
  NovaJoined,
  RecordCreated,
  TokenMetadataUpdated,
} from "../generated/AutID/AutID";
import { AutID, HubJoinedInfo } from "../generated/schema";

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
export function handleNovaJoined(event: NovaJoined): void {
  let id = event.params.account.toHexString();
  let autID = AutID.load(id);

  if (autID == null) {
    autID = new AutID(id);
  }

  // Create a new HubJoinedInfo entity
  let novaJoinedInfo = new HubJoinedInfo(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  novaJoinedInfo.autID = autID.id;
  novaJoinedInfo.role = event.params.role;
  novaJoinedInfo.commitment = event.params.commitment;
  novaJoinedInfo.hubAddress = event.params.nova as Bytes;
  novaJoinedInfo.save();
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
  let txFrom = event.transaction.from; // novaAddress

  if (txFrom) {
    let id = txFrom.toHexString();
    let autID = AutID.load(id);
    if (autID) {
      autID.metadataUri = event.params.uri;
      autID.save();
    }
  }
}

// export function handleNovaWithdrawn(event: NovaWithdrawn): void {
//   let id = event.params.member.toHexString();
//   let autID = AutID.load(id);

//   if (autID) {
//     autID.commitment = BigInt.fromI32(0);
//     autID.novaAddress = Address.zero();
//     autID.save();
//   }
// }
