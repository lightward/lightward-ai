# Transaction object

## The transaction object

## How to access it

- Use {% for transaction in order.transactions %} in tasks responding to shopify/orders events
- Use {% for transaction in refund.transactions %} in tasks responding to shopify/refunds events

## What it contains

- Every property from the Transaction resource in the Shopify REST Admin API

[PreviousTheme asset object](/platform/liquid/objects/shopify/theme-asset)[NextVariant object](/platform/liquid/objects/shopify/variant)

Last updated 2021-04-05T20:03:29Z