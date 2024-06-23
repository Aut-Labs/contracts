import { Bytes } from "@graphprotocol/graph-ts";
import {
  NovaJoined,
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
export function handleNovaJoined(event: NovaJoined): void {
  let id = event.params.account.toHexString();

  let autID = AutID.load(id);
  if (autID == null) {
    autID = new AutID(id);
    autID.joinedNovas = [];
  }

  autID.role = event.params.role;
  autID.commitment = event.params.commitment;
  autID.novaAddress = event.params.nova as Bytes;

  if (autID.joinedNovas == null) {
    autID.joinedNovas = [];
  }

  let novaAddress = event.params.nova as Bytes;
  let novas = autID.joinedNovas as Array<Bytes>;
  novas.push(novaAddress);
  autID.joinedNovas = novas;

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
