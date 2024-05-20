# Bulk operations

Fetching large amounts of data can exhaust the Shopify API limit for your Mechanic account, slowing down other tasks, and running the risk of consuming too much time or memory for your Mechanic workers.

To solve this general problem, Shopify offers the bulk operations GraphQL API. This API allows you to submit a query to Shopify for processing, the results to be stored elsewhere to be retrieved once the query is complete.

For a review of how Mechanic uses bulk operations, start here: Reading data / Bulk operations.

## Great resources for learning Shopify GraphQL bulk operations

### Key concepts

- bulkOperationRunQuery
- Polling your operation's status (don't worry Mechanic takes care of this for you)
- Data retrieval and JSONL
- Rate limits
- Operation restrictions

https://shopify.dev/tutorials/perform-bulk-operations-with-admin-api

Last updated 2024-01-21T19:23:44Z