[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/customer-object]

# Customer object

## How to access it

- Use {{ customer }} in tasks responding to shopify/customers events
- Look up specific customers by their ID, using {{ shop.customers[12345678900] }}
- Look up specific customers by their email address, using {{ shop.customers["test@example.com"] }}

## What it contains

- Every property from the Customer resource in the Shopify REST Admin API (warning: Shopify delivers customer.tags as a comma-delimited string, not an array of strings!)
- {{ customer.account\_activation\_url }}, containing the Shopify-hosted URL where the customer can create a password for their account
- {{ customer.unsubscribe\_url }}, containing the Mechanic-hosted URL where the customer can mark their own customer account as not accepting marketing; see How do I add an unsubscribe link to my emails?
- The related metafields object: {{ customer.metafields }}

Last updated 2021-06-14T23:13:27Z