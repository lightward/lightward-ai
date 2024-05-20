# Inventory item object

## How to access it

- Use {{ order.line\_items[n].variant.inventory\_item }} in tasks responding to shopify/orders events
- Use {{ product.variants[n].inventory\_item }} in tasks responding to shopify/products events

## What it contains

- Every property from the InventoryItem resource in the Shopify REST Admin API
- An array of related inventory level objects: {{ variant.inventory\_levels }}
- The related variant object: {{ inventory\_item.variant }}

Last updated 2021-04-05T20:03:28Z