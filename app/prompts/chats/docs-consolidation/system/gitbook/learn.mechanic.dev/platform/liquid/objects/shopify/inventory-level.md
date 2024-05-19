# Inventory level object

## How to access it

- Use {{ order.line\_items[n].variant.inventory\_levels[n] }} in tasks responding to shopify/orders events
- Use {{ product.variants[n].inventory\_levels[n] }} in tasks responding to shopify/products events

## What it contains

- Every property from the InventoryLevel resource in the Shopify REST Admin API
- The related inventory item object: {{ inventory\_level.inventory\_item }}
- The related variant object: {{ inventory\_level.variant }}
- The related location object: {{ inventory\_level.location }}

[PreviousInventory item object](/platform/liquid/objects/shopify/inventory-item)[NextLine item object](/platform/liquid/objects/shopify/line-item)

Last updated 2021-04-05T20:03:26Z