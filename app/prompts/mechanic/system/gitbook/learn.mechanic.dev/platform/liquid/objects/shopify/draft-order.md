# Draft order object

## How to access it

- Use {{ draft\_order }} in tasks responding to shopify/draft\_orders events
- Look up specific draft orders by their ID, using {{ shop.draft\_orders[12345678900] }}

## What it contains

- Every property from the DraftOrder resource in the Shopify REST Admin API
- The related order object, if any: {{ draft\_order.order }}
- The related customer object, if any: {{ draft\_order.customer }}
- An array of line item objects: {{ draft\_order.line\_items }}
- An array of note\_attributes, that also supports lookups by attribute name: {% for attr in draft\_order.note\_attributes %}{% if attr.name == "color" %}{{ attr.value }}{% endif %}{% endfor %} , or {{ draft\_order.note\_attributes.color }}

Last updated 2021-04-05T20:03:27Z