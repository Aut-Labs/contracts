import { Task } from '../generated/schema'
import { RegisterTask } from '../generated/TaskRegistry/TaskRegistry'
import { fetchMetadataFromIpfs } from './fetch-metadata';

export function handleRegisterTask(event: RegisterTask): void {
    let task = new Task(event.params.taskId.toHexString())
    task.metadataUri = event.params.uri;
    task.metadataJson = fetchMetadataFromIpfs(event.params.uri);
    task.taskId = event.params.taskId;
    task.creator = event.params.who;
    task.blockNumber = event.block.number;
    task.blockTimestamp = event.block.timestamp;
    task.transactionHash = event.transaction.hash;
    task.save()
}