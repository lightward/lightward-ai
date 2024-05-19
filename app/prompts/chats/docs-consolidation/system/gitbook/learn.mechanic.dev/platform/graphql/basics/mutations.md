# Mutations

GraphQL mutations create, update, or delete objects in the Shopify GraphQL admin API. A mutation has a name, takes input data, and specifies fields to return in the response.

This page discusses the general concept of a GraphQL mutation. For more detail on how this applies to Mechanic and the Shopify API, see Actions / Shopify.

## Create a product and return the product ID

GraphQL mutationResponse

Copy

    mutation {
      productCreate(input: {title: "Red Ball", productType: "Toy", vendor: "Toys"}) {
       product {
        id
       }
      }
    }

Copy

    {
      "data": {
        "productCreate": {
          "product": {
            "id": "gid://shopify/Product/13588"
          }
        }
      }
    }

## Update a product's type and return the product ID and new type

GraphQL mutationResponse

Copy

    mutation {
      productUpdate(input: {id: "gid://shopify/Product/13588", productType: "Ball"}) {
       product {
        id
        type
       }
      }
    }

Copy

    {
      "data": {
        "productCreate": {
          "product": {
            "id": "gid://shopify/Product/13588"
            "productType" : "Ball"
          }
        }
      }
    }

## Great resources for learning GraphQL mutations

https://shopify.dev/concepts/graphql/mutations

https://www.shopify.com/partners/blog/getting-started-with-graphql

https://graphql.org/learn/queries/

[PreviousQueries](/platform/graphql/basics/queries)[NextPagination](/platform/graphql/basics/pagination)

Last updated 2021-07-21T20:04:35Z