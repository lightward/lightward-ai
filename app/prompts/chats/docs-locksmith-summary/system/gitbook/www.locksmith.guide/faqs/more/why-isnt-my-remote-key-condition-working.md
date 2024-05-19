# Why isn't my passcode, secret link, newsletter, or location key working?

Tip: we call these "remote key conditions", because they involve making remote calls to Locksmith for verification.

You tested out your key, and it worked great. But now it stopped asking for verification. This can often happen when using one of these key types:

- Passcode
- Secret link
- Newsletter
- Location

For background, Locksmith remembers your previous access using the same mechanism Shopify uses to remember you: via browser cache.

The easiest way to move forward is by opening a private browsing session (sometimes called "incognito mode"), and then proceeding to test Locksmith in your online storefront.

Detailed information on using private/incognito mode here:

[pageHow to use a private browsing session](/tutorials/more/how-to-use-a-private-browsing-session)

Note: If you're using location keys, and you're changing your location with a VPN for testing purposes, the cause is the same in that Locksmith caches your access status. Using a private browsing session can still help with this in that you'll have fresh cache

Tip: Each time you test, be sure to start a new private browsing session. Remember, the cache in private browsing doesn't clear stored access until you close all private windows or stop the main Incognito process.

## Locksmith is remembering your browser.

When you open the key, Locksmith remembers it as long as your browser application remains running. To get around this, you'll need to use a private session (see above), or use a different browser or device.

In the case of location keys, if you're using a VPN to change your apparent location, it can even be useful to delete the browser cache during the same browser session. We have a guide on how to do this here:

[pageHow to clear cache for a single website](/tutorials/more/how-to-clear-cache-for-a-single-website)
## Locksmith is remembering your account.

If you were signed into a customer account when you opened the key, Locksmith can remember access on that account. This is a toggle-able setting on those key condition types, and, when turned on, Locksmith will never ask again when you're signed in.

To turn this setting off, head into the lock and click on the link to the key condition. Next, scroll down in the pop up and disable the option "Remember for signed in customer":

Toggle the setting OFF, and don't forget to save your lock!

[PreviousI switched themes, and Locksmith isn't working.](/faqs/more/i-switched-themes-and-locksmith-isnt-working.)[NextCan Locksmith lock Shopify's public JSON API for my online store?](/faqs/more/can-locksmith-lock-shopifys-public-json-api-for-my-online-store)

Last updated 2024-05-07T21:37:53Z