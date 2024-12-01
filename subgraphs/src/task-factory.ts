import { CreateContribution } from '../generated/TaskFactory/TaskFactory'
import { Contribution } from '../generated/schema'

export function handleCreateContribution(event: CreateContribution): void {
  let contribution = new Contribution(event.params.contributionId.toHexString())

  contribution.taskId = event.params.taskId
  contribution.role = event.params.role
  contribution.startDate = event.params.startDate
  contribution.endDate = event.params.endDate
  contribution.points = event.params.points
  contribution.quantity = event.params.quantity
  contribution.descriptionId = event.params.descriptionId
  contribution.hubAddress = event.params.hub

  contribution.creator = event.params.sender
  contribution.blockNumber = event.block.number
  contribution.blockTimestamp = event.block.timestamp
  contribution.transactionHash = event.transaction.hash
  contribution.save()
}