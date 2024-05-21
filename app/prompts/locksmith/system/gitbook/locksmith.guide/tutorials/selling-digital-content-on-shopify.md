[Original URL: https://www.locksmith.guide/tutorials/selling-digital-content-on-shopify]

# Selling digital content on Shopify

How to use the Locksmith app to sell digital content on Shopify

If you have special content that you want to monetize, and it lives in your Shopify store, Locksmith allows you to sell access to it via in-store purchases.

Note: Selling digital content on Shopify might mean different things for different merchants. If you are simply wanting to sell digital files that are sent to customers via email, see Shopify's guide on this here.

## Step 1: Create your restricted content

Common choices for this are to add your restricted content to one of the following:

- Shopify's built-in blogging engine for your store. Keep in mind that you are not restricted to a single blog, so you can have a general access blog for your site news, etc, and still use a restricted blog for your digital content.
- Pages - Shopify's built in webpages for your store.
- Product page - You can build custom product templates that also house your restricted content and combine it with Locksmith's manual locking, so that the restricted portion only reveals itself after the product has been purchased. This option has a less straightforward setup, but is still available if desired. If this is you, the best place to start is by contacting us via email at team@uselocksmith.com.

Again, for best results, your content should live in your online store. However, there are some other options that might apply to you:

#### Secure file viewing or downloading

This requires another provider, and we recommend Dropbox: Get started with this on Dropbox' website.

#### Secure video viewing

You can embed the videos to be viewed just like any of your other content. However, if you want to secure this process, you'll need to enlist the help of a third party video viewing service. We recommend private and unlisted videos on Vimeo, but keep in mind that making your videos private/unlisted on Vimeo requires a paid Vimeo plan! Get started with this on Vimeo's website.

#### Other general content that doesn't live in Shopify

If your content must live elsewhere, consider using iframes to embed your content into a Shopify page, which you can then lock. This is more of an advanced technique and would require someone familiar with code. Locksmith support won't be able to code this kind of thing for you. This is also less secure because the original source of the iframe can't be locked by Locksmith.

#### 

## Step 2: Create your "access product"

### Requiring a simple one time purchase

You'll need to have at least one product that is clearly marked as the product that customers will purchase, in order to gain access to the locked content. Something like this:

### Requiring a recurring subscription charge for access

You'll need to use a third party app to set up the subscription service. We recommend ReCharge, and we have a more in depth guide on setting up Recharge here:

[pageEarn recurring revenue on your exclusive content using ReCharge](/tutorials/more/recharge)
## Step 3: Setting up the lock

Create a lock on your subscription product (the one created in the previous step). For your key, use the condition labelled "has purchased..." to create a key condition that permits access if the customer has purchased the appropriate product:

Note: You can also specify a time window, using the option labelled "Only look for orders in the last...". With this, you could require - for example - that the customer has made the purchase within the last 365 days. This is a good way to limit the access period time, but you should still use a recurring subscription app if you want an automatically recurring charge.

## Step 4: Making sure your customers are signed in when purchasing your "access product"

In order for Locksmith to register that a customer has actually purchased your "access product", it is important that you require that customers are actually signed in when the purchase is made.

You can do that with either of the following ways:

Make customer accounts required for your entire store: This means that everyone must be signed into your store when they check out. More information from Shopify on doing this. This might be considered overkill for some merchants, so if that's the case, use the next option.

Use Locksmith to require that a customer is signed in when purchasing your "access product": Pretty simple - just add a lock directly to the "access product" and use "Permit if customer is signed in" as the key condition. You can edit the locked landing page for this product by editing the "Guest message content" message to let the customer know that they need to sign in before access. Or, if you prefer, you can even employ manual locking if you just want to hide the add-to-cart button instead of the whole page.

## Optional: Directing customers to your content after purchase

You may wish to direct customers to the content that they just purchased.

### ... in order confirmation emails

We can use some custom code to conditionally add a link to your locked content if the customer has purchased the right product.

To set this up, head to Settings -\> Notifications in your Shopify admin, then scroll down and click the link for "Order confirmation". Insert this code and adjust as appropriate:

Copy

    {% for line_item in line_items %}
      {% if line_item.title == "Some Product" %}
        Thank you for your purchase! You may now access this locked page.
      {% endif %}
    {% endfor %}

Feel free to add multiple copies of this code, if you need to send the customer to one of several pages.

### ... and in the order confirmation page, after checkout

The code above can also be modified to suit the order confirmation screen that your customers see, right after completing an order.

To set this up, locate the "Additional content and scripts" box, near the end of the Settings -\> Checkout area in your Shopify admin.

Use this code:

Copy

    {% for line_item in order.line_items %}
      {% if line_item.title == "Some Product" %}
        Thank you for your purchase! You may now access this locked page.
      {% endif %}
    {% endfor %}

... adjusting the "Some Product" for your actual product title, and "/pages/some-locked-page" part for the address to your locked content.

Feel free to add multiple copies of this code, if you need to send the customer to one of several pages.

Last updated 2022-11-09T04:44:49Z