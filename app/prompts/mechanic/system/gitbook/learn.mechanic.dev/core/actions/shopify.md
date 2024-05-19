# Shopify

The Shopify action sends requests to the Shopify admin API. It supports both REST and GraphQL requests.

In Mechanic, writing data to Shopify must happen using an action. While the Shopify action is usually the right choice, the HTTP action can also be used for this purpose, by manually configuring authentication headers.

To learn more, see Interacting with Shopify.

## Options

This action has several usage styles, each with a different set of constraints on action options.

### GraphQL

This usage style invokes the Shopify GraphQL Admin API. In this style, a single GraphQL query string is supplied as the action options. The action tag has specific support for this action type, allowing this string to be provided as the contents of an action block.

To prepare complex query inputs, use the graphql\_arguments Liquid filter.

LiquidJSON

Copy

    {% action "shopify" %}
      mutation {
        customerCreate(
          input: {
            email: "test@example.com"
          }
        ) {
          customer {
            id
          }
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": "\n mutation {\n customerCreate(\n input: {\n email: \"test@example.com\"\n }\n ) {\n customer {\n id\n }\n userErrors {\n field\n message\n }\n }\n }\n"
      }
    }

### GraphQL with variables

This usage style invokes the Shopify GraphQL Admin API, and supports combining GraphQL queries with GraphQL variables. This can be useful for re-using queries with multiple inputs, and is critical when dealing with very large pieces of input. Because GraphQL queries (excluding whitespace) are limited in length to 50k characters, GraphQL variables can be used in cases when large inputs (like Base64-encoded images) need to be submitted.

| 

Option

 | 

Description

 |
| 

query

 | 

Required; a string containing a GraphQL query

 |
| 

variables

 | 

Required; a JSON object mapping variable names to values

 |

#### Basic example

LiquidJSON

Copy

    {% capture query %}
      mutation DeleteProduct($productId: ID!) {
        productDelete(
          input: {
            id: $productId
          }
        ) {
          userErrors {
            field
            message
          }
        }
      }
    {% endcapture %}
    
    {% action "shopify" %}
      {
        "query": {{ query | json }},
        "variables": {
          "productId": "gid://shopify/Product/1234567890"
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": {
          "query": "\n mutation DeleteProduct($productId: ID!) {\n productDelete(\n input: {\n id: $productId\n }\n ) {\n userErrors {\n field\n message\n }\n }\n }\n",
          "variables": {
            "productId": "gid://shopify/Product/1234567890"
          }
        }
      }
    }

#### Complex example

This example shows how the query and variables may be built up separately, and provided to the action using concise tag syntax.

LiquidJSON

Copy

    {% assign metafield_owner_id = "gid://shopify/Customer/507332001849" %}
    {% assign metafield_value = hash %}
    {% assign metafield_value["foo"] = "bar" %}
    
    {% capture query %}
      mutation MetafieldsSet($metafields: [MetafieldsSetInput!]!) {
        metafieldsSet(metafields: $metafields) {
          metafields {
            key
            namespace
            value
            createdAt
            updatedAt
          }
          userErrors {
            field
            message
            code
          }
        }
      }
    {% endcapture %}
    
    {% assign metafield = hash %}
    {% assign metafield["ownerId"] = metafield_owner_id %}
    {% assign metafield["namespace"] = "demo" %}
    {% assign metafield["key"] = "demo" %}
    {% assign metafield["type"] = "json" %}
    {% assign metafield["value"] = metafield_value | json %}
    {% assign metafields = array %}
    {% assign metafields = metafields | push: metafield %}
    
    {% assign variables = hash %}
    {% assign variables["metafields"] = metafields %}
    
    {% action "shopify" query: query, variables: variables %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": {
          "query": "\n mutation SetCustomerMetafield(\n $customerId: ID!\n $metafieldNamespace: String!\n $metafieldKey: String!\n $metafieldId: ID\n $metafieldValue: String!\n ) {\n customerUpdate(\n input: {\n id: $customerId\n metafields: [\n {\n id: $metafieldId\n namespace: $metafieldNamespace\n key: $metafieldKey\n valueType: STRING\n value: $metafieldValue\n }\n]\n }\n ) {\n userErrors {\n field\n message\n }\n customer {\n metafield(\n namespace: $metafieldNamespace\n key: $metafieldKey\n ){\n id\n }\n }\n }\n }\n",
          "variables": {
            "customerId": "gid://shopify/Customer/700837494845",
            "metafieldNamespace": "test",
            "metafieldKey": "test",
            "metafieldId": "gid://shopify/Metafield/18788961353789",
            "metafieldValue": "1615244317"
          }
        }
      }
    }

### Resourceful REST

This usage style invokes the Shopify REST Admin API. It accepts an array of option values, containing these elements in order:

1. Operation Must be one of "create" , "update" , or "delete" .
2. Resource specification When creating, use a single string (e.g. "customer" ). When updating or deleting, use an array (e.g. ["customer", 123] ).
3. An object of attributes Only applies to creating and updating.

#### Example: Creating a resource

This example creates a (minimal) customer record.

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "create",
        "customer",
        {
          "email": "test@example.com"
        }
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "create",
          "customer",
          {
            "email": "test@example.com"
          }
        ]
      }
    }

#### Example: Updating a resource

This example appends a line to the order note (assuming a task subscription to shopify/orders/create).

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "update",
        [
          "order",
          {{ order.id | json }}
        ],
        {
          "note": {{ order.note | append: newline | append: newline | append: "We're adding a note! 💪" | strip | json }}
        }
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "update",
          [
            "order",
            3656038711357
          ],
          {
            "note": "[customer-supplied note]\n\nWe're adding a note! 💪"
          }
        ]
      }
    }

#### Example: Deleting a resource

This example deletes a product, having a certain ID.

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "delete",
        ["product", 4814813560893]
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "delete",
          [
            "product",
            4814813560893
          ]
        ]
      }
    }

### Explicit REST

This usage style invokes Shopify REST Admin API. It accepts an array of option values, containing these elements in order:

1. Operation Must be one of "get", "post" , "put" , or "delete"
2. Request path The entire, literal request path to use, including the requested API version — e.g. "/admin/api/2020-01/orders.json"
3. A JSON object of attributes In general, this means a wrapper object whose key is named after the current resource type, and whose value is the same set of data that would be used in the resourceful style

When switching from resourceful to explicit REST, it's common to forget the outer wrapper object. This wrapper is required by Shopify for all request methods except GET and DELETE; it's handled automatically during resourceful usage, but must be handled manually during explicit usage.

#### Example: Creating a resource

This example creates a (minimal) customer record.

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "post",
        "/admin/api/2020-01/customers.json",
        {
          "customer": {
            "email": "test@example.com"
          }
        }
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "post",
          "/admin/api/2020-01/customers.json",
          {
            "customer": {
              "email": "test@example.com"
            }
          }
        ]
      }
    }

#### Example: Updating a resource

This example appends a line to the order note (assuming a task subscription to shopify/orders/create).

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "put",
        "/admin/api/2020-01/orders/{{ order.id }}.json",
        {
          "order": {
            "note": {{ order.note | append: newline | append: newline | append: "We're adding a note! 💪" | strip | json }}
          }
        }
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "put",
          "/admin/api/2020-01/orders/3656063189053.json",
          {
            "order": {
              "note": "We're adding a note! 💪"
            }
          }
        ]
      }
    }

#### Example: Deleting a resource

This example deletes a product, having a certain ID.

LiquidJSON

Copy

    {% action "shopify" %}
      [
        "delete",
        "/admin/api/2020-01/products/4814813724733.json"
      ]
    {% endaction %}

Copy

    {
      "action": {
        "type": "shopify",
        "options": [
          "delete",
          "/admin/api/2020-01/products/4814813724733.json"
        ]
      }
    }

[PreviousReport Toaster](/core/actions/integrations/report-toaster)[NextFile generators](/core/actions/file-generators)

Last updated 2023-07-27T19:49:23Z