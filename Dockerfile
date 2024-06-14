FROM ruby:3.3.3-alpine AS builder
WORKDIR /app

RUN apk update && apk add --no-cache build-base
RUN apk update && apk add --no-cache build-base libpq-dev
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN bin/rails assets:precompile

# Build the system context for clients/helpscout-{locksmith,mechanic}
RUN bin/rake "prompts:sitemaps[clients/helpscout-locksmith]"
RUN bin/rake "prompts:sitemaps[clients/helpscout-mechanic]"

FROM ruby:3.3.3-alpine as runner
RUN apk update
WORKDIR /app

# runtime dependencies for the application
RUN apk add --no-cache libpq postgresql-client

COPY --from=builder /app ./
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'
