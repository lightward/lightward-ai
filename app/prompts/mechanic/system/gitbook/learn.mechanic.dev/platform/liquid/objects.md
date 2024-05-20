# Mechanic objects

Mechanic makes a variety of Liquid environment variables available, containing specific Liquid objects. (The shop variable, for example, is always available and always contains the Shop object.)

Mechanic's Liquid objects mapping to Shopify resources all contain data pulled from the Shopify's REST Admin API reference. These objects are listed here:

[pageShopify REST Admin API](/platform/liquid/objects/shopify)

Shopify variables in Mechanic do not necessarily contain the same attributes as Liquid variables used in Shopify (in places like themes or email templates) – even if they share the same name.

In Mechanic, Shopify variables always contain data from Shopify events, which are delivered to Mechanic via webhook. This means that Shopify variables always have the same data structure as Shopify webhooks, corresponding to Shopify's REST representation for this data.

For example, while Shopify themes support customer.name, Mechanic does not (because Shopify's REST representation of the customer resource does not contain a "name" property). On the other hand, Mechanic supports customer.created\_at, while Shopify themes do not.

Last updated 2023-11-08T16:17:44Z