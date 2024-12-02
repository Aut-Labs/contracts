import { DomainRegistered } from '../generated/HubDomainsRegistry/HubDomainsRegistry'
import { Domain, Hub } from '../generated/schema'

export function handleDomainRegistered(event: DomainRegistered): void {
  // Create or update the Domain entity
  let domain = new Domain(event.params.name)
  domain.hubAddress = event.params.hub
  domain.metadataUri = event.params.uri
  domain.tokenId = event.params.tokenId
  domain.save()

  // Update the NovaDAO entity
  let hub = Hub.load(event.params.hub.toHex())
  if (hub == null) {
    hub = new Hub(event.params.hub.toHex())
  }
  hub.domain = event.params.name
  hub.save()
}