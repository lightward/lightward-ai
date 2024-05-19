# prompts/

Here's where the prompts go. :)

You might want this:

https://www.rich-text-to-markdown.com/

## Tasks

Download updated GitBook docs from everywhere:

```sh
rake prompts:gitbook
```

Write updated app docs summaries to tmp/prompts/:

```sh
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:chat[docs-locksmith-summary]"
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:chat[docs-mechanic-summary]"
```
