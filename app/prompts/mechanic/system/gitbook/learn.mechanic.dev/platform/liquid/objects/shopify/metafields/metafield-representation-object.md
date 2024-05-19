# Metafield representation object

This page is part of a series: see Metafields for an overview on how Mechanic's Liquid implementation thinks about metafields.

Mechanic's metafield representation object mirrors Shopify's metafield Liquid object, in that it makes the metafield type and value easily available, in a usable form. It is not the same as Mechanic's metafield object, which contains the REST Admin API representation of a metafield.

Metafield representation objects are only available for modern metafield types. They are not available for deprecated metafields (i.e. json\_string, number, and string).

## What it contains

A metafield representation object always contains these three properties:

- type — the type of the metafield (see Shopify's reference list)
- value — the parsed, appropriately-typed value of the metafield
- metafield — the source metafield object, useful for retrieving the metafield ID

### Resource references

For reference types that map to a REST API resource (e.g. page\_reference, product\_reference, and variant\_reference), a metafield representation object also contains a property named after the resource in question.

For example, a product\_reference metafield representation object contains a product property, which holds the associated product object. This means that the referenced product may be retrieved using resource.metafields.namespace.key.product.

## How to access it

A metafield representation object can only be retrieved via metafield collection lookup: resource.metafields.namespace.key.

[PreviousMetafield object](/platform/liquid/objects/shopify/metafields/metafield-object)[NextMetafield collection object](/platform/liquid/objects/shopify/metafields/metafield-collection)

Last updated 2021-07-28T17:45:18Z