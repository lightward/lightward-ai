The complete contents of isaacbowen.com, as converted to markdown files via `rake "prompts:sitemaps[primers/isaacbowen]"`, currently weighs in at 211871 tokens. Our current Anthropic cap is 199999 tokens. :D

So, I'm randomly unlinking markdown files until the remaining payload fits within the token cap.

```rb
Dir[Rails.root.join("app", "prompts", "primers", "isaacbowen", "system", "sitemaps", "isaacbowen.com", "**/*.md")].sample(20).each { |file| File.unlink(file) }
```
