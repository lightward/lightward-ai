[Original URL: https://learn.mechanic.dev/platform/liquid/objects/cache]

# Cache object

The cache object is used for retrieving values stored in the shop's Mechanic cache. For more on this, see Using the cache.

Cache data is unavailable during task preview.

## How to access it

- Use {{ cache["some\_key"] }} or {{ cache.some\_key }} in any task script
- Use {% for keyval in cache %} to iterate through the keys and values in your account's cache

### Related articles

- The "cache" action
- Using cache endpoints to share data
- Using the cache

Last updated 2023-10-31T15:10:21Z