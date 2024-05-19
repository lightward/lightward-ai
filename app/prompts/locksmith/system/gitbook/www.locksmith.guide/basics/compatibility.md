# Compatibility with other apps and Shopify features

Locksmith works in and around the online storefront theme layer – an arena shared by many, many other apps. Locksmith's interoperability is excellent; its internal Liquid engine is very good at injecting its code in the right places, without causing issues for themes or apps. Because of this, in the vast majority of cases, you won't need to worry about Locksmith's compatibility.

Having said that, there are a few places where there are specific points of compatibility or incompatibility.

## Officially unsupported apps

- The Shop app - Shopify's official Shop app is NOT compatible in any way with Locksmith! This is true for any other access control apps out there as well. Unfortunately, Shopify has drawn a pretty clear line here so there is no wiggle room: the two apps simply cannot be used on the same store at the same time. Even just installing Locksmith to your store will immediately affect your products in the Shop app, so please be aware of this if you use the Shop app heavily.

The following apps have known compatibility issues with Locksmith - although they may work in some cases, with the correct settings.

- Any other access control apps that work in a similar way to Locksmith will almost certainly not work well alongside Locksmith, as they tend to inject code into the same areas of your theme.
- Bold Custom Pricing: Wholesale - but only when using Locksmith's variant locking and manual locking features.
- Any app that controls price at the variant level - but only when using Locksmith's variant locking and manual locking features.
- Locksmith's manual locking feature can not generally be used to hide content being displayed by other third-party apps, including prices, buttons, widgets etc.
- Gempages - while it is possible to use the apps together in some cases, there are still many compatibility issues between the two apps.
- Weglot - Locksmith's location detection key condition is not compatible with Weglot, but you should otherwise be fine using both apps at the same time if not using location detection.

## Other areas of incompatibility

- Predictive searches - Locksmith generally cannot remove products from searches that dynamically show search results as you type. This includes built-in theme searches, and most apps that add predictive searches to your theme. That being said, it is possible to manage the appearance of specific products in store searches using product metafields: more information on that here.
- The Checkout area - Apps are pretty heavily limited in their ability to make changes to the checkout area, for security reasons. This means that Locksmith cannot restrict access to payment methods, shipping methods, shipping addresses, or anything else that is shown during the checkout process. If you wish to use Locksmith to restrict customers ability to check out, this would be done on the cart page before checkout begins. More information on that here.
- Protecting against bot/resellers - Locksmith cannot protect against purchases done by bots! Direct-to-checkout links, which allow products to be purchased without even visiting the Online Store, exist within the Shopify platform, and Locksmith cannot get involved with this layer. That being said, there is a strategy that you can employ, that doesn't use Locksmith directly, to help you protect against bots. More information on that here.

[PreviousCreating keys](/basics/creating-keys)[NextRemoving Locksmith](/basics/removing-locksmith)

Last updated 2024-02-21T23:35:24Z