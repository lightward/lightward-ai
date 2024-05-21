[Original URL: https://www.locksmith.guide/tutorials/more/making-a-product-accessible-exclusively-from-the-direct-product-link]

# Making a product accessible exclusively from the direct product link

This can be useful for merchants that don't need a product to be "secure", but still want to keep customers from finding the product by accident.

Locksmith also has a secret link feature, which is more heavily used and different than what this guide describes. The secret link feature is more secure. If you are looking for that, simply use the key condition labelled "Permit if customer arrives from the secret link" when setting up your key. If not, read on... Use the following steps:

1. Create a lock on the product in question - to do so, open Locksmith app and search for a product by name.
2. On the next page, under Keys, select the "(custom Liquid)" condition
3. Paste template == "product" into the "Liquid condition" box
4. Make sure the "hide this product from search results and other lists" option is checked!

You're done :)

Note: This technique can be used with other types of resources such as Pages, Collections, Articles, Blogs, etc. You'd just substitute the correct template name in your Liquid condition.

If this technique isn't working, it's possible that your theme uses a non-standard template name (other than "product"). To fix this, just update "product" in the lock to whatever your theme uses.

#### If you would like more information on Liquid key conditions, checkout the guide linked below.
[pageLiquid key basics](/keys/more/liquid-key-basics)
## Something else not covered here?

Let us know by emailing us at: team@uselocksmith.com

Last updated 2023-12-07T19:49:19Z