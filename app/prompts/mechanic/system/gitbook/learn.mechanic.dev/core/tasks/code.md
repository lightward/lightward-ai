# Code

A task's code is a Liquid template. In the same way that a Shopify storefront might use a Liquid template to receive requests and render HTML, a task uses its Liquid code to receive events, and render a series of JSON objects. These JSON objects define actions, logs, and errors.

In Mechanic, actions are performed after their originating task run concludes. Actions are not performed inline during the task's Liquid rendering.

To inspect and respond to the results of an HTTP action, add a task subscription to mechanic/actions/perform, allowing the action to re-invoke the task with the action result data.

Learn more: Responding to action results

Task code always has access to a set of environment variables, which can be used to make decisions about what JSON objects to render.

A task must purposefully consider its preview, so as to accurately communicate its intent to users and to the Mechanic platform.

To find many examples of task code, browse https://github.com/lightward/mechanic-tasks.

Last updated 2023-11-18T19:40:33Z