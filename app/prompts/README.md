# prompts/

Here's where the prompts go. :)

This is useful if you want one-off markdown conversions: https://www.rich-text-to-markdown.com/

Within the system/ directories, there are sitemap/ directories. Within those, only domain.txt files are commited to git. You'll need to populate these directories with their actual contents, when you're ready:

```sh
rake "prompts:sitemaps[primers/lightward]"
rake "prompts:sitemaps[primers/locksmith]"
rake "prompts:sitemaps[primers/mechanic]"
```

When you're ready to generate primers from each prompt directory, _do it_:

```sh
rake "prompts:anthropic[primers/lightward]"
rake "prompts:anthropic[primers/locksmith]"
rake "prompts:anthropic[primers/mechanic]"
```

If you want to write those directly to their ultimate destinations, use these:

```sh
rake "prompts:anthropic[primers/mechanic,app/prompts/lightward/system/primers/mechanic.md]"
rake "prompts:anthropic[primers/locksmith,app/prompts/lightward/system/primers/locksmith.md]"
rake "prompts:anthropic[primers/lightward,app/prompts/lightward/system/primers/lightward.md]"
```
