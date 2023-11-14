import {
  Approval as ApprovalEvent,
  ApprovalForAll as ApprovalForAllEvent,
  AutIDCreated as AutIDCreatedEvent,
  CommitmentUpdated as CommitmentUpdatedEvent,
  DiscordIDConnectedToAutID as DiscordIDConnectedToAutIDEvent,
  Initialized as InitializedEvent,
  MetadataUriSet as MetadataUriSetEvent,
  NovaJoined as NovaJoinedEvent,
  NovaWithdrawn as NovaWithdrawnEvent,
  Transfer as TransferEvent
} from "../generated/AutID/AutID"
import {
  Approval,
  ApprovalForAll,
  AutIDCreated,
  CommitmentUpdated,
  DiscordIDConnectedToAutID,
  Initialized,
  MetadataUriSet,
  NovaJoined,
  NovaWithdrawn,
  Transfer
} from "../generated/schema"

export function handleApproval(event: ApprovalEvent): void {
  let entity = new Approval(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.owner = event.params.owner
  entity.approved = event.params.approved
  entity.tokenId = event.params.tokenId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleApprovalForAll(event: ApprovalForAllEvent): void {
  let entity = new ApprovalForAll(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.owner = event.params.owner
  entity.operator = event.params.operator
  entity.approved = event.params.approved

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleAutIDCreated(event: AutIDCreatedEvent): void {
  let entity = new AutIDCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.owner = event.params.owner
  entity.tokenID = event.params.tokenID
  entity.username = event.params.username

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCommitmentUpdated(event: CommitmentUpdatedEvent): void {
  let entity = new CommitmentUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.NovaExpanderAddress = event.params.NovaExpanderAddress
  entity.member = event.params.member
  entity.newCommitment = event.params.newCommitment

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleDiscordIDConnectedToAutID(
  event: DiscordIDConnectedToAutIDEvent
): void {
  let entity = new DiscordIDConnectedToAutID(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleInitialized(event: InitializedEvent): void {
  let entity = new Initialized(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.version = event.params.version

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleMetadataUriSet(event: MetadataUriSetEvent): void {
  let entity = new MetadataUriSet(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.tokenId = event.params.tokenId
  entity.metadataUri = event.params.metadataUri

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNovaJoined(event: NovaJoinedEvent): void {
  let entity = new NovaJoined(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.NovaExpanderAddress = event.params.NovaExpanderAddress
  entity.member = event.params.member

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNovaWithdrawn(event: NovaWithdrawnEvent): void {
  let entity = new NovaWithdrawn(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.NovaExpanderAddress = event.params.NovaExpanderAddress
  entity.member = event.params.member

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTransfer(event: TransferEvent): void {
  let entity = new Transfer(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.from = event.params.from
  entity.to = event.params.to
  entity.tokenId = event.params.tokenId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
