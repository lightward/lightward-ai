# Hiding product prices and/or the add to cart button

How to use the Locksmith app to hide specific page content on your Shopify Online Store

Locksmith's manual mode feature can be used to hide your product prices so that customers can still browse your shop, but can only see prices and purchase products if certain conditions are met.

Here is an example of a product page that has been setup properly with Locksmith to hide prices:

Then, when the customer meets the conditions, the product pages will appear normally:

Note: The results may look different depending on your Locksmith conditions, theme, or other settings.

Also note: While this method does hide the price visually, it may still be possible for someone viewing the source (or interacting with the browser console) to see the price. This is because of the presence of things like Google Analytics and other tools, which reproduce the price in the source - but not visually on the page - for their own usage. These are out of control of the Locksmith app.

You can also setup Locksmith to hide from collection pages and searches (as long as the default Shopify search is used).

You have flexibility! For example, you can require accounts to be approved in addition to signed in. Our whole library of key conditions is at your disposal here. You can also set it up on only some of your products if you want to leave some products available. Or, you can simply hide the add-to-cart button and leave the product prices visible.

Use the following two steps to set it all up:

## 1. Create lock

The first step to hiding your prices using Locksmith is to create a lock that covers the products that you would like to hide prices on. To do this, open up Locksmith and use the search bar on the main page of the app. If this is all of your products (most common), you can simply search for "all" and choose the "All Products" collection:

Warning: make sure to choose "Collection: All" and not "Collections Listing"

If you are only wanting to apply pricing hiding to some of your products, you can instead create a lock on different collection(s) or products that you want prices hidden for

Once you've created the lock, you'll choose the conditions for access. Many merchants use the "Permit if customer is tagged with..." key condition, which lets you manually approve accounts for price access by adding a customer tag:

That's the most common way to set it up, but you have the freedom to choose whatever key conditions work for your setup.

Before saving, turn on "Enable manual mode" right there in the lock (Clicking "Advanced" will show the option):

Done with step one!

## 2. Updating your theme for manual locking

You'll now need to add the code to your theme to let Locksmith know which parts need to be hidden.

Because each theme is a bit different, this feature does require manual coding. If you install a new theme down the road, these changes will need to be re-applied.

The rest of this guide gets a bit technical, we'll happily to the coding portion for you! If you've already created the lock described in step 1, simply write us a message at team@uselocksmith.com to request help.

Note: Locksmith's manual locking feature generally can not hide elements or sections that are being managed or displayed by other third-party apps.

If you are a developer type, and prefer to do the coding portion yourself, read on... You'll need to start by locating the places in your theme that show the price. Here are some examples of files that you might find the price in:

- snippets/product-card-grid.liquid
- templates/product.liquid
- snippets/product-card-list.liquid
- snippets/product-price.liquid

Each theme is very different, so those are simply examples. You'll need to go to each of the files that display price, and do the following steps:

1. Open up the Liquid file, and add this to the very top of the file: Copy{% capture var %}{% render 'locksmith-variables', variable: 'access\_granted', scope: 'subject', subject: product %}{% endcapture %}{% if var == 'true' %}{% assign locksmith\_access\_granted = true %}{% else %}{% assign locksmith\_access\_granted = false %}{% endif %}
2. Find the code you want to hide from unauthorized viewers, and wrap it with: Copy{% if locksmith\_access\_granted %}...{% endif %}
3. To hide prices, you'll be looking for elements like: Copy{{ product.price }} ... or: Copy{{ item.price }} Example: This shows Locksmith manual locking code wrapping an entire price section, which I've highlighted.
4. Save!

Remember, those 4 steps need to be done for each file that display the price.

In many cases, the above code only needs to be added to two or three files. Whichever file is in charge of displaying the price on product pages, collection pages, and searches. The latter two are oftentimes the same.

### Configuring Locksmith to hide the add-to-cart button only

You can still restrict purchasing products, while leaving the product details visible to the customer. This also a good option for those wanting to make sure that products are available for search engines to index.

As a reminder, we can help guide you through this process, including adding the code, so don't hesitate to get in touch.

Step 1 is exactly the same, but the code you add in step 2 will be slightly different.

Find the product-template or product-form file in your theme, and locate the code that generates the "add-to-cart" button. This is different for all themes, so it won't be possible to give you an exact location for this. Then, add the code that you want to render, inside of a Liquid "else" statement. For example:

Copy

    {% capture var %}{% render 'locksmith-variables', variable: 'access_granted', scope: 'subject', subject: product %}{% endcapture %}{% if var == 'true' %}{% assign locksmith_access_granted = true %}{% else %}{% assign locksmith_access_granted = false %}{% endif %}
    
    {% if locksmith_access_granted %}
      
        Add to cart button example
      
    {% else %}
      Product not available
    {% endif %}

This results in the add-to-cart button being replaced, in cases where the customer doesn't have access. What is shown depends on what is added above. Just make sure your key conditions on the lock match the conditions that you want your customers to meet before being able to purchase.

If you need to render a "Login to purchase" button, use the following code (the button classes may need to be edited):

Copy

    Log in to purchase

If you need to render a passcode prompt button, use the following code (the button classes may need to be edited):

Copy

    Enter passcode to purchase

### Here are some visual examples of the result

#### Requiring, a sign-in:

#### A passcode:

#### A country-specific visitor:

Please note: since the custom liquid code is added manually to the store theme, anytime you switch to a new theme the custom code has to be manually added again to the new theme.

[PreviousCreating restricted wholesale products](/tutorials/locksmith-wholesale)[NextSelling digital content on Shopify](/tutorials/selling-digital-content-on-shopify)

Last updated 2024-02-20T22:11:51Z