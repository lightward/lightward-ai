# Screenshots

We do a lot of documentation, and a lot of email. Screenshots come up a lot.

## Priorities

- Let the subject be one thing. Even if it's a multi-component thing. Stay focused. Be clear with yourself about what the screenshot is for.
- Don't distract the user. Avoid inconsistencies in your screenshot capture. Avoid elements (including data) that are irrelevant.
- Make it easy for someone to locate the thing for themselves. Given a particular app URL, make it easy for someone to orient themselves upon arrival, such that they can locate the subject of your screenshot for themselves.
- If all else fails, use a red box. Avoid it, but, you know, don't hesitate to use it if it's the only way.

## Strategies

### Pad your crops the way the UI pads content

Our app UI (powered by Polaris) always has a consistent amount of padding around each element, be it text or an interactive selector. When you're drawing screenshot boundaries, consider that padding, and make choices that feel like they fit.

### Include "peeks" of nearby areas

If you're helping your users find something in the UI, give them reference points by including pieces of the surrounding terrain when drawing the boundaries of your screenshot.

Heuristic for this: take the natural boundary of your content, and expand it just enough that someone can figure out the local context. Make it easy for people to find what you're showing them.

### Be inclusive

When filling in sample data, prefer sample data (names, email addresses, genders, countries) that reflect our global community.

Here's a name generator that works well: https://www.name-generator.org.uk/quick/

### Don't include internal references

Don't distract the user. It's less of a security thing, and more of a kindness thing.

If your screenshot includes data from our dev/staging/test instances, use Chrome's developer tools to edit that content out before taking the screenshot. Use generic content (like "example.com") wherever possible.

[PreviousREADME](/technical/readme)[NextCronitor](/technical/cronitor)

Last updated 2023-11-23T16:18:22Z