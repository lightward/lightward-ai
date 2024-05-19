# Fulfillment object

## How to access it

- Use {% for fulfillment in order.fulfillments %} in tasks responding to shopify/orders events

## What it contains

- Every property from the Fulfillment resource in the Shopify REST Admin API
- The related order object: {{ fulfillment.order }}
- The related location object: {{ fulfillment.location }}
- An array of line item objects: {{ fulfillment.line\_items }}

[PreviousDraft order object](/platform/liquid/objects/shopify/draft-order)[NextFulfillment order object](/platform/liquid/objects/shopify/fulfillment-order)

Last updated 2023-11-01T19:38:45Z