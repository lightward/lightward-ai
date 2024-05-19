# GraphQL in Liquid

Tasks may use the shopify Liquid filter to convert GraphQL query strings into simple result objects, by sending the query to the Shopify GraphQL Admin API. The easiest way to build these queries is via the Shopify Admin API GraphiQL explorer, which allows queries to be interactively constructed.

The shopify filter does not support running mutations (i.e. writing Shopify data via GraphQL). To run mutations, use the Shopify action.

## Usage

The shopify filter accepts a GraphQL query string, and returns everything back from Shopify's GraphQL admin API. This means that reading back GraphQL data is as easy as this:

Copy

    {% capture query %}
      query {
        shop {
          name
        }
      }
    {% endcapture %}
    
    {% assign result = query | shopify %}
    
    {% log result.data.shop.name %}

The shopify filter also supports GraphQL variables!

If you're working with multiple pages of data, you might use set up a forloop, using a cursor to retrieve page after page:

Copy

    {% assign cursor = nil %}
    {% assign total_inventory = 0 %}
    
    {% for n in (0..100) %}
      {% capture query %}
        query {
          products(
            first: 250
            after: {{ cursor | json }}
          ) {
            pageInfo {
              hasNextPage
            }
            edges {
              cursor
              node {
                totalInventory
              }
            }
          }
        }
      {% endcapture %}
    
      {% assign result = query | shopify %}
    
      {% if event.preview %}
        {% capture result_json %}
          {
            "data": {
              "products": {
                "edges": [
                  {
                    "node": {
                      "totalInventory": -4
                    }
                  }
                ]
              }
            }
          }
        {% endcapture %}
    
        {% assign result = result_json | parse_json %}
      {% endif %}
    
      {% for product_edge in result.data.products.edges %}
        {% assign product = product_edge.node %}
        {% assign total_inventory = total_inventory | plus: product.totalInventory %}
      {% endfor %}
    
      {% if result.data.products.pageInfo.hasNextPage %}
        {% assign cursor = result.data.products.edges.last.cursor %}
      {% else %}
        {% break %}
      {% endif %}
    {% endfor %}

You'll note that this code includes stub data when running during a preview event. This technique is extremely useful for generating dynamic preview actions, by allowing you to exercise your entire task script.

The hardest part of using GraphQL in Mechanic is writing the query itself. :) For help with this, we recommend installing Shopify's GraphiQL app. It provides an environment where, using auto-complete and built-in documentation, you can rapidly build the right query for your task.

Note: GraphQL queries (excluding whitespace) are limited to 50,000 characters. That's a hard limit, enforced on Shopify's end – if you bump up against it, you'll need to adjust your query strategy to always stay under that limit. If you're saving large values to a metafield, for example, consider separating those values using GraphQL variables, keeping the query itself trim. Learn more about this scenario using the Shopify action, or with the shopify Liquid filter.

## Use GraphQL when...

- ... you want to make things more efficient. GraphQL is fantastic for being really precise about what data you want, which makes your tasks run in less time: no more looping through collections to find your data, and no more downloading data you don't require.

## Don't use GraphQL when...

- ... it's easier and more readable to use Liquid objects, unless performance becomes an issue. Ultimately, the most important thing is that your task works well tomorrow – and that includes making sure that whoever works on it next understands what you're doing. If that means using a quick-and-simple Liquid lookup over a moderately-more-complex GraphQL lookup, go for it.
- ... you find yourself staring at nested loops. Looping through all orders is one thing – it's quite another to loop through pages of orders and loop through pages of line items within each order. For those scenarios, whenever possible, use a bulk operation.

[PreviousLiquid objects](/core/shopify/read/liquid-objects)[NextBulk operations](/core/shopify/read/bulk-operations)

Last updated 2022-04-13T14:10:58Z