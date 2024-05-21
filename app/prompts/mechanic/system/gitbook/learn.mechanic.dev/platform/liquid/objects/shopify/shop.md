[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/shop]

# 💪Shop object

## How to access it

- Use {{ shop }} in any task, at any time

## What it contains

- Every property from the Shop resource in the Shopify REST Admin API

### Associated resources

Use caution when loading large sets of resources through the shop object. Using code like {% product in shop.products %} will result in Mechanic downloading the complete REST representation of all products in the store, which may be more data than is necessary or useful. When working with large amounts of data, consider using GraphQL instead.

For clarity: looking up a single resource by ID will only result in a single REST API call, as in {% assign product = shop.products[1234567890] %}. If many of these requests are necessary, it may still be useful to look to GraphQL, but this kind of usage does not load more than the specific, single resource identified.

- The admin URL of the shop (e.g. https://admin.shopify.com/store/mechanic-shop/) {{ shop.admin\_url }}
- An index of collection objects {{ shop.collections[1234567890] }} {% for collection in shop.collections %}
- An index of product objects {{ shop.products[1234567890] }} {% for product in shop.products %} {% for product in shop.products.published %}
- An index of variant objects {{ shop.variants[1234567890] }} {% for variant in shop.variants %}
- An index of order objects {{ shop.orders[1234567890] }} {% for order in shop.orders %} {% for order in shop.orders.paid %}
- An index of draft order objects {{ shop.draft\_orders[1234567890] }} {% for draft\_order in shop.draft\_orders.invoice\_sent %}
- An index of customer objects {{ shop.customers[1234567890] }} {{ shop.customers["jdoe@example.com"] }} {% for customer in shop.customers %}
- An index of price rule objects {{ shop.price\_rules[1234567890] }} {% for price\_rule in shop.price\_rules %}
- A lookup of discount code objects {{ shop.discount\_codes["SUMMERTIME"] }}
- An index of blog objects {{ shop.blogs[1234567890] }} {% for blog in shop.blogs %}
- A set of article tags {{ shop.articles.tags }}
- A set of article authors {{ shop.articles.authors }}
- A set of shipping zones {% for shipping\_zone in shop.shipping\_zones %}
- The related metafields object {{ shop.metafields }}

Last updated 2024-04-26T19:18:52Z