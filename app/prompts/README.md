# prompts/

Here's where the prompts go. :)

This is useful if you want one-off markdown conversions: https://www.rich-text-to-markdown.com/

Within the system/ directories, there are sitemap/ directories. Within those, only domain.txt files are commited to git. You'll need to populate these directories with their actual contents, when you're ready:

```sh
rake "prompts:sitemaps[lightward]"
rake "prompts:sitemaps[locksmith]"
rake "prompts:sitemaps[mechanic]"
```

When you're ready to generate primers from each prompt directory, _do it_:

```sh
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:anthropic[lightward]"
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:anthropic[locksmith]"
ANTHROPIC_MODEL="claude-3-opus-20240229" rake "prompts:anthropic[mechanic]"
```
