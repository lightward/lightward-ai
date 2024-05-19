# Events

In Mechanic, an event represents anything that happens. This could be an order being paid, or a customer record being created, or a fulfillment being delivered.

An event always has a topic, and data (even if the data is null/nil). Event attributes may be referenced in Liquid using the Event object.

Events may trigger any number of tasks, resulting in any number of actions.

Events are fed into Mechanic by the responsible party – for events that are about things in Shopify, for example, the events come to Mechanic from Shopify itself.

Incoming events may be selectively skipped using event filters.

[PreviousFetching data from a shared Google sheet](/resources/tutorials/fetching-data-from-a-shared-google-sheet)[NextTopics](/core/events/topics)

Last updated 2023-07-31T17:36:21Z