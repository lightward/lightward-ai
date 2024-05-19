# API rate limit

Mechanic has native awareness of Shopify's Admin API rate limit, and will accordingly manage the execution of operations that require access to the Shopify API. Mechanic users do not need to manage the API rate limit themselves.

If the rate limit has been reached, any due task runs or Shopify action runs will wait to be enqueued until the rate limit has recovered.

If the rate limit is reached during a run's performance, Mechanic will automatically wait and retry any affected API queries until they succeed, up to a certain number of retries. If the API rate limit does not recover in a reasonable amount of time, Mechanic will raise a permanent error for the run.

Learn more about the Admin API rate limit from Shopify, at https://shopify.dev/api/usage/rate-limits.

## Optimizing API usage

### Query efficiency

When querying for data within a task, use GraphQL whenever possible, rather than using Liquid objects. GraphQL is much more resource-efficient, and usually results in greater operational throughput.

When working with large volumes of data, use a bulk operation. This way, Shopify bears the burden of collecting all relevant data, without in any way playing against the Shopify API rate limit for Mechanic.

### Task configuration

Keep an eye on tasks that are running at the same time, competing for resources. The Shopify API rate limit is shared across each store's entire Mechanic account, which means that simultaneously-running tasks may be in competition for Shopify API usage. Adjustments to task timing (possibly using subscription offsets) can be useful, when making sure that tasks aren't competing. And, in some cases, it may be useful to decrease the overall concurrency limit for a Mechanic account, by emailing team@usemechanic.com.

### Shopify Plus

In high-volume scenarios for Shopify Plus accounts, Mechanic's performance can be improved by creating a custom Shopify app, having the same permissions that you've granted to Mechanic. Because this private app represents your explicit control and intent, it usually comes with a higher API rate limit. (And, in some cases, Shopify can grant this custom app a higher API usage limit, upon request.) By providing Mechanic with this custom app's Shopify Admin API access token, you can extend this higher limit to Mechanic.

This feature is also useful for accessing Plus-only APIs, which are only available to custom Shopify apps. Notably, this includes gift cards (using the gift card object).

This setting can be found in the Mechanic account settings, in the Permissions area. (This setting is only shown for Shopify Plus accounts.) Before adding your API token, you must ensure that the private app has every access scope that Mechanic requires. A list of current required access scopes is provided just below the token field.

Once configured, this custom API token will be used for all user-configured Shopify operations, wherever supported. (It will not be used when querying for publications, since this resource is only accessible to public apps like Mechanic.)

[PreviousShopify admin action links](/core/shopify/admin-action-links)[NextAPI versions](/core/shopify/api-versions)

Last updated 2022-05-29T15:24:02Z