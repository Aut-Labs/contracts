import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
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
} from "../generated/AutID/AutID"

export function createApprovalEvent(
  owner: Address,
  approved: Address,
  tokenId: BigInt
): Approval {
  let approvalEvent = changetype<Approval>(newMockEvent())

  approvalEvent.parameters = new Array()

  approvalEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  approvalEvent.parameters.push(
    new ethereum.EventParam("approved", ethereum.Value.fromAddress(approved))
  )
  approvalEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )

  return approvalEvent
}

export function createApprovalForAllEvent(
  owner: Address,
  operator: Address,
  approved: boolean
): ApprovalForAll {
  let approvalForAllEvent = changetype<ApprovalForAll>(newMockEvent())

  approvalForAllEvent.parameters = new Array()

  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("operator", ethereum.Value.fromAddress(operator))
  )
  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("approved", ethereum.Value.fromBoolean(approved))
  )

  return approvalForAllEvent
}

export function createAutIDCreatedEvent(
  owner: Address,
  tokenID: BigInt,
  username: string
): AutIDCreated {
  let autIdCreatedEvent = changetype<AutIDCreated>(newMockEvent())

  autIdCreatedEvent.parameters = new Array()

  autIdCreatedEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  autIdCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenID",
      ethereum.Value.fromUnsignedBigInt(tokenID)
    )
  )
  autIdCreatedEvent.parameters.push(
    new ethereum.EventParam("username", ethereum.Value.fromString(username))
  )

  return autIdCreatedEvent
}

export function createCommitmentUpdatedEvent(
  NovaExpanderAddress: Address,
  member: Address,
  newCommitment: BigInt
): CommitmentUpdated {
  let commitmentUpdatedEvent = changetype<CommitmentUpdated>(newMockEvent())

  commitmentUpdatedEvent.parameters = new Array()

  commitmentUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "NovaExpanderAddress",
      ethereum.Value.fromAddress(NovaExpanderAddress)
    )
  )
  commitmentUpdatedEvent.parameters.push(
    new ethereum.EventParam("member", ethereum.Value.fromAddress(member))
  )
  commitmentUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newCommitment",
      ethereum.Value.fromUnsignedBigInt(newCommitment)
    )
  )

  return commitmentUpdatedEvent
}

export function createDiscordIDConnectedToAutIDEvent(): DiscordIDConnectedToAutID {
  let discordIdConnectedToAutIdEvent = changetype<DiscordIDConnectedToAutID>(
    newMockEvent()
  )

  discordIdConnectedToAutIdEvent.parameters = new Array()

  return discordIdConnectedToAutIdEvent
}

export function createInitializedEvent(version: i32): Initialized {
  let initializedEvent = changetype<Initialized>(newMockEvent())

  initializedEvent.parameters = new Array()

  initializedEvent.parameters.push(
    new ethereum.EventParam(
      "version",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(version))
    )
  )

  return initializedEvent
}

export function createMetadataUriSetEvent(
  tokenId: BigInt,
  metadataUri: string
): MetadataUriSet {
  let metadataUriSetEvent = changetype<MetadataUriSet>(newMockEvent())

  metadataUriSetEvent.parameters = new Array()

  metadataUriSetEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  metadataUriSetEvent.parameters.push(
    new ethereum.EventParam(
      "metadataUri",
      ethereum.Value.fromString(metadataUri)
    )
  )

  return metadataUriSetEvent
}

export function createNovaJoinedEvent(
  NovaExpanderAddress: Address,
  member: Address
): NovaJoined {
  let novaJoinedEvent = changetype<NovaJoined>(newMockEvent())

  novaJoinedEvent.parameters = new Array()

  novaJoinedEvent.parameters.push(
    new ethereum.EventParam(
      "NovaExpanderAddress",
      ethereum.Value.fromAddress(NovaExpanderAddress)
    )
  )
  novaJoinedEvent.parameters.push(
    new ethereum.EventParam("member", ethereum.Value.fromAddress(member))
  )

  return novaJoinedEvent
}

export function createNovaWithdrawnEvent(
  NovaExpanderAddress: Address,
  member: Address
): NovaWithdrawn {
  let novaWithdrawnEvent = changetype<NovaWithdrawn>(newMockEvent())

  novaWithdrawnEvent.parameters = new Array()

  novaWithdrawnEvent.parameters.push(
    new ethereum.EventParam(
      "NovaExpanderAddress",
      ethereum.Value.fromAddress(NovaExpanderAddress)
    )
  )
  novaWithdrawnEvent.parameters.push(
    new ethereum.EventParam("member", ethereum.Value.fromAddress(member))
  )

  return novaWithdrawnEvent
}

export function createTransferEvent(
  from: Address,
  to: Address,
  tokenId: BigInt
): Transfer {
  let transferEvent = changetype<Transfer>(newMockEvent())

  transferEvent.parameters = new Array()

  transferEvent.parameters.push(
    new ethereum.EventParam("from", ethereum.Value.fromAddress(from))
  )
  transferEvent.parameters.push(
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to))
  )
  transferEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )

  return transferEvent
}
