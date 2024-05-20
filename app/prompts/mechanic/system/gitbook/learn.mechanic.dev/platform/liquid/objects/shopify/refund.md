# Refund object

## How to access it

- Use {{ refund }} in tasks responding to shopify/refunds events
- Use {% for refund in order.refunds %} in tasks responding to shopify/orders events

## What it contains

- Every property from the Refund resource in the Shopify REST Admin API
- The related order object: {{ refund.order }
- An array of refund line items, each containing a line item object: {{ refund.refund\_line\_items.first.line\_item }}

Last updated 2021-04-05T20:03:29Z