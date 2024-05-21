[Original URL: https://www.locksmith.guide/faqs/more/how-do-i-change-where-customers-are-redirected-to-after-registration-on-shopify]

# How do I change where customers are redirected to after registration on Shopify

This guide is specific to Locksmith key conditions that require a customer to sign into a store account.

[pageCustomer account keys](/keys/customer-account-keys)

Locksmith will automatically present locked content to customers after they sign into a store account and are granted access by a locks key conditions. Part of this involves redirecting customers back to the store location where they signed in for access.

However, Locksmith doesn't have a built in way to automatically redirect customers back to locked content after registration. This is because Locksmith doesn't handle the registration process at all.

Locksmith uses the built in customer account system that comes with your store! This means it doesn't create a separate registration form, sign-in form, or customer database.

All Shopify themes come with a registration form that includes Name, E-mail, and Password fields.

## Changing the default location customers are redirected to after registration

The default location customers are redirected to after registration is determined by the theme and is typically the customer account page. The team over at Helium apps have written blog post on how to change that location using their app or some JavaScript:

Helium - How to manually redirect customers after registration on Shopify

## How to redirect customers to unlocked content after a customer creates an account

The access message and content that Locksmith presents for customer account key conditions can be modified to include a login and registration form on the same page. See our Customizing the customer login page guide:

[pageCustomizing the customer login page](/tutorials/more/customizing-the-customer-login-page)

We don't officially have support for a return redirect after customer registration, but it should be possible to achieve that using Helium's redirect script from the above section and modifying that script a little.

Replace the following:

Copy

    var REDIRECT_PATH = '/checkout';

With this code:

Copy

    var current_url = window.location.href;
    var REDIRECT_PATH = '{{ current_url }}{% if collection %}/collections/{{ collection.handle }}/products/{{ product.handle }}{% elsif product %}/products/{{ product.handle }}{% elsif page %}/pages/{{ page.handle }}{% else %}{% endif %}';

The above modification should only work to redirect customers to locked content if the registration form was submitted from the access message Locksmith presents, for product, collection and page locks. For other parts of the store, customers will be returned to the homepage.

## Related articles
[pageCustomizing the registration form](/tutorials/more/customizing-the-registration-form)[pageApproving customer registrations](/tutorials/approving-customer-registrations)
## Something else not covered here?

Let us know by emailing us at: team@uselocksmith.com

Last updated 2023-11-13T11:13:40Z