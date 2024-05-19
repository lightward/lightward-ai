# Can my Mechanic concurrency limit be raised?

Perhaps! This question can come up when the Mechanic queue for a particular store becomes backlogged, delaying task activity. Queue concurrency is controlled by each store's Mechanic concurrency limit.

In most cases, an inefficient run queue is best addressed by combining or reorganizing tasks, improving Shopify API usage efficiency (converting REST requests to GraphQL is often helpful), or by making judicious use of event filters.

It can be also useful to temporarily disable a task responsible for the backup; doing so will cause Mechanic to instantly fail its enqueued runs when they come up for processing, but it will not fail those task runs ahead of time.

The limit can be evaluated and adjusted on a case-by-case basis with the platform support team. Contact team@usemechanic.com with your shop domain and as many specifics about your scenario as possible, and we can discuss from there.

[PreviousI'm getting a "query param length is too long" error when using GraphQL.](/faq/query-param-length-is-too-long)[NextWhat IP address does Mechanic use?](/faq/what-ip-address-does-mechanic-use)

Last updated 2023-03-20T16:22:06Z