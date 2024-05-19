# I'm getting a "query param length is too long" error when using GraphQL.

This error is about the length of the GraphQL query as a whole (which Shopify limits to 50,000 characters in total), and not about specific strings within the query. (Using an example from the Mechanic task library, this scenario could return this error if the list of list of SKUs is extremely long.)

To work around this error, refactor your query so that any long string values are provided using GraphQL variables, instead of provided inline.

Learn about this technique using the Shopify action, or with the shopify Liquid filter.

If your query isn't using any particularly large string values, you may need to split your query into several pieces instead.

[PreviousWhat's possible with timeline comments?](/faq/whats-possible-with-timeline-comments)[NextCan my Mechanic concurrency limit be raised?](/faq/can-my-mechanic-concurrency-limit-be-raised)

Last updated 2022-04-13T14:12:15Z