# Product object

## How to access it

- Use {{ product }} in tasks responding to shopify/products events
- Look up specific products by their ID, using {{ shop.products[1234567890] }}
- List published products using {{ shop.products.published }}
- List unpublished products using {{ shop.products.unpublished }}

## What it contains

- Every property from the Product resource in the Shopify REST Admin API (warning: Shopify delivers product.tags as a comma-delimited string, not an array of strings!)
- An array of related variant objects: {{ product.variants }}
- An array of related collection objects: {{ product.collections }}
- An array of related product image objects: {{ product.images }}
- The related metafields object: {{ product.metafields }}

[PreviousPrice rule object](/platform/liquid/objects/shopify/price-rule)[NextProduct image object](/platform/liquid/objects/shopify/product-image)

Last updated 2021-04-05T20:03:30Z