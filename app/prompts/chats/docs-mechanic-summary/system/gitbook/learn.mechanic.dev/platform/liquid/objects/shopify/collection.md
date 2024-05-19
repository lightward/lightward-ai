# Collection object

## How to access it

- Use {{ collection }} in tasks responding to shopify/collections events
- Look up specific collections by their ID, using {{ shop.collections[1234567890] }}
- Locate it in the array of product collections, using {{ products.collections[0] }}, in tasks responding to shopify/products events

## What it contains

- Every property from the Collection resource in the Shopify REST Admin API — see documentation for custom collections, and for automatic/smart collections
- An array of related product objects, ordered by their position in the collection: {{ collection.products }}

[PreviousBlog object](/platform/liquid/objects/shopify/blog)[NextCustomer object](/platform/liquid/objects/shopify/customer-object)

Last updated 2021-04-05T20:03:27Z