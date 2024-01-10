import { NovaCreated } from "../generated/NovaRegistry/NovaRegistry";
import { MetadataUriUpdated, CommitmentUpdated } from "../generated/Nova/Nova";
import { NovaDAO } from "../generated/schema";

export function handleNovaCreated(event: NovaCreated): void {
  let id = event.params.novaAddress.toString();
  let nova = NovaDAO.load(id);
  if (nova == null) {
    nova = new NovaDAO(id);
  }
  nova.deployer = event.params.deployer;
  nova.address = event.params.novaAddress;
  nova.market = event.params.market;
  nova.metadataUri = event.params.metadataUri;
  nova.minCommitment = event.params.minCommitment;

  // system
  nova.blockNumber = event.block.number;
  nova.blockTimestamp = event.block.timestamp;
  nova.transactionHash = event.transaction.hash;
  nova.save();
}

export function handleMetadataUriUpdated(event: MetadataUriUpdated): void {
  let id = event.params.novaAddress.toString();
  let nova = NovaDAO.load(id);

  if (nova) {
    nova.metadataUri = event.params.newMetadataUri;
    nova.save();
  }
}

export function handleCommitmentUpdated(event: CommitmentUpdated): void {
  let id = event.params.novaAddress.toString();
  let nova = NovaDAO.load(id);

  if (nova) {
    nova.minCommitment = event.params.newCommitment;
    nova.save();
  }
}
