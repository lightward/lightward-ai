# Price rule object

## How to access it

- Look up specific price rules by ID, using {{ shop.price\_rules[12345] }}
- Loop through all price rules: {% for price\_rule in shop.price\_rules %}

## What it contains

- Every property from PriceRule resource in the Shopify REST Admin API
- An index of related discount code objects: {{ price\_rule.discount\_codes }}

### Related articles

- The shop object
- The discount code object

Last updated 2021-04-05T20:03:31Z