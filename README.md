# lightward-ai

:)

## Checking rendered prompts

Good idea to check on estimated prompt counts and also on the actual interpreted input token count from Anthropic.

```sh
# this does both
rake prompts
```

## Booting in dev

This is a multi-process app, so use `bin/dev` to start them. `rails s` won't cut it. :)

```sh
bin/dev
```

## Adding js modules

```sh
bin/importmap pin dompurify
```

## Deployment

### A word about PgBouncer

This thing _is not_ compatible with pgbouncer transaction pooling! we're
using postgres for pubsub, and LISTEN is (as of this writing) not compatible
with transaction pooling.

https://www.pgbouncer.org/features.html#sql-feature-map-for-pooling-modes
