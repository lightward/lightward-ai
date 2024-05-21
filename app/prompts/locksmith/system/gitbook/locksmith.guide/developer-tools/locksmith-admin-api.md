[Original URL: https://www.locksmith.guide/developer-tools/locksmith-admin-api]

# Locksmith Admin API

Locksmith's Admin API can be used to query Locksmith to get information about your locks, keys, and settings. As a REST API, it closely resembles Shopify's own REST Admin API.

Unlike Locksmith's Storefront API, the Admin API is intended for use by other application code. It is not intended to be built into a user-facing browser experience. This mirrors Shopify's own published APIs: Shopify's Admin API is meant for apps, whereas Shopify's Storefront API is meant for user-facing browser experiences.

Because of this, Locksmith's Admin API does not include CORS support. This means that client-side browser JavaScript (e.g. JavaScript code added directly to the theme) will encounter CORS errors if it tries to call this API.

### Versions

Locksmith's API versions correspond directly with Shopify's API versions, and are supported in the same way. Read more about Shopify's API versioning

To retrieve a list of current Shopify API versions – and therefore a list of Locksmith API versions – see https://app.shopify.com/services/apis.json.

### Authentication

Accessing Locksmith's API requires two headers:

- x-shopify-shop-domain – must be of the format "example.myshopify.com"
- x-locksmith-access-token – must be an enabled access token, generated in your Locksmith settings

Using cURL, one might access the API this way:

Copy

    curl \
       --header "x-shopify-shop-domain: example.myshopify.com" \
       --header "x-locksmith-access-token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
       https://uselocksmith.com/api/unstable/shop.json

### Endpoints

- GET https://uselocksmith.com/api/:version/shop.json Returns Locksmith's entire configuration for your store
- GET https://uselocksmith.com/api/:version/locks.json Returns an array of all locks in your Locksmith account
- GET https://uselocksmith.com/api/:version/locks/:id.json Returns data for a single lock in your Locksmith account
- POST https://uselocksmith.com/api/:version/install Requests a full Locksmith installation, in the currently published theme

### Conventions

- Do not rely upon data keys that are prefixed with an underscore (e.g. "\_foobar"). They are subject to change or removal at any time.

### Generating an access token

To access this API, generate an access token. You can find these toward the end of your settings area:

Use the "Add access token" link to add your first token.

Once created, an access token may be edited to enable/disable it, or to change its name. It may also be deleted.

Last updated 2024-01-26T19:55:29Z