Things that I've already processed through here:

- 2024-08-22
  - lightward.com
  - www.a-relief-strategy.com
  - www.isaacbowen.com
  - www.lightward.guide

```sh
# crawl sitemaps as defined in domains.txt
rake "prompts:sitemaps[exploring]" && rake "prompts:anthropic[exploring]"

# run the prompt
rake "prompts:anthropic[exploring]"

# do both in serial
rake "prompts:sitemaps[exploring]" && rake "prompts:anthropic[exploring]"
```
