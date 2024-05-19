# Tagging Shopify resources

Merchants commonly use Mechanic for adding or removing tags from customers, orders, products, and other Shopify resources.

When writing your task scripts, use a Shopify action to add or remove tags via the Shopify API. There are two usages available: one using GraphQL, and one using the REST API.

## GraphQL

This is the recommended usage, because – unlike the REST API – it allows for tags to be individually added and removed, without any risk of interfering with simultaneous tagging operations.

Because the permission required varies based on what you're tagging, make sure to render a representative node ID during preview mode to avoid "TagsAdd access denied" errors. In this approach, we use stub data to create dynamic preview actions.

Copy

    {% if event.preview %}
      {% capture customer_json %}
        {
          "admin_graphql_api_id": "gid://shopify/Customer/12345"
        }
      {% endcapture %}
    
      {% assign customer = customer_json | parse_json %}
    {% endif %}
    
    {% action "shopify" %}
      mutation {
        tagsAdd(
          id: {{ customer.admin_graphql_api_id | json }}
          tags: ["some", "new", "tags"]
        ) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}
    
    {% action "shopify" %}
      mutation {
        tagsRemove(
          id: {{ customer.admin_graphql_api_id | json }}
          tags: ["tags", "to", "remove"]
        ) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}

### Logging the results

The one drawback is that using GraphQL does not automatically log the results of a tagging operation, whereas REST does. However, it's easy to include the final tags for a resource, in the results of your GraphQL mutation – very useful for proving that your mutation is doing what you expect, and also for allowing you to refer back to the current tagged state of the resource.

Copy

    {% action "shopify" %}
      mutation {
        tagsAdd(
          id: {{ customer.admin_graphql_api_id | json }}
          tags: ["some", "new", "tags"]
        ) {
          node {
            ... on Customer {
              tags
            }
          }
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}

Note the triple dots: the ... on \ syntax marks an inline fragment. Replace "Customer" with the name of the GraphQL type you're working with (e.g. "Product", or "Order). Read more from Shopify: GraphQL / Advanced Concepts / Inline Fragments.

## REST

This approach is also viable, but has one risk: because it specifies all of the tags at once that the customer should have, it's possible to overwrite tags that some other task or app has added.

Copy

    {% action "shopify" %}
      [
        "update",
        ["customer", {{ customer.id | json }}],
        {
          "tags": {{ customer.tags | add_tag: "approved" | json }}
        }
      ]
    {% endaction %}

Copy

    {% action "shopify" %}
      [
        "update",
        ["customer", {{ customer.id | json }}],
        {
          "tags": {{ customer.tags | remove_tag: "approved" | json }}
        }
      ]
    {% endaction %}

These examples use add\_tag and remove\_tag, which are Liquid filters unique to Mechanic (see Mechanic's list of supported filters).

[PreviousWriting a high-quality task](/techniques/writing-a-high-quality-task)[NextDebouncing events](/techniques/debouncing-events)

Last updated 2021-04-17T19:33:29Z