# Line item object

## How to access it

- Access an array of line items using {{ order.line\_items }} whenever an order object is available

## What it contains

- Every property from Orders.line\_items in the Shopify REST Admin API
- The related product object: {{ line\_item.product }}
- The related variant object: {{ line\_item.variant }}
- An array of properties, that also supports lookups by attribute name: {% for prop in line\_item.properties %}{% if prop.name == "Delivery window" %}{{ prop.value }}{% endif %}{% endfor %}, or {{ line\_item.properties["Delivery window"] }}

Last updated 2021-04-05T20:03:28Z