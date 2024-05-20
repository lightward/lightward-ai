# Locksmith Storefront API

Locksmith includes a JavaScript-friendly Storefront API, embedded in your online store. This API can be used to check the current visitor's current authorization status for the resources that you name. For example, a search app could use this API to make sure a visitor has access to each of the resources that are in a set of search results, before showing those results to the visitor.

Locksmith's Storefront API is meant to facilitate user-facing browser experiences. Use the Admin API when building application code that manages Locksmith configurations.

This mirrors Shopify's own published APIs: Shopify's Admin API is meant for apps, whereas Shopify's Storefront API is meant for user-facing browser experiences.

### Usage

#### Requests

This API has a single endpoint, available on your online store's domain:

- GET /apps/locksmith/api/resources

When calling this path, include a series of urls[] query parameters, naming the relative URLs of the resources you want to check on.

Note: In some cases, using repeated urls[] query parameters can cause problems with API clients, and in some cases, Shopify may drop repeated query parameters with the same key. In these cases, use the querystring form ?urls[0]=/path1&urls[1]=/path2 instead.

There are limits to how many requests can be made per page load, since this is a storefront tool that uses Shopify's own Liquid engine. Product urls have a limit of 20 per page since they use the all\_products liquid object behind the scenes.

#### Responses

This API returns text/html responses, containing a JSON body. The Content-Type header should be ignored (it's a quirk of how Shopify's API proxy works), and the body should be interpreted as JSON.

The JSON response is an object whose keys are the URLs provided in the request's query parameters. The values are each objects themselves, containing state information defining the current visitor's authorization for each resource. The keys in these interior objects map to standard Locksmith variables; for their definitions, see Locksmith variables.

### Example

Some JavaScript libraries, like jQuery, make it easy to supply an array of query parameters in a way that serializes well for this API.

The example below uses jQuery to check on a single, specific product. See an interactive version of this example, here.

Copy

    
      $.get(
        '/apps/locksmith/api/resources',
        {
          urls: ['/products/short-sleeve-t-shirt'],
    
          // if providing URLs as an array isn't working
          // for your API client, try an object instead:
          urls: {
            0: '/products/short-sleeve-t-shirt',
            1: '/another/path',
          },
        },
        (response) => {
          const resources = JSON.parse(response);
          console.log(resources);
        }
      );
    

This script results in a logged value that looks like this:

Copy

    {
      "\/products\/short-sleeve-t-shirt": {
        "canonical_url": "\/products\/short-sleeve-t-shirt",
        "locked": true,
        "access_granted": true,
        "access_denied": false,
        "manual_lock": false,
        "hide_resource": false,
        "hide_links_to_resource": false,
        "locks": {
          "all": [12345],
          "opened": [12345]
        },
        "keys": [67890]
      }
    }

Last updated 2024-02-26T03:26:28Z