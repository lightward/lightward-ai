# Stub data

Stub data is hard-coded into a task, providing an unchanging source of data for previews. It is an important tool when generating dynamic preview actions. Stub data may be used for user-defined variables, but may also override environment variables as needed.

For controlling preview event data (i.e. the values in event.data, and values found in event subject variables), use defined preview events to cleanly specify these values outside of the task code.

## Stubbing Liquid variables

Most tasks make decisions based on the Liquid variables automatically provided, making it a common practice to stub them during preview mode. Any and all Liquid variables may be replaced by stub data, including event and any event subject variables.

In simple cases, replacement objects may be constructed using the assign tag.

The stub data in the following examples include an ID for the order, so as to generate a realistic tagsAdd mutation during preview mode.

Realistic preview actions are important for users and developers, but there's a functional importance for tagsAdd mutations in particular: in preview mode, Mechanic looks at the id argument in order to determine what kind of resource will be tagged, in order to determine what permissions this particular mutation requires. If you generate tagsAdd mutations during preview, make sure to use realistic ID values!

Copy

    {% if event.preview %}
      {% assign order = hash %}
      {% assign order["source_name"] = "web" %}
      {% assign order["admin_graphql_api_id"] = "gid://shopify/Order/1234567890" %}
    {% endif %}
    
    {% if order.source_name == "web" %}
      {% action "shopify" %}
        mutation {
          tagsAdd(id: {{ order.admin_graphql_api_id | json }}, tags: "web") {
            userErrors { field, message }
          }
        }
      {% endaction %}
    {% endif %}

It's also possible to construct this data using parse\_json.

Copy

    {% if event.preview %}
      {% capture order_json %}
        {
          "source_name": "web",
          "admin_graphql_api_id": "gid://shopify/Order/1234567890"
        }
      {% endcapture %}
    
      {% assign order = order_json | parse_json %}
    {% endif %}
    
    {% if order.source_name == "web" %}
      {% action "shopify" %}
        mutation {
          tagsAdd(id: {{ order.admin_graphql_api_id | json }}, tags: "web") {
            userErrors { field, message }
          }
        }
      {% endaction %}
    {% endif %}

## Stubbing GraphQL data

Mechanic makes GraphQL data available to tasks via the shopify filter. Mechanic observes the shopify filter in action during preview mode, using its inputs to inform Mechanic's knowledge of what permissions the task needs.

For this reason, it's important to allow the shopify filter to run normally, and construct stub data afterwards.

It can be useful to specify stub data using JSON, fed through the parse\_json filter. Sample JSON is easy to generate using Shopify's GraphiQL app.

GraphQL with stub dataGraphQL pagination with stub data

Copy

    {% capture query %}
      query {
        publications(first: 250) {
          edges {
            node {
              id
              name
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
            "publications": {
              "edges": [
                {
                  "node": {
                    "id": "gid://shopify/Publication/69217648807",
                    "name": "Online Store"
                  }
                }
              ]
            }
          }
        }
      {% endcapture %}
    
      {% assign result = result_json | parse_json %}
    {% endif %}
    
    {% log available_publications: result.data.publications %}

Copy

    {% assign cursor = nil %}
    {% assign total_inventory = 0 %}
    
    {% for n in (0..100) %}
      {% capture query %}
        query {
          orders(
            first: 250
            query: "status:open"
            after: {{ cursor | json }}
          ) {
            pageInfo { hasNextPage }
            edges {
              node { name, email }
            }
          }
        }
      {% endcapture %}
    
      {% assign result = query | shopify %}
    
      {% if event.preview %}
        {% capture result_json %}
          {
            "data": {
              "orders": {
                "pageInfo": {
                  "hasNextPage": false
                },
                "edges": [
                  {
                    "node": {
                      "name": "#1135",
                      "email": "isaac@example.com"
                    }
                  }
                ]
              }
            }
          }
        {% endcapture %}
    
        {% assign result = result_json | parse_json %}
      {% endif %}
    
      {% for order_edge in result.data.orders.edges %}
        {% assign order_node = order_edge.node %}
    
        {% if order_node.email == blank %}
          {% continue %}
        {% endif %}
    
        {% action "email" %}
          {
            "to": {{ order_node.email | json }},
            "subject": {{ "We're still working on " | append: order_node.name | json }},
            "body": "Thanks for your patience!"
          }
        {% endaction %}
      {% endfor %}
    
      {% if result.data.orders.pageInfo.hasNextPage %}
        {% assign cursor = result.data.orders.edges.last.cursor %}
      {% else %}
        {% break %}
      {% endif %}
    {% endfor %}

[PreviousDefining preview events](/core/tasks/previews/events)[NextShopify API version](/core/tasks/shopify-api-version)

Last updated 2022-05-05T16:16:08Z