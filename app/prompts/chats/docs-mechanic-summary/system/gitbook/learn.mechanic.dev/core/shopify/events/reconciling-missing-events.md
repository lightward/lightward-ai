# Reconciling missing events

Shopify does not offer a strict guarantee on webhook delivery. In rare cases (and usually in high-volume situations), we've observed Shopify fail to send a webhook.

Quoting from Shopify's recommendation for this scenario:

> Your app shouldn't rely solely on receiving data from Shopify webhooks. Because webhook delivery isn't always guaranteed, you should implement reconciliation jobs to periodically fetch data from Shopify.

This applies to Mechanic tasks as well (which are, essentially, tiny apps).

For tasks that respond to events on Shopify resources, we recommend the following, using shopify/orders/create as an example:

1. Update the task code to mark orders as having been processed. This could take the form of an order tag (e.g. "processed-by-task-xyz"), or a metafield. Additionally, ensure that this code skips orders that are already marked as processed.
2. Add a Mechanic scheduler subscription, like mechanic/scheduler/15min. Then, update the task code so that these scheduled runs are used to scan for and process new orders in the last 15 minutes that have not yet been processed. This is the reconciliation step, ensuring that all new orders are ultimately processed, one way or another.

## Example

[PreviousResponding to events](/core/shopify/events)[NextReading data](/core/shopify/read)

Last updated 2021-09-29T14:53:49Z