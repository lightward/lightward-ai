# Theme asset object

## How to access it

- Look up specific a specific asset by its ID, using {{ shop.themes[12345].assets[67890] }}
- Loop through all assets in a theme: {% for asset in shop.themes[12345]assets %}

## What it contains

- Every property from the Asset resource in the Shopify REST Admin API

[PreviousTheme object](/platform/liquid/objects/shopify/theme)[NextTransaction object](/platform/liquid/objects/shopify/transaction)

Last updated 2021-04-05T20:03:29Z