import {
  AutIDCreated as AutIDCreatedEvent,
} from "../generated/AutID/AutID"
import {
  AutIDCreated,
} from "../generated/schema"

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
