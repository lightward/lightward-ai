# Can I query external APIs?

For more general information on third-party APIs, including more options for reading and writing data, see Working with external APIs.

Mechanic only has first-class API support for Shopify. However, you can use the HTTP action to fetch data from any source that's accessible with an HTTP URL. (APIs that require authentication via query param or header - basic auth, for example - are all supported. APIs that require authentication via OAuth are generally not supported.)

Tip: use Couchdrop's Shared Links to make any file available via a secret URL, from an FTP server or cloud storage provider.

For this kind of work, we recommend an execution sequence that looks like this:

1. Use an HTTP action to fire a GET request for your data's URL.
2. Set up your task to respond to mechanic/actions/perform, so you can respond to the GET request's downloaded results.
3. If you expect to use the retrieved data frequently, or across several tasks, consider using the cache to store that data for easy re-use.

## Example

- Demonstration: Fetch an external configuration file

Last updated 2021-04-18T02:00:07Z