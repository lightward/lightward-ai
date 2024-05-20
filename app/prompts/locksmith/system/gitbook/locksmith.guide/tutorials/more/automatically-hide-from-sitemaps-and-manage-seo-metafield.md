# Automatically managing the seo.hidden metafield using Locksmith

How to set up your Locksmith locks to automatically manage the seo.hidden metafield for any content covered by them.

Shopify provides merchants with the seo.hidden metafield that, when added to your resources, does the following:

- Removes it from sitemaps
- Prevents search engines from indexing (via the "noindex, nofollow" metatag)
- Removes it from the customer-facing search within your Online Store (with some exceptions, depending on theme or apps used and how they treat the "seo.hidden" metafield)

More complete information about the seo.hidden metafield, directly from Shopify, can be found here.

Locksmith will automatically add this metafield if you turn on the 'Hide from sitemaps' in your lock settings (found under Advanced):

Locksmith will remove this metafield if you:

- Disable the lock
- Delete the lock
- Disable the "Hide from sitemaps" setting
- Press the Disable Locksmith button from the Settings tab
- Press the Remove Locksmith button from the Help tab
- On collection locks, disabling "Protect products in this collection" will remove the metafield from the products inside the collection.

Important: Locksmith cannot perform any metafield operations if you remove the app from your store. So it is very important to perform one of the above - before deleting the app from your store.

#### This setting is available for locks on the following resource types:

- Products
- Collections
- Blogs
- Pages

## Caveats

- This setting can be convenient to remove locked products from all storefront searches, but just keep in mind that products covered by this setting won't show up in storefront search at all, even for customers that have access. If this is an issue for you, stick to hiding from product grids whenever possible.
- Products in more that one locked collection: if you have the "Hide from sitemaps" setting turned on for more than one collection lock, products will retain the metafield as long as at least one locked collection with this setting turned on remains.

## Alternative setting: Add the "noindex" meta tag to any pages protected by this lock

In addition to Shopify meta-fields, which is a Shopify concept for adding additional information to your resources, this section talks about meta-tags, which are an HTML concept. For example:

Copy

    

The add-noindex-metatag setting for Locksmith locks adds a "noindex" robots metatag to the page during rendering, which signals to search engines that you don't want that particular page indexed. This setting is turned on by default since the vast majority of merchants want their locked pages kept out of search engines.

Keep in mind that turning this setting OFF does not result in your locked content being indexed or available. It simply results in the locked version of the page (i.e. "This content is protected....) being available for indexing.

This setting overlaps with the hide-from-sitemaps setting. This setting does not add any metafields to your Shopify resources, but since the seo.hidden metafield already results in the "noindex" meta-tag being added to the resource page by Shopify, the add-noindex-metatag setting is automatically toggled on when you turn on the hide-from-sitemaps setting.

## Related
[pageHow does Locksmith affect search engines and SEO?](/faqs/more/how-does-locksmith-affect-search-engines-and-seo)

Last updated 2024-03-26T17:43:14Z