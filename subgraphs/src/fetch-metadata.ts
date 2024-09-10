import { ipfs, json } from "@graphprotocol/graph-ts";

export function fetchMetadataFromIpfs(metadataUri: string): string | null {
  if (metadataUri.startsWith("ipfs://")) {
    let cid = metadataUri.split("ipfs://")[1];
    let metadata = ipfs.cat(cid);
    if (metadata) {
      let parsedMetadata = json.try_fromBytes(metadata);
      if (parsedMetadata.isOk) {
        return parsedMetadata.value.toString();
      } else {
        return null;
      }
    } else {
      return null;
    }
  } else {
    return null;
  }
}
