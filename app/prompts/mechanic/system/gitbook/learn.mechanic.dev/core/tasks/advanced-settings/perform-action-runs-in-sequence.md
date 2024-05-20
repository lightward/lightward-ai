# Perform action runs in sequence

Mechanic's run system works asynchronously, performing as much work as possible, as quickly as possible. However, there are cases where it's important that actions run in a sequence – one after the other.

We support this with an advanced task setting called "Perform action runs in sequence", configured in two parts:

- Perform action runs in sequence – When enabled, Mechanic will only run one of the task's resulting actions at a time, performing them in the order in which they were generated.
- Halt the sequence when one fails – When this option is also enabled, Mechanic will only run the next action if the current action was performed successfully. If the action fails, all following actions will be marked as failed as well, with error messages explaining the situation.

Action run sequences are enforced within each task run. This means that a task could see more than one of its actions performed at the same time, if the task itself were to run multiple times, simultaneously.

To explain by example: a task that responds to mechanic/scheduler/10min, generating a sequence of 5 actions that each take 1 minute to run, will never see those actions overlap. However, if the task generated 15 actions instead, the actions would begin to overlap, as the task generates 15-minute action sequences every 10 minutes.

Last updated 2022-05-05T16:34:54Z