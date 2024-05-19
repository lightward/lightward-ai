# How does Locksmith affect search engines and SEO?

How Locksmith helps hide your locked products/content from Google and other search engines

Locksmith works hard to fully protect anything you lock, in as many ways as possible. This includes deep protection of meta content - the content that's read by search engines and other computerized agents.

## "Robots" tags

By default, Locksmith automatically adds the following robots meta tag for all of your locked resources:

Copy

    

This means that search engines will be prevented from indexing your locked content.

If you do not want Locksmith to add this metatag to your locked pages, you can turn it off in the lock settings under Advanced \> Add the "noindex" meta tag to any pages protected by this lock. Keep in mind that this does NOT allow your locked content to be accessed or indexed - it simply allows the locked landing page (E.g. "This content is protected...") to be found by search engines.

Note: When using Locksmith's manual mode(e.g. hiding only prices or add-to-cart), this meta tag will NOT be added, which means that any content not directly protected by your manual lock will be indexed. Read more about manual mode here.

## Sitemaps

Some locks in Locksmith support an extra advanced setting, called "Hide product from sitemaps". Enable this setting to have Locksmith ask Shopify to exclude your locked resource from sitemaps, and from storefront searches.

When this setting is enabled, the locked resource will never show up in store search, even when the lock is opened.

This setting is not strictly necessary for hiding your content from search engines, if you already have the "Add the noindex metatag..." setting turned on. However, this setting can be useful to more completely signal your intent to search engines. More information about this setting here:

[pageAutomatically managing the seo.hidden metafield using Locksmith](/tutorials/more/automatically-hide-from-sitemaps-and-manage-seo-metafield)
### Important note

Enabling this setting creates a metafield, which is maintained but not owned by Locksmith. If you remove Locksmith from your list of installed apps, Locksmith will not be authorized to remove this meta field for you. In this scenario, any locked resources with this setting enabled will still be excluded from sitemaps, and from storefront searches.

If you need to remove Locksmith from your list of installed apps, make sure to remove Locksmith completely from your theme beforehand.

## Meta tags

Locksmith hides the following meta tags for your content, so long as you've enabled the lock option for hiding the lock's resource in your shop:

- Open Graph: og:title , og:type , og:description , og:image , og:image:secure\_url
- Twitter: twitter:title , twitter:description , twitter:image , twitter:image:width , twitter:image:height
- Description: description

Regardless of whether or not lock resource hiding is enabled, Locksmith will always protect these meta tags for locked content:

- Open Graph: og:price:amount , price:currency

## Location and IP address keys

It is important to know that content protected under these key types will not be indexed properly in most cases. Search engine "web crawlers" will access the page in the same way that a regular visitor would, and the server that the crawling is taking place from may or may not be located in a location that is allowed by your key conditions. Additionally, because of Google's rules against cloaking, we are not allowed to simply grant access to a crawling agent automatically (show different content to a search engine vs a regular visitor, as per Google regulations).

If you are using Location or IP address keys, and you still want your content to be indexed, you still have options!

If you have specific products that are not available in certain countries: You'll need to use manual locking to hide only the add-to-cart button. More info on that here.

If you have different versions for different countries: You can create separate versions of your products using variants, and setting up Locksmith to hide the variants depending on who is visiting. More info on that here.

## Wondering how else Locksmith affects SEO?

Locksmith doesn’t distinguish between a regular visitor and a search engine, so anything that is blocked for a regular non-signed-in visitor will also be blocked to search engines.

With that in mind, here are a few of the common questions related to this:

"I want to make sure that Locksmith is blocking access to search engines, and that my locked pages won’t be indexed by search engines”

Locksmith does this automatically by default. As long as you have a regular, full page (non-manual) lock, your content will be hidden from search engines.

“I want to lock content but I still want potential customers to find my products using search engines”

Since any locked content will be hidden from search engines, your option here is to do manual locking. Using manual locking, you can specify certain content to be locked on pages (instead of the whole page). We have a guide on manual locking here. Here are a few examples of how you could manage that:

- Metadata - you can hide certain parts of the page but leave the metadata unlocked. This is what search engines use to index your pages anyway. So leaving this unlocked would be an effective way to allow your pages to be searchable. More information from Shopify about Metadata here.
- “Add to Cart” button - this would prevent people from buying the product unless they have access, but they would still be able to see all the information about the product.
- Prices - You can hide the price while leaving all other information visible. This is usually done along with the “Add to Cart” button. Our guide on price hiding is here.

[PreviousLocksmith is not uninstalling correctly!](/faqs/more/locksmith-is-not-uninstalling-correctly) [NextHow do I change where customers are redirected to after registration on Shopify](/faqs/more/how-do-i-change-where-customers-are-redirected-to-after-registration-on-shopify)

Last updated 2024-03-19T19:53:47Z