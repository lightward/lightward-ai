# Custom authentication

In extraordinary cases, Mechanic can be configured to route Shopify API requests through a custom Shopify app. This may be necessary when a store's Mechanic tasks need to perform work in a way that is only possible via a custom app (e.g. accessing select Shopify APIs, or working with a Shopify API rate limit negotiated for a specific custom app).

## Configuration

Shopify Plus accounts can configure this in the store's Mechanic settings.

Before saving a new access token, you must ensure that the custom app has every access scope that Mechanic requires.

Last updated 2023-06-07T16:32:12Z