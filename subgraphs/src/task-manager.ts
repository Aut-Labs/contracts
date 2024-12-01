import { BigInt } from '@graphprotocol/graph-ts'
import { CommitContribution, GiveContribution } from '../generated/TaskManager/TaskManager'
import { ContributionCommit } from '../generated/schema'
import { log } from '@graphprotocol/graph-ts'

export function handleCommitContribution(event: CommitContribution): void {
  let contributionId = event.params.contributionId.toHexString()
  let who = event.params.who
  let commitId = contributionId + '-' + who.toHexString()
  let commit = new ContributionCommit(commitId)
  commit.contribution = event.params.contributionId.toHexString()
  commit.sender = event.params.sender
  commit.hub = event.params.hub
  commit.who = event.params.who
  commit.data = event.params.data
  commit.status = 1 // 1: pending, 2: inactive, 3: completed
  commit.points = new BigInt(0)
  commit.blockNumber = event.block.number
  commit.blockTimestamp = event.block.timestamp
  commit.transactionHash = event.transaction.hash
  commit.save()
}

export function handleGiveContribution(event: GiveContribution): void {
  let contributionId = event.params.contributionId.toHexString()
  let commitId = contributionId + '-' + event.params.who.toHexString()
  let commit = ContributionCommit.load(commitId)
  if (commit == null) {
    log.error('Commit not found: {}', [commitId])
    return
  }
  commit.status = 3 // 1: pending, 2: inactive, 3: completed
  commit.points = event.params.points
  commit.save()
}