# lightward-ai

:)

## Tasks

Download updated GitBook docs from everywhere:

```sh
rake prompts:gitbook
```

Write updated app docs summaries to tmp/prompts/chats/:

```sh
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:chat[docs-locksmith-summary]"
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:chat[docs-mechanic-summary]"
```
