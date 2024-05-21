[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/location]

# Location object

## How to access it

- Use {% for location in shop.locations %} in any task
- Use {{ order.location.name }} in tasks responding to shopify/orders events
- Use {{ fulfillment.location.name }} in tasks responding to shopify/fulfillments events
- Use {{ inventory\_level.location.name }} in tasks responding to shopify/inventory\_levels events

## What it contains

- Every property from the Location resource in the Shopify REST Admin API

Last updated 2021-04-05T20:03:32Z