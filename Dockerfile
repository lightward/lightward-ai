# latest push seems to be broken so I'm pinning us to this ref for now
FROM ruby:3.4.1-alpine@sha256:1b9cac2013735a1ada5f53da62d78bd8f250647c571ad50ca89a458b7744bb13 AS builder
WORKDIR /app

RUN apk update && apk add --no-cache build-base
RUN apk update && apk add --no-cache build-base libpq-dev
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN bin/rails assets:precompile

# this is a sanity check
RUN bin/rake prompts:system

FROM ruby:3.4.1-alpine@sha256:1b9cac2013735a1ada5f53da62d78bd8f250647c571ad50ca89a458b7744bb13 as runner
RUN apk update
WORKDIR /app

# runtime dependencies for the application
RUN apk add --no-cache libpq postgresql-client

COPY --from=builder /app ./
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'
