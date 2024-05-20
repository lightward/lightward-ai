# Variant object

## How to access it

- Use {{ order.line\_items[n].variant }} in tasks responding to shopify/orders events
- Use {{ product.variants[n] }} in tasks responding to shopify/products events

## What it contains

- Every property from the Product Variant resource in the Shopify REST Admin API
- An array of related inventory level objects: {{ variant.inventory\_levels }}
- The related inventory item object: {{ variant.inventory\_item }}
- The related product object: {{ variant.product }}
- The related metafields object: {{ variant.metafields }}

Last updated 2021-04-05T20:03:29Z