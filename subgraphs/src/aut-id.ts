import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
  AutIDCreated,
  CommitmentUpdated,
  MetadataUriSet,
  NovaWithdrawn,
} from "../generated/AutID/AutID";
import { AutID } from "../generated/schema";

export function handleAutIDCreated(event: AutIDCreated): void {
  let id = event.params.owner.toString();
  let autID = AutID.load(id);
  if (autID == null) {
    autID = new AutID(id);
  }

  autID.tokenID = event.params.tokenID;
  autID.owner = event.params.owner;
  autID.username = event.params.username;
  autID.novaAddress = event.params.novaAddress;
  autID.role = event.params.role;
  autID.commitment = event.params.commitment;
  autID.metadataUri = event.params.metadataUri;

  // system
  autID.blockNumber = event.block.number;
  autID.blockTimestamp = event.block.timestamp;
  autID.transactionHash = event.transaction.hash;

  autID.save();
}

export function handleCommitmentUpdated(event: CommitmentUpdated): void {
  let id = event.params.member.toString();
  let autID = AutID.load(id);
  if (autID) {
    autID.commitment = event.params.newCommitment;
    autID.save();
  }
}

export function handleMetadataUriSet(event: MetadataUriSet): void {
  let id = event.params.member.toString();
  let autID = AutID.load(id);

  if (autID) {
    autID.metadataUri = event.params.metadataUri;
    autID.save();
  }
}

export function handleNovaWithdrawn(event: NovaWithdrawn): void {
  let id = event.params.member.toString();
  let autID = AutID.load(id);

  if (autID) {
    autID.commitment = BigInt.fromI32(0);
    autID.novaAddress = Address.zero();
    autID.save();
  }
}
