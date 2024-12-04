# lightward-ai

:)

## Booting in dev

This is a multi-process app, so use `bin/dev` to start them. `rails s` won't cut it. :)

```sh
bin/dev
```

## Adding js modules

```sh
bin/importmap pin dompurify
```

## Subscription testing

```
stripe listen --latest --forward-to https://lightward-ai-dev-isaac.ngrok.lightward.dev/webhooks/stripe

# save the resulting webhook secret to .env
# STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

# Test payment failure
stripe trigger invoice.payment_failed

# Test subscription cancellation
stripe trigger customer.subscription.deleted

# Test subscription update
stripe trigger customer.subscription.updated
```

## Deployment

### A word about PgBouncer

This thing _is not_ compatible with pgbouncer transaction pooling! we're
using postgres for pubsub, and LISTEN is (as of this writing) not compatible
with transaction pooling.

https://www.pgbouncer.org/features.html#sql-feature-map-for-pooling-modes
