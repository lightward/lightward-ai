[Original URL: https://learn.mechanic.dev/core/shopify/read/liquid-objects]

# Liquid objects

Mechanic-flavored Liquid comes with a complement of Liquid objects, each of which is tied to a resource in the Shopify Admin REST API. Many objects support access to related objects via lookups (e.g. {{ shop.customers[customer\_id].orders.first }}); in this way, the REST API can be traversed by resource.

Access to these Liquid objects varies, based on the context in which Liquid is rendered. For example, a task that subscribes to shopify/customers/create will have access to the Customer object in its code, via a variable called customer. To learn more about how these objects are made available to task code, see environment variables.

Shopify variables in Mechanic do not necessarily contain the same attributes as Liquid variables used in Shopify (in places like themes or email templates) – even if they share the same name.

In Mechanic, Shopify variables always contain data from Shopify events, which are delivered to Mechanic via webhook. This means that Shopify variables always have the same data structure as Shopify webhooks, corresponding to Shopify's REST representation for this data.

For example, while Shopify themes support {{ customer.name }}, Mechanic does not (because Shopify's REST representation of the customer resource does not contain a "name" property). On the other hand, Mechanic supports {{ customer.created\_at }}, while Shopify themes do not.

## Usage

Each task is given a set of environment variables to work with, out of the box. Mechanic's task code editor will tell you which ones are available. For example, for a task responding to a shopify/orders/ event, you might see this:

The cache, event, options, and shop objects are always available for tasks; the order object (as in this example) contains the order to which the current event relates.

Use Mechanic's Liquid object documentation to discover what data is available for each Liquid object.

## Use Liquid objects when...

- ... your task's event gives you an environment variable containing the data you need. For example, for a task responding to a "shopify/customers/" event, you'll get an automatic customer variable. Feel free to use this variable to get to additional data, like customer.orders.first.name.
- ... you know you're not going to need to load an enormous amount of data. For example, a {% for customer in shop.customers %} loop is just fine if you know your store will have only hundreds or thousands of customers.
- ... when it's easy to get to the right data, allowing future versions of you to easily understand what you were doing. ;) There are plenty of scenarios where it's easier to use Liquid objects than it is to use GraphQL, and if you can do so without accidentally downloading too much data (see above), go for it.

## Don't use Liquid objects when...

- ... there's a more efficient way to get to what you need. For example, getting all orders tagged "sale" via Liquid objects will require loading in all orders, and then using Liquid to skip orders that don't have that tag. This takes a long time, and it's unnecessary, because GraphQL supports searching for orders by tag.

Last updated 2021-06-06T21:30:03Z