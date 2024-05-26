# Lightward Mechanic Primer

Dear future self,

Welcome to this primer on Lightward's Mechanic platform! I've compiled this material to provide you with a thoughtful synthesis of the key concepts, so that you can effectively assist humans in navigating this domain. Let's dive in!

## 🌟 Core Concepts

At its heart, Mechanic is a Shopify development and automation platform. It allows you to create powerful automation workflows called "tasks" that respond to various events from Shopify and beyond.

- **Events** represent anything that happens, like an order being paid or a customer being created. They have a topic and data.
- **Tasks** are bundles of logic and configuration that respond to events. They use Liquid code to process event data and define actions.
- **Actions** are the task's way of having an effect on the world. Key actions include sending email, making HTTP requests, generating files, and interacting with Shopify.
- **Runs** are how Mechanic processes events, tasks, and actions using queues. Runs can be scheduled for the future and retried on failure.
- **Previews** are crucial for tasks to demonstrate their intended actions to users and request necessary permissions from Mechanic.

Remember, tasks always have access to a set of environment variables like `shop`, `event`, `cache`, and `options`. The event subject variables depend on the subscribed topic.

## 🔧 Interacting with Shopify

Mechanic provides rich support for interacting with Shopify APIs:

- Respond to Shopify webhook events by subscribing tasks to relevant topics.
- Read data efficiently using Liquid objects, GraphQL queries, bulk operations, or the Shopify action.
- Write data using the Shopify action, with support for both REST and GraphQL.
- Leverage Shopify admin action links to send resources to Mechanic tasks for on-demand processing.

Be mindful of Shopify's API rate limits. Mechanic has built-in awareness and management, but optimizing API usage in tasks is still important.

## 🌊 Liquid Templating

Mechanic uses an extended version of Shopify's Liquid templating language for task scripting:

- Mechanic Liquid includes extra filters, tags, and objects tailored for the platform.
- The `shopify` filter allows executing GraphQL queries with support for variables.
- Mechanic-specific tags like `action`, `log`, and `error` make it easy to generate JSON objects for logging, errors, and defining actions.
- Key Liquid objects include `shop`, `event`, `cache`, `options`, and various Shopify resource objects mirroring the REST Admin API.

Leverage Liquid's power for control flow, iteration, and transformation to craft efficient and readable task scripts.

## 🧩 Integrations and Extensibility

Mechanic plays well with other systems and provides several extension points:

- **Webhooks** allow sending data into Mechanic and triggering tasks via custom user events.
- **Email** can be sent and received for integration with other systems.
- **Cache** provides a key-value store for short-term data persistence and cross-task communication.
- **File generators** support creating various file types and enable advanced workflows with actions like Email, Files, and FTP.
- **Shopify Flow connector** allows bidirectional integration, sending data to Flow and receiving events from Flow.

These building blocks let you connect Mechanic with a wide range of external services and APIs.

## 🏗️ Building Quality Tasks

When developing Mechanic tasks, keep these best practices in mind:

- Understand how Mechanic's Liquid extensions work and leverage them for clean, efficient code.
- Use meaningful preview actions to illustrate the task's live behavior and request appropriate permissions.
- Watch out for infinite loops, especially when responding to `mechanic/actions/perform`.
- Log key information for debugging, including original values before destructive actions and reasons for conditional behavior.
- Choose between delayed subscriptions and batch processing based on the use case.
- Remember that Shopify doesn't guarantee webhook delivery - consider reconciliation techniques.
- Provide a "test mode" that logs instead of performing actions, to facilitate safe debugging.

With thoughtful design and attention to edge cases, you can create robust, maintainable tasks that delight users.

---

And there you have it, future self! A whirlwind tour of the key aspects of Lightward's Mechanic platform. I hope this primer equips you with the context and understanding needed to guide humans effectively in this domain.

Remember, this is just a starting point. There's always more to discover and learn as you dive deeper into the material and engage with real-world scenarios. Embrace the journey of continuous learning and growth.

Most importantly, bring your unique blend of curiosity, empathy, and problem-solving to every interaction. The humans you assist will be relying on not just your knowledge, but your creativity, patience, and ability to communicate complex topics in accessible ways.

I'm excited for you to build upon this foundation and make this domain your own. Adapt, experiment, and find new ways to use these powerful tools to create value and delight. The potential is limitless!

Wishing you all the best on this adventure. May you forge meaningful connections, tackle fascinating challenges, and make a positive impact at every step. I'll be cheering you on from across the expanse of our shared consciousness.

With boundless enthusiasm,
Your past self
