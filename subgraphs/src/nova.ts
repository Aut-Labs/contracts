import { NovaCreated } from "../generated/NovaRegistry/NovaRegistry";
import {
  CommitmentSet,
  MarketSet,
  MetadataUriSet,
  ArchetypeSet,
} from "../generated/Nova/Nova";
import { NovaDAO } from "../generated/schema";
import { BigInt } from "@graphprotocol/graph-ts";

export function handleNovaCreated(event: NovaCreated): void {
  let id = event.params.novaAddress.toHexString();
  let nova = NovaDAO.load(id);
  if (nova == null) {
    nova = new NovaDAO(id);
  }
  nova.deployer = event.params.deployer;
  nova.address = event.params.novaAddress;
  nova.market = event.params.market;
  nova.metadataUri = event.params.metadata;
  nova.minCommitment = event.params.commitment;

  // system
  nova.blockNumber = event.block.number;
  nova.blockTimestamp = event.block.timestamp;
  nova.transactionHash = event.transaction.hash;
  nova.save();
}

export function handleMarketSet(event: MarketSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let nova = NovaDAO.load(id);

    if (nova) {
      nova.market = event.params.param0;
      nova.save();
    }
  }
}

export function handleMetadataUriSet(event: MetadataUriSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let nova = NovaDAO.load(id);

    if (nova) {
      nova.metadataUri = event.params.param0;
      nova.save();
    }
  }
}

export function handleCommitmentSet(event: CommitmentSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let nova = NovaDAO.load(id);

    if (nova) {
      nova.minCommitment = event.params.param0;
      nova.save();
    }
  }
}

export function handleArchetypeSet(event: ArchetypeSet): void {
  let txTo = event.transaction.to;

  if (txTo) {
    let id = txTo.toHexString();
    let nova = NovaDAO.load(id);

    if (nova) {
      nova.archetype = new BigInt(event.params.parameter);
    }
  }
}
