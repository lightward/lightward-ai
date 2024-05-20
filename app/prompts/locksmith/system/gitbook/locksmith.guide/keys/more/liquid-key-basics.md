# Liquid key basics

Locksmith allows you to create a custom keys that use Liquid to determine whether or not the current visitor has access. This gives you a few more options than what comes with Locksmith's out-of-the-box key conditions.

Before continuing on, you may want to check out Shopify's Liquid reference, as that will give you a good idea of the kinds of things you can use when creating Liquid key conditions. Keep in mind that while Liquid key conditions can add more versatility, they are still limited to the scope of what's already available inside of Shopify's Liquid engine for the Online Store channel.

You can always contact us at team@uselocksmith.com if you have any questions about this!

To create a Liquid key condition, start by selecting it from the key condition list. You'll be presented with the key condition area for Liquid key conditions:

## The "Liquid condition"

This is where you'll write the primary condition, using Liquid. The condition simply needs to evaluate to true or false.

For example, consider if you simply wrote the following:

{% iffalse%}

This would result in this particular key never opening, since it's always false. This is not necessarily advisable(it would be the equivalent of adding no keys at all), but it's a proof of concept.

So, here are some examples of useful conditions.

#### To check for a metafield

{% if customer.metafields.namespace.key == "matching-value" %}

The metafield must be public in order for it to be accessed this way. More information on Shopify meta-fields here.

#### To check if the customer has at least 5 items in the cart currently

{% if cart.item\_count \> 4 %}

#### To check if the customer has spent at least $50 in the past

{% if customer.total\_spent \> 5000 %}

#### To check if the current page is a using the "collection" template

{% if template == "collection" %}

For most themes, this should match any collection pages unless you've created custom templates. You can use this strategy for other resource types as well (products, pages, etc).

#### To check for a specific sub-string inside of the current URL

{% if canonical\_url contains "/special-product-handle" %}

The canonical\_url global Liquid object is accessible anywhere in the theme and always contains the entire URL of the current page, but does NOT contain any URL parameters. More information from Shopify on it here.

#### To check for some attribute of the request object

{% if request.page\_type == "index" %}

As seen here, another Liquid global object of note is the request object, and it can very useful in this context. Check out Shopify's documentation on it here.

## The "Liquid prelude"

This is a place for you to write any code that that you may need to set up the Liquid condition. It does not need to evaluate to true or false, but it does need to use valid Liquid syntax.

Basically, you can assign to any custom variable in the prelude, and then use that variable in the condition to ultimately decide whether or not the customer qualifies to use this key.

For example, your prelude could look something like this:

Copy

    {% for item in cart.items %}
      {% if item.product.handle contains "members-only" %}
        {% assign purchase_allowed = false %}
      {% endif %}
    {% endfor %}

So now, in the "Liquid condition", you would have access to the purchase\_allowed variable, so it would simply look like this:

{% if purchase\_allowed %}

So that would give you even more flexibility to write different Liquid conditions that can be used to set up your locks and keys.

## Other resources

Relatedly, you can also use Liquid to create Locks! More information on that here:

[pageLiquid locking basics](/tutorials/more/liquid-locking-basics)

As always, feel free to check in with us via email at team@uselocksmith.com, if you have any questions about any of this!

Last updated 2024-01-12T02:44:14Z