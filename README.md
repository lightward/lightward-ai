# lightward-ai

:)

## Booting in dev

This is a multi-process app, so use `bin/dev` to start them. `rails s` won't cut it. :)

```sh
bin/dev
```

## Deployment

### A word about PgBouncer

This thing *is not* compatible with pgbouncer transaction pooling! we're
using postgres for pubsub, and LISTEN is (as of this writing) not compatible
with transaction pooling.

https://www.pgbouncer.org/features.html#sql-feature-map-for-pooling-modes
