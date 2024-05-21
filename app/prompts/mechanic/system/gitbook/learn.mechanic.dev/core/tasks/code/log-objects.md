[Original URL: https://learn.mechanic.dev/core/tasks/code/log-objects]

# Log objects

Log objects are useful for recording information for later reference. They have no side-effects. Carefully chosen log objects can massively simplify post-hoc debugging, especially (as we've found) when investigating merchant bug reports.

A log object is a plain JSON object, having the following structure:

Copy

    {
      "log": LOG_DETAILS
    }

The log details can be any JSON value.

Log objects are most easily generated using the log tag.

Log objects appear wherever task run results are visible, including the task preview and when viewing an event.

Last updated 2023-04-25T20:37:19Z