[Original URL: https://www.locksmith.guide/keys/more/has-purchased]

# "Has purchased..." key

Granting access to content in your store only after the appropriate purchase has been made

Locksmith allows you to check for a purchase of a specific product and only grant access to your locked content if an applicable purchase has been made.

This key condition can only account for a customer's latest 50 orders (and in some cases only the latest 25). Learn more about this in the Limitations section.

This key condition relies on Shopify's customer account system, the same that's used throughout Shopify for all Shopify stores. Customer accounts need to be enabled for your store in order for this key condition to function correctly.

Additionally, when this key condition is used, Locksmith will automatically prompt guests to sign in to their customer account when they visit a locked page.

Learn more about customer account keys

## Setup

Once you create a lock that covers the content that you want to require a purchase for, click the "+ Add key" button. In the condition selector that appears, select "if the customer has purchased...".

Locksmith will examine the customer's order history for products matching what you enter.

Important: Whether you choose to enter the SKU, title (shown above), variant ID, or product tag, they are all case sensitive!

## Options

#### Maximum quantity purchased

Sets a maximum allowed purchase amount. When used, Locksmith will only grant access if the customer has not yet purchased this many units of the product

#### Only look at orders in the last...

Allows to you specify, in days, how far back you want Locksmith to purchase. E.g. you may want to only allow access for 30 days after purchase.

#### Ignore cancelled orders

When ON - Cancelled orders will not fulfill the requirements for access. Default: ON.

#### Ignore unfulfilled or partially fulfilled orders

When ON - Unfulfilled orders will not fulfill the requirements for access. Default: OFF, most merchants will want to leave it this way.

#### Ignore orders that are not fully paid

When ON - Only orders with a payment status of "Paid" will fulfill the requirements for this lock. Default: ON.

Caution: This setting often causes issues for merchants who are testing out their locks. Consider turning this setting OFF while testing, but back ON for general use.

## Inverting this key condition

Like all key conditions, this one can be inverted. This is useful to verify that a customer has NOT yet purchased a specific product:

[pageInverting conditions in Locksmith](/keys/more/inverting-conditions-in-locksmith)
## Limitations

This key condition can only account for the 50 most recent orders for the current customer. In some cases, it can only account for the most recent 25 orders instead.

The stricter 25-order limit comes into play when a customer navigates to a URL that includes a page number, e.g. a URL with "?page=2" in it. This is because a page number in the URL limits Locksmith's ability to ask Shopify for the maximum number of orders possible (i.e. 50), leaving Locksmith to work with the default number of orders (i.e. 25).

To work around this limit, consider setting up your Shopify store to auto-tag customers according to their order history. These customer tags can then be used in new Locksmith keys which grant access based on those tags.

Locksmith doesn't have customer auto-tagging built in, so merchants generally accomplish this by involving a second app.

- Shopify Flow has options for auto-tagging, and is available for free for all stores.
- Mechanic (also made by Lightward) has a variety of tasks that can be used for this purpose. Like Locksmith, Mechanic is also available under Lightward's Pay What Feels Good pricing policy.

## Related articles
[pageCustomer account keys](/keys/customer-account-keys)[pageSelling digital content on Shopify](/tutorials/selling-digital-content-on-shopify)

Last updated 2023-09-29T21:52:51Z