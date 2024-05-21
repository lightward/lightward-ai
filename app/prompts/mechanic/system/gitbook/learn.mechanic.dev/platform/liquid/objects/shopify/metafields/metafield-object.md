[Original URL: https://learn.mechanic.dev/platform/liquid/objects/shopify/metafields/metafield-object]

# Metafield object

This page is part of a series: see Metafields for an overview on how Mechanic's Liquid implementation thinks about metafields.

The metafield object reflects the REST Admin API's representation of a metafield.

Mechanic includes support for the metafield object for completeness, but it is not the most useful way to go about using metafield values (see Metafield representation object).

## What it contains

- Every property from the Metafield resource in the Shopify REST Admin API

For many metafield types (e.g. dimension, weight, decimal, etc), the value attribute of the metafield object is a JSON-encoded string. For most scalar types (e.g. boolean, number\_integer), the value attribute has a matching type.

The simplest way to access a usable version of a metafield value is via the metafield representation object, i.e. resource.metafields.namespace.key.value.

## How to access it

- For modern metafields, use resource.metafields.namespace.key.metafield to retrieve the metafield object itself. Use resource.metafields.namespace.key to access the metafield representation object for that metafield.
- For deprecated metafields, use resource.metafields.namespace.key to retrieve the parsed, appropriately-typed metafield value.

Last updated 2021-07-28T17:45:18Z