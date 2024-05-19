# Can Locksmith hide content from my in-store search?

How to adjust your lock settings to prevent your content from being found via your in-store search

Locksmith includes a checkbox inside of the "Settings" area, on lock pages, that will remove products and other resources from searches - but only from the default and static searches in your store.

Note: Locksmith can NOT remove products from display in other apps, nor can it remove products from dynamic (shows results as you type) searches. In these cases, see suggestions below...

You'll find the hide-from-search setting on each of your lock pages, like so:

## Suggestions for third-party or dynamic searches

Using the above Locksmith setting to 'hide from search results' will not remove the search results when a third party or dynamic search is enabled in your store, so we have some suggestions for alternatives.

### Dynamic searches(show results as you type) enabled from within the theme settings

The only option here, if you want to make sure that your locked content is never displayed inside of your in-store search, is to disable the dynamic loading of the products. Each theme is different, but this is typically done within the "search" settings for the theme.

Once you open the Theme Editor, you can find it under your "Search" settings. On the Debut theme, for example, go to:

- Theme Settings \> Search \> Enable product suggestions (turn OFF)

### Third party searches:

Locksmith won’t be able to hide your products from a search in this case, since the third party app is completely responsible for displaying search results when enabled. Suggestions:

- Many third party apps have their own ways to prevent products from showing up in them. Check the settings for the app that you're using! At the very least, they should allow you to remove certain products entirely from appearing in searches, using a specific product tag.

Sobooster has developed an integration using Locksmith’s publicly available Storefront API, for their AI Search & Product Filter app: AI Search & Product Filter by Sobooster

## The "Hide from sitemaps..." setting

For product and collection locks, Locksmith also gives you the option to hide from sitemaps:

Behind the scenes, this setting uses Shopify's "seo" metafield, which removes products from any in-store searches, but also works to remove products from search engines like Google.

Note: When enabled, his setting will remove products completely from in-store searches. In other words, even visitors that have access to the content via Locksmith won't see the products appear in searches. Because of that, this setting may not work for everyone, but is still available as an option.

On collection locks, as long as the 'protect products in this collection' option is enabled, the setting will also be applied to each product in the collection.

## Related topics
[pageHow does Locksmith affect search engines and SEO?](/faqs/more/how-does-locksmith-affect-search-engines-and-seo)

[PreviousFAQ: I see blank spaces in my collections and/or searches when locking](/faqs/faq-i-see-blank-spaces-in-my-collections-and-or-searches-when-locking)[NextLocksmith is not working with my page builder app](/faqs/locksmith-is-not-working-with-my-page-builder-app)

Last updated 2024-04-18T05:11:20Z