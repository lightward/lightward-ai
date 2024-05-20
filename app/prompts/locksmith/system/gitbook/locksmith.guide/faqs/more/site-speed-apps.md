# I'm having trouble using Locksmith with a site speed optimization app.

Locksmith isn't supported in combination with site speed optimization apps. It may work with some, but we don't offer support for this combination.

## Apps known to be affected

- Nostra

If you run into an app that should be on this list (or if you find one that does seem to work), please let us know: team@uselocksmith.com.

## Why isn't this supported?

Locksmith's session state is very tightly coupled with the customer's Shopify session state (as managed by the Online Store channel). The two operate hand in hand, and depend on each other.

Site speed apps usually work by caching, or by dynamic injection of content delivered from a non-Shopify source. This introduces a layer between Locksmith's state and Shopify's state, which creates a synchronization problem, and one that we can't sustainably sign up for.

Last updated 2023-11-03T21:32:30Z