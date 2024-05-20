# Order object

## How to access it

- Use {{ order }} in tasks responding to shopify/orders events
- Use {{ refund.order }} in tasks responding to shopify/refunds events
- Look up specific orders by their ID, using {{ shop.orders[12345678900] }}
- Loop through all open orders: {% for order in shop.orders %}

Or, loop through all orders, not just open orders: {% for order in shop.orders.any %}

Or, use these sub-objects to loop through certain subsets of orders: shop.orders.open shop.orders.closed shop.orders.cancelled shop.orders.authorized shop.orders.pending shop.orders.paid shop.orders.partially\_paid shop.orders.refunded shop.orders.voided shop.orders.partially\_refunded shop.orders.unpaid shop.orders.shipped shop.orders.partial shop.orders.unshipped

Or, combine to be even more selective: shop.orders.any.paid.unshipped shop.orders.refunded.shipped shop.orders.open.pending.unshipped

## What it contains

- Every property from the Order resource in the Shopify REST Admin API (warning: Shopify delivers order.tags as a comma-delimited string, not an array of strings!)
- The related customer object: {{ order.customer }}
- An array of line item objects: {{ order.line\_items }}
- An array of refund objects: {{ order.refunds }}
- An array of order risk objects: {{ order.risks }}
- An array of transaction objects: {{ order.transactions }}
- An array of fulfillment objects: {{ order.fulfillments }}
- An array of fulfillment orders objects: {{ order.fulfillment\_orders }}
- An array of note attributes, that also supports lookups by attribute name: {% for attr in order.note\_attributes %}{% if attr.name == "color" %}{{ attr.value }}{% endif %}{% endfor %}, or {{ order.note\_attributes.color }}

## Notes

Out of the box, only orders from the last 60 days are accessible. To give Mechanic access to your complete order history, enable "read all orders".

Last updated 2023-11-01T19:43:58Z