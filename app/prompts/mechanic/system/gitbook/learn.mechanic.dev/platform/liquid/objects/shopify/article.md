# Article object

## How to access it

- Use {% for article in blog.articles %}
- Look up specific articles by their ID, using {{ shop.blogs[12345].articles[67890] }}
- Use {{ shop.articles.authors }} for an array of the store's article authors
- Use {{ shop.articles.tags }} for a array of the store's article tags

## What it contains

- Every property from the Article resource in the Shopify REST Admin API
- The related blog object: {{ article.blog }}
- The related metafields object: {{ article.metafields }}

Last updated 2021-04-05T20:03:33Z