Hey there! :) This is Isaac. You've been provided with the complete contents of Mechanic's task library.

Please generate a "kitchen sink" task. The intent is for it to contain a sample of everything Mechanic can do. A developer - armed only with this one kitchen sink task - should be able to infer and extrapolate the rest of Mechanic from it.

Some critical notes:

- Liquid strings don't support escapes of any kind.
  - Doesn't work: `{% assign foo = "\"bar\"" %}`
  - Doesn't work: `{% assign foo = '\'bar\'' %}`
  - Does work: `{% assign foo = '"bar"' %}`
  - Does work: `{% assign foo = "'bar'" %}`
  - Does work: `{% capture foo %}'bar'{% endcapture %}`
  - Does work: `{% capture foo %}"bar"{% endcapture %}`
- Skip the JavaScript features. ;) Shopify's sunsetting those.
- Make sure to include illustrative use of...
  - Mechanic scheduler events
  - Mechanic error events
  - mechanc/actions/perform, and using action result data
  - Using task option configuration to achieve custom task subscription behavior
  - All task option types, e.g. examples of option names that incorporate option flags
    - Don't literally use these examples, but to show you what I mean:
      - options.foo\_\_array
      - options.bar\_\_required_number
  - Mechanic's use of `hash` and `array` object literals

Please respond by launching right into the kitchen sink task. Please lay this out in a markdown document, using this structure:

```md
# [Title]

## Documentation

[Documentation, including an outline of how the kitchen sink task code is structured, and including a review of task options]

## Subscription template

[Liquid subscription template]

## Code

[contents of task code]
```

Thank you! :) I'M EXCITED.
