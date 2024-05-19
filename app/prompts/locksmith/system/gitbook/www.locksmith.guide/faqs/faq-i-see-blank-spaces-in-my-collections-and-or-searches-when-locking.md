# FAQ: I see blank spaces in my collections and/or searches when locking

Some strategies to improve the appearance of your collections and searches when Locksmith is filtering out products

Locksmith supports hiding locked products across your shop, preventing them from appearing to unauthorized customers in collection listings, search results, and anywhere else product lists appear.

However, if a collection has some products which are locked, and some that aren't, the result can be a collection with empty or partially-empty pages. This is because Shopify only permits filtering products out of a collection page by page - there's no way to reshuffle products so that every page appears full.

There are, however, some other options to get around this issue.

### Option 1: Turn up the maximum number of products that are displayed per page

The maximum products per page, Shopify-wide, is 50. This may not work for everyone, but it can make pages appear less empty. And, if you have less than the maximum products in your collection, this can eliminate the issue completely in those cases. To change the maximum number of products, follow the tutorial here.

### Option 2: Don't mix locked products and unlocked products in the same collections

Simple enough. To make sure that each customer type gets pointed to the right collections, follow these steps.

1. Create versions of each collection that are geared toward each audience. For example, if you have a "Staff" collection that has some manager-only products, create one "Staff" collection with just non-manager products, and another "Staff" collection with all the manager-friendly products.
2. Next, add links to all versions to your shop's navigation menus. We'll take care of filtering the links themselves in the next step, but for now, make sure your shop's navigation gives your visitors a way to get to the collection that's right for them.
3. Finally, lock each collection, making sure to check the box labeled "Hide any links to this collection and its products in my shop's navigation menus". This will instruct Locksmith to only show a collection link to the visitor if they're qualified to open its lock.

### Option 3: Use an app to create "infinite scroll" pages on your store

We've seen that some infinite scroll features and apps can handle reordering, or "filtering down" the products on the collection page, removing the empty spots where the locked products would normally show.

### Handling the "All" collection

Shopify generates a default collection called "All", located at the /collections/all url of your shop. Out of the box, this collection contains your entire product catalog.

Because this collection is subject to the same conditions that are described above, it may be useful to override this collection with one that just contains the products in your shop that are public friendly.

To do that, simply create a new collection in your shop called "All", and manually specify the products (either individually or using conditions) that should be visible to the public. This will override the default collection, and visitors who open it will see normal, full collection pages, containing your public-friendly products.

### Handling "Frontpage" collections, and other theme-specific product areas

Some themes include the ability to feature a collection of products on the frontpage, or elsewhere. Most themes don't support swapping collections based on the visitor, so it will require custom code to use audience-specific collections in these cases. This kind of thing would only work with specific key types such as customer tags or e-mail addresses.

Feel free to get in touch if you have questions about any of this! You can do that by just hitting the message icon on the bottom right of this screen ↘️

[PreviousWhy aren't my locks working?](/faqs/why-arent-my-locks-working)[NextCan Locksmith hide content from my in-store search?](/faqs/can-locksmith-hide-content-from-my-in-store-search)

Last updated 2023-10-11T16:25:59Z