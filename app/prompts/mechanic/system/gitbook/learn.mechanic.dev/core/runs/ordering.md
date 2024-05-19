# Ordering

In general, Mechanic's run system does not guarantee the execution order for runs that have been created at the same time (see Concurrency). This applies to all kinds of runs: events, tasks, and actions.

For tasks, the simplest way to manage this is by using subscription delays, offsetting the time at which each task is run. For example, if you have two tasks that subscribe to shopify/customers/create, you might adjust one so that it it subscribes to shopify/customers/create+10.minutes instead. This way, your first task has a chance to execute and run before the other.

This is not a perfect solution: naturally, if the first task takes more than 10 minutes to run, there will still be overlap. So, Mechanic makes

## Guaranteeing run order for actions

Each task has an advanced option called "Perform action runs in sequence". When this is enabled, all generated actions for a given task run will be executed precisely in order.

## Guaranteeing run order for tasks

The best tool to leverage here is the Event action, coupled with action sequences (see above).

1. Begin by making a list of the tasks for which you need to guarantee run order, sorted by the desired run order. For these purposes, all of these tasks should subscribe to the same event topic.
2. Beginning with the task that should run first, (a) enable "Perform action runs in sequence", and (b) add an "event" action at the very end of your task script. The intent here is for this action to kick off a unique event topic that the second task should the subscribe to.
3. Having added that "event" action, update the second task so that it subscribes to your new event topic, instead of the original event topic. If there is a third task that should follow this one, repeat step 2 for this task as well, in preparation for kicking off the third task.
4. Repeat until you reach the final task in your list. This task does not need an "event" action at its conclusion; it only needs to have its subscription updated to listen for the penultimate task's generated event.

One more tool is worth mentioning: tasks may subscribe to mechanic/actions/perform to be re-triggered when each of their own actions are performed. For more on this strategy, see Responding to action results.

[PreviousConcurrency](/core/runs/concurrency)[NextRetries](/core/runs/retries)

Last updated 2021-04-05T20:03:10Z