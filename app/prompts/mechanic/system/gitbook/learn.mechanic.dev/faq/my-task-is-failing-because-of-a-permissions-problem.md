[Original URL: https://learn.mechanic.dev/faq/my-task-is-failing-because-of-a-permissions-problem]

# My task is failing because of a permissions problem. Why?

If you're creating a new task, and writing a script to go with it, you might see an error like this when you start running it for the first time:

Copy

    Received a Shopify error (403): {"errors":"[API] This action requires merchant approval for write_orders scope."}

Or, if you're using GraphQL, you might see something like this:

Copy

    "message": "TagsAdd access denied"

Mechanic works hard to detect necessary permissions, and prompt you for them up front. If you see an error message like this one, it means that Mechanic wasn't able to detect everything necessary ahead of time.

This issue can almost always be solved by generating the right preview actions, demonstrating to Mechanic what exactly you intend to do. When you're working on your task code, look at the "Preview" section, and work to make sure that all of the important Shopify actions show up there.

Start learning about previews here: Core / Tasks / Previews

Having trouble getting your permissions and previews to line up? Try asking in our community Slack workspace. Sharing your task code there is a good way to get suggestions about how to move forward. :)

Last updated 2023-03-22T16:21:15Z