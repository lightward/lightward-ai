# Restricting the cart for mixed products and combinations of products

This is an incomplete guide! In an effort to share the information we have as soon as possible, this guide has been started and published here in what we consider to be an incomplete state. If something is missing, please let us know by emailing us at team@uselocksmith.com.

Locksmith can be used to restrict checkout from the cart page by creating a lock for the cart. This lock can be used to hide the whole cart page, or to only lock the checkout buttons on the cart page. Locksmith has a few cart specific key conditions that can be used to check specific attributes of a customers' cart. This guide will primarily focus on the use of the “has a certain product in their cart” key condition.

## Preventing access to the checkout from the cart

Our guide on setting up a cart lock is linked below. That guide covers both locking the whole cart page and locking the checkout button.

[pageRestricting checkout from the cart](/tutorials/more/restricting-checkout-from-the-cart)

Locking the checkout button can be a better option here. This will allow customers to still be able to edit the products in the cart, even when the checkout button is locked.

## Managing cart access based on products in the cart

There are three general ways of restricting access to the checkout via your Shopify cart based on mixed products or combinations of products. Keep in mind, this isn’t an exhaustive list.

### 1. Preventing checkout with mixed products from two different groups of products. Eg. Wholesale and Retail

The "Look for products matching…" field on the "has a certain product in their cart" key condition can be used to check for a product title, or product tags. For example, "tag:wholesale will check for any products with the "wholesale" tag.

You will need to create three separate keys for your cart lock. Our guide on adding keys is here for reference: Creating keys

1. You’ll need a key that grants access if a customer does have products tagged with the "wholesale" products tag (for example) in the cart, but only if the customer doesn't have any products tagged with "retail" in the cart. Create a key and then select the "has a certain product in their cart" key condition and add “tag:wholesale” to the "Look for products matching…" field on the condition. Then combine a second "has a certain product in their cart" key condition with the first, add “tag:retail” to the "Look for products matching…" field on the condition, and then invert the condition. Combining Key Conditions Inverting conditions in Locksmith You should have a key that looks like the following image.
2. The second key will use a set of conditions that are the inverse of the fist key, to grant access to customers who don't have any products tagged with "wholesale" in the cart but do have products tagged with "Retail" in the cart. Create a new key by clicking the “+Add key” button and then select the "has a certain product in their cart" key condition and add “tag:retail” to the "Look for products matching…" field on this condition. Then combine a second "has a certain product in their cart" key condition with the first, add “tag:wholesale” to the "Look for products matching…" field on the condition, and then invert this condition. You should have a key that looks like the following image.
3. This third key is only required, if you have another set of products, other than wholesale and retail, that can be purchased with anything product. The third key can be used to grant access for when there are no products with the "wholesale" or "retail" tags in the cart. This will require the combination of two inverted "has a certain product in their cart" key conditions, one of each product tag. You should have a key that looks like the following image.

### Something else not covered here?

Let us know by emailing us at team@uselocksmith.com

[PreviousCustomising Locksmith’s "Access denied content" messages, and redirecting customers](/tutorials/more/customising-locksmiths-access-denied-content-messages-and-redirecting-customers)[NextLocking products by vendor](/tutorials/more/locking-products-by-vendor)

Last updated 2024-01-18T22:51:43Z