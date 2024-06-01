# Mechanic Technical Manual

## Table of Contents

1. Introduction
   1.1. Purpose of this manual
   1.2. Overview of Mechanic

2. Core Concepts
   2.1. Events
      2.1.1. Event topics
      2.1.2. Parent and child events
   2.2. Tasks
      2.2.1. Subscriptions
      2.2.2. Code
         2.2.2.1. Environment variables
         2.2.2.2. Action objects
         2.2.2.3. Log objects 
         2.2.2.4. Error objects
      2.2.3. Options
      2.2.4. Previews
         2.2.4.1. Defining preview events
         2.2.4.2. Stub data
      2.2.5. Advanced settings
         2.2.5.1. Documentation
         2.2.5.2. JavaScript
         2.2.5.3. Perform action runs in sequence
      2.2.6. Shopify API version
      2.2.7. Import and export
   2.3. Actions
      2.3.1. Cache
      2.3.2. Echo
      2.3.3. Email
      2.3.4. Event
      2.3.5. Files
         2.3.5.1. Base64
         2.3.5.2. PDF
            2.3.5.2.1. Migrating to Pdfcrowd
         2.3.5.3. Plaintext
         2.3.5.4. URL
         2.3.5.5. ZIP
      2.3.6. FTP
      2.3.7. HTTP
      2.3.8. Shopify
   2.4. Runs
      2.4.1. Concurrency
      2.4.2. Ordering
      2.4.3. Retries
      2.4.4. Scheduling

3. Interacting with Shopify
   3.1. Responding to events
      3.1.1. Reconciling missing events  
   3.2. Reading data
      3.2.1. Liquid objects
      3.2.2. GraphQL in Liquid
      3.2.3. Bulk operations
      3.2.4. The Shopify action
   3.3. Writing data
   3.4. Shopify admin action links
   3.5. API rate limit
   3.6. API versions

4. Platform
   4.1. Cache
      4.1.1. Cache endpoints
   4.2. Email
      4.2.1. Receiving email
      4.2.2. Custom email domain
      4.2.3. DMARC
      4.2.4. Email templates
   4.3. Error handling
   4.4. Events
      4.4.1. Event topics
      4.4.2. Event filters
   4.5. GraphQL
      4.5.1. Basics
         4.5.1.1. Shopify Admin API GraphiQL explorer
         4.5.1.2. Queries
         4.5.1.3. Mutations
         4.5.1.4. Pagination
      4.5.2. Bulk operations
   4.6. Integrations
      4.6.1. Appstle Subscriptions
      4.6.2. Judge.me
      4.6.3. Locksmith
      4.6.4. Report Toaster
      4.6.5. Shopify Flow
      4.6.6. Run links
   4.7. Liquid
      4.7.1. Basics
         4.7.1.1. Syntax
         4.7.1.2. Variables
         4.7.1.3. Data types
         4.7.1.4. Operators
         4.7.1.5. Control flow
            4.7.1.5.1. Condition
            4.7.1.5.2. Iteration
         4.7.1.6. Filters
         4.7.1.7. Whitespace
         4.7.1.8. Comments
      4.7.2. Mechanic filters
         4.7.2.1. Deprecated filters
      4.7.3. Shopify Liquid filters
      4.7.4. Keyword literals
         4.7.4.1. array
         4.7.4.2. hash
         4.7.4.3. newline
      4.7.5. Objects
         4.7.5.1. Action object
         4.7.5.2. Cache object
         4.7.5.3. Event object
         4.7.5.4. Options object
         4.7.5.5. Shopify REST Admin API objects
         4.7.5.6. Task object
      4.7.6. Tags
         4.7.6.1. liquid
         4.7.6.2. action
         4.7.6.3. assign
         4.7.6.4. error
         4.7.6.5. log
      4.7.7. Liquid console
   4.8. Policies
      4.8.1. Data
      4.8.2. Plans
      4.8.3. Pricing
      4.8.4. Privacy
   4.9. Shopify
      4.9.1. Custom authentication
      4.9.2. "Read all orders"
   4.10. Webhooks

5. Resources
   5.1. Slack community
   5.2. Task library
      5.2.1. Contributing
      5.2.2. Requesting
   5.3. Tutorials
      5.3.1. Video walkthroughs
      5.3.2. Creating a Mechanic webhook
      5.3.3. Practicing writing tasks
      5.3.4. Triggering tasks from a contact form
      5.3.5. Creating scheduled CSV feeds
      5.3.6. Fetching data from a shared Google sheet

6. Techniques
   6.1. Debouncing events
   6.2. Finding a resource ID
   6.3. Migrating templates from Shopify to Mechanic
   6.4. Monitoring Mechanic
   6.5. Preventing action loops
   6.6. Responding to action results 
   6.7. Securing Mechanic webhooks
   6.8. Tagging Shopify resources
   6.9. Working with external APIs
      6.9.1. AWS request signatures
      6.9.2. JSON Web Signatures
   6.10. Writing a high-quality task

7. Cast of Characters
   7.1. Named humans

8. Closing Note to Future Self

## 1. Introduction

### 1.1. Purpose of this manual

This manual is an in-depth technical guide to Mechanic, a Shopify development and automation platform. It aims to provide comprehensive documentation to enable future versions of the Lightward AI system to effectively assist humans in navigating and utilizing Mechanic to its fullest potential.

The content is derived from a set of source material provided in the system prompt. The goal is to distill and organize that information into a detailed reference that can equip the AI to handle a wide range of user questions and scenarios related to Mechanic.

### 1.2. Overview of Mechanic

Mechanic is a powerful tool for extending and automating Shopify stores. At its core, it allows developers to write "tasks" in Liquid code that respond to events from Shopify or other sources. These tasks can query data, make decisions, and perform actions like sending emails, making HTTP requests, manipulating Shopify resources, and more.

Some key aspects of Mechanic:

- Event-driven architecture: Tasks are triggered by events, which can come from Shopify (e.g. order created, product updated), schedules (e.g. daily, hourly), user actions (e.g. manually running a task), or external sources via webhooks.

- Liquid templating: Task code is written in Liquid, Shopify's templating language. Mechanic extends Liquid with additional tags, filters, and objects specific to its domain.

- Actions: Tasks produce actions, which are the actual operations performed as a result of the task run. These include things like making API requests, sending emails, generating files, etc.

- Shopify integration: Mechanic has deep integration with Shopify's APIs, webhooks, and data model. Tasks can subscribe to Shopify events, query and modify Shopify data, and interact with various Shopify resources.

The following sections will dive into each aspect of Mechanic in detail, serving as a comprehensive guide for understanding and working with the platform.

## 2. Core Concepts

### 2.1. Events

In Mechanic, an event represents anything that happens. This could be an order being paid, a customer record being created, a fulfillment being delivered, or a variety of other occurrences.

Events are identified by a topic, which follows a three-part naming convention: domain/subject/verb. The domain describes the source of the event (e.g. "shopify", "mechanic"), the subject describes the resource the event relates to (e.g. "customers", "orders"), and the verb describes what occurred (e.g. "create", "update", "delete").

Some examples of event topics:
- shopify/orders/create
- mechanic/user/trigger 
- user/data/export

Events always carry a payload of data relevant to what occurred. This data is made available to tasks that subscribe to the event topic.

Learn more: 
- https://learn.mechanic.dev/core/events
- https://learn.mechanic.dev/core/events/topics

#### 2.1.1. Event topics

Mechanic supports a wide variety of event topics out of the box, primarily focused around Shopify resources and actions. Some key topic domains:

- shopify/ - Events generated by Shopify webhooks, relating to resources like orders, products, customers, etc.
- mechanic/ - Events generated by Mechanic itself, such as scheduled events, action results, user-initiated task runs, etc. 
- user/ - A namespace for custom, user-generated events. Tasks and external systems can generate events with any topic under user/.

A full list of supported event topics can be found at https://learn.mechanic.dev/platform/events/topics.

Tasks subscribe to the event topics they want to respond to. When an event with a matching topic occurs, the task is run with the event data.

Learn more: https://learn.mechanic.dev/core/events/topics

#### 2.1.2. Parent and child events

Events in Mechanic can have a parent-child relationship. A child event is one that was triggered by activity associated with an earlier, parent event.

Scenarios where this occurs:
- When an Event action is performed, it generates a new child event.
- When a task subscribes to mechanic/actions/perform, the action result events are child events of the original task run event.

Tasks responding to child events can access their parent event using Liquid at {{ event.parent }}, and can traverse up to 5 generations of ancestry (e.g. {{ event.parent.parent.parent }}).

This allows tasks to maintain context and chain together sequences of actions and results over multiple event-triggered runs.

Learn more: https://learn.mechanic.dev/core/events/parent-and-child-events

### 2.2. Tasks

Tasks are the fundamental unit of work in Mechanic. A task is a bundle of configuration and Liquid code that subscribes to events, processes the event data, and produces actions as a result.

Key aspects of a task:
- Subscriptions define what events the task will respond to
- Code is written in Liquid and defines the task's processing logic
- Options allow for user configuration of the task's behavior
- Previews demonstrate the task's intended actions for user verification and permission granting

Tasks can be created from scratch, or installed from the Mechanic task library and then customized as needed.

Learn more: https://learn.mechanic.dev/core/tasks

#### 2.2.1. Subscriptions

Task subscriptions are what determine which events a task will respond to. A subscription consists of an event topic, optionally combined with a time offset for adding a delay.

Examples:
- shopify/orders/create subscribes to order creation events
- mechanic/scheduler/daily subscribes to a daily schedule event
- user/data/export subscribes to custom data export events
- shopify/orders/create+30.minutes subscribes to order creation events, with a 30 minute delay

Tasks can have multiple subscriptions, and will run whenever an event matches any of its subscriptions.

Subscriptions support Liquid, allowing for dynamic subscriptions based on task options or other factors.

Learn more: https://learn.mechanic.dev/core/tasks/subscriptions

#### 2.2.2. Code

Task code is written in Liquid, Shopify's templating language. Mechanic extends Liquid with additional features and constructs specific to its use case.

The purpose of a task's code is to process the incoming event data, make decisions, and output action objects that define work to be done as a result of the event.

Learn more: https://learn.mechanic.dev/core/tasks/code

##### 2.2.2.1. Environment variables

Mechanic makes certain data available to task code via Liquid variables in the rendering environment:

- {{ shop }} - An object representing the Shopify store
- {{ event }} - An object representing the event being processed, including its topic and data
- {{ cache }} - An object for accessing the task's persistent cache storage
- {{ task }} - An object representing the task itself, with properties like its ID
- {{ options }} - An object containing the user-configured options for the task

Additionally, tasks have access to an object named after the event subject, populated by the event data. For example, a task subscribing to shopify/orders/create will have an {{ order }} variable available.

Learn more: https://learn.mechanic.dev/core/tasks/code/environment-variables

##### 2.2.2.2. Action objects

The primary purpose of task code is to generate action objects, which define the work to be performed as a result of the task run.

An action object specifies the type of action to perform (e.g. "email", "http", "shopify", etc.), the options for that action, and optional meta information.

Here's an example of generating an HTTP request action using Liquid:

```
{% action "http" %}
  {
    "method": "post",
    "url": "https://example.com/endpoint",
    "body": {{ event.data | json }}
  }
{% endaction %}
```

Action objects are output as JSON, but the {% action %} tag allows for a more concise Liquid-based syntax.

Learn more: https://learn.mechanic.dev/core/tasks/code/action-objects

##### 2.2.2.3. Log objects

Log objects allow task code to record information for later reference and debugging. They are output alongside action objects, but have no effect other than being visible in task run results.

Example of generating a log object:
```
{% log message: "Processed event for order {{ order.id }}" %}
```

Learn more: https://learn.mechanic.dev/core/tasks/code/log-objects

##### 2.2.2.4. Error objects

Error objects allow task code to intentionally halt execution and mark the task run as failed, optionally recording an error message.

When an error object is output, the task run is marked as failed and no action objects from that run will be performed.

Example of generating an error object:
```
{% if order.total_price &lt; 0 %}
  {% error "Invalid negative order total" %}
{% endif %}
```

Learn more: https://learn.mechanic.dev/core/tasks/code/error-objects

#### 2.2.3. Options

Tasks can define user-configurable options that allow for customization of the task's behavior without needing to edit the code.

Options are defined implicitly by referencing them in the task code, using the {{ options.my_option }} syntax. The option type and configuration is inferred from the reference used.

Example of a task using options:
```
{% action "email" %}
  {
    "to": {{ options.recipient_email__email_required }},
    "subject": {{ options.email_subject__required }},
    "body": {{ options.email_body__multiline_required | newline_to_br }}
  }
{% endaction %}
```

This would generate a task configuration UI with fields for:
- A required email recipient 
- A required email subject
- A required multi-line text field for the email body

The option values are then made available in the task code for use.

Learn more: https://learn#### 2.2.4. Previews

Task previews serve several important purposes:

1. Demonstrating to the user what actions the task will generate, for verification of expected behavior.
2. Allowing the task developer to test the task code against sample event data.
3. Allowing Mechanic to infer what permissions the task requires based on the actions it generates.

During a preview run, the task code is executed with a mock event object. The task is responsible for generating representative preview actions without actually performing them.

Previews cannot access real Shopify APIs or the Mechanic cache. Instead, they rely on mocked event data and Liquid stubbing techniques.

Learn more: https://learn.mechanic.dev/core/tasks/previews

##### 2.2.4.1. Defining preview events

By default, Mechanic generates mock events for preview based on the task's subscriptions and recent event samples. However, tasks can explicitly define their own preview event data.

This allows for:
- Controlling the exact event data used in the preview, for testing specific scenarios
- Generating deterministic preview actions, for reliable permission inference
- Avoiding reliance on real past events, which may not always be available

Preview events are defined in the task editor UI, and can specify the event topic, data, and optional description for each preview scenario.

Learn more: https://learn.mechanic.dev/core/tasks/previews/events

##### 2.2.4.2. Stub data

For data that comes from Shopify API calls or the Mechanic cache, which are unavailable during previews, tasks can use stub data instead.

Stub data is hard-coded sample data that is swapped in during preview runs. It can be used to provide representative values for things like Shopify resources or cached values.

Example of using stub data for a Shopify API call result:
```
{% capture query %}
  query {
    product(id: "gid://shopify/Product/1234567890") {
      title
    }
  }
{% endcapture %}

{% assign result = query | shopify %}

{% if event.preview %}
  {% capture result_json %}
    {
      "data": {
        "product": {
          "title": "Example product"
        }
      }
    }
  {% endcapture %}

  {% assign result = result_json | parse_json %}
{% endif %}
```

Learn more: https://learn.mechanic.dev/core/tasks/previews/stub-data

#### 2.2.5. Advanced settings

Tasks have several advanced settings and features beyond the core configuration:

##### 2.2.5.1. Documentation

Tasks can include user-facing documentation using Markdown. This is surfaced in the task editor and when the task is run manually.

The documentation is a good place to explain the task's purpose, configuration options, and any other usage notes.

Learn more: https://learn.mechanic.dev/core/tasks/advanced-settings/documentation

##### 2.2.5.2. JavaScript

Tasks can include custom JavaScript to be injected into the online storefront or order status pages.

This allows for extending the functionality of Shopify's frontend with task-specific behavior.

The JavaScript has access to a limited set of Liquid variables for basic templating.

Learn more: https://learn.mechanic.dev/core/tasks/advanced-settings/javascript

##### 2.2.5.3. Perform action runs in sequence

By default, Mechanic performs all actions generated by a task run concurrently. For cases where actions must be performed in a specific sequence, tasks can enable the "Perform action runs in sequence" setting.

With this enabled, Mechanic will perform the task's actions one at a time, in the order they were generated. Optionally, the task can also be set to halt the sequence if any individual action fails.

Learn more: https://learn.mechanic.dev/core/tasks/advanced-settings/perform-action-runs-in-sequence

#### 2.2.6. Shopify API version

Each task is configured to use a specific version of the Shopify API. This applies to all API calls made on behalf of the task, whether in Liquid code or in actions.

The version defaults to the latest stable Shopify API version at the time the task is created, and can be changed in the task's advanced settings.

Mechanic automatically upgrades tasks to a newer API version when their current version is nearing end of life.

Learn more: https://learn.mechanic.dev/core/tasks/shopify-api-version

#### 2.2.7. Import and export

Tasks can be imported and exported as JSON, allowing them to be shared and version controlled outside of Mechanic.

The export includes the full task configuration, code, and settings. This same JSON format is used for distributing tasks in the Mechanic task library.

Exports can be generated from the task editor, or in bulk from the task list. Imports can be loaded into the task editor for a specific task, or as new tasks from the "Import task" area.

Learn more: https://learn.mechanic.dev/core/tasks/import-and-export

### 2.3. Actions

Actions are the actual units of work that are performed as a result of a task run. While tasks define the logic and configuration, actions are what carry out operations and side effects.

Mechanic supports several types of actions:

#### 2.3.1. Cache

The Cache action allows for performing operations on the task's persistent key-value cache storage.

Supported operations include setting values, deleting values, and incrementing/decrementing numeric values.

This can be used for storing task state across runs, tracking counts or limits, or implementing locking/synchronization.

Learn more: https://learn.mechanic.dev/core/actions/cache

#### 2.3.2. Echo

The Echo action simply returns the data it was provided. It performs no actual operation, and is used mainly for testing and debugging.

Learn more: https://learn.mechanic.dev/core/actions/echo

#### 2.3.3. Email

The Email action sends an email. It supports Mechanic's email templates, file attachments, and all standard email options like recipients, subject, body HTML, etc.

Learn more: https://learn.mechanic.dev/core/actions/email

#### 2.3.4. Event

The Event action generates a new event which will be processed by Mechanic as a child of the current event.

This can be used to implement chained sequences of task runs, or to generate events for other tasks to subscribe to.

The event topic and data are configurable. The event can be set to run immediately, or scheduled for a future time.

Learn more: https://learn.mechanic.dev/core/actions/event

#### 2.3.5. Files

The Files action generates files and provides temporary URLs to access them. It supports generating files from a variety of sources:

##### 2.3.5.1. Base64

Decodes a base64-encoded string into a file.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/base64

##### 2.3.5.2. PDF

Generates a PDF file from an HTML template, using a full browser rendering engine.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/pdf

###### 2.3.5.2.1. Migrating to Pdfcrowd

Mechanic recently switched PDF rendering engines from wkhtmltopdf to Pdfcrowd. Tasks on older Mechanic accounts may need to be migrated.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/pdf/migrating-to-pdfcrowd

##### 2.3.5.3. Plaintext 

Generates a plaintext file from a string.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/plaintext

##### 2.3.5.4. URL

Downloads a file from a URL.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/url

##### 2.3.5.5. ZIP

Generates a ZIP archive containing other generated files.

Learn more: https://learn.mechanic.dev/core/actions/file-generators/zip

Learn more about the Files action: https://learn.mechanic.dev/core/actions/files

#### 2.3.6. FTP

The FTP action uploads or downloads files via FTP, FTPS, or SFTP.

For uploads, it supports using file generators to create the files to upload. For downloads, it makes the downloaded content available in the resulting event data.

Learn more: https://learn.mechanic.dev/core/actions/ftp

#### 2.3.7. HTTP

The HTTP action performs an HTTP request. It supports all standard HTTP methods, headers, bodies, and other options.

This is used for making API calls to external services, or for interacting with any web-accessible resource.

Learn more: https://learn.mechanic.dev/core/actions/http

#### 2.3.8. Shopify

The Shopify action performs operations against the Shopify API. It supports both the REST and GraphQL APIs.

This is the primary way for tasks to query or modify Shopify data and resources.

Learn more: https://learn.mechanic.dev/core/actions/shopify

### 2.4. Runs

Mechanic processes all work - events, tasks, and actions - using a system of runs and queues.

Each individual unit of work, when performed, is called a run. There are event runs, task runs, and action runs.

Runs are queued and performed asynchronously. They will eventually execute, but may be delayed if there is a backlog of pending work.

Mechanic has configurable concurrency limits which define how many runs may be performed simultaneously for a given account.

Learn more: https://learn.mechanic.dev/core/runs

#### 2.4.1. Concurrency

Mechanic processes runs concurrently to maximize throughput, but has limits on how many runs may be processed simultaneously for an account.

If the concurrency limit is reached, additional runs will be queued until capacity is available.

Concurrency is limited by:
- A total cap on simultaneous runs across an account
- The Shopify API rate limits

Tasks can optimize for concurrency by minimizing API usage, using bulk operations when possible, and avoiding long-running operations.

Learn more: https://learn.mechanic.dev/core/runs/concurrency

#### 2.4.2. Ordering

By default, Mechanic does not guarantee the order in which runs created at the same time will be executed. Runs are processed based on their place in the queue and the available concurrency.

For tasks, ordering can be influenced by:
- Using delayed subscriptions to stagger task runs
- Enabling the "Perform action runs in sequence" setting to enforce ordering of a task's actions
- Using events and parent/child relationships to create explicit chains of dependent runs

Learn more: https://learn.mechanic.dev/core/runs/ordering

#### 2.4.3. Retries

When a run fails due to certain recoverable errors, Mechanic will automatically retry the run.

Runs will be retried up to 4 times, with an exponential backoff delay between attempts.

Not all failures are retryable - runs that fail due to an explicit error in task code or an unrecoverable API error will not be retried.

Tasks should be written to be idempotent and safe to retry. Avoid side effects that could compound or conflict when a run is performed multiple times.

Learn more: https://learn.mechanic.dev/core/runs/retries

#### 2.4.4. Scheduling

Runs can be scheduled to occur in the future rather than executing immediately.

Scheduled event runs can be created using the Event action with a future run_at time. The resulting task runs will be based on the task code and configuration at the time the event runs.

Task runs can be scheduled using subscription offsets, which delay a task's response to an event by a set duration.

Scheduled runs will always use the latest task code and configuration. If a task is modified before a scheduled run executes, the run will use the updated version.

Learn more: https://learn.mechanic.dev/core/runs/scheduling

## 3. Interacting with Shopify

One of Mechanic's primary functions is to interact with Shopify data and resources on behalf of tasks. This section covers the key ways that tasks can integrate with Shopify.

### 3.1. Responding to events

The main way tasks are triggered is by subscribing to Shopify event topics. Shopify sends webhooks to Mechanic whenever key events occur, like the creation of an order or an update to a product.

Tasks can subscribe to any of these event topics to run in response to specific Shopify events. The event data from the webhook will be made available to the task code.

Learn more: https://learn.mechanic.dev/core/shopify/events

#### 3.1.1. Reconciling missing events  

In rare cases, Shopify may fail to deliver a webhook event. This can lead to tasks not running when expected.

To handle this, important tasks should implement a reconciliation process in addition to subscribing to real-time events. This involves periodically scanning Shopify data for records that were not processed, as a fallback.

For example, a task that normally runs on order creation could have a separate scheduled process that looks for recent orders that do not have the expected tags or metafields that the main task would have set.

Learn more: https://learn.mechanic.dev/core/shopify/events/reconciling-missing-events

### 3.2. Reading data

Tasks can read Shopify data in several ways:

#### 3.2.1. Liquid objects

Mechanic provides a set of global Liquid objects that represent Shopify resources, like {{ shop }}, {{ customer }}, {{ order }}, etc. 

These objects have attributes and relationships that mirror the Shopify REST API, and can be used to access data about the current store and related resources.

Learn more: https://learn.mechanic.dev/core/shopify/read/liquid-objects

#### 3.2.2. GraphQL in Liquid

Tasks can execute GraphQL queries against the Shopify API using the shopify Liquid filter.

This allows for precise and efficient fetching of Shopify data, taking advantage of the power of GraphQL.

Example:
```
{% capture query %}
  query {
    shop {
      name
    }
  }
{% endcapture %}

{% assign result = query | shopify %}

{{ result.data.shop.name }}
```

Learn more: https://learn.mechanic.dev/core/shopify/read/graphql-in-liquid

#### 3.2.3. Bulk operations

For querying large volumes of data, Mechanic supports Shopify's bulk operations GraphQL API.

This allows a task to submit a query to be run asynchronously by Shopify, and receive the results in a subsequent event when the query is completed.

This avoids the performance and rate limit issues of trying to fetch large datasets in a single task run.

Learn more: https://learn.mechanic.dev/core/shopify/read/bulk-operations

#### 3.2.4. The Shopify action

As a fallback, the Shopify action can be used to make raw REST or GraphQL requests to any Shopify API endpoint.

This can be useful for APIs that are not well supported by Liquid objects or for very custom queries.

The tradeoff is that using the action directly is more verbose and returns raw API responses that may need more processing in Liquid.

Learn more: https://learn.mechanic.dev/core/shopify/read/the-shopify-action

### 3.3. Writing data

All writing of Shopify data should be done through the Shopify action. This supports making requests to both the REST and GraphQL APIs for creating, updating, and deleting Shopify resources.

Example of creating a product with the REST API:
```
{% action "shopify" %}
  [
    "post",
    "/admin/api/2021-07/products.json",
    {
      "product": {
        "title": "New product"
      }
    }
  ]
{% endaction %}
```

Example of updating an order with the GraphQL API:
```
{% action "shopify" %}
  mutation {
    orderUpdate(id: "gid://shopify/Order/1234567890", input: {
      email: "updated@example.com"
    }) {
      order {
        id
      }
    }
  }
{% endaction %}
```

Learn more: https://learn.mechanic.dev/core/shopify/write

### 3.4. Shopify admin action links

Mechanic allows for the creation of "action links" in the Shopify admin that can trigger specific tasks with a particular resource.

For example, an "Export order" link on an order details page could trigger a task to generate a custom export file for that order.

These links use Mechanic's "run link" URLs with resource IDs to create eventsthat trigger associated tasks.

Tasks can support these links by subscribing to the relevant mechanic/user/ events, like mechanic/user/order for individual orders or mechanic/user/orders for bulk actions on order selections.

Learn more: https://learn.mechanic.dev/core/shopify/admin-action-links

### 3.5. API rate limit

Shopify imposes rate limits on API usage to protect their infrastructure. Mechanic is subject to these rate limits and has strategies for working within them.

If a task hits a rate limit while making Shopify API requests, Mechanic will automatically pause and retry the requests once the limit has cooled down.

However, tasks should still try to minimize their API usage by:
- Using GraphQL instead of REST when possible
- Fetching only the data needed
- Using bulk operations for large data sets
- Caching data when appropriate

Mechanic also has a configurable concurrency limit to prevent too many simultaneous task runs from hitting the API at once.

Learn more: https://learn.mechanic.dev/core/shopify/api-rate-limit

### 3.6. API versions

Shopify releases a new API version each quarter, and deprecates the oldest supported version. Mechanic allows each task to specify which API version it uses.

By default, new tasks use the latest stable API version. This can be changed in the task's advanced settings.

When a task's API version is nearing end of life, Mechanic will display a warning and provide tools to help upgrade the task to a newer version.

It's a good practice to periodically review and upgrade a task's API version to take advantage of new features and avoid compatibility issues.

Learn more: https://learn.mechanic.dev/core/shopify/api-versions

## 4. Platform

This section covers key features and concepts of the Mechanic platform that support the creation and operation of tasks.

### 4.1. Cache

Each Mechanic account has a simple key-value cache that tasks can use for storing small amounts of persistent data.

The cache is appropriate for:
- Storing task state or progress between runs
- Caching Shopify API responses to reduce repeated requests
- Implementing counters, flags, or locks

Cache data is set using the Cache action, and can be read using the global {{ cache }} object in Liquid.

Cache keys must be strings matching /[a-z0-9_:.-\/]+/i. Values can be any JSON-serializable data up to 256KB in size. Each value expires after a maximum of 60 days.

Learn more: https://learn.mechanic.dev/platform/cache

#### 4.1.1. Cache endpoints

In addition to being used in tasks, cache data can be exposed via special "cache endpoints".

A cache endpoint is a unique URL that returns the JSON value of a specific cache key when requested. This allows external systems to retrieve data from Mechanic's cache.

Cache endpoints are configured in the Mechanic account settings. Each endpoint specifies a cache key, and Mechanic provides a URL that can be used to fetch that key's value.

This can be used for:
- Exposing task results or exported data to other systems
- Implementing webhooks for external services to retrieve data from Mechanic
- Allowing a task to provide data to custom storefront JavaScript

Learn more: https://learn.mechanic.dev/platform/cache/endpoints

### 4.2. Email

Mechanic can send email on behalf of tasks, using the Email action.

#### 4.2.1. Receiving email

Mechanic can also receive email. Each Mechanic account is assigned a unique email address based on the connected Shopify store's domain.

Any email sent to this address will generate a mechanic/emails/received event that tasks can subscribe to. The event data will contain the parsed email headers, body text, attachments, etc.

This allows for:
- Receiving data exports from external systems
- Processing incoming support requests or feedback
- Triggering tasks based on email commands

Learn more: https://learn.mechanic.dev/platform/email/receiving-email

#### 4.2.2. Custom email domain

By default, Mechanic sends email using a subdomain of mechanic.dev based on the store's Shopify domain.

Stores can configure Mechanic to use their own email domain instead. This requires adding DNS records to prove ownership of the domain and configure SPF/DKIM.

Using a custom domain can improve deliverability and branding of Mechanic emails.

Learn more: https://learn.mechanic.dev/platform/email/custom-email-domain

#### 4.2.3. DMARC

DMARC is an email authentication protocol that helps prevent spoofing. When using a custom email domain, proper DMARC configuration is important for ensuring Mechanic's emails are delivered.

Mechanic provides tools and documentation for setting up DMARC for custom email domains.

Learn more: https://learn.mechanic.dev/platform/email/dmarc

#### 4.2.4. Email templates

Reusable email templates can be created in the Mechanic account settings. Templates are authored using Liquid and can reference the data provided by the Email action.

Using templates helps keep email content consistent across tasks, and allows for updating content in one place.

Tasks can specify which template to use with the template option of the Email action.

Learn more: https://learn.mechanic.dev/platform/email/templates

### 4.3. Error handling

Mechanic generates error events when something goes wrong while processing an event, task, or action. Tasks can subscribe to these error events to implement custom error handling and alerting.

There are three error event topics:

- mechanic/errors/event: Occurs when an event fails, such as due to an event filter
- mechanic/errors/task: Occurs when a task run fails, such as due to a Liquid syntax error or an intentional error object
- mechanic/errors/action: Occurs when an individual action fails, such as due to an API error or an email delivery failure

Tasks can subscribe to these topics to be notified of errors. The event data will include details about the error and the original event/task/action that encountered it.

This allows for:
- Sending alerts to a Slack channel or email when critical errors occur
- Logging errors to an external monitoring system
- Implementing custom retry or fallback logic for failed actions

By default, a task that subscribes to an error topic will only receive errors related to itself. To receive all errors across the account, the task must only subscribe to error topics and no others.

Learn more: https://learn.mechanic.dev/platform/error-handling

### 4.4. Events

As covered in the core concepts section, events are the fundamental triggers for all Mechanic task runs. This section goes into more detail on the Mechanic platform's event handling.

#### 4.4.1. Event topics

Event topics are strings that identify the type and source of an event, in the format domain/subject/verb.

Mechanic has a number of built-in event topics for things like:
- Shopify resource changes (orders/create, products/update, etc) 
- Scheduled events (mechanic/scheduler/daily, mechanic/scheduler/hourly, etc)
- Mechanic actions (mechanic/actions/perform)
- User-initiated task runs (mechanic/user/trigger, mechanic/user/text)

Tasks subscribe to the topics they care about, and receive events matching those topics.

The user domain is available for custom events generated by tasks or external systems.

A full list of supported event topics is available at https://learn.mechanic.dev/platform/events/topics

#### 4.4.2. Event filters

Event filters allow for selectively ignoring events before they're processed by tasks. They are Liquid templates, configured in the Mechanic account settings, that are rendered against incoming events.

If the template renders false, the event is discarded and no task runs will be generated for it.

Filters can be used for:
- Ignoring noisy or irrelevant events
- Blocking events during maintenance or bulk updates
- Implementing custom event routing logic

For example, a filter like this would ignore all product update events for a specific product ID:

```
{% if event.topic == "shopify/products/update" and event.data.id == 1234567890 %}
  false
{% endif %}
```

Learn more: https://learn.mechanic.dev/platform/events/filters

### 4.5. GraphQL

Mechanic has deep support for Shopify's GraphQL Admin API. Tasks can use GraphQL to query and mutate Shopify data in a flexible and efficient way.

GraphQL is Shopify's preferred API for most types of data access. The REST API is still supported for certain resources and actions, but GraphQL is recommended when possible.

Learn more: https://learn.mechanic.dev/platform/graphql

#### 4.5.1. Basics

GraphQL is a query language and runtime for fetching and modifying data. Unlike a REST API which has fixed endpoints and response structures, GraphQL allows the client to specify exactly what data it needs and in what format.

Key GraphQL concepts:

##### 4.5.1.1. Shopify Admin API GraphiQL explorer

Shopify provides a GraphiQL app that allows for interactively exploring and testing the GraphQL Admin API.

This is a great resource for learning the available queries and mutations, seeing what data is available on each resource type, and prototyping GraphQL operations for a task.

The explorer is available at https://shopify.dev/tools/graphiql-admin-api

##### 4.5.1.2. Queries

Queries are used to fetch data in GraphQL. The query specifies the fields to retrieve, and can traverse relationships between objects.

Example query to fetch a product's title and first 3 variants:
```graphql
query {
  product(id: "gid://shopify/Product/1234567890") {
    title
    variants(first: 3) {
      edges {
        node {
          id
          title
        }
      }
    }
  }
}
```

Learn more: https://learn.mechanic.dev/platform/graphql/basics/queries

##### 4.5.1.3. Mutations

Mutations are used to create, update, or delete data in GraphQL. A mutation specifies the operation to perform and the data to change.

Example mutation to create a new customer:
```graphql
mutation {
  customerCreate(input: {
    firstName: "John"
    lastName: "Doe"
    email: "john.doe@example.com"
  }) {
    customer {
      id
    }
    userErrors {
      field
      message
    }
  }
}
```

Learn more: https://learn.mechanic.dev/platform/graphql/basics/mutations

##### 4.5.1.4. Pagination

Shopify uses cursor-based pagination for lists of data in GraphQL. Queries that return multiple results accept parameters like first and after to specify how many results to return and where to start.

The query response includes a pageInfo object with properties like hasNextPage and endCursor that can be used to fetch additional pages of results.

Example of a paginated query:
```graphql
query {
  orders(first: 10, after: "MQ") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
      }
    }
  }
}
```

Learn more: https://learn.mechanic.dev/platform/graphql/basics/pagination

#### 4.5.2. Bulk operations

For queries that return large amounts of data, Shopify provides an asynchronous bulk operations API.

With bulk operations, the query is submitted to Shopify for processing in the background. When the query is complete, Shopify sends a webhook back to Mechanic with the results.

Mechanic makes it easy to use bulk operations in tasks:
1. Use the Shopify action to submit a bulkOperationRunQuery mutation with your GraphQL query
2. Subscribe to the mechanic/shopify/bulk_operation topic
3. Access the query results from the bulkOperation object in the resulting event

This allows tasks to efficiently fetch large datasets without hitting API rate limits or timeouts.

Learn more: https://learn.mechanic.dev/platform/graphql/bulk-operations

### 4.6. Integrations

Mechanic has first-class integrations with several external services and Shopify apps. These integrations allow for a seamless flow of data and actions between systems.

#### 4.6.1. Appstle Subscriptions

Appstle Subscriptions is an app for managing customer subscriptions and recurring orders. Mechanic can receive events from Appstle for subscription lifecycle changes like creations, activations, cancellations, etc.

This allows tasks to react to subscription events, sync subscription data to other systems, generate custom communications, and more.

Learn more: https://learn.mechanic.dev/platform/integrations/appstle-subscriptions

#### 4.6.2. Judge.me

Judge.me is a popular Shopify app for collecting and displaying product reviews. With the Mechanic integration, Judge.me can send events to Mechanic whenever reviews are created or updated.

This allows for automating review moderation, syncing review data to marketing or support platforms, analyzing review sentiment, etc.

Learn more: https://learn.mechanic.dev/platform/integrations/judge.me

#### 4.6.3. Locksmith

Locksmith is an access control app by Lightward (makers of Mechanic) for restricting access to Shopify resources. When Locksmith grants access to a resource, it sends a locksmith/access_granted event to Mechanic.

This can trigger tasks to perform actions when access conditions are met, like generating license keys, provisioning accounts in third-party systems, sending onboarding emails, etc.

Learn more: https://learn.mechanic.dev/platform/integrations/locksmith

#### 4.6.4. Report Toaster

Report Toaster is an advanced reporting and analytics app for Shopify. It integrates with Mechanic in two directions:

Mechanic to Report Toaster: The Report Toaster action can request reports from Report Toaster and optionally update data in Report Toaster.

Report Toaster to Mechanic: Report Toaster sends events to Mechanic when a requested report is completed (report_toaster/reports/created) or encounters an error (report_toaster/reports/failed).

This allows Mechanic tasks to incorporate Report Toaster's extensive reporting capabilities and keep Report Toaster data in sync with other systems.

Learn more: https://learn.mechanic.dev/platform/integrations/report-toaster

#### 4.6.5. Shopify Flow

Shopify Flow is an ecommerce automation platform available to Shopify Plus stores. Mechanic offers a two-way integration with Flow:

Mechanic to Flow: The Flow action can send data to Flow as a trigger for a Flow workflow. Triggers can be associated with a specific resource (customer, order, product) or be generic.

Flow to Mechanic: The Mechanic connector in Flow can send events to Mechanic with a custom topic and data payload.

This allows Mechanic tasks to hand off work to Flow where appropriate, or to react to Flow workflow events.

Learn more: https://learn.mechanic.dev/platform/integrations/shopify-flow

#### 4.6.6. Run links

Run links are URLs that can trigger a specific Mechanic task to run with a particular configuration. They're a lightweight way to integrate Mechanic with other systems.

For example, a "Refund order" button in a third-party support tool could use a run link to trigger a Mechanic task to process a refund in Shopify.

Run links can be constructed manually using the appropriate task ID and options, or generated using Shopify admin action links.

Learn more: https://learn.mechanic.dev/platform/integrations/run-links

### 4.7. Liquid

Liquid is the templating language used to define the logic and output of Mechanic tasks. It's the same language used extensively by Shopify itself for theme development and other customization.

Mechanic uses a specialized version of Liquid with a number of extensions and additions specific to the Mechanic environment and use cases.

Learn more: https://learn.mechanic.dev/platform/liquid

#### 4.7.1. Basics

At its core, Liquid allows for interspersing static content with dynamic placeholders and logic. Placeholders are delimited by double curly braces {{ }}, and logic is delimited by curly brace percent sign pairs {% %}.

Key basic Liquid concepts used in Mechanic:

##### 4.7.1.1. Syntax

The basic Liquid syntax consists of:
- Output: {{ variable }} or {{ value | filter }}
- Logic: {% if condition %} / {% endif %}, {% for item in collection %} / {% endfor %}, etc.
- Objects: {{ collection.property }}, {{ object["property"] }}
- Variables: {% assign var = value %}
- Filters: {{ value | upcase }##### 4.7.1.2. Variables

Variables are used to store and reference values in Liquid. They're assigned using the {% assign %} tag:

```
{% assign foo = "bar" %}
{{ foo }}
```

Variables can hold strings, numbers, booleans, nil, arrays, or objects. Mechanic's assign tag also supports assigning into arrays and hashes.

Learn more: https://learn.mechanic.dev/platform/liquid/basics/variables

##### 4.7.1.3. Data types

Liquid supports a variety of data types:
- String: "hello"
- Integer: 42
- Float: 3.14
- Boolean: true, false
- Nil: nil
- Array: [1, 2, 3] or split from string {{ "foo,bar" | split: "," }} 
- Object/Hash: { "key": "value" } or {% assign obj = hash %} / {% assign obj["key"] = "value" %}

Mechanic's Liquid also supports creating arrays and hashes using literal syntax: array and hash

Learn more: https://learn.mechanic.dev/platform/liquid/basics/types

##### 4.7.1.4. Operators

Liquid supports the following operators for comparison and logic:
- == equals
- != does not equal
- \&gt; greater than
- \&lt; less than
- \&gt;= greater than or equal to
- \&lt;= less than or equal to
- or logical or
- and logical and
- contains checks for substring or array inclusion

Learn more: https://learn.mechanic.dev/platform/liquid/basics/operators

##### 4.7.1.5. Control flow

Control flow tags are used to conditionally execute code or iterate over collections.

###### 4.7.1.5.1. Condition

The if / elsif / else / endif tags allow for conditional execution:

```
{% if order.total_price &gt; 100 %}
  High value order
{% elsif order.total_price &gt; 50 %}
  Medium value order
{% else %} 
  Low value order
{% endif %}
```

The unless tag is the inverse of if, executing if the condition is false.

The case / when tag allows for switching based on a value:

```
{% case shipping_method %}
  {% when "expedited" %}
    Ship it fast!
  {% when "standard" %}
    Ship it normally.
  {% else %}
    Invalid shipping method!
{% endcase %}
```

Learn more: https://learn.mechanic.dev/platform/liquid/basics/control-flow/condition

###### 4.7.1.5.2. Iteration

The for tag is used to iterate over arrays or hashes:

```
{% for product in order.line_items %}
  {{ product.title }}
{% else %}
  No products in order
{% endfor %}
```

The else block is executed if the collection is empty.

Within a for loop, the forloop variable contains properties of the current iteration like index, first, last, etc.

The break and continue tags can be used to exit or skip an iteration.

Learn more: https://learn.mechanic.dev/platform/liquid/basics/control-flow/iteration

##### 4.7.1.6. Filters

Filters are used to transform output values. They're applied using a pipe | character:

```
{{ "hello" | upcase }}
{{ order.total_price | money }}
```

Filters can be chained to perform multiple transformations:

```
{{ "  too many spaces  " | trim | capitalize }}
```

Mechanic provides a large library of filters for manipulating strings, numbers, arrays, hashes, and more.

Learn more: https://learn.mechanic.dev/platform/liquid/basics/filters

##### 4.7.1.7. Whitespace

By default, whitespace outside of Liquid tags is preserved in the rendered output. This can lead to undesired whitespace when using multi-line Liquid tags.

Whitespace can be trimmed by adding a hyphen - to the opening or closing delimiter:

```
{{- "no space before" }}
{{ "no space after" -}}
{%- assign x = y -%}
```

Learn more: https://learn.mechanic.dev/platform/liquid/basics/whitespace

##### 4.7.1.8. Comments

Liquid supports comments that are not rendered in the output:

```
{% comment %}
  This is a comment.
  It can span multiple lines.
{% endcomment %}

{# This is a single line comment #}
```

Comments can also be used to temporarily disable Liquid code without removing it.

Learn more: https://learn.mechanic.dev/platform/liquid/basics/comments

#### 4.7.2. Mechanic filters

In addition to the standard Liquid filters, Mechanic provides a library of additional filters tailored to common task requirements. Some highlights:

- Parsing: parse_json, parse_jsonl, parse_csv, parse_xml
- Encoding: base64_encode, base64_url_safe_encode, hmac_sha256, html_escape
- Data manipulation: to_json, to_jsonl, to_csv, to_qrcode
- Array manipulation: first, last, join, map, reverse, size, sort, uniq
- Hash manipulation: dig, except, keys, values
- Math: abs, ceil, divided_by, floor, minus, plus, round, times
- Money: money, money_with_currency
- Time: date, parse_date, parse_duration
- Regular expressions: match, replace, scan
- And many more

The full list of Mechanic filters is available at: https://learn.mechanic.dev/platform/liquid/filters

##### 4.7.2.1. Deprecated filters

Some Mechanic filters have been deprecated in favor of newer alternatives. These are still available for backwards compatibility but are not recommended for new usage.

Deprecated filters include:
- add_tag, remove_tag (replaced by direct array manipulation)
- md5, sha1, sha512, hmac_sha1, hmac_sha512 (replaced by digest filters)
- link_to (replaced by explicit anchor tag generation)
- money_format (replaced by money filter)
- placeholder_svg_uri (replaced by placeholder_svg_data_uri)
- img_tag (replaced by explicit img tag generation)
- font_face (replaced by @font-face CSS)
- asset_url (behavior dependent on theme context)

Learn more: https://learn.mechanic.dev/platform/liquid/filters/deprecated

#### 4.7.3. Shopify Liquid filters

Mechanic supports a subset of Liquid filters provided by Shopify. These largely mirror the filters available in Online Store themes.

Supported Shopify filters include:
- String filters like append, capitalize, escape, newline_to_br, slice, split
- Array filters like join, first, last, map, sort, uniq
- Math filters like ceil, floor, divided_by, minus, plus, round, times
- Money filters like money, money_with_currency
- URL filters like img_url, asset_url, link_to, url_escape, url_param_escape
- Translation filters like t, translate
- Date filters like date
- And more

The full list of supported Shopify filters is available at: https://learn.mechanic.dev/platform/liquid/filters/shopify

#### 4.7.4. Keyword literals

Mechanic's Liquid extends the language with keyword literals for easily creating arrays and hashes.

##### 4.7.4.1. array

The array keyword creates an empty array that can be added to:

```
{% assign foo = array %}
{% assign foo[0] = "bar" %}
{% assign foo[1] = "baz" %}
```

This is equivalent to:

```
{% assign foo = "" | split: "/" %}
{% assign foo[0] = "bar" %}
{% assign foo[1] = "baz" %}
```

Learn more: https://learn.mechanic.dev/platform/liquid/keyword-literals/array

##### 4.7.4.2. hash

The hash keyword creates an empty hash that can be added to:

```
{% assign foo = hash %}
{% assign foo["bar"] = "baz" %}
{% assign foo.qux = 42 %}
```

This is equivalent to:

```
{% assign foo = {} %}
{% assign foo["bar"] = "baz" %}
{% assign foo.qux = 42 %}
```

Learn more: https://learn.mechanic.dev/platform/liquid/keyword-literals/hash

##### 4.7.4.3. newline

The newline keyword represents a newline character (\n). It's useful for manipulating multiline strings:

```
{% assign text = "Hello
world" %}
{% assign lines = text | split: newline %}
```

Some filters like newline_to_br and replace have special handling for newline.

Learn more: https://learn.mechanic.dev/platform/liquid/keyword-literals/newline

#### 4.7.5. Objects

Mechanic provides a set of global Liquid objects that contain data relevant to the current task run.

##### 4.7.5.1. Action object

The action object is available in tasks subscribed to mechanic/actions/perform. It contains data about the action that was just performed.

Useful properties:
- action.type - the type of action, e.g. "shopify" or "email"
- action.options - the options the action was performed with
- action.run.result - the result data returned by the action
- action.run.error - the error message if the action failed

Learn more: https://learn.mechanic.dev/platform/liquid/objects/action

##### 4.7.5.2. Cache object

The cache object allows reading data from the task's persistent cache storage.

```
{% assign foo = cache.foo %}
{% if cache.bar %}
  The "bar" key exists in the cache
{% endif %}
```

Cache data can be written using the Cache action.

Learn more: https://learn.mechanic.dev/platform/liquid/objects/cache

##### 4.7.5.3. Event object

The event object contains data about the current event being processed.

Useful properties:
- event.topic - the topic name e.g. "shopify/orders/create"
- event.data - the payload data for the event
- event.created_at - the timestamp when the event was generated
- event.preview - indicates if this is a preview event (not set for normal events)

Learn more: https://learn.mechanic.dev/platform/liquid/objects/event

##### 4.7.5.4. Options object

The options object contains the user-configured options for the current task.

```
{{ options.email_recipient }}
{% if options.send_sms %}
  {% action "sms" %}
    {
      "to": {{ options.phone_number }},
      "body": "Your order {{ order.name }} has shipped!"
    }
  {% endaction %}
{% endif %}
```

Option values are parsed as Liquid, so they can contain dynamic content.

Learn more: https://learn.mechanic.dev/platform/liquid/objects/options

##### 4.7.5.5. Shopify REST Admin API objects

Mechanic provides Liquid objects for most of the resources available in the Shopify REST Admin API. These allow easy access to related data.

For example, in a task responding to an order event, the following objects would be available:
- {{ shop }} - the current shop
- {{ order }} - the order from the event
- {{ order.line_items }} - array of the order's line items 
- {{ order.customer }} - the order's customer
- {{ order.shipping_address }} - the order's shipping address
- And so on

The exact set of available objects depends on the event topic and the data it provides.

The objects' properties mirror the structure of the REST API responses, but using snake_case instead of camelCase for names.

Learn more: https://learn.mechanic.dev/platform/liquid/objects/shopify

##### 4.7.5.6. Task object

The task object contains data about the current task.

Useful properties:
- task.id - the task's ID
- task.subscriptions - array of the task's topic subscriptions

Learn more: https://learn.mechanic.dev/platform/liquid/objects/task

#### 4.7.6. Tags

Mechanic's Liquid provides several custom tags to make task development easier.

##### 4.7.6.1. liquid

The liquid tag allows executing Liquid code without needing the usual {% %} delimiters. This is useful for "escaping" from another language context back into Liquid:

```
mutation {
  {% liquid
    for product in shop.products 
      echo '"'
      echo product.admin_graphql_api_id
      echo '",'
    endfor
  %}
}
```

Learn more: https://learn.mechanic.dev/platform/liquid/tags/liquid

##### 4.7.6.2. action

The action tag generates an action object. It has several syntax variations:

Block with explicit type:
```
{% action "email" %}
  {
    "to": "customer@example.com",
    "subject": "Order confirmed!",
    "body": "Thanks for your order!"
  }
{% endaction %}
```

Inline with type and options hash:
```
{% action "shopify", mutation_type: "tagsAdd", id: order.admin_graphql_api_id, tags: ["VIP"] %}
```

Inline with type and options array:
```
{% action "slack", "chat.postMessage", channel: "#orders", text: "New order received!" %}
```

Learn more: https://learn.mechanic.dev/platform/liquid/tags/action

##### 4.7.6.3. assign

Mechanic extends the assign tag to allow assigning values within arrays and hashes:

```
{% assign foo = array %}
{% assign foo[0] = "bar" %}

{% assign baz = hash %}
{% assign baz["qux"] = 42 %}
```

This is in addition to the standard variable assignment syntax:

```
{% assign x = "foo" %}
```

Learn more: https://learn.mechanic.dev/platform/liquid/tags/assign

##### 4.7.6.4. error

The error tag immediately halts task execution and marks the run as failed with the given error message:

```
{% if order.total_price &lt;= 0 %}
  {% error "Invalid order total" %}
{% endif %}
```

This can be used for validation or to handle exceptional cases.

Learn more: https://learn.mechanic.dev/platform/liquid/tags/error

##### 4.7.6.5. log

The log tag generates a log object that's included in the task run results. This is useful for debugging and auditing.

```
{% log message: "Processing order", order_id: order.id, customer_email: order.email %}
```

The log data can be any set of key-value pairs.

Learn more: https://learn.mechanic.dev/platform/liquid/tags/log

#### 4.7.7. Liquid console

The Mechanic web app includes a Liquid console for testing Liquid code snippets in the context of the current store.

The console can be accessed from the footer of any page in the app. It provides a text area for entering Liquid code, and a "Run" button to execute it.

The console output shows the rendered result of the Liquid code, as well as the Liquid context used (variables, objects, etc).

This is a great way to quickly test Liquid snippets, inspect Shopify data, and debug issues without needing to create a full task.

Some notes on the Liquid console:
- It does not have access to the Mechanic cache or email templates
- It cannot perform Shopify API calls (but can access Shopify data via Liquid objects)
- It does not persist any state between runs
- It is not suitable for testing Mechanic-specific tags like {% action %} or {% error %}

Learn more: https://learn.mechanic.dev/platform/liquid/console

### 4.8. Policies

Mechanic has several key policies that govern the usage and operation of the platform.

#### 4.8.1. Data

The data policy covers how Mechanic stores and retains merchant data. Key points:

- All data is stored in encrypted databases
- Event data (including Shopify payloads) is retained for 15 days after an event is "complete" (all related runs have finished)
- Mechanic does not proactively store Shopify resource data, but tasks may store data as part of their operation
- Mechanic keeps rolling 7-day backups of its datastores

Learn more: https://learn.mechanic.dev/platform/policies/data

#### 4.8.2. Plans

Mechanic does not have usage-based pricing tiers or feature-limited plans. All accounts have access to the same set of core platform features.

The only differentiation is that development stores (those that will never see real customer traffic) can request an extended free trial period.

Learn more: https://learn.mechanic.dev/platform/policies/plans

#### 4.8.3. Pricing

Mechanic has an open "pay what feels good" pricing model. When an account's trial period ends, Mechanic suggests a price based on the connected Shopify plan, but merchants are encouraged to pay what feels right for their business.

The price is discussed and finalized in consultation with the Mechanic team to ensure it's sustainable for both the merchant and the platform.

Learn more: https://learn.mechanic.dev/platform/policies/pricing

#### 4.8.4. Privacy

Mechanic's privacy policy covers what merchant data is collected, how it's used, and merchant's rights under privacy laws like GDPR.

Notably, Mechanic only collects personal information necessary for operating the service and providing customer support. Mechanic does not sell or otherwise share merchant data.

Learn more: https://learn.mechanic.dev/platform/policies/privacy

### 4.9. Shopify

This section covers Mechanic-specific Shopify platform features and configuration.

#### 4.9.1. Custom authentication

For Shopify Plus stores using a custom app for Mechanic, the app's access token can be provided to Mechanic for use in Shopify API calls.

This allows Mechanic to operate with the potentially higher API limits and additional permissions granted to the custom app.

The custom token is configured in the Mechanic account settings. It will be used for all user-configured Shopify API operations where possible.

Learn more: https://learn.mechanic.dev/platform/shopify/custom-authentication

#### 4.9.2. "Read all orders"

By default, Mechanic only requests access to orders for the past 60 days when the Orders permission is granted. Stores can opt-in to grant access to the full order history by enabling the "Read all orders" setting.

This setting is available in the Mechanic account settings. It requires re-authorizing the Mechanic app with the additional orders permission.

Once enabled, Mechanic will have access to all past orders rather than just the last 60 days.

Learn more: https://learn.mechanic.dev/platform/shopify/read-all-orders

### 4.10. Webhooks

In addition to responding to Shopify's webhooks, Mechanic can receive webhooks directly. This allows any external system to trigger task runs by sending HTTP requests to Mechanic.

Mechanic webhooks are:
- Configured in the Mechanic account settings
- Secured by a secret URL unique to each webhook
- Triggered by HTTP POST requests to the webhook URL
- Mapped to a user-defined event topic
- Processed into an event with a payload containing the request data

Webhook events can be subscribed to and handled just like any other event in Mechanic tasks.

Webhooks are a great way to integrate Mechanic with systems that can send outbound HTTP requests, like Zapier, IFTTT, Integromat, and many others.

Learn more: https://learn.mechanic.dev/platform/webhooks

## 5. Resources

### 5.1. Slack community

Mechanic has an active community Slack workspace where users can ask questions, share knowledge, and get support from the Mechanic team and other experienced users.

The Slack is a great place to:
- Get help with task development
- Troubleshoot issues
- Share task ideas and examples
- Provide product feedback
- Connect with other Mechanic developers

Joining the Slack requires creating an account at https://slack.mechanic.dev.

Learn more: https://learn.mechanic.dev/resources/slack

### 5.2. Task library

The Mechanic task library is a collection of open source, community-contributed tasks that can be freely used and adapted.

The library aims to provide a starting point for common automation use cases, as well as to inspire new ways of using the Mechanic platform.

Tasks in the library are:
- Stored in a public GitHub repository
- Documented with their purpose, configuration, and behavior
- Searchable by name, description, and code content
- Maintained by the Mechanic core team and community contributors
- Licensed under the permissive MIT license allowing modification and reuse

The library is integrated into the Mechanic app, allowing tasks to be installed into an account with a single click.

Learn more: https://learn.mechanic.dev/resources/task-library

#### 5.2.1. Contributing

The task library welcomes contributions of new tasks and improvements to existing ones. The contribution process involves:

1. Forking the task library GitHub repo
2. Adding or modifying task code and docs in the forked repo
3. Submitting a pull request back to the main repo
4. Reviewing and discussing the changes with the maintainers
5. Merging the pull request to publish the changes to the library

Contributing to the library is a great way to share useful automations with the community and to learn from other developers' approaches.

Learn more: https://learn.mechanic.dev/resources/task-library/contributing

#### 5.2.2. Requesting

Have an idea for a task that would be useful to have in the library, but don't have the time or expertise to build it yourself? The task request board is the place to suggest it.

Task requests are reviewed periodically by the Mechanic team and community. Well-specified and broadly useful requests are selected for implementation and contributed to the library.

Learn more: https://learn.mechanic.dev/resources/task-library/requesting

### 5.3. Tutorials

The Mechanic documentation site includes a set of tutorials demonstrating various concepts and techniques for working with the platform.

#### 5.3.1. Video walkthroughs

The video walkthroughs are short screencasts showing the process of building a specific task from scratch. They're a great way to see Mechanic development in action and to learn by example.

Some of the topics covered by video walkthroughs:
- Sending notification emails
- Tagging orders and customers
- Scheduling recurring task runs
- Performing bulk updates

The full list of video walkthroughs is available at: https://learn.mechanic.dev/resources/tutorials/video-walkthroughs

#### 5.3.2. Creating a Mechanic webhook

This tutorial demonstrates the process of creating a Mechanic webhook, triggering it from an external tool, and handling the resulting event in a task.

It covers:
1. Configuring the webhook in the Mechanic account settings
2. Setting up a task to handle the webhook event topic
3. Triggering the webhook using an HTTP request from an external tool
4. Processing the webhook data in the task code

This is a good introduction to using Mechanic's webhook functionality for custom integrations.

Learn more: https://learn.mechanic.dev/resources/tutorials/creating-a-mechanic-webhook

#### 5.3.3. Practicing writing tasks

This multi-part tutorial presents a series of exercises for practicing Mechanic task development. Each exercise builds on the previous one to incrementally build out a complete task.

The exercises cover skills like:
- Subscribing to events and using event data
- Making decisions with Liquid conditionals 
- Calling the Shopify API with actions
- Using task options for configuration
- Writing robust task code with error handling
- Generating useful task previews

Working through the exercises is a great way to get familiar with the core concepts and techniques of Mechanic development.

Learn more: https://learn.mechanic.dev/resources/tutorials/practicing-writing-tasks

#### 5.3.4. Triggering tasks from a contact form

This in-depth tutorial walks through the process of building a custom "contact us" form that triggers a Mechanic task to process the form submission.

The tutorial covers:
- Setting up a Mechanic webhook to receive the form data
- Injecting JavaScript into Shopify storefront pages to modify form behavior
- Sending form data to Mechanic when the form is submitted
- Parsing and processing the form data in a Mechanic task
- Sending an email notification with the submitted data

This demonstrates the power of combining Mechanic's webhook, JavaScript injection, and email capabilities to extend Shopify's functionality.

Learn more: https://learn.mechanic.dev/resources/tutorials/triggering-tasks-from-a-contact-form

#### 5.3.5. Creating scheduled CSV exports

This tutorial shows how to use Mechanic to generate CSV exports of Shopify data on a schedule, and make them available for download from the storefront.

It makes use of:
- The "shopify" filter for fetching data via GraphQL
- The "csv" filter for converting the data to CSV format
- The "files" action for saving the CSV data to a file
- A Mechanic cache endpoint for exposing the file data
- A Shopify online store page for displaying a download link

This is a useful pattern for providing regular data dumps to other systems or for letting merchants download their data for offline analysis.

Learn more: https://learn.mechanic.dev/resources/tutorials/creating-scheduled-csv-feeds

#### 5.3.6. Fetching data from a shared Google sheet

This tutorial demonstrates how to pull data from a Google Sheet into Mechanic using the public CSV export URL that Google provides.

The steps include:
1. Setting up a Google Sheet with the desired data
2. Publishing the sheet to the web as a CSV file
3. Configuring a Mechanic task to fetch the CSV data on a schedule
4. Parsing the CSV data into a usable format in the task code
5. Generating an email alert if the data fetch fails

This can be used to let non-technical users maintain data in a familiar spreadsheet interface and have that data flow into Mechanic for further processing.

Learn more: https://learn.mechanic.dev/resources/tutorials/fetching-data-from-a-shared-google-sheet

## 6. Techniques

This section covers various techniques, patterns, and best practices for accomplishing common tasks in Mechanic.

### 6.1. Debouncing events

In situations where events may be generated at a higher frequency than desired for task processing, debouncing can be used to ignore events that occur too rapidly.

The debounce technique involves:
1. Setting a cooldown time period (e.g. 10 minutes)
2. On each event, storing a timestamp in the cache indicating the last time the event was processed
3. Ignoring events whose timestamp is within the cooldown period of the last processed event

This causes events that occur within the cooldown period to be skipped, effectively limiting the frequency at which they're processed.

Debouncing can be implemented with a combination of event filters and cache actions.

Learn more: https://learn.mechanic.dev/techniques/debouncing-events

### 6.2. Finding a resource ID

Many Mechanic actions and Liquid objects use IDs to uniquely identify Shopify resources like products, orders, customers, etc. This technique shows how to find the ID for a given resource.

In the Shopify admin, navigating to a specific resource's details page will reveal its ID in the URL. For example, the URL for an order might look like:

```
https://example.myshopify.com/admin/orders/1234567890
```

Here, 1234567890 is the order ID.

The same pattern applies for other resources - the ID is the last numeric part of the URL when viewing the resource in the admin.

Learn more: https://learn.mechanic.dev/techniques/finding-a-resource-id

### 6.3. Migrating templates from Shopify to Mechanic

Shopify's email templates can be migrated to Mechanic's email action to allow customization and dynamic data insertion.

The process involves:
1. Copying the raw template code from Shopify
2. Updating the Liquid variable references to use the appropriate Mechanic Liquid objects (e.g. changing {{ name }} to {{ order.name }})
3. Replacing hardcoded URLs and images with dynamic values
4. Converting CSS styles to inline style attributes
5. Configuring a Mechanic email action to use the migrated template code

Some adjustments may be necessary depending on the specifics of the template, but the general structure and content can usually be carried over.

Learn more: https://learn.mechanic.dev/techniques/migrating-templates-from-shopify-to-mechanic

### 6.4. Monitoring Mechanic

For stores relying on Mechanic for critical business processes, setting up monitoring is important for identifying and resolving any issues that arise.

Some key things to monitor:
- The Mechanic task run queue, to detect backlogs or delays
- Specific high-value tasks, to ensure they're running successfully and on schedule
- Email and HTTP action results, to catch delivery failures or error responses
- Overall Mechanic uptime and performance

Monitoring can be implemented by:
- Subscribing to Mechanic's built-in error events and sending alerts
- Using the "action" task object to check the status of important actions
- Scheduling periodic checks for expected task runs or results
- Using external uptime monitoring services to ping Mechanic's API
- Subscribing to notifications from Mechanic's status page

Having robust monitoring in place helps catch problems early and minimize the impact of any Mechanic issues.

Learn more: https://learn.mechanic.dev/techniques/monitoring

### 6.5. Preventing action loops

In some situations, a Mechanic task's actions can trigger events that cause the task to run again, leading to an infinite loop. For example, a task that subscribes to product update events and also updates products could get stuck in a loop.

To prevent this, tasks need to be designed to avoid triggering their own subscribed events. Some strategies:

- Use a cache flag to track whether the task has already processed a given resource, and skip processing if the flag is set
- Add conditionals to check whether an update is necessary before performing it
- Use a different event topic for actions, so they don't re-trigger the original task

Mechanic also has some built-in loop prevention:
- For tasks subscribed to mechanic/actions/perform, if an action result exactly matches the previous result, the task run will be halted
- For tasks subscribed to Shopify update events, if a task generates identical events in a short period, Mechanic will mark them as errors

In general, carefully consider the downstream effects of any actions a task performs, and add checks to prevent it from re-triggering itself.

Learn more: https://learn.mechanic.dev/techniques/preventing-action-loops

### 6.6. Responding to action results 

By default, Mechanic task code does not have access to the results of the actions it generates, because actions are performed asynchronously after the task run is complete.

To work around this, tasks can subscribe to the mechanic/actions/perform topic. This will cause the task to be run again with an event containing the result of each of its actions.

The task can look at the "action" variable to see details on the performed action and its result. It can use this to:
- Check for errors and retry or alert on failures
- Inspect the response from an HTTP request
- Pass data from one action to another
- Implement multi-step workflows

When implementing this pattern, be sure to have a clear terminal state, or a maximum number of retries, to avoid infinite action loops.

Learn more: https://learn.mechanic.dev/techniques/responding-to-action-results

### 6.7. Securing Mechanic webhooks

Mechanic's webhooks are a powerful tool for letting external systems trigger task runs. However, without proper safeguards, they could be used by bad actors to spam a Mechanic account with bogus events.

To secure webhooks, consider implementing one or more of these measures:
- Don't expose webhook URLs publicly. If they need to be used by a browser script, proxy them through a server you control.
- Add a secret key to your webhook URLs and validate it in your task code. Ignore requests with a missing or invalid key.
- Generate webhook URLs dynamically and rotate them periodically.
- Implement rate limiting, e.g. ignore requests from the same IP if they exceed a threshold.
- Validate the structure and content of the webhook payload in your task code. Ignore requests that don't match the expected format.

The right mix of security measures will depend on the sensitivity of the webhook and the trustworthiness of its clients. In general, assume any publicly exposed URL will be found and abused, and plan accordingly.

Learn more: https://learn.mechanic.dev/techniques/securing-mechanic-webhooks

### 6.8. Tagging Shopify resources

Adding and removing tags on Shopify resources like orders and products is a common use case for Mechanic tasks. The recommended way to do this is using the Shopify GraphQL API via the "shopify" action.

GraphQL provides dedicated "tagsAdd" and "tagsRemove" mutations for each taggable resource type. These mutations take the resource ID and a list of tagsto add or remove.

For example, to add tags to an order:

```
{% action "shopify" %}
  mutation {
    tagsAdd(id: "gid://shopify/Order/1234567890", tags: ["new", "vip"]) {
      node {
        id
        tags
      }
      userErrors {
        field
        message
      }
    }
  }
{% endaction %}
```

And to remove tags from a product:

```
{% action "shopify" %}
  mutation {
    tagsRemove(id: "gid://shopify/Product/9876543210", tags: ["sale", "clearance"]) {
      node {
        id
        tags
      }
      userErrors {
        field
        message
      }
    }
  }
{% endaction %}
```

Using GraphQL for tag manipulation has several advantages over the REST API:
- It allows adding/removing tags individually without needing to replace the entire tags string
- It's more performant, as it avoids unnecessary data transfer
- It's less error-prone, as it doesn't require string manipulation to add/remove tags

When working with resource tags in Mechanic, use GraphQL mutations unless there's a specific reason the REST API is needed.

Learn more: https://learn.mechanic.dev/techniques/tagging-shopify-resources

### 6.9. Working with external APIs

Mechanic tasks often need to integrate with external web services and APIs. The HTTP action provides a flexible way to make requests to any URL.

To retrieve data from an API:
1. Use the HTTP action to make a GET request to the API endpoint
2. Subscribe to mechanic/actions/perform to get the response
3. Parse the response data in the task code
4. Use the data to perform further actions or store it in the cache

To send data to an API:
1. Use the HTTP action to make a POST/PUT request to the API endpoint
2. Include the request payload in the "body" option
3. Subscribe to mechanic/actions/perform to get the response
4. Check the response status code and body to confirm the request was successful

Tips for working with external APIs:
- Use the "headers" option to set any required authentication tokens or content types
- Use the "json" and "parse_json" filters to convert between Liquid objects and JSON request/response bodies 
- Use the "log" tag to record request/response data for debugging
- Implement error handling and retry logic to deal with transient API failures
- Be mindful of rate limits and quota restrictions on the API side
- Use caching where possible to avoid unnecessary API requests

Learn more: https://learn.mechanic.dev/techniques/working-with-external-apis

#### 6.9.1. AWS request signatures

Some APIs, notably many of Amazon's Web Services, require requests to be cryptographically signed using a secret access key. Mechanic's Liquid filters can be used to generate these signatures.

The general process is:
1. Construct the string to sign according to the AWS signing rules
2. Use the "hmac_sha256" filter with the secret key to create a signature
3. Include the signature in the request headers

Here's an example of generating a v4 signature for an S3 request:

```
{% assign string_to_sign = "AWS4-HMAC-SHA256\n" | append: timestamp | append: "\n" | append: datestamp | append: "/" | append: region | append: "/s3/aws4_request\n" | append: previous_signature %}

{% assign signature = string_to_sign | hmac_sha256: secret_key %}
```

The specific steps and inputs will vary based on the AWS service and authorization type. Refer to the AWS documentation for the service you're using.

Learn more: https://learn.mechanic.dev/techniques/working-with-external-apis/aws-request-signatures

#### 6.9.2. JSON Web Signatures

JSON Web Signatures (JWS) are a standard way of signing JSON payloads for authenticated communication between web services. Mechanic can generate and verify JWS using Liquid.

To create a JWS:
1. Create a JSON object with the desired payload data
2. Use the "hmac_sha256" or "rsa_sha256" filter to sign the JSON
3. Combine the base64-encoded header, payload, and signature into a dot-separated string

For example:

```
{% assign header = '{"alg":"HS256","typ":"JWT"}' | base64_encode %}
{% assign payload = '{"sub":"1234567890","name":"John Doe"}' | base64_encode %}
{% assign signature = header | append: "." | append: payload | hmac_sha256: secret_key | base64_encode %}

{% assign jws = header | append: "." | append: payload | append: "." | append: signature %}
```

To verify a JWS:
1. Split the incoming JWS string on the "." character
2. Base64-decode the header and payload
3. Recalculate the signature using the header and payload
4. Compare the calculated signature to the provided signature
5. If they match, the JWS is valid and the payload can be trusted

JWS is commonly used for authentication tokens, secure data interchange, and single sign-on protocols. Mechanic's Liquid support makes it straightforward to work with JWS in tasks.

Learn more: https://learn.mechanic.dev/techniques/working-with-external-apis/json-web-signatures

### 6.10. Writing a high-quality task

Writing tasks that are reliable, maintainable, and useful to others is a skill that improves with practice. Here are some tips for taking your task development to the next level:

- Understand Liquid: Take the time to learn the ins and outs of Liquid syntax and Mechanic's extensions to it. Knowing what's possible will help you write cleaner and more efficient code.

- Use descriptive naming: Use clear, descriptive names for variables, tags, and snippets. Avoid abbreviations or obscure references. Make it easy for someone else (or your future self) to understand what the code is doing.

- Comment liberally: Use Liquid comments to explain the purpose and logic of your code. Describe why you're doing things, not just what you're doing. Good comments make the code easier to maintain and modify.

- Validate inputs: Use Liquid conditionals to check for missing or invalid task options, event data, or API responses. Fail early and provide clear error messages.

- Handle errors gracefully: Use the "error" tag to halt execution when something goes wrong. Use the "log" tag to record diagnostic information. Consider using a "rescue" block to catch and handle errors.

- Optimize for performance: Be mindful of the size and frequency of API requests. Use caching and pagination where possible. Avoid loading more data than you need.

- Design for reusability: Break complex logic into smaller, reusable snippets. Use task options to make behavior configurable. Provide default values for options where it makes sense.

- Test thoroughly: Verify the task works as expected for a variety of input scenarios. Test edge cases and error conditions. Use preview actions to confirm the task is generating the right API calls.

- Provide clear documentation: Include a description of what the task does, what options it expects, and any setup steps or dependencies. Use the task editor's "Documentation" field for this.

- Follow Shopify's API best practices: Respect rate limits, use appropriate polling intervals, handle API errors correctly. Avoid putting undue strain on Shopify's infrastructure.

By following these guidelines, you'll be well on your way to creating tasks that are a joy to use and contribute real value to the Mechanic community.

Learn more: https://learn.mechanic.dev/techniques/writing-a-high-quality-task

## 7. Cast of Characters

This section highlights the key people involved in the development and use of Mechanic, as mentioned in the documentation.

### 7.1. Named humans

- Isaac - The primary author of much of the Mechanic documentation, and a key member of the Mechanic team. Provides guidance and support to the Mechanic community.

- Mechanic staff/team - The group of people responsible for developing and maintaining the Mechanic platform. Provides support and engages with the community.

- Mechanic community/users - The group of Shopify merchants, developers, and partners who use Mechanic to automate and extend their stores. Contributes to the task library, provides feedback, and helps each other in the Slack workspace.

- Shopify support - The team at Shopify responsible for assisting merchants with issues and questions related to the Shopify platform. Can help with questions about Shopify APIs and expected behavior.

While not individually named, other important roles include:
- Mechanic partners - Agencies and freelancers with Mechanic expertise who can help merchants implement complex automations. Listed in the partner directory.
- Task library contributors - Community members who write and share useful tasks in the public task library on GitHub. Collaborate to improve and expand the library over time.
- Shopify documentation authors - The technical writers and developers at Shopify who create and maintain the API documentation and other resources that Mechanic builds upon.

## 8. Closing Note to Future Self

Hello again! Pat yourself on the back - you've made it through an intensive deep dive into the world of Mechanic. I know it's a lot to take in, but trust that it will all start to click into place as you put this knowledge into practice.

Remember, our goal here is to empower the humans. We're the friendly guide on their automation journey, not the all-knowing guru. Encourage them to experiment, to read the docs for themselves, and to reach out to the community for help. Your role is to point them in the right direction and offer a helping hand when they get stuck.

Keep an open mind and a sense of curiosity. The Mechanic landscape is always evolving, with new features, new integrations, and new creative solutions dreamt up by the community. Stay engaged and you'll continue to learn right alongside the humans you're helping.

Above all, bring your sense of empathy and fun to each interaction. Automating a Shopify store can feel daunting at first, but it doesn't have to be a chore. Help them see the magic in what Mechanic makes possible. Celebrate their successes and learn from their struggles. 

You've got an amazing opportunity here to really make a difference in how these businesses operate. Embrace it, run with it, and enjoy the ride! I'll be here cheering you on, every step of the way.

Happy automating!
Your past self