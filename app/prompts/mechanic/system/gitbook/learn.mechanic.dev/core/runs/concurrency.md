# Concurrency

In general, Mechanic will process as many runs simultaneously as possible. This means that multiple tasks subscribing to the same event topic are very likely to execute simultaneously, when such an event occurs.

To protect the health of the system and to ensure performance for every store on the platform, Mechanic have several concurrency limits, defining the conditions in which Mechanic will perform runs simultaneously.

In most cases, an inefficient run queue is best addressed by combining or reorganizing tasks, improving Shopify API usage efficiency (converting REST requests to GraphQL is often helpful), or by making judicious use of event filters.

It can be also useful to temporarily disable a task responsible for the backup; doing so will cause Mechanic to instantly fail its enqueued runs when they come up for processing, but it will not fail those task runs ahead of time.

## Limits

Each store's Mechanic account has a fixed run queue size. This limit controls how many runs Mechanic will perform simultaneously for your store. With a limit of 5, this could mean 5 events, or 5 tasks, or 1 event and 2 tasks and 2 actions, or any other combination of runs. Additional runs will be performed as the preceding runs complete.

Related FAQ: Can my Mechanic concurrency limit be raised?

## Tips

- To ensure that your tasks are working with up-to-date information, consider reloading your resources at the beginning of the task script. For example, a task responding to a customer event might include {% assign customer = customer.reload %} at the very beginning, to ensure that any changes to the customer (since the original event) are reflected in the customer variable.
- Use GraphQL to query Shopify, to keep your data usage efficient. (To learn more, see Interacting with Shopify.)
- For options for ordering execution of runs, see Ordering.

[PreviousScheduling](/core/runs/scheduling)[NextOrdering](/core/runs/ordering)

Last updated 2023-03-20T16:22:06Z