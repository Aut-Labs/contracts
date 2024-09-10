import { CreateContribution } from '../generated/TaskFactory/TaskFactory'
import { Contribution } from '../generated/schema'
import { ethereum, Bytes } from '@graphprotocol/graph-ts'

export function handleCreateContribution(event: CreateContribution): void {
  let contribution = new Contribution(event.params.contributionId.toHexString())

  let decoded = ethereum.decode(
    "(bytes32,string,uint256,uint256,uint8,uint8,string)",
    event.params.encodedContribution
  )

  if (decoded !== null) {
    let tuple = decoded.toTuple()
    contribution.taskId = tuple[0].toBytes()
    contribution.role = tuple[1].toString()
    contribution.startDate = tuple[2].toBigInt()
    contribution.endDate = tuple[3].toBigInt()
    contribution.points = tuple[4].toI32()
    contribution.quantity = tuple[5].toI32()
    contribution.description = tuple[6].toString()
  }

  contribution.creator = event.params.sender
  contribution.blockNumber = event.block.number
  contribution.blockTimestamp = event.block.timestamp
  contribution.transactionHash = event.transaction.hash
  contribution.save()
}