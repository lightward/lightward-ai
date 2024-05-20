# Theme object

## How to access it

- Use {{ theme }} in tasks responding to shopify/themes events
- Look up specific themes by their ID, using {{ shop.themes[12345678900] }}
- Loop through all themes: {% for theme in shop.themes %}

## What it contains

- Every property from the Theme resource in the Shopify REST Admin API
- An array of asset objects: {{ theme.assets }}

Last updated 2021-04-05T20:03:36Z