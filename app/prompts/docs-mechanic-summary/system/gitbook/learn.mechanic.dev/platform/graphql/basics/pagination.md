# Pagination

Shopify uses cursor-based pagination, and this is a concept you will frequently use in your Mechanic tasks. Shopify has excellent coverage on the topics, I highly recommend reviewing their documentation.

In the query below you'll notice the fieldspageInfo and cursor. These are important concepts for pagination, make sure to review them in the resources listed below. Page info tells us if there is another page of results before or after the current page. The cursor field provides a reference to an edge's position, which is then used as an anchor to retrieves nodes before or after it in the connection.

Copy

    query {
      orders(first:10) {
        pageInfo { # Returns details about the current page of results
          hasNextPage # Whether there are more results after this page
          hasPreviousPage # Whether there are more results before this page
        }
        edges {
          cursor # A marker for an edge's position in the connection
          node {
            name # The fields to be returned for each node
          }
        }
      }
    }

## Great resources for learning GraphQL pagination

### Key concepts to read up on

- Connections
- Edges
- Nodes
- pageInfo
- hastNextPage
- hasPreviousPage
- cursor
- Cursor-based pagination

https://shopify.dev/concepts/graphql/pagination

https://graphql.org/learn/pagination/

[PreviousMutations](/platform/graphql/basics/mutations)[NextBulk operations](/platform/graphql/bulk-operations)

Last updated 2021-04-05T20:03:31Z