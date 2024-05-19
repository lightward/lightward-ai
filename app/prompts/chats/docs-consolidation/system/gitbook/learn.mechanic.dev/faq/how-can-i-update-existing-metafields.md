# How can I update existing metafields?

Metafields may be managed using the Shopify action, whether you use REST or GraphQL. While metafields can be uniquely referenced for a resource, using their namespace and key, any updates to them must include the metafield ID.

Any attempts to update an existing metafield, without providing the ID, will receive this error from Shopify:

Copy

    Received a Shopify error (resource invalid): metafields.key must be unique within this namespace on this resource

Use the following code as an example for how you might create a metafield if is missing, or update it if it already exists, using either REST or GraphQL:

Copy

    {% assign customer = shop.customers[1234567890] %}
    
    {% assign rest_metafield = customer.metafields | where: "namespace", "testing" | where: "key", "REST" | first %}
    {% assign graphql_metafield = customer.metafields | where: "namespace", "testing" | where: "key", "GraphQL" | first %}
    
    {% action "shopify" %}
      [
        "update",
        [
          "customer",
          1234567890
        ],
        {
          "metafields": [
            {
              "id": {{ rest_metafield.id | json }},
              "namespace": "testing",
              "key": "REST",
              "value": "test!",
              "type": "single_line_text_field"
            }
          ]
        }
      ]
    {% endaction %}
    
    {% action "shopify" %}
      mutation {
        customerUpdate(
          input: {
            id: "gid://shopify/Customer/1234567890"
            metafields: [
              {
                id: {{ graphql_metafield.admin_graphql_api_id | json }}
                namespace: "testing"
                key: "GraphQL"
                value: "test!"
                type: "single_line_text_field"
              }
            ]
          }
        ) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}

[PreviousHow do I preview email attachments?](/faq/how-do-i-preview-email-attachments)[NextCan I query external APIs?](/faq/can-i-query-external-apis)

Last updated 2022-05-19T15:49:30Z