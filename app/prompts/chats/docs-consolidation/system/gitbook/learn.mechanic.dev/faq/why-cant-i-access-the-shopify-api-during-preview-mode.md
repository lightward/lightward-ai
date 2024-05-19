# Why can't I access the Shopify API during preview mode?

A task is always run in response to an event. However, for several purposes, Mechanic may also run your task with a preview event, without performing any of the actions the task generates.

We refer to this as preview mode, and it's used for...

- Showing merchants what actions they can expect the task to perform
- Determining what permissions the task requires in order to run
- Performance-related analysis

Because all of these purposes require very fast performance of the task, Mechanic disallows all API requests during preview mode. You can use the event.preview variable to make decisions about what should happen during preview mode, like creating stub data that results in the appropriate actions being rendered during preview – a good practice when accounting for preview actions.

[PreviousCan I query external APIs?](/faq/can-i-query-external-apis)[NextHow do marketing preferences work with Mechanic?](/faq/how-do-marketing-preferences-work-with-mechanic)

Last updated 2023-05-06T21:47:10Z