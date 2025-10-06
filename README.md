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
