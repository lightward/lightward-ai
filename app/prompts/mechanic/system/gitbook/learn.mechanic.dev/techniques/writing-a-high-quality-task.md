# Writing a high-quality task

Here are some best practices we've found, as a community, about writing tasks that improve life for everyone.

Working on getting better at task-writing? See Practicing writing tasks.

- Know how Mechanic uses Liquid. We've extended the language with new tags and filters – being familiar with them will help you write a task that works efficiently, and reads cleanly.
- Render preview actions. During preview, your task should behave in way illustrative of its behavior with live events. Lean on defined preview events to cut down on preview-specific code, falling back to preview-specific code only when necessary.
- Watch out for action loops. If you're responding to mechanic/actions/perform, make sure the task guards against action events it's not interested in. If your task modifies a Shopify resource and also subscribes to that resource's update event, ensure that the task knows to not attempt to update it a second time.
- If you generate actions that destroy data, log the original values. You never know when you'll need to go back and pull the data that was in place before your action ran.
- If your task sometimes does nothing, log the reason why. This simple practice can save hours of customer support time later.
- When you want to do work x days after y, choose purposefully between delayed subscriptions and regular batch processing. Instead of using "shopify/orders/create+5.days" to queue up a bunch of future work, consider a task that runs on "mechanic/scheduler/daily" which queries for all orders that were created 5 days ago, processing all of them as a batch. This practice allows the merchant to disable/enable the task at will, without having to think about events that are already scheduled, and without having to wait x days before the task starts working again.
- ⚠️ Recall that Shopify doesn't guarantee webhook deliverability. During Shopify service interruptions, webhooks can be severely delayed. And, we've seen some cases in which Shopify completely fails to deliver webhooks – very rare, but it does happen. For more on this, and what to do about it, see Reconciling missing events.
- Include a test mode that only renders logs – no actions. When test mode is enabled, the task should log a summary of what the task would actually do if test mode were disabled. Use a boolean – something like {% if options.test\_mode\_\_boolean %}. This is very useful for debugging, before setting a task live.

Last updated 2023-09-21T22:04:49Z