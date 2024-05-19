# prompts/

Here's where the prompts go. :)

You might want this:

https://www.rich-text-to-markdown.com/

## Tasks

Download updated GitBook docs from everywhere:

```sh
rake "prompts:gitbook[locksmith]"
rake "prompts:gitbook[mechanic]"
```

Write updated app docs summaries to tmp/prompts/:

```sh
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:anthropic[locksmith]"
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:anthropic[mechanic]"
```
