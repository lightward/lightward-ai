[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/fulfillment-order]

# Fulfillment order object

## How to access it

- Use {% for fulfillment\_order in order.fulfillment\_orders %} in tasks responding to shopify/orders events

## What it contains

- Every property from the Fulfillment Order resource in the Shopify REST Admin API
- The related order object: {{ fulfillment\_order.order }}

Last updated 2023-11-01T20:20:11Z