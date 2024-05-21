[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/metafields]

# Metafields

Mechanic's Liquid implementation contains three object types that address Shopify's metafield system:

- Metafield — Directly mirrors metafield data from the Shopify REST Admin API, including values that are possibly JSON-encoded strings.
- Metafield representation — Resembles Shopify's metafield variable, containing the metafield type and the parsed, appropriately-typed value. Also contains a reference to the metafield object itself, and to any objects referenced by the metafield (i.e. to a product object, for a product\_reference metafield). Note that metafield representations are not available for or applicable to deprecated metafields.
- Metafield collection — An iterable set of metafields for a resource, which also supports narrowing by namespace, or resolving to an individual metafield by key.

To retrieve the value of a modern metafield, use resource.metafields.namespace.key.value.

To retrieve the value of a deprecated metafield, use resource.metafields.namespace.key.

Last updated 2021-07-28T18:03:28Z