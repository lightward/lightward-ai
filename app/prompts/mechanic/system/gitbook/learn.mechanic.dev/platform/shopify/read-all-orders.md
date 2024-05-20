# "Read all orders"

When order access is required, Mechanic defaults to requesting access to the last 60 days of a store's order history. Users can choose to give Mechanic access to all orders, across the store's entire history, by enabling the "Read all orders" option.

#### Why?

Mechanic has a platform policy of requiring as few permissions as necessary. As such, it uses Shopify's read\_orders OAuth scope, which covers the last 60 days of order history. Enabling Mechanic's "Read all orders" setting results in Mechanic requesting the read\_all\_orders scope instead.

## Configuration

Find the "Read all orders" option by opening Mechanic's settings, via the "Settings" link in the main app navigation. Or, navigate directly to https://admin.shopify.com/apps/mechanic/settings.

Last updated 2023-03-08T17:13:46Z