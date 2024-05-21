[Original URL: https://www.locksmith.guide/faqs/more/my-featured-collections-on-my-home-page-only-show-one-product.]

# My featured collections on my home page only show one product.

This error happens on specific themes (notably, the "Minimal" theme and similiar themes). There is a minor incompatibility with theses themes, but we can get it patched up for you pretty quickly!

Please get ahold of us if you would like us to make the edit. That being said, if you need an immediate update, here are the steps to fix it.

Start by opening the sections/featured-collection.liquid file in the theme editor and making the following replacements:

### Line 1

Before:

Copy

    {% assign featured = section.settings.featured_collection %}

After:

Copy

    {% assign featured_collection = section.settings.featured_collection %}

### Line 28

Before:

Copy

    {% for product in collections[featured].products limit: total_products %}

After:

Copy

    {% for product in collections[featured_collection].products limit: total_products %}

### Line 30

Before:

Copy

    {%- include 'locksmith-variables', locksmith_scope: 'subject', locksmith_subject: product, locksmith_subject_parent: collections[featured] %} ...

After:

Copy

    {%- include 'locksmith-variables', locksmith_scope: 'subject', locksmith_subject: product, locksmith_subject_parent: collections[featured_collection] %} ...

So, as you can see, you'll just be replacing "featured", with "featured\_collection" in a couple places. This will clear up the ambiguity on what the "featured" holds.

Note: If your theme has been custom edited, the above line number may not be exact.

As always, do contact us if you aren't feeling up to this! We are happy to do this for you. You can get in touch with the message button in the lower right corner.

Last updated 2022-09-16T17:06:05Z