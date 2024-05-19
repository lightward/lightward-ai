# Customising Locksmith’s "Access denied content" messages, and redirecting customers

Locksmith access denied content is presented to customers who are signed in, but don’t meet the access requirements of the lock (e.g. the customer doesn’t have the specific customer tag that is required for access). Or when the lock has no keys.

## Key conditions that use the “Access denied content" filed:

- is tagged with…
- has one of many email addresses
- has an email address from an input list…
- the customer's email contains…
- has placed at least x orders
- has purchased…
- (custom Liquid) in some cases
[pageCustomer account keys](/keys/customer-account-keys)
## 1. Modifying the default message

The "Access denied content" message field can be modified in the same way as Locksmith’s other access messages, including using code to modify the appearance and functionality of the message.

[pageCustomizing messages](/tutorials/more/customizing-messages)
### The following code can be used in this field:

- HTML
- CSS (via the \ tag)
- Javascript (via the \<script\> tag)
- Liquid (Shopify's template language for themes)

## 2. Adding the registration form to this page

Simply add the following Liquid to the "Access denied content" message field:

Copy

    {{ locksmith_customer_register_form }}

This will render the theme’s default registration form.

## 3. Adding a custom registration form or content

Liquid code can be used to render a snippet or section from your theme that contains a custom form or message.

1. render - Renders a snippet

Copy

    {% render 'filename' %}

1. section - Renders a section.

Copy

    {% section 'name' %}

## 4. Automatically redirecting customers to another part of your store

A JavaScript redirect can can be added to the “"Access denied content" message field if you would like to automatically send customers who are denied access to your lock, to some other part of your store.

This might be useful for a few different reasons:

- To take customers to a specific product they can purchase for access. For example, to buy a product, or membership, or subscription for access.
- To take customers to an information page.
- To take customers to a custom registration form
- To direct customers to an alternative resource

Simply add the following code to the "Access denied content" message field and modify the URL to your desired location.

Copy

    <script>
        window.location.replace("http://www.example.com");
    </script>

## Related articles:
[pageAdding translations to your Locksmith messages](/tutorials/more/adding-translations-to-your-locksmith-messages)[pageCustomizing the customer login page](/tutorials/more/customizing-the-customer-login-page)[pageCustomizing the registration form](/tutorials/more/customizing-the-registration-form)[pageSelling digital content on Shopify](/tutorials/selling-digital-content-on-shopify)[pageEarn recurring revenue on your exclusive content using ReCharge](/tutorials/more/recharge)[pageNewsletter keys](/keys/more/newsletter-keys)[pageHow do I change where customers are redirected to after registration on Shopify](/faqs/more/how-do-i-change-where-customers-are-redirected-to-after-registration-on-shopify)
### Something else not covered here?

Let us know by emailing us at: team@uselocksmith.com

[PreviousHow to access your browser's dev tools](/tutorials/more/how-to-access-your-browsers-dev-tools)[NextRestricting the cart for mixed products and combinations of products](/tutorials/more/restricting-the-cart-for-mixed-products-and-combinations-of-products)

Last updated 2024-03-08T00:00:23Z