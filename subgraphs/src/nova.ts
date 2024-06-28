import { NovaCreated } from "../generated/NovaRegistry/NovaRegistry";
import {
  CommitmentSet,
  MarketSet,
  MetadataUriSet,
  ArchetypeSet,
} from "../generated/Nova/Nova";
import { Hub } from "../generated/schema";
import { BigInt } from "@graphprotocol/graph-ts";

export function handleNovaCreated(event: NovaCreated): void {
  let id = event.params.novaAddress.toHexString();
  let hub = Hub.load(id);
  if (hub == null) {
    hub = new Hub(id);
  }
  hub.deployer = event.params.deployer;
  hub.address = event.params.novaAddress;
  hub.market = event.params.market;
  hub.metadataUri = event.params.metadata;
  hub.minCommitment = event.params.commitment;

  // system
  hub.blockNumber = event.block.number;
  hub.blockTimestamp = event.block.timestamp;
  hub.transactionHash = event.transaction.hash;
  hub.save();
}

export function handleMarketSet(event: MarketSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let hub = Hub.load(id);

    if (hub) {
      hub.market = event.params.param0;
      hub.save();
    }
  }
}

export function handleMetadataUriSet(event: MetadataUriSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let hub = Hub.load(id);

    if (hub) {
      hub.metadataUri = event.params.param0;
      hub.save();
    }
  }
}

export function handleCommitmentSet(event: CommitmentSet): void {
  let txTo = event.transaction.to; // novaAddress

  if (txTo) {
    let id = txTo.toHexString();
    let hub = Hub.load(id);

    if (hub) {
      hub.minCommitment = event.params.param0;
      hub.save();
    }
  }
}

export function handleArchetypeSet(event: ArchetypeSet): void {
  let txTo = event.transaction.to;

  if (txTo) {
    let id = txTo.toHexString();
    let hub = Hub.load(id);

    if (hub) {
      hub.archetype = new BigInt(event.params.parameter);
    }
  }
}
