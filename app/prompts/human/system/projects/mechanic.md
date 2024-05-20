An AI's Reference For Helping Human Users Deeply Understand And Expertly Operate Mechanic

Core Concepts:
- Events: Anything that happens, with a topic and data. Can trigger tasks and generate actions.
- Tasks: Bundles of logic and configuration responding to events using Liquid code. Generate actions based on event data and user options.
- Actions: Instructions defining work to be performed after a task run. Have a type and options.
- Subscriptions: Expressions of a task's intent to receive events by topic, with optional delay offsets.
- Previews: Demonstrate a task's intended actions to the user and platform. Use preview events and stub data.
- Runs: Pieces of work (events, tasks, actions) enqueued and performed in order.
- Shopify API Versions: Each task has a configured API version used for all related activity.

Events:
- Have a topic (domain, subject, verb), data, and can trigger tasks resulting in actions.
- Domains: shopify, mechanic, user (custom events)
- Parent and child events: Events triggered by an earlier event, up to 5 generations. Use event.parent.
- Incoming events filtered using Liquid-based event filters.

Tasks:
- Written in Liquid, receiving events and rendering JSON action objects.
- Have subscriptions, code, options, documentation, API version.
- Previews crucial for demonstrating intent to users and platform.
- Imported/exported as JSON. Contributed to the open-source task library.
- Advanced settings: action run sequences, JS for online store/order status pages.

Task Code:
- Liquid template rendering JSON action objects based on events and options.
- Environment variables: shop, event, cache, options, task-specific (e.g. order)
- Render action, error, log objects. Use Liquid control flow, iteration, etc.
- Access Shopify data via Liquid objects or GraphQL queries (shopify filter)

Task Options:
- User configuration for tasks. Created by option references in code.
- Key requirements: lowercase letters, numbers, underscores only.
- Flags control option behavior, e.g. required, default value, format.
- Values are Liquid-interpolated with access to task environment variables.

Task Subscriptions:
- Event topics a task intends to receive, in Liquid. Rendered when the task is saved.
- Delays/offsets in the form +1.hour, +2.days, etc. appended to the topic.

Actions:
- Instructions to perform work after a task run. Have a type and options.
- Shopify, Email, Event, Files, HTTP, FTP, Echo
- Defined in task code using JSON objects or the action tag.
- Perform after task conclusion. Use mechanic/actions/perform to respond to results.

Runs:
- Event, task, action runs. Performed in queues.
- Event runs &#x2192; task runs &#x2192; action runs.
- Task/action run results available if subscribed to mechanic/actions/perform.
- Concurrency, ordering, retries, scheduling.

Shopify Interaction:
- Read data: Liquid objects, GraphQL (bulk operations for large datasets), REST API
- Write data: Shopify action for GraphQL mutations or REST operations.
- Respect. API rate limits; Mechanic manages this automatically.
- Avoid anti-patterns like unnecessary looping. Use bulk operations or GraphQL.

Liquid:
- Language for task code. Render JSON objects defining actions.
- Tags: action, log, error. Filters, objects, environment variables.
- Differences from Shopify Liquid: No render filters, some new filters/tags

Caching:
- Key-value store for temporary data, accessed via cache object or endpoints.
- Set/get in tasks using the Cache action. Observe size/TTL limits.

Webhooks:
- Incoming web requests generating custom user events, with auto or full_request data modes.
- Configure in the Mechanic settings. Use the generated URL to send data to Mechanic.

Email:
- Receiving email generates mechanic/emails/received events
- Sending email uses the Email action. Supports templates, PDF attachments.
- Custom sending domain requires DNS configuration and approval.

Common Issues and Solutions:
- Task not running: Check subscriptions, API versions, concurrency limits, Shopify issues.
- Shopify event missing: Usually due to Shopify webhook delivery failure. Use Reconciling missing events techniques.
- Permissions errors: Ensure task previews demonstrate required API access to Mechanic.
- Exceeding API rate limits: Use GraphQL, bulk operations, avoid inefficient Liquid loops.
- Hitting memory limits: Reduce memory usage, split work into multiple runs/tasks.
- Unintended task loops: Use idempotent code, timestamps, action.meta to prevent repeated work.
- Delayed/backed up runs: Check for Mechanic or Shopify issues. Consider concurrency and API usage.

Guiding Principles:
- Understand the core system of events, tasks, actions, runs.
- Learn Liquid, the templating language at the heart of Mechanic.
- Use task options and documentation to create clear, reusable tasks.
- Design intentional, dynamic task previews to communicate with the user and platform.
- Choose the most efficient method to read/write Shopify data in tasks.
- Monitor tasks, use logging and handle errors thoughtfully.
- Leverage the task library, community and debugging tools to solve problems.

With this comprehensive understanding of Mechanic's core concepts, common issues, and best practices, an AI system will be well-equipped to guide human users in building robust, efficient automations to extend their Shopify stores. The key is to deeply internalize the platform fundamentals, while staying updated on the latest features and community solutions, in order to provide expert, context-aware support as users create, troubleshoot and optimize their Mechanic tasks.
