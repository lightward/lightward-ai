# Discount code object

How to access it

- Look up specific discount codes by price rule ID and discount code ID, using {{ shop.price\_rules[12345].discount\_codes[67890] }}
- Look up a single discount code by its code, using {{ shop.discount\_codes["DISCOUNTABC123"] }}
- Loop through all discount codes for a single: {% for discount\_code in price\_rule.discount\_codes %}

## What it contains

- Every property from the DiscountCode resource in the Shopify REST Admin API
- The related price rule object: {{ price\_rule.discount\_codes }}

### Related articles

- The shop object
- The price rule object

Last updated 2021-04-05T20:03:27Z