# Cache

Each Mechanic account has a simple key-value cache, which may be written to using Cache actions, and read from using the cache object and cache endpoints.

Cache data is unavailable during task preview.

## Restrictions

Cache keys must match /\A[a-z0-9\_:-.\/]+\z/i; that is, they must only contain alphanumeric characters, plus any of the following characters: \_:-./.

The cache is intended for temporary data storage. As such, each stored value is persisted for a maximum of 60 days. (Shorter expiration periods can be set using the Cache action's "ttl" option.)

The cache is not intended for large value storage. As such, each stored value is limited to a maximum of 256kb.

For storing larger values, consider spreading the value across multiple cache keys, or using the FTP action to upload data to another storage service (possibly using a service like Couchdrop as a intermediary). To read larger values in task code, use the HTTP action to perform a GET request, then respond to the action's results.

[PreviousPrivacy](/platform/policies/privacy)[NextCache endpoints](/platform/cache/endpoints)

Last updated 2023-10-31T14:48:21Z