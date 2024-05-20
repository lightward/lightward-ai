# Gift card object

Note: This API is only available to Shopify Plus stores, who have configured their Mechanic account with a custom Shopify API password.

## How to access it

- Use {% for gift\_card in shop.gift\_cards %} to loop through all gift cards
- Use {% for gift\_card in shop.gift\_cards.enabled %} to loop through all enabled gift cards
- Use {% for gift\_card in shop.gift\_cards.disabled %} to loop through all disabled gift cards
- Use {{ shop.gift\_cards[1234567890] }} to retrieve a single gift card, by ID

## What it contains

- Every property from the Gift Card resource in the Shopify REST Admin API
- The related order object: {{ gift\_card.order }}
- The related customer object: {{ gift\_card.customer }}

Last updated 2021-04-05T20:03:25Z