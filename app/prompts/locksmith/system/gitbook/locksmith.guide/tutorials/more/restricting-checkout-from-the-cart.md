[Original URL: https://www.locksmith.guide/tutorials/more/restricting-checkout-from-the-cart]

# Restricting checkout from the cart

How to use the Locksmith app to add checkout restrictions on your Shopify Online Store

Locksmith allows you to restrict checkout by using a lock on the cart page in your store. This is a good choice for merchants who want to allow customers to view all content in their store and browse fully, only adding in restrictions on the last page before checkout. Or, to simply add extra restrictions for checking out, on top of other locks in the store.

### Limitations:

- The method locks down the cart page only. The cart page is always found at the '.../cart' link in your store (e.g. www.example-store.com/cart). Using other types of carts (slider, dropdown, dynamic/ajax, etc.) or adding "Buy Now" links to your store (which point the customer directly to checkout without going through the cart page) will not work with this method.
- Locking the checkout area itself is not possible using Locksmith. So any check out links that lead straight to checkout including "Buy Now" button, upsell links, or abandoned cart links can't be used with this method.

Moving on, this is the checkout page without any locks in effect:

You can lock the entire cart page if preferred. This will work just like any other Locksmith lock. However, it is also possible to take it further and lock only the "Check out" button. Once Locksmith is set up, the result will be something like one of these screenshots (depending on your settings):

------

## Part One: Creating the lock

Use the following steps

1. Open up the Locksmith app and search and for "cart", clicking on it when it comes up in the search.

2. On the next page, under "Keys", you'll add in your conditions. Here are some of the more common conditions used...

To impose a minimum purchase amount:

a To make sure only customers that are signed in and have approved accounts can proceed:

Customer must enter a passcode to checkout:

3. If you just want to lock the entire cart page, click "Save" to finish. If you want to lock only the "Checkout" button, make sure "enable manual locking" is checked under Advanced Settings before saving:

Done with part one!

If you need help with setting up more complicated checkout conditions, Locksmith may be able to help. Just get in touch with us :)

## Part two: Theme changes

New to manual locking? Check out our general introduction.

Some modifications to your shop's theme will need to be done to protect just the checkout button.

Because each theme is a bit different, this feature does require manual coding. If you install a new theme down the road, these changes will need to be re-applied.

The rest of this guide gets a bit technical! We can take care of adding the code for you for you, no problem, so if you're interested, get ahold of us.

#### Rather do it yourself? Keep reading...

In this portion, you'll update your shop's theme to protect just the checkout button(s) on your cart, allowing your visitors to manage their cart but not check out until they meet your criteria.

1. From your Shopify admin area, navigate to "Online Store" -\> "Themes". Then, click the three-dots button in the upper-right corner for your theme, and select the "Edit HTML/CSS" option.
2. Open the "cart.liquid" file (under "Templates"). If you have a newer "sectioned" theme, you may actually need to edit the "cart-template.liquid" file (under "Sections")
3. Add the following to the very top of the file:{% capture var %}{% render 'locksmith-variables', variable: 'access\_granted', scope: 'subject', subject: cart %}{% endcapture %}{% if var == 'true' %}{% assign locksmith\_access\_granted = true %}{% else %}{% assign locksmith\_access\_granted = false %}{% endif %}
4. Find the checkout submit button(s), and wrap this code with {% if locksmith\_access\_granted %} ... {% endif %} . You can also add an "else" section to show a message to anyone who's been prevented from checking out.Here's a pretty typical example:

Before:

Copy

    
    
    {% if additional_checkout_buttons %}
      
     
      {{ content_for_additional_checkout_buttons }}
     
    {% endif %}

After:

Copy

    {% if locksmith_access_granted %}
      
    
      {% if additional_checkout_buttons %}
        
     
      {{ content_for_additional_checkout_buttons }}
     
      {% endif %}
    {% else %}
      Please add at least $50 to your cart to check out.
    {% endif %}

Save the template, and you're done! :)

### Other considerations...

Note: The script used here isn't an officially supported Locksmith feature. The following is an example of a script that's commonly used to clear a customer's cart when they log out.

Some merchants set up their cart restrictions so that they only apply to certain signed-in customers and the exclusive products they have access to. In this case, it might be possible for customers to sign out to bypass these conditions once restricted products have been added to the cart. If that applies to you, consider ensuring that all products are removed from the cart when a customer signs out.

You can achieve this by adding the following JavaScript to your layout/theme.liquid file, just before the closing tag:

Copy

    
      $(document).on('click', 'a[href="/account/logout"]', function (e) {
        e.preventDefault();
        $.ajax({ method: 'POST', url: '/cart/clear.js' }).always(function () { window.location = '/account/logout'; });
      });
    

This will clear the cart when the logout button is pressed, preventing that workaround.

If this script doesn't work in your theme, your theme may not include jQuery libraries. To include those libraries, the following script can be added to an empty line right before the cart clearing script mentioned above.

Copy

    

## A note about Abandoned Cart emails

If you have abandoned cart emails enabled on your shop, either through the built-in Shopify feature or an app, those emails may allow the customer to circumvent checkout restrictions.

These emails can send the customer directly to the checkout process without touching the cart page. The customer will be able to check out with whatever amount was in the abandoned cart, whether or not it passes your restrictions.

Your checkout restrictions will not work 100% of the time if you're sending abandoned cart emails, so keep that in mind when you're setting this up. :)

Last updated 2023-12-01T01:22:09Z