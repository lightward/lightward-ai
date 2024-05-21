[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/blog]

# Blog object

## How to access it

- Use {% for blog in shop.blogs %}
- Look up specific blogs by their ID, using {{ shop.blogs[1234567890] }}

## What it contains

- Every property from the Blog resource in the Shopify REST Admin API
- An array of related article objects: {{ blog.articles }}
- The related metafields object: {{ blog.metafields }}

Last updated 2021-04-05T20:03:33Z