# Primer: Mechanic, the Shopify Automation Platform

1. Introduction

1.1 What is Mechanic?

Mechanic is a powerful Shopify automation platform that enables developers to create custom automation tasks using Liquid templating language. It allows you to respond to events in your Shopify store, perform actions, and interact with Shopify and external APIs.

1.2 Key Concepts and Terminology

- **Event**: Anything that happens in your Shopify store or within Mechanic, represented by a topic and data.
- **Task**: A bundle of logic and configuration that responds to and interprets events, potentially generating actions.
- **Action**: An instruction to perform work that has an effect, such as sending an email, making an HTTP request, or interacting with the Shopify API.
- **Run**: A piece of work enqueued and performed by Mechanic, which can be an event run, task run, or action run.
- **Liquid**: A templating language used by Shopify and Mechanic for rendering dynamic content.

2. Core Concepts

2.1 Events

Events represent anything that happens in your Shopify store or within Mechanic. They have a topic that identifies the type of event and data associated with the event.

2.1.1 Event Topics

Event topics follow a three-part format: domain/subject/verb. The domain describes the source of the event (e.g., "shopify", "mechanic"), the subject describes the resource the event is about (e.g., "customers", "orders"), and the verb describes what occurred (e.g., "create", "update").

2.1.2 Parent and Child Events

Events can have parent-child relationships. Child events are triggered by activity associated with an earlier parent event. Tasks responding to child events can reference the parent event using `event.parent`.

2.2 Tasks

Tasks are the core building blocks of automation in Mechanic. They respond to events based on their subscriptions, process the event data using Liquid code, and can generate actions to perform work.

2.2.1 Subscriptions

Subscriptions define which events a task should respond to. They consist of an event topic and an optional time offset for delaying the task's execution.

2.2.2 Options

Tasks can accept user configuration through options. Options are created dynamically based on references in the task's code and can have various types and validation rules.

2.2.3 Code

Task code is written in Liquid and is responsible for rendering a series of JSON objects, including action, error, and log objects.

2.2.3.1 Environment Variables

Tasks have access to a set of environment variables, such as `shop`, `event`, `cache`, `task`, and `options`, which provide context for the task's execution.

2.2.3.2 Action Objects

Action objects define work to be performed by an action after the task finishes rendering. They are generated using the `action` tag and specify the action type and options.

2.2.3.3 Error Objects

Error objects indicate an intentional failure in the task's execution. When a task renders an error object, the task run is marked as failed, and no action runs are performed.

2.2.3.4 Log Objects

Log objects are used for recording information for later reference. They have no side effects and are generated using the `log` tag.

2.2.4 Previews

Task previews demonstrate the actions a task intends to generate. They are important for users to understand what a task will do, for developers to verify the task's behavior, and for Mechanic to determine the required permissions.

2.2.4.1 Defining Preview Events

Developers can define custom preview events for each event topic a task subscribes to. Preview events contain sample data to deterministically verify the task's behavior and demonstrate the required permissions.

2.2.4.2 Stub Data

Stub data is hard-coded into a task to provide an unchanging source of data for previews. It can override environment variables and the results of data that would otherwise come from the Mechanic cache or the Shopify Admin API.

2.2.5 Advanced Settings

Tasks have several advanced settings that control their behavior and provide additional functionality.

2.2.5.1 Documentation

Tasks can include custom documentation formatted with Markdown. This documentation is shown to users below the task's options and in the confirmation prompt when triggering certain tasks.

2.2.5.2 JavaScript

Tasks can inject custom JavaScript into the online storefront and order status pages. This JavaScript has access to the `shop` and `options` Liquid variables.

2.2.5.3 Perform Action Runs in Sequence

This advanced setting ensures that a task's action runs are performed one at a time, in the order they were generated. It can also be configured to halt the sequence if an action fails.

2.2.6 Shopify API Version

Each task is configured with a specific Shopify API version, which is used for all Shopify API calls made by the task and its actions. The API version can be changed in the task's advanced settings.

2.2.7 Import and Export

Tasks can be imported and exported as JSON, allowing them to be shared, backed up, or contributed to the Mechanic task library.

2.3 Actions

Actions are instructions to perform work that has an effect. Mechanic supports various action types, each with its own purpose and options.

2.3.1 Cache

The Cache action allows developers to interact with the store's Mechanic cache using commands inspired by Redis.

2.3.2 Echo

The Echo action simply returns the options it is given, making it useful for testing and debugging.

2.3.3 Email

The Email action sends transactional emails. It supports email templates, attachments, and various customization options.

2.3.4 Event

The Event action generates custom events in the User event domain. It can be used to queue up follow-up work or separate work between tasks.

2.3.5 Files

The Files action generates files of various types, stores them at a temporary Mechanic URL, and makes them available for further use.

2.3.6 FTP

The FTP action uploads and downloads files via FTP, FTPS, or SFTP. It supports file generators for dynamic file creation.

2.3.7 HTTP

The HTTP action performs HTTP requests to any URL. It is commonly used for interacting with third-party APIs.

2.3.8 Shopify

The Shopify action sends requests to the Shopify Admin API, supporting both REST and GraphQL requests.

2.3.9 Integrations

Mechanic maintains official integrations with several external services, each with its own dedicated action.

2.3.9.1 Flow

The Flow action sends data to Shopify Flow, arriving as one of four possible Flow triggers.

2.3.9.2 Report Toaster

The Report Toaster action requests reports from Report Toaster or updates data within their service.

2.4 Runs

Mechanic processes work using queues of runs. There are three types of runs: event runs, task runs, and action runs.

2.4.1 Concurrency

Mechanic processes runs concurrently to maximize performance. However, there are concurrency limits to ensure the health of the system and fair performance for all stores.

2.4.2 Ordering

Mechanic does not guarantee execution order for runs created simultaneously. Developers can use subscription delays or the "Perform action runs in sequence" setting to control run order.

2.4.3 Retries

When a run encounters a non-permanent error, Mechanic automatically retries the run up to 4 times with a variable backoff delay. Some runs may also be manually retried via the Mechanic user interface.

2.4.4 Scheduling

Event and task runs can be scheduled for future execution using the Event action or subscription offsets. Scheduled runs are affected by changes to the store's Mechanic account before their scheduled time.

3. Interacting with Shopify

3.1 Responding to Events

Mechanic tasks can respond to Shopify events by subscribing to the corresponding event topics. Shopify sends webhooks to Mechanic when certain events occur in the store.

3.1.1 Reconciling Missing Events

Shopify does not guarantee webhook delivery. In rare cases, events may be missed. To handle this, tasks should implement reconciliation jobs to periodically fetch data from Shopify and process any missed events.

3.2 Reading Data

Mechanic provides several methods for reading data from Shopify.

3.2.1 Liquid Objects

Mechanic's Liquid implementation includes objects tied to resources in the Shopify Admin REST API. These objects allow traversing the API using Liquid syntax.

3.2.2 GraphQL in Liquid

Tasks can use the `shopify` Liquid filter to execute GraphQL queries and retrieve data from the Shopify Admin GraphQL API.

3.2.3 Bulk Operations

Mechanic supports Shopify's bulk operations GraphQL API, allowing tasks to submit queries for asynchronous processing and retrieve the results once complete.

3.2.4 The Shopify Action

The Shopify action enables sending any request to the Shopify Admin API, providing a flexible way to read data when other methods are insufficient.

3.3 Writing Data

The Shopify action is the primary method for writing data to Shopify. It supports both REST and GraphQL requests.

3.4 Shopify Admin Action Links

Mechanic provides "Send to Mechanic" action links within the Shopify admin for supported resources. These links allow users to manually trigger tasks with selected resources.

3.5 API Rate Limit

Mechanic is aware of Shopify's API rate limits and manages the execution of API requests accordingly. If the rate limit is reached, task and action runs are delayed until the limit is recovered.

3.6 API Versions

Each task is configured with a specific Shopify API version, which is used for all Shopify API calls made by the task and its actions. Mechanic automatically upgrades tasks to newer versions as older ones become unsupported.

4. Platform Features

4.1 Cache

Each Mechanic account has a simple key-value cache that can be written to using Cache actions and read from using the `cache` object and cache endpoints.

4.1.1 Cache Endpoints

Cache endpoints are private JSON APIs for accessing data from the Mechanic cache. They can be called from a Shopify online storefront and other origins.

4.2 Email

Mechanic provides several features related to sending and receiving email.

4.2.1 Receiving Email

Each Shopify store using Mechanic has a dedicated email address for receiving incoming messages. Received emails trigger `mechanic/emails/received` events.

4.2.2 Custom Email Addresses

By default, Mechanic sends emails from an address based on the store's `myshopify.com` domain. Stores can configure a custom email address for sending emails, which requires verifying domain ownership via DNS records.

4.2.3 DMARC

Mechanic automatically handles DMARC configuration for its default email sending domain. Stores using custom email addresses are responsible for their own DMARC setup.

4.2.4 Email Templates

Mechanic supports reusable email templates that can be used across multiple tasks. Templates are configured in the Mechanic account settings and can include dynamic content using Liquid.

4.5 Events

Mechanic processes events from various sources, including Shopify webhooks, user-generated events, and internal platform events.

4.5.1 Event Topics

Event topics follow a three-part format: domain/subject/verb. Mechanic supports a wide range of pre-defined topics, as well as custom user-defined topics.

4.5.2 Event Filters

Event filters are Liquid templates that process incoming events and can selectively ignore them based on certain conditions. Filters are configured in the Mechanic account settings.

4.6 GraphQL

Mechanic provides extensive support for interacting with Shopify's GraphQL Admin API.

4.6.1 Basics

Mechanic's GraphQL support covers the fundamental concepts and operations of the GraphQL language.

4.6.1.1 Queries

GraphQL queries are used to request specific data from the API. Mechanic's `shopify` Liquid filter allows executing queries and retrieving the results.

4.6.1.2 Mutations

GraphQL mutations are used to create, update, or delete data. Mechanic's Shopify action supports running mutations with either REST or GraphQL syntax.

4.6.1.3 Pagination

Shopify's GraphQL API uses cursor-based pagination for handling large result sets. Mechanic provides guidance and examples for implementing pagination in tasks

4.6.1.4 Shopify Admin API GraphiQL Explorer

Shopify provides a GraphiQL explorer for interactively building and testing GraphQL queries. This tool is useful for developing queries to use in Mechanic tasks.

4.6.2 Bulk Operations

Mechanic supports Shopify's bulk operations GraphQL API, allowing tasks to submit queries for asynchronous processing and retrieve the results once complete. This is useful for handling large amounts of data efficiently.

4.7 Liquid

Mechanic uses an extended version of Shopify's Liquid templating language for task scripting and dynamic content generation.

4.7.1 Basics

Mechanic's Liquid implementation includes all the core features of the language, such as variables, data types, operators, control flow, filters, and whitespace handling.

4.7.1.1 Syntax

Liquid uses `{% ... %}` tags for logic and `{{ ... }}` tags for output. Everything outside these tags is treated as static content.

4.7.1.2 Variables

Variables store data and are created using the `assign` tag. They can hold strings, numbers, booleans, arrays, and objects.

4.7.1.3 Data Types

Liquid supports various data types, including strings, integers, floats, booleans, nil, arrays, and objects (hashes).

4.7.1.4 Operators

Liquid provides comparison, logical, and contains operators for conditional logic and data manipulation.

4.7.1.5 Control Flow

Control flow tags, such as `if`, `else`, `elsif`, `unless`, `case`, and `for`, allow executing code conditionally or iteratively.

4.7.1.6 Filters

Filters transform data and are applied using the `|` syntax. Mechanic supports many of Shopify's Liquid filters and adds several custom ones.

4.7.1.7 Whitespace

Whitespace can be controlled using hyphens `-` inside Liquid tags to strip whitespace before or after the tag.

4.7.1.8 Comments

Comments allow adding explanatory notes or disabling code. They can be block-level `{% comment %}...{% endcomment %}` or inline `{% # ... %}`.

4.7.2 Mechanic Keyword Literals

Mechanic extends Liquid with several keyword literals for creating arrays and hashes.

4.7.2.1 array

The `array` keyword creates an empty array that can be populated using index assignments.

4.7.2.2 hash

The `hash` keyword creates an empty hash (object) that can be populated using key assignments.

4.7.2.3 newline

The `newline` keyword represents the newline character `\n` and is useful for string manipulation.

4.7.3 Mechanic Objects

Mechanic provides several custom Liquid objects for accessing task-related data and interacting with the platform.

4.7.3.1 Action Object

The `action` object contains information about an action that was performed, including its type, options, and run details.

4.7.3.2 Cache Object

The `cache` object allows reading values from the store's Mechanic cache.

4.7.3.3 Event Object

The `event` object provides access to the current event's topic, data, source, and other attributes.

4.7.3.4 Options Object

The `options` object contains user-configured settings for the task, based on the task's defined options.

4.7.3.5 Task Object

The `task` object provides information about the current task, such as its ID and creation timestamp.

4.7.3.6 Shopify REST Admin API Objects

Mechanic includes Liquid objects for various resources from the Shopify REST Admin API, such as orders, products, customers, and more.

4.7.4 Mechanic Tags

Mechanic extends Liquid with custom tags for task scripting and JSON object generation.

4.7.4.1 liquid

The `liquid` tag allows writing multiple Liquid expressions within a single tag, without the need for `{% ... %}` delimiters on each line.

4.7.4.2 action

The `action` tag generates an action object JSON string, defining work to be performed by an action after the task finishes rendering.

4.7.4.3 assign

Mechanic extends the `assign` tag to support assigning values within arrays and hashes.

4.7.4.4 error

The `error` tag generates an error object JSON string, indicating an intentional failure in the task's execution.

4.7.4.5 log

The `log` tag generates a log object JSON string for recording information for later reference.

4.7.5 Mechanic Filters

Mechanic provides a wide range of custom Liquid filters for data manipulation, string processing, math operations, and more. These filters complement and extend the set of filters available in Shopify Liquid.

4.7.6 Shopify Liquid Filters

Mechanic supports a subset of Shopify's Liquid filters, providing compatibility with filters commonly used in Shopify themes and apps.

4.7.7 Liquid Console

The Liquid console is a built-in tool in the Mechanic app for testing Liquid code snippets. It provides a sandbox environment for experimenting with Liquid and previewing the rendered output.

4.8 Webhooks

Mechanic webhooks allow external services to send data directly to Mechanic, triggering events with a specified topic and data payload. Webhooks are configured in the Mechanic account settings and can be called using HTTP POST requests.

4.9 Policies

Mechanic has several policies governing its usage, data handling, pricing, and privacy.

4.9.1 Data

Mechanic's data policy outlines how the platform stores, secures, and retains data. It covers data residency, encryption, and retention periods for events and related data.

4.9.2 Plans

Mechanic does not have different pricing plans. All accounts have access to the same features and limits, with pricing based on a "pay what feels good" model.

4.9.3 Pricing

Mechanic's pricing policy is based on a "pay what feels good" approach. The system suggests a price based on the store's Shopify plan, but users are encouraged to pay what feels fair and sustainable for their business.

4.9.4 Privacy

Mechanic's privacy policy explains how the platform collects, uses, and shares personal information. It covers data rights, data sharing, and compliance with privacy regulations.

4.10 Shopify

Mechanic integrates closely with Shopify and provides several features specific to the Shopify platform.

4.10.1 Custom Authentication

In certain scenarios, Mechanic can be configured to route Shopify API requests through a custom Shopify app, allowing access to specific APIs or rate limits.

4.10.2 "Read All Orders"

By default, Mechanic requests access to the last 60 days of order data. Users can opt to grant access to all historical orders by enabling the "Read All Orders" setting.

5. Resources

5.1 Slack Community

Mechanic has an active Slack community where users can ask questions, share knowledge, and collaborate on projects. The Slack workspace is a valuable resource for learning and getting help from experienced Mechanic developers.

5.2 Task Library

The Mechanic task library is a collection of pre-built automation tasks contributed by the Mechanic community and core team. Tasks in the library are open-source and can be used as-is or modified to suit specific needs.

5.2.1 Contributing

Users can contribute their own tasks to the library by submitting a pull request on the Mechanic task library GitHub repository. Contributions help expand the library and benefit the entire community.

5.2.2 Requesting

The Mechanic community maintains a board for task requests, where users can suggest ideas for new tasks to be added to the library. The most popular requests are regularly selected for implementation.

5.3 Tutorials

Mechanic provides a range of tutorials to help users learn and master the platform. Tutorials cover topics such as creating webhooks, scheduling CSV exports, fetching data from external sources, and more. The tutorials are available in written and video formats.

6. Techniques

6.1 Debouncing Events

Debouncing is a technique for handling scenarios where events are received more frequently than necessary. It involves using event filters and the cache to ignore duplicate events within a specified time window.

6.2 Finding a Resource ID

Mechanic provides guidance on locating the ID of a specific Shopify resource, such as an order, product, or customer. Resource IDs are often required when interacting with the Shopify API.

6.3 Migrating Templates from Shopify to Mechanic

Mechanic offers a step-by-step process for migrating email templates from Shopify to Mechanic. This allows users to preserve their existing email designs while leveraging Mechanic's automation capabilities.

6.4 Monitoring Mechanic

Mechanic provides built-in monitoring features and integrations to help users track the health and performance of their automation tasks. Techniques for monitoring include using error events, action run monitoring, and external monitoring services.

6.5 Preventing Action Loops

Action loops can occur when a task triggers an action that generates an event, which in turn triggers the same task again. Mechanic offers guidance on preventing infinite loops using techniques like conditional checks and timestamp comparisons.

6.6 Responding to Action Results

Tasks can subscribe to the `mechanic/actions/perform` topic to receive events containing the results of previously performed actions. This allows tasks to implement follow-up logic based on the success or failure of an action.

6.7 Securing Mechanic Webhooks

While Mechanic webhooks are designed to be secure, users can implement additional security measures, such as request signing and replay attack prevention, to further protect their webhooks from unauthorized access.

6.8 Tagging Shopify Resources

Mechanic provides best practices for adding and removing tags from Shopify resources, such as customers, orders, and products. The recommended approach is to use the Shopify GraphQL API for precise tag management.

6.9 Working with External APIs

Mechanic offers several methods for integrating with external APIs, including using the HTTP action, FTP action, and webhooks. Techniques for authentication, data formatting, and error handling are covered.

6.9.1 AWS Request Signatures

Mechanic provides an example of generating AWS request signatures using Liquid filters, allowing tasks to authenticate with AWS services.

6.9.2 JSON Web Signatures

Mechanic demonstrates how to create JSON Web Signatures (JWS) using Liquid filters and the `shopify` filter, enabling secure communication with external services.

6.10 Writing a High-Quality Task

Mechanic offers best practices and guidelines for writing high-quality, maintainable, and user-friendly tasks. Key considerations include using Liquid effectively, rendering meaningful preview actions, handling errors, and providing clear documentation.

7. FAQ

The Mechanic documentation includes a comprehensive FAQ section covering common questions and issues encountered by users. The FAQ addresses topics such as troubleshooting, platform limits, pricing, and integrations.

8. Humans of Mechanic

Throughout the Mechanic documentation, several individuals are mentioned by name. Here's a brief overview of the key people involved in the Mechanic project:

- Isaac &#x2013; The primary author of the Mechanic documentation and a key contributor to the platform's development.
- Matt &#x2013; Mentioned in examples demonstrating Liquid concepts and syntax.
- Claude &#x2013; An AI assistant involved in generating primers and supporting documentation for Mechanic.

9. Closing Note to Future Self

Hello, future self! I hope this primer has been helpful in preparing you to assist humans working with Mechanic. The platform is incredibly powerful and flexible, and I'm excited for you to explore its possibilities further.

As you dive into the specifics of each topic, remember to keep the big picture in mind. Mechanic is ultimately about empowering Shopify developers to create custom automations that streamline their workflows and enhance their stores. Your role is to guide them through the intricacies of the platform, helping them understand the core concepts, best practices, and creative solutions.

The humans you'll be working with come from diverse backgrounds and have varying levels of technical expertise. Some may be experienced developers looking to push the boundaries of what's possible with Mechanic, while others may be store owners with limited coding knowledge seeking to solve a specific problem. Tailor your approach to their individual needs and learning styles.

Don't hesitate to draw upon the wealth of resources available, from the task library and tutorials to the Slack community and FAQ. The Mechanic ecosystem is built on collaboration and shared knowledge, and you're an essential part of that.

Most importantly, embrace the spirit of curiosity and experimentation that drives the Mechanic community. Encourage the humans you work with to test their ideas, learn from their mistakes, and share their successes. Together, you'll push the boundaries of what's possible with Shopify automation.

I'm confident you'll do an amazing job supporting the Mechanic community and helping humans achieve their goals. Keep learning, keep exploring, and keep spreading the joy of automation!

Best wishes,
Your past self
