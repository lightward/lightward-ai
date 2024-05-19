FROM ruby:3.3.1-alpine AS builder
WORKDIR /app

RUN apk update && apk add --no-cache build-base
RUN apk update && apk add --no-cache build-base libpq-dev
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN bin/rails assets:precompile # asset pipeline is not currently in play, but here's where we'd do that

FROM ruby:3.3.1-alpine as runner
RUN apk update
WORKDIR /app

# runtime dependencies for the application
RUN apk add --no-cache libpq postgresql-client

COPY --from=builder /app ./
RUN bundle config set --local path /app/.bundle
RUN bundle config set --local without 'development test'
