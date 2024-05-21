[Original URL: https://www.locksmith.guide/developer-tools/requests-from-locksmith]

# Requests from Locksmith

Locksmith occasionally makes requests to a shop's Online Store, starting with the shop's myshopify.com subdomain and then following redirects as necessary. (For example, Locksmith might request https://lightward.myshopify.com/, and then follow the redirect to https://lightward.shop/.)

Locksmith may make these requests to scan shop content or to verify Locksmith configuration, among other reasons.

Requests coming from Locksmith are identified with the following user agent header format, where $VERSION is Locksmith's own internal version identifier and $SHOP is the identifier for the Shopify store on whose behalf Locksmith is operating.

Copy

    user-agent: Locksmith/v$VERSION (uselocksmith.com; +$SHOP.myshopify.com)

Occasionally we'll see a store's non-Shopify security layers or proxies have an issue with Locksmith's requests. If you're using a service like Cloudflare or Edgemesh, a good place to start is by checking request logs for this user agent.

Remember: user agent strings can be easily spoofed. Security-by-user-agent is not a great practice.

Last updated 2023-12-21T18:39:25Z