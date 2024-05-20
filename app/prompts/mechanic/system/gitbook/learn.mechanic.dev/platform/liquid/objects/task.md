# Task object

Only available within a task, the task object contains attributes describing the current task itself.

## How to access it

- Use {{ task.id }} in a task code

## What it contains

This object is always a hash, containing the following keys:

- "id" – string
- "created\_at" – string

This object is most useful for scheduling follow-up work for itself, using the "task\_ids" option in the "event" action.

Last updated 2021-04-05T20:03:27Z