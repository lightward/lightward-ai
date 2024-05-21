[Original URL: https://learn.mechanic.dev/core/runs/scheduling]

# Scheduling

Event and task runs may be scheduled to perform in the future. They will not have any effect until they are performed. This means that their eventual performance may be impacted by changes to a store's Mechanic account, prior to the scheduled performance time.

## Event runs

### The Event action

Event runs may be scheduled using the Event action, using its run\_at option to define the time at which the run should be performed.

The task runs that arise from a scheduled event run will not be established until the event run is performed. (This does not apply if the task\_ids option is used, which determines ahead of time which tasks may be run in response to the new event.) This means that changes to the set of enabled tasks can have an impact on what tasks are actually run, in response to a scheduled event run.

### Scheduler events

Mechanic supports several scheduler topics (such as mechanic/scheduler/hourly), allowing tasks to be automatically invoked by the platform on a regular repeating interval.

Event runs generated in response to scheduler events are always adjusted for the store's local time.

## Task runs

### Subscription offsets

Task runs may be scheduled using subscription offsets, in which a task states that it wishes to run later (by some amount of time) than the event that triggers it.

Subscription offsets are a property of the task, and are applied by the task run – not the event run. This means that the subscribed-to event must be created and run before the subscription offset is calculated and applied.

In some cases, the first task run on a new mechanic/scheduler/daily task may not be performed when expected.

To illustrate: if a user creates a task at 9am Monday, subscribing to mechanic/scheduler/daily+10.hours, they will have to wait until the following midnight before the mechanic/scheduler/daily event is created. When that event's run is performed, the task's subscription offset will be calculated and applied, and the task run will be enqueued for 10 hours later. This means that the task will run for the first time on 10am Tuesday, not 10am Monday.

### The Event action

To achieve precise scheduling (e.g. "run on December 16th at 2:30pm"), or to accomplish scheduling for an interval not supported by Mechanic's scheduler topics, use the Event action to schedule an event run at any chosen time, with a custom event topic. Make sure that the desired task is subscribed to the same custom topic, and consider using the Event action's task\_id option to specify that only the desired task is allowed to respond to the new event.

Task runs that are scheduled for the future will always use a task's latest configuration, including the task's options, code, and Shopify API version.

If a task is disabled or deleted at the time a task run comes due, the task run will still perform at the scheduled time, but will fail instantly.

Last updated 2022-05-13T17:25:30Z