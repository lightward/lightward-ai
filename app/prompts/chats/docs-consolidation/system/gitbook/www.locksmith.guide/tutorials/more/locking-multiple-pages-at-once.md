# Locking multiple pages at once

Because Shopify doesn't provide any way to group pages (in the way that collections work for products), we need to get down to the code level in order to protect more than one page at a time.

To get started, you'll need to begin a "Liquid lock:

[pageLiquid locking basics](/tutorials/more/liquid-locking-basics)

To lock all pages containing a certain word in the title, fill out the form like so:

Or, to lock all pages that use a certain custom template, use this:

3. Submit the form to create your lock, then proceed by configuring keys as appropriate.

If you'd like to use something other than the title or template to activate this lock, take a look at Shopify's Liquid documentation for pages - you can adapt your custom lock for any of the page attributes listed there.

## Related articles
[pageLiquid locking basics](/tutorials/more/liquid-locking-basics)

[PreviousLocking products by tag](/tutorials/more/locking-products-by-tag)[NextMaking a product accessible exclusively from the direct product link](/tutorials/more/making-a-product-accessible-exclusively-from-the-direct-product-link)

Last updated 2022-09-09T19:44:33Z