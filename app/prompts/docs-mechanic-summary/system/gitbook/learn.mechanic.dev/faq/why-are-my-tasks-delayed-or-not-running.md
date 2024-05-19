# Why are my tasks delayed or not running?

In general, there are two reasons why a task might be delayed, or might not be appearing to run:

1. Your Mechanic queue is backed up
2. The upstream service (like Shopify) is delayed in sending notifications to Mechanic

Using Mechanic for a business-critical purpose? Learn about monitoring Mechanic.

## If your Mechanic queue is backed up...

... then you'll see a steady stream of incoming activity, in your account's activity log, but you might not see activity corresponding to the very latest events in your store. Mechanic has some concurrency limits that determine how much can happen in your account at once, and if you reach those limits, processing of new events will be delayed until Mechanic catches up.

Related FAQ: Can my Mechanic concurrency limit be raised?

## If upstream service is delayed in sending notifications to Mechanic...

... then you won't see anything appearing in Mechanic's activity log. If that service is Shopify, you might see something reported on Shopify's status page.

In most cases, delays are resolved in time, and the delayed events are later on sent to Mechanic, where they can be processed.

In very rare cases, Shopify may erroneously miss an event entirely. This is a documented behavior of Shopify's webhook system. To learn more about this, see Reconciling missing events.

### A note about update events

So as to avoid sending out floods of notifications, Shopify waits a few seconds before sending notifications for update events, to see if any other updates occur that should be included in the notification.

For example, if you change a product's title, then save it, then notice a mistake and change the title again, Shopify may only send a single update instead of two. This means that update events take a little longer to arrive than other events.

Read more about this from Shopify

[PreviousDo you have a Partner-friendly plan?](/faq/do-you-have-a-partner-friendly-plan)[NextMy task is failing because of a permissions problem. Why?](/faq/my-task-is-failing-because-of-a-permissions-problem)

Last updated 2023-03-21T00:51:24Z