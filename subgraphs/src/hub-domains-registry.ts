import { DomainRegistered } from '../generated/HubDomainsRegistry/HubDomainsRegistry'
import { Domain, Hub } from '../generated/schema'

export function handleDomainRegistered(event: DomainRegistered): void {
  // Create or update the Domain entity
  let domain = new Domain(event.params.domain)
  domain.hubAddress = event.params.hubAddress
  domain.metadataUri = event.params.metadataUri
  domain.tokenId = event.params.tokenId
  domain.save()

  // Update the NovaDAO entity
  let hub = Hub.load(event.params.hubAddress.toHex())
  if (hub == null) {
    hub = new Hub(event.params.hubAddress.toHex())
  }
  hub.domain = event.params.domain
  hub.save()
}