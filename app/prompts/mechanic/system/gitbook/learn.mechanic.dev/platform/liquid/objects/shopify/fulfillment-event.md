# Fulfillment event object

## How to access it

- Use {{ fulfillment\_event }} in tasks responding to shopify/fulfillment\_events events

## What it contains

- Every property from the FulfillmentEvent resource in the Shopify REST Admin API
- The related order object: {{ fulfillment\_event.order }}
- The related fulfillment object: {{ fulfillment\_event.fulfillment }}

Last updated 2021-04-05T20:03:26Z