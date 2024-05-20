# Liquid locking basics

Locksmith has a feature to create "Liquid" locks, which allows you to lock pages in your store that are otherwise not searchable using the basic "Add lock" resource search in Locksmith.

Note: this is an advanced guide that requires knowledge of Shopify's Liquid language. If you're a developer type, read on! If that is not you, and you aren't finding what you're looking for in the Locksmith app, please feel free to contact us via email at team@uselocksmith.com.

Moving on - to begin, press the "Start a Liquid lock" link:

This will bring up the following form:

## The "Liquid condition"

The "Liquid condition" is the condition that is evaluated to decide if the lock will be engaged on the current page. The Liquid condition simply needs to evaluate to true or false.

All liquid objects in Shopify are fair game here, more info on Liquid objects here.

Useful examples

Any condition that evaluates to true will result in a locked page. So, imagine if you created a lock with this condition:

Copy

    {% if true %}

That would result in every single page in your store becoming locked. This isn't advisable, it's just a proof of concept :)

* * *

One of the most useful variables that you can use is the canonical\_url variable. This variable contains the full url of the current page, so it is a good way to lock pages that aren't usually searchable. For example you have an app that lives at my-store.myshopify.com/apps/bulk-order-form-app, you could lock it with the following condition:

Copy

    {% if canonical_url contains "apps/bulk-order-form-app" %}

* * *

Another useful variable is the template variable. For example, an easy way to lock only the home page would be:

Copy

    {% if template == "index" %}

If your home page template is called something else, you have the flexibility to lock it by adjusting the condition above.

## The "Liquid prelude"

The "Liquid prelude" will be evaluated before the liquid condition, and is where you'll add any code that helps you set up the Liquid condition, and can span multiple lines. For example, you can assign to a specific custom variable, which can then be used the the Liquid condition later.

For example, if you have a large number of pages that you want to lock at once, normally you'd need to do that by creating a separate lock on each page. You could use the Liquid lock feature to lock them all at once. Perhaps something like the following:

In your Liquid prelude:

Copy

    {% assign page_is_locked = false %}
    {% if scope = "page" %}
     {% if page.handle contains "member" or page.handle contains "secret" %}
      {% assign page_is_locked = true %}
     {% endif %}
    {% endif %}

In your Liquid condition:

Copy

    {% if page_is_locked %}

This would result in all "Pages" in your store that contain "member" or "secret" in the title becoming locked.

## Related resources

You can also create Liquid keys! While the function of Liquid keys is fundamentally different than what is covered on this page, the concepts while setting them up are very similar:

[pageLiquid key basics](/keys/more/liquid-key-basics)

Last updated 2024-01-12T02:43:46Z