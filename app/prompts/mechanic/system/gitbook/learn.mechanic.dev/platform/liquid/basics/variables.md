# Variables

Like other language, Liquid stores information in variables. There are two Liquid tags that facilitate creating variables: assign, and capture.

## Assign

The assign tag creates a new variable.

Copy

    {% assign my_name = "Matt" %}
    
    {% assign is_tired = false %}
    
    {% assign favorite_number = 8 %}

In Mechanic, the assign tag can also create arrays and hashes. This isn't possible in other versions of Liquid – this feature is unique to Mechanic.

## Capture

The capture tag is a useful tool for creating strings of multiple variables, which is very useful in Mechanic. We use this tag extensively in our task code for capturing GraphQL queries, email bodies, and more.

In the following example, the string is captured into a variable named query.

Copy

    {% capture query %}
      query {
        inventoryLevel(id: {{ inventory_level.admin_graphql_api_id | json }}) {
          item {
            variant {
              sku
            }
          }
        }
      }
    {% endcapture %}

Last updated 2021-04-05T20:03:07Z