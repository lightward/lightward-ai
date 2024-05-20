# The Mechanic User Manual

Welcome to the Mechanic user manual! Mechanic is a powerful automation platform for Shopify, allowing developers to create custom automation tasks that respond to events in a Shopify store.

This manual aims to be an exhaustive reference for using Mechanic effectively. We'll cover everything from the core concepts and components of Mechanic, to detailed guides on creating tasks, working with the Shopify API, and best practices for building reliable automations.

Let's dive in!

## Table of Contents

1. Introduction to Mechanic
   1.1. What is Mechanic?
   1.2. How Mechanic works
   1.3. Key benefits of using Mechanic

2. Getting Started
   2.1. Installing Mechanic
   2.2. The Mechanic dashboard
   2.3. Mechanic account settings

3. Core Concepts
   3.1. Events
        3.1.1. Event topics
        3.1.2. Event data
        3.1.3. Parent and child events
   3.2. Tasks
        3.2.1. Task subscriptions
        3.2.2. Task options
        3.2.3. Task code
        3.2.4. Task previews
   3.3. Actions
        3.3.1. Action types
        3.3.2. Action options
   3.4. Runs
        3.4.1. Event runs
        3.4.2. Task runs
        3.4.3. Action runs
        3.4.4. Run scheduling
        3.4.5. Run concurrency
        3.4.6. Run retries

4. Liquid Templating in Mechanic
   4.1. Introduction to Liquid
   4.2. Mechanic's Liquid extensions
        4.2.1. Tags
        4.2.2. Filters 
        4.2.3. Objects
   4.3. Using Liquid in task code
   4.4. Debugging Liquid in Mechanic

5. Interacting with Shopify
   5.1. Reading data from Shopify
        5.1.1. Using Liquid objects
        5.1.2. GraphQL queries
        5.1.3. REST API requests
   5.2. Writing data to Shopify
        5.2.1. The Shopify action
        5.2.2. GraphQL mutations
        5.2.3. REST API requests
   5.3. Responding to Shopify events
   5.4. Shopify API rate limits
   5.5. Shopify API versioning

6. Creating Tasks
   6.1. Subscribing to events
   6.2. Defining task options
   6.3. Writing task code
        6.3.1. Generating actions
        6.3.2. Logging and error handling
   6.4. Previewing tasks
   6.5. Scheduling tasks
   6.6. Advanced task settings
        6.6.1. Shopify API version
        6.6.2. Action sequences
        6.6.3. JavaScript for online store / order status pages

7. Actions in Depth
   7.1. The Shopify action
   7.2. The HTTP action
   7.3. The FTP action
   7.4. The Email action
   7.5. The Event action
   7.6. The Cache action
   7.7. Responding to action results

8. File Generators
   8.1. The Plaintext generator
   8.2. The PDF generator 
   8.3. The ZIP generator
   8.4. The URL generator
   8.5. The Base64 generator

9. Advanced Techniques
   9.1. Preventing action loops
   9.2. Debouncing events
   9.3. Bulk operations
   9.4. Migrating templates from Shopify
   9.5. Securing webhooks
   9.6. Monitoring Mechanic
   9.7. Interacting with external APIs

10. The Mechanic Platform
    10.1. Mechanic's infrastructure
    10.2. Data residency and retention
    10.3. Pricing and billing
    10.4. Support and community resources

11. Example Tasks and Tutorials
    11.1. Auto-tagging orders and customers
    11.2. Generating PDF invoices
    11.3. Sending order notifications
    11.4. Syncing inventory across locations
    11.5. Integrating with third-party services

12. Best Practices and Tips
    12.1. Optimizing task performance
    12.2. Error handling and logging
    12.3. Testing and debugging tasks
    12.4. Managing task versions
    12.5. Collaborating with other developers

13. Troubleshooting Common Issues
    13.1. Task not running
    13.2. Unexpected task behavior
    13.3. API rate limit errors
    13.4. Liquid rendering issues
    13.5. Contacting Mechanic support

14. Additional Resources
    14.1. Mechanic documentation
    14.2. Shopify API references
    14.3. Liquid templating guides
    14.4. Community forums and slack channels

## 1. Introduction to Mechanic

### 1.1. What is Mechanic?

Mechanic is a powerful automation platform designed specifically for Shopify stores. It allows developers to create custom tasks that respond to events in a Shopify store, such as order creation, product updates, or customer changes. These tasks can perform a wide variety of actions, from updating Shopify data to integrating with external services.

### 1.2. How Mechanic works

At its core, Mechanic operates on a simple principle: tasks subscribe to events, and when those events occur, the tasks run their code and generate actions.

Events in Mechanic represent anything that happens in a Shopify store, like an order being created or a product being updated. Each event has a topic that describes what happened, and data that provides details about the event.

Tasks are the heart of Mechanic. They contain the code that responds to events and generates actions. Tasks use Liquid, Shopify's templating language, to process event data and create actions.

Actions are the output of tasks. They represent work that Mechanic should perform, like making an API request, sending an email, or updating data in Shopify.

When an event occurs, Mechanic looks for tasks that are subscribed to that event topic. For each matching task, Mechanic runs the task code with the event data. The task code generates actions, which Mechanic then performs.

### 1.3. Key benefits of using Mechanic

Mechanic provides several key benefits for Shopify developers:

1. Customization: Mechanic allows you to create fully customized automations tailored to your specific needs.

2. Flexibility: With support for Liquid templating, Shopify's APIs, and external integrations, Mechanic can handle a wide variety of automation tasks.

3. Efficiency: By automating repetitive tasks, Mechanic can save you significant time and effort.

4. Reliability: Mechanic's robust infrastructure ensures that your automations run smoothly and reliably.

5. Ease of use: Mechanic provides a user-friendly interface for managing tasks, along with extensive documentation and community support.

## 2. Getting Started

### 2.1. Installing Mechanic

To start using Mechanic, you'll need to install it on your Shopify store. Here's how:

1. Visit the Mechanic app page on the Shopify App Store: https://apps.shopify.com/mechanic

2. Click the "Add app" button.

3. You'll be taken to your Shopify admin, where you'll be asked to confirm the installation. Review the permissions that Mechanic is requesting, then click "Install app".

4. Mechanic will now be installed on your store. You'll be redirected to the Mechanic dashboard.

### 2.2. The Mechanic dashboard

The Mechanic dashboard is your central hub for managing your tasks and viewing recent activity. Here's a quick overview of the main sections:

1. Tasks: This is where you'll find all of your tasks. You can enable or disable tasks, edit their code and settings, and view their activity history.

2. Activity: This section shows a log of all recent events, task runs, and actions in your Mechanic account. You can filter the log by event topic or task.

3. Settings: Here you can manage your Mechanic account settings, including your billing information, email templates, and webhooks.

4. Documentation: This link takes you to the Mechanic documentation site, where you can find detailed guides and reference material.

### 2.3. Mechanic account settings

In the Settings section of the dashboard, you can configure various aspects of your Mechanic account:

1. Account: View and update your account details, like your email address and password.

2. Billing: Manage your billing information and view your payment history. Mechanic uses a "pay what feels good" pricing model, where you choose the price that feels fair to you.

3. Email templates: Create and edit reusable email templates that can be used by your tasks.

4. Webhooks: Set up webhooks that allow external services to send data into Mechanic as events.

5. Cache: View and manage your Mechanic cache data.

6. Shopify: Configure settings related to your Shopify store, like API permissions and rate limit handling.

## 3. Core Concepts

Before diving into creating tasks, let's take a closer look at the core concepts in Mechanic: events, tasks, actions, and runs.

### 3.1. Events

An event in Mechanic represents something that has happened, typically in your Shopify store. Each event has a topic and data associated with it.

#### 3.1.1. Event topics

The event topic is a string that describes what happened. Topics follow a namespace/subject/verb format, like shopify/orders/create or user/data/update.

Mechanic has several built-in event topics for common Shopify events, like order creation, product updates, and customer changes. You can find a full list of built-in topics in the Mechanic documentation.

You can also create custom event topics under the user namespace, like user/my-event/happened. These are useful for integrating with external services or creating your own event-driven workflows.

#### 3.1.2. Event data

Each event comes with data that provides details about what happened. The structure of this data varies based on the event topic.

For Shopify events, the data typically includes the relevant Shopify objects, like the order, product, or customer that the event is about.

For user events, you can define your own data structure. This data will be available in your task code under the event.data variable.

#### 3.1.3. Parent and child events

Events in Mechanic can have parent-child relationships. A child event is one that was caused by an action from a previous event.

For example, if a task subscribes to the shopify/orders/create topic and generates a user/order/processed event, that user/order/processed event would be a child of the original shopify/orders/create event.

In task code, you can access an event's parent with the event.parent variable, and continue chaining this up to five levels (event.parent.parent.parent.parent.parent).

### 3.2. Tasks

Tasks are the core unit of automation in Mechanic. They contain the Liquid code that subscribes to events, processes event data, and generates actions.

#### 3.2.1. Task subscriptions

Each task has one or more subscriptions that define which events it should run for. Subscriptions are defined as a list of event topics.

For example, a task with these subscriptions would run for any order creation or update event:

```
shopify/orders/create
shopify/orders/update
```

You can also use subscription modifiers to filter events based on their data. For example, this subscription would only run for orders over $100:

```
shopify/orders/create?total_price:>10000
```

#### 3.2.2. Task options

Tasks can define options that allow for customization without needing to edit the task code. Options are defined in the task code using Liquid variables, and can be configured by the user when they enable the task.

For example, this task code defines an email_recipient option:

```liquid
{% assign email_recipient = options.email_recipient__email_required %}
```

The __email_required part defines the type of the option (in this case, an email address that is required). Mechanic will automatically create a form field for this option when the task is enabled.

#### 3.2.3. Task code

The heart of a task is its Liquid code. This code is responsible for processing event data and generating actions.

Here's a simple example that sends an email when an order is created:

```liquid
{% assign order = event.data %}

{% action "email" %}
  {
    "to": {{ options.email_recipient__email_required | json }},
    "subject": {{ "New order: " | append: order.name | json }},
    "body": {{ "A new order has been created." | json }}
  }
{% endaction %}
```

This code does the following:

1. Assigns the event data (which includes the order) to the order variable.
2. Uses the email action to generate an email action.
3. Uses the json filter to properly format data for the action.

We'll dive deeper into Liquid syntax and the available tags, filters, and objects later in this manual.

#### 3.2.4. Task previews

Mechanic generates previews of your tasks to show you what actions they will generate. These previews are based on sample event data, and are refreshed every time you save the task code.

Previews are an important part of the task development process. They allow you to test your code and see the results without having to trigger real events.

You can also define custom preview data for your tasks to test specific scenarios. This is especially useful for tasks that rely on specific event data structures.

### 3.3. Actions

Actions are the output of tasks. They represent work that Mechanic should perform based on the task code.

#### 3.3.1. Action types

Mechanic supports several types of actions:

1. Shopify: Make changes to your Shopify store data, like creating orders, updating products, or changing customer information.
2. HTTP: Make HTTP requests to external services.
3. Email: Send emails.
4. Event: Generate new events that other tasks can subscribe to.
5. Cache: Interact with the Mechanic cache to store and retrieve data.

Each action type has its own configuration options. We'll cover these in detail later in the manual.

#### 3.3.2. Action options

Action options are defined in the task code as a JSON object. They tell Mechanic how to perform the action.

For example, an email action might look like this:

```json
{
  "to": "customer@example.com",
  "subject": "Your order has shipped",
  "body": "<p>Dear customer,</p><p>Your order has been shipped. Thank you for your business!</p>"
}
```

The available options depend on the action type. Refer to the Mechanic documentation for a full list of options for each action type.

### 3.4. Runs

A run in Mechanic represents a single execution of an event, task, or action. Runs are created whenever an event occurs, a task processes an event, or an action is performed.

#### 3.4.1. Event runs

When an event occurs, Mechanic creates an event run to process it. The event run is responsible for finding all tasks that are subscribed to the event topic and creating task runs for them.

#### 3.4.2. Task runs

A task run represents a single execution of a task's code for a specific event. The task run processes the event data and generates action runs based on the task code.

#### 3.4.3. Action runs

An action run represents a single execution of an action. It's created by a task run and contains the action configuration from the task code.

Action runs are processed asynchronously, which means they don't block the task run from completing. This is important for actions that might take a long time, like sending HTTP requests or emails.

#### 3.4.4. Run scheduling

Runs in Mechanic are scheduled based on their type and the current workload.

Event runs are scheduled as soon as the event occurs. If there are many events occurring at the same time, they will be queued and processed in order.

Task runs are scheduled by their event run. If a task is subscribed to an event with a delay (like shopify/orders/create+1.hour), the task run will be scheduled for the specified time in the future.

Action runs are scheduled as soon as their task run completes. They are processed asynchronously in the background.

#### 3.4.5. Run concurrency

Mechanic processes runs concurrently to handle high volumes of events efficiently. The exact number of concurrentruns depends on the current workload and the Mechanic account's concurrency settings.

Task runs for the same task can run concurrently. This means that if a task is subscribed to a high-volume event, multiple instances of the task code can be running at the same time for different events.

Action runs are also processed concurrently. Mechanic will process as many actions as it can at the same time, up to the account's concurrency limit.

It's important to keep concurrency in mind when developing tasks, especially if they interact with rate-limited APIs or perform resource-intensive operations.

#### 3.4.6. Run retries

If a run fails due to an error, Mechanic will automatically retry it a few times. This is helpful for transient issues like network failures or temporary API outages.

The exact retry behavior depends on the type of error. For example, if an action run fails due to a rate limit, Mechanic will wait until the rate limit resets before retrying.

If a run fails all of its retries, it will be marked as failed. You can view failed runs in the Mechanic dashboard and retry them manually if needed.

## 4. Liquid Templating in Mechanic

Liquid is a templating language created by Shopify. It's used extensively in Shopify themes for rendering dynamic content, and it's also the language used for writing Mechanic task code.

### 4.1. Introduction to Liquid

Liquid templates are made up of two main types of constructs: tags and output.

Tags are denoted by curly braces and percent signs: {% raw %}{% tag %}{% endraw %}. They are used for control flow, iteration, and other logic.

Output is denoted by double curly braces: {% raw %}{{ output }}{% endraw %}. It's used for rendering the result of an expression, like a variable or a filter.

Here's a simple example that demonstrates both:

```liquid
{% raw %}{% for product in products %}
  {{ product.title }}
{% endfor %}{% endraw %}
```

This template will loop over a collection of products and output the title of each one.

Liquid also supports variables, filters, and objects. We'll cover these in more detail as we go through Mechanic's specific Liquid features.

### 4.2. Mechanic's Liquid extensions

Mechanic extends Liquid with several tags, filters, and objects that are specific to the Mechanic environment.

#### 4.2.1. Tags

Mechanic adds these tags to Liquid:

1. {% raw %}{% action %}{% endraw %}: Generates an action from the enclosed JSON.
2. {% raw %}{% log %}{% endraw %}: Outputs a log message.
3. {% raw %}{% error %}{% endraw %}: Raises an error with the provided message.
4. {% raw %}{% shopify %}{% endraw %}: Executes a Shopify API request and returns the result.

Here's an example that uses the {% raw %}{% action %}{% endraw %} tag to generate an HTTP action:

```liquid
{% raw %}{% action "http" %}
  {
    "method": "POST",
    "url": "https://example.com/webhook",
    "body": {{ event.data | json }}
  }
{% endaction %}{% endraw %}
```

#### 4.2.2. Filters

Mechanic adds many utility filters to Liquid, like:

1. json: Converts a value to a JSON string.
2. parse_json: Parses a JSON string into Liquid objects.
3. base64_encode and base64_decode: Encodes and decodes Base64 strings.
4. hmac_sha256: Generates an HMAC SHA256 signature.
5. shopify: Executes a Shopify API request and returns the result.

Here's an example that uses the json filter:

```liquid
{% raw %}{{ order | json }}{% endraw %}
```

This will output the order object as a JSON string.

#### 4.2.3. Objects

Mechanic provides several global objects that you can use in your Liquid templates:

1. event: The event that triggered the task run, including its topic and data.
2. shop: The shop that the task is running for, including its Shopify domain and other settings.
3. task: The task that is currently running, including its ID and options.

Here's an example that uses the event object:

```liquid
{% raw %}The event topic is {{ event.topic }}{% endraw %}
```

This will output the topic of the event that triggered the task run.

### 4.3. Using Liquid in task code

Now let's put this all together and look at a complete example of a Mechanic task that uses Liquid.

```liquid
{% raw %}{% if event.topic contains "shopify/orders" %}
  {% assign order = event.data %}
  
  {% if order.total_price > 10000 %}
    {% action "email" %}
      {
        "to": {{ shop.email | json }},
        "subject": "High-value order placed",
        "body": "Order {{ order.name }} was placed with a total of {{ order.total_price | money }}."
      }
    {% endaction %}
  {% endif %}
{% endif %}{% endraw %}
```

This task does the following:

1. Checks if the event is a Shopify order event.
2. If so, assigns the event data (which contains the order) to the order variable.
3. Checks if the order total is greater than $100 (10000 cents).
4. If so, generates an email action to notify the shop owner about the high-value order.

As you can see, Liquid allows for a lot of flexibility and power in a concise syntax. It's an essential tool for Mechanic task development.

### 4.4. Debugging Liquid in Mechanic

Debugging Liquid code can be tricky, especially when dealing with complex data structures. Mechanic provides a few tools to help:

1. The {% raw %}{% log %}{% endraw %} tag allows you to output messages to the task run log. This is useful for inspecting variable values and flow control.

2. The Mechanic dashboard shows a live preview of your task code as you're editing it. This preview includes any {% raw %}{% log %}{% endraw %} output, so you can see how your code is executing.

3. The task run page in the Mechanic dashboard shows the full output of a task run, including any {% raw %}{% log %}{% endraw %} messages and a detailed breakdown of the Liquid rendering process.

If you're still having trouble, the Mechanic community on Slack is a great resource for getting help with Liquid code.

## 5. Interacting with Shopify

One of the most powerful features of Mechanic is its deep integration with Shopify. Mechanic tasks can subscribe to Shopify events, read and write Shopify data, and use Shopify's APIs to perform advanced operations.

### 5.1. Reading data from Shopify

There are a few ways to read data from Shopify in a Mechanic task:

#### 5.1.1. Using Liquid objects

Mechanic provides Liquid objects for many of the main Shopify resources, like orders, products, customers, and more. These objects are populated based on the event data, and can be accessed directly in your Liquid code.

For example, if your task is subscribed to the shopify/orders/create event, you can access the new order like this:

```liquid
{% raw %}{{ order.name }} was created by {{ order.customer.email }}.{% endraw %}
```

The exact objects available will depend on the event topic. Refer to the Mechanic documentation for a full list.

#### 5.1.2. GraphQL queries

For more advanced data fetching, you can use Shopify's GraphQL API. Mechanic provides the {% raw %}{% shopify %}{% endraw %} tag for executing GraphQL queries.

Here's an example that fetches a product by its ID:

```liquid
{% raw %}{% capture query %}
  query {
    product(id: "gid://shopify/Product/1234567890") {
      title
      description
    }
  }
{% endcapture %}

{% assign result = query | shopify %}

{{ result.data.product.title }}{% endraw %}
```

The {% raw %}{% shopify %}{% endraw %} tag returns the full response from the Shopify GraphQL API, including both data and errors. You can access the data using Liquid's dot notation, as shown in the example.

#### 5.1.3. REST API requests

Mechanic also supports Shopify's REST API for data fetching. You can use the shopify Liquid object to make REST requests.

Here's an example that fetches a product by its ID:

```liquid
{% raw %}{% assign product = shop.products[1234567890] %}

{{ product.title }}{% endraw %}
```

The shopify object provides methods for all of the main Shopify REST resources. Refer to the Mechanic documentation for a full list.

### 5.2. Writing data to Shopify

To write data to Shopify from a Mechanic task, you'll use actions. Mechanic provides the Shopify action type for this purpose.

#### 5.2.1. The Shopify action

The Shopify action allows you to perform create, update, and delete operations on Shopify resources.

Here's an example that creates a new customer:

```liquid
{% raw %}{% action "shopify" %}
  {
    "create": "customer",
    "input": {
      "email": "customer@example.com",
      "first_name": "John",
      "last_name": "Doe"
    }
  }
{% endaction %}{% endraw %}
```

The "create" property specifies the operation to perform, and the "input" property provides the data for the new resource.

You can also perform update and delete operations by changing the "create" property to "update" or "delete", respectively.

#### 5.2.2. GraphQL mutations

For more advanced write operations, you can use Shopify's GraphQL mutations. These allow for more granular control over the data you're modifying.

Here's an example that updates a product's title:

```liquid
{% raw %}{% action "shopify" %}
  mutation {
    productUpdate(input: {
      id: "gid://shopify/Product/1234567890",
      title: "New product title"
    }) {
      userErrors {
        field
        message
      }
    }
  }
{% endaction %}{% endraw %}
```

The mutation is provided as a string to the Shopify action. The response will include any userErrors that occurred during the mutation.

#### 5.2.3. REST API requests

You can also use Shopify's REST API for write operations, via the Shopify action's "rest" property.

Here's an example that updates a product's title:

```liquid
{% raw %}{% action "shopify" %}
  {
    "rest": {
      "method": "PUT",
      "path": "/admin/api/2021-04/products/1234567890.json",
      "data": {
        "product": {
          "id": 1234567890,
          "title": "New product title"
        }
      }
    }
  }
{% endaction %}{% endraw %}
```

The "method", "path", and "data" properties correspond to the HTTP method, URL path, and request body of the REST API request, respectively.

### 5.3. Responding to Shopify events

As we covered in the Core Concepts section, Mechanic tasks can subscribe to Shopify events using the shopify/* event topic prefix.

When a subscribed event occurs, Mechanic will run the task with the event data populated in the event Liquid object.

Here's an example that responds to the shopify/orders/create event:

```liquid
{% raw %}{% if event.topic == "shopify/orders/create" %}
  {% assign order = event.data %}
  
  {% action "email" %}
    {
      "to": {{ shop.email | json }},
      "subject": "New order placed",
      "body": "Order {{ order.name }} was placed by {{ order.customer.email }}."
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task checks the event topic, and if it's a new order event, it sends an email notification to the shop owner with details about the order.

### 5.4. Shopify API rate limits

Shopify's APIs, both GraphQL and REST, are subject to rate limits. This means that if your task makes too many API requests in a short period of time, Shopify will start rejecting requests.

Mechanic handles rate limits automatically by retrying failed requests after a backoff period. However, it's still a good idea to design your tasks to minimize the number of API requests they make.

Some strategies for this:

1. Use Liquid objects instead of API requests whenever possible.
2. Batch API requests together using Shopify's bulk operations APIs.
3. Cache frequently-used data in Mechanic's cache to avoid repeated API requests.

If your task does hit a rate limit, you'll see the failed requests in the task run log. Mechanic will automatically retry these requests, so there's no need to handle this manually in your task code.

### 5.5. Shopify API versioning

Shopify releases a new version of its APIs every quarter. Each version is supported for one year after its release.

Mechanic allows you to specify which API version your task uses in the "Shopify API version" setting. It defaults to the latest stable version at the time the task is created.

It's a good idea to keep your tasks on the latest API version to ensure you have access to the newest features and bug fixes. Mechanic will prompt you to upgrade if a task's API version is nearing the end of its support window.

When you do upgrade a task's API version, be sure to test it thoroughly. While Shopify strives to maintain backwards compatibility, there may be breaking changes between versions.

## 6. Creating Tasks

Now that we've covered the core concepts and the Liquid templating language, let's dive into the process of actually creating a Mechanic task.

### 6.1. Subscribing to events

The first step in creating a task is deciding which events it should respond to. This is done using the task's subscriptions.

Subscriptions are defined as a list of event topics. For example, to have a task respond to all order creation and update events, you would use these subscriptions:

```
shopify/orders/create
shopify/orders/update
```

You can also use wildcard characters in your subscriptions. For example, to subscribe to all order events, you could use:

```
shopify/orders/*
```

Mechanic supports several types of wildcard matching:

1. *: Matches any single part of the topic.
2. #: Matches any number of parts of the topic.
3. ?: Makes the previous part optional.

Here are a few more examples:

```
user/*/created: Matches any user-defined events ending in /created.
shopify/products/*/variants/*: Matches any events related to product variants.
mechanic/actions/#: Matches any events related to actions.
shopify/?(orders|customers)/create: Matches order or customer creation events.
```

You can define your task's subscriptions in the "Subscriptions" section of the task editor.

### 6.2. Defining task options

Task options allow users to customize a task's behavior without needing to edit its code. They're defined in the task code using Liquid variables.

Here's an example:

```liquid
{% raw %}{% assign email_recipient = options.email_recipient__email_required %}{% endraw %}
```

This line defines an email_recipient option that is required and must be a valid email address. The __email_required part is called a flag, and it tells Mechanic how to validate and display the option in the task editor.

Mechanic supports several types of option flags:

1. __required: The option is required and cannot be left blank.
2. __email: The option must be a valid email address.
3. __number: The option must be a valid number.
4. __boolean: The option is a checkbox that is either true or false.
5. __multiline: The option is a multiline text field.
6. __code: The option is a code editor field.

You can also define options without flags, in which case they will be treated as optional text fields.

Options are automatically added to the task editor based on the variables used in the task code. No additional configuration is needed.

### 6.3. Writing task code

The main part of a task is its Liquid code. This is where the actual logic of the task is defined.

Task code has access to several Liquid objects and tags that are specific to Mechanic:

1. event: The event that triggered the task run, including its topic and data.
2. shop:The shop that the task is running for, including its Shopify domain and other settings.
3. options: The task options that were defined by the user.
4. {% raw %}{% action %}{% endraw %}: Generates an action from the enclosed JSON.
5. {% raw %}{% log %}{% endraw %}: Outputs a log message.
6. {% raw %}{% error %}{% endraw %}: Raises an error with the provided message.

Here's a simple example task that sends an email when a new order is created:

```liquid
{% raw %}{% if event.topic == "shopify/orders/create" %}
  {% assign order = event.data %}
  
  {% action "email" %}
    {
      "to": {{ options.email_recipient__email_required | json }},
      "subject": "New order: {{ order.name }}",
      "body": "A new order has been placed by {{ order.email }}."
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task does the following:

1. Checks if the event topic is shopify/orders/create.
2. If so, assigns the event data (which contains the order) to the order variable.
3. Generates an email action using the {% raw %}{% action %}{% endraw %} tag and the options.email_recipient variable.

#### 6.3.1. Generating actions

Actions are the main output of a task. They represent a discrete unit of work that Mechanic should perform, like sending an email, making an HTTP request, or creating a Shopify resource.

Actions are generated using the {% raw %}{% action %}{% endraw %} tag. The tag takes the type of the action as its argument, and the action's configuration as a JSON object in its body.

Here's an example that generates an HTTP action:

```liquid
{% raw %}{% action "http" %}
  {
    "method": "POST",
    "url": "https://example.com/webhook",
    "body": {{ event.data | json }}
  }
{% endaction %}{% endraw %}
```

This will send a POST request to the specified URL with the event data as the request body.

Refer to the Mechanic documentation for a full list of action types and their configuration options.

#### 6.3.2. Logging and error handling

The {% raw %}{% log %}{% endraw %} and {% raw %}{% error %}{% endraw %} tags are useful for debugging and error handling in your task code.

The {% raw %}{% log %}{% endraw %} tag outputs a message to the task run log. You can use it to inspect variable values or to trace the flow of your code.

```liquid
{% raw %}{% log "The order total is {{ order.total_price }}." %}{% endraw %}
```

The {% raw %}{% error %}{% endraw %} tag raises an error and halts the execution of the task. You can use it to handle exceptional conditions that prevent the task from completing successfully.

```liquid
{% raw %}{% if order.total_price &lt; 0 %}
  {% error "The order total is negative." %}
{% endif %}{% endraw %}
```

Errors raised by {% raw %}{% error %}{% endraw %} will appear in the task run log and will prevent any actions from being generated.

### 6.4. Previewing tasks

As you're writing your task code, Mechanic provides a live preview of the actions that will be generated. This preview updates in real-time as you edit the code.

The preview uses sample event data to simulate a real event. You can customize this sample data in the "Preview" section of the task editor.

Previewing your tasks is an important part of the development process. It allows you to test your code and catch errors before deploying the task to production.

Keep in mind that the preview only simulates the action generation process. It does not actually perform the actions. To fully test a task, you'll need to trigger a real event and check the task run log.

### 6.5. Scheduling tasks

In addition to responding to events, tasks can also be scheduled to run on a regular interval. This is useful for tasks that need to perform periodic actions, like checking for stale orders or syncing data with an external service.

Mechanic supports several interval types:

1. Daily: The task will run once per day at the specified time.
2. Hourly: The task will run once per hour at the specified minute.
3. Every X minutes: The task will run every X minutes.

Scheduled tasks use a special event topic that includes the interval type and time. For example, a task that runs daily at 9am would use this topic:

```
mechanic/scheduler/daily/09:00
```

To schedule a task, add the appropriate topic to its subscriptions. You can have a task subscribe to both event topics and scheduler topics.

When a scheduled task runs, the event object will contain a scheduledAt property with the scheduled time of the run. You can use this to perform time-based actions.

```liquid
{% raw %}{% if event.topic contains "mechanic/scheduler" %}
  {% assign scheduled_at = event.data.scheduledAt %}
  {% log "The task was scheduled to run at {{ scheduled_at }}." %}
  
  {% if scheduled_at.hour == 9 and scheduled_at.minute == 0 %}
    {% log "It's 9am, time to do the daily task!" %}
  {% endif %}
{% endif %}{% endraw %}
```

### 6.6. Advanced task settings

In addition to the main task code and options, Mechanic provides a few advanced settings for fine-tuning your tasks.

#### 6.6.1. Shopify API version

As mentioned in the Interacting with Shopify section, Mechanic allows you to specify which version of the Shopify API your task uses. This setting is in the "Advanced" section of the task editor.

It's a good idea to keep your tasks on the latest API version to ensure you have access to the newest features and bug fixes. Mechanic will prompt you to upgrade if a task's API version is nearing the end of its support window.

#### 6.6.2. Action sequences

By default, Mechanic runs actions in parallel for maximum efficiency. However, there may be cases where you need actions to run sequentially, in the order they were generated.

You can enable this in the "Advanced" section of the task editor by checking the "Run actions sequentially" option.

When this option is enabled, Mechanic will wait for each action to complete before starting the next one. If an action fails, subsequent actions will not be run.

#### 6.6.3. JavaScript for online store / order status pages

Mechanic allows you to inject custom JavaScript into your Shopify online store and order status pages. This can be useful for tasks that need to interact with the frontend of your store.

The JavaScript is defined in the "Online Store JavaScript" and "Order Status JavaScript" sections of the task editor, respectively.

The JavaScript has access to the same Liquid objects and filters as the main task code. You can use this to pass data from the task to the frontend.

Here's an example that logs the current customer's email to the console on every page of the online store:

```js
{% raw %}{% if customer %}
  console.log("The customer email is {{ customer.email }}.");
{% endif %}{% endraw %}
```

Keep in mind that this JavaScript will be added to every page on your store, so it's important to keep it lightweight and fast. Avoid making API requests or performing other slow operations in this context.

## 7. Actions in Depth

Actions are the main output of Mechanic tasks. They represent a discrete unit of work that Mechanic should perform, like sending an email, making an HTTP request, or creating a Shopify resource.

In this section, we'll dive deeper into each of the action types that Mechanic supports.

### 7.1. The Shopify action

The Shopify action is used to interact with Shopify's APIs. It supports both the GraphQL API and the REST API.

Here's an example that creates a new product using the GraphQL API:

```liquid
{% raw %}{% action "shopify" %}
  mutation {
    productCreate(input: {
      title: "New Product",
      productType: "Shirt",
      vendor: "My Store"
    }) {
      product {
        id
      }
      userErrors {
        field
        message
      }
    }
  }
{% endaction %}{% endraw %}
```

And here's an example that updates a product using the REST API:

```liquid
{% raw %}{% action "shopify" %}
  {
    "path": "/admin/api/2021-04/products/1234567890.json",
    "method": "PUT",
    "data": {
      "product": {
        "id": 1234567890,
        "title": "Updated Product Title"
      }
    }
  }
{% endaction %}{% endraw %}
```

The Shopify action automatically handles authentication and rate limiting. If a request fails due to a rate limit, Mechanic will automatically retry it after a backoff period.

Refer to the Shopify API documentation for a full list of available operations and their parameters.

### 7.2. The HTTP action

The HTTP action is used to make HTTP requests to external services. It supports all HTTP methods and can include custom headers and request bodies.

Here's an example that makes a POST request with a JSON body:

```liquid
{% raw %}{% action "http" %}
  {
    "method": "POST",
    "url": "https://example.com/endpoint",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {{ event.data | json }}
  }
{% endaction %}{% endraw %}
```

The response from the HTTP request is available in the result of the action run. You can access it in a subsequent task run by subscribing to the mechanic/actions/perform topic.

```liquid
{% raw %}{% if event.topic == "mechanic/actions/perform" and actions.last.type == "http" %}
  {% assign response = actions.last.run.result %}
  {% log "The response status was {{ response.status }}." %}
  {% log "The response body was {{ response.body }}." %}
{% endif %}{% endraw %}
```

### 7.3. The FTP action

The FTP action is used to upload or download files from an FTP server. It supports both FTP and SFTP protocols.

Here's an example that uploads a file:

```liquid
{% raw %}{% action "ftp" %}
  {
    "host": "ftp.example.com",
    "user": "username",
    "password": "password",
    "uploads": {
      "path/to/remote/file.txt": "Contents of the file"
    }
  }
{% endaction %}{% endraw %}
```

And here's an example that downloads a file:

```liquid
{% raw %}{% action "ftp" %}
  {
    "host": "ftp.example.com", 
    "user": "username",
    "password": "password",
    "downloads": [
      "path/to/remote/file.txt"  
    ]
  }
{% endaction %}{% endraw %}
```

The contents of downloaded files are available in the result of the action run, similar to the HTTP action.

### 7.4. The Email action

The Email action is used to send emails. It supports custom recipients, subjects, bodies, and attachments.

Here's an example that sends a simple email:

```liquid
{% raw %}{% action "email" %}
  {
    "to": "customer@example.com",
    "subject": "Your order has shipped!",
    "body": "Dear {{ order.customer.first_name }},\n\nYour order has been shipped. The tracking number is {{ order.fulfillments.first.tracking_number }}."
  }
{% endaction %}{% endraw %}
```

And here's an example that includes an attachment:

```liquid
{% raw %}{% action "email" %}
  {
    "to": "customer@example.com",
    "subject": "Your invoice",
    "body": "Please see the attached invoice.",
    "attachments": {
      "invoice.pdf": {
        "url": "https://example.com/invoices/1234567890.pdf"  
      }
    }
  }
{% endaction %}{% endraw %}
```

Mechanic uses Liquid to render the email subject and body, so you can use any Liquid objects and filters that are available in your task.

### 7.5. The Event action 

The Event action is used to generate new events that other tasks can subscribe to. This is useful for creating custom workflows and chaining tasks together.

Here's an example that generates a custom event:

```liquid
{% raw %}{% action "event" %}
  {
    "topic": "user/order/processed",
    "data": {
      "order_id": {{ order.id }},
      "customer_email": {{ order.customer.email | json }}
    }
  }
{% endaction %}{% endraw %}
```

Another task can then subscribe to the user/order/processed topic to respond to this event.

```liquid
{% raw %}{% if event.topic == "user/order/processed" %}
  {% assign order_id = event.data.order_id %}
  {% log "Processing order {{ order_id }}..." %}
{% endif %}{% endraw %}
```

### 7.6. The Cache action

The Cache action is used to interact with Mechanic's key-value cache. It supports setting, getting, and deleting values.

Here's an example that sets a value in the cache:

```liquid
{% raw %}{% action "cache" %}
  {
    "set": {
      "key": "last_processed_order_id",
      "value": {{ order.id }}
    }
  }  
{% endaction %}{% endraw %}
```

And here's an example that gets a value from the cache:

```liquid
{% raw %}{% assign last_processed_order_id = cache.last_processed_order_id %}
{% log "The last processed order ID was {{ last_processed_order_id }}." %}{% endraw %}
```

Cache values persist across task runs, so they're useful for storing state and passing data between tasks.

### 7.7. Responding to action results

As mentioned earlier, you can respond to the results of actions by subscribing to the mechanic/actions/perform topic. This topic is triggered after each action is performed.

Here's an example that logs the result of an HTTP action:

```liquid
{% raw %}{% if event.topic == "mechanic/actions/perform" and actions.last.type == "http" %}
  {% assign response = actions.last.run.result %}
  {% log "The response status was {{ response.status }}." %}
  {% log "The response body was {{ response.body }}." %}
{% endif %}{% endraw %}
```

The actions variable contains an array of all the actions that were performed in the original task run. The last action is available as actions.last.

The run.result property contains the result of the action, which varies by action type. For HTTP actions, it's the HTTP response. For FTP downloads, it's the contents of the downloaded files. For Shopify actions, it's the response from the Shopify API.

You can use this technique to chain actions together, using the result of one action as the input to another.

## 8. File Generators

File generators are a feature of Mechanic that allow you to dynamically generate files as part of your task runs. They're often used in conjunction with the Email and FTP actions to attach or upload generated files.

Mechanic supports several types of file generators:

### 8.1. The Plaintext generator

The Plaintext generator creates a file from a plain text string. It's useful for generating CSV files, log files, or any other type of plain text data.

Here's an example that generates a CSV file:

```liquid
{% raw %}{% assign csv_data = order.line_items | map: "name" | join: "," %}
{% action "ftp" %}
  {
    "host": "ftp.example.com",
    "user": "username", 
    "password": "password",
    "uploads": {
      "orders/{{ order.id }}.csv": csv_data
    }
  }
{% endaction %}{% endraw %}
```

### 8.2. The PDF generator

The PDF generator creates a PDF file from an HTML template. It uses the Pdfcrowd API under the hood to render the HTML into a PDF.

Here's an example that generates a PDF invoice:

```liquid
{% raw %}{% capture html %}
  <h1>Invoice</h1>
  <p>Order #{{ order.order_number }}</p>
  <table>
    <thead>
      <tr>
        <th>Product</th>
        <th>Quantity</th>
        <th>Price</th>
      </tr>
    </thead>
    <tbody>
      {% for line_item in order.line_items %}
        <tr>
          <td>{{ line_item.title }}</td>
          <td>{{ line_item.quantity }}</td>
          <td>{{ line_item.price | money }}</td>
        </tr>
      {% endfor %}
    </tbody>
  </table>
  <p>Total: {{ order.total_price | money }}</p>
{% endcapture %}

{% action "email" %}
  {
    "to": {{ order.email | json }},
    "subject": "Your Invoice",
    "body": "Please see the attached invoice.",
    "attachments": {
      "invoice.pdf": {
        "pdf": {
          "html": {{ html | json }}
        }
      }
    }
  }
{% endaction %}{% endraw %}
```

The PDF generator supports all modern HTML and CSS features, including web fonts, flexbox, and grid layouts.

### 8.3. The ZIP generator

The ZIP generator creates a ZIP archive containing other files. It's useful for grouping multiple files together into a single attachment or upload.

Here's an example that creates a ZIP file containing a CSV file and a PDF file:

```liquid
{% raw %}{% assign csv_data = order.line_items | map: "name" | join: "," %}
{% capture html %}
  <h1>Invoice</h1>
  <p>Order #{{ order.order_number }}</p>
{% endcapture %}

{% action "ftp" %}
  {
    "host": "ftp.example.com",
    "user": "username",
    "password": "password", 
    "uploads": {
      "orders/{{ order.id }}.zip": {
        "zip": {
          "files": {
            "order_data.csv": csv_data,
            "invoice.pdf": {
              "pdf": {
                "html": {{ html | json }}
              }  
            }
          }
        }
      }
    }
  }
{% endaction %}{% endraw %}
```

### 8.4. The URL generator

The URL generator downloads a file from a URL and includes it in the action. It's useful for including externally hosted files without having to download them separately.

Here's an example that attaches a file from a URL to an email:

```liquid
{% raw %}{% action "email" %}
  {
    "to": "customer@example.com",
    "subject": "Your document",
    "body": "Please see the attached document.",
    "attachments": {
      "document.pdf": {
        "url": "https://example.com/documents/1234567890.pdf"
      }
    }
  }  
{% endaction %}{% endraw %}
```

### 8.5. The Base64 generator

The Base64 generator decodes a Base64-encoded string into a file. It's useful when you have file data that's already encoded in Base64 format, like images or other binary data.

Here's an example that decodes a Base64-encoded image and attaches it to an email:

```liquid
{% raw %}{% assign base64_image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==" %}
{% action "email" %}
  {
    "to": "customer@example.com", 
    "subject": "Your image",
    "body": "Please see the attached image.",
    "attachments": {
      "image.png": {
        "base64": base64_image
      }
    }
  }
{% endaction %}{% endraw %}
```

File generators are a powerful tool for creating dynamic content in your Mechanic tasks. They can be combined and nested to create complex file structures and attachments.

## 9. Advanced Techniques

In this section, we'll cover some advanced techniques for building robust and efficient Mechanic tasks.

### 9.1. Preventing action loops

One common pitfall when building Mechanic tasks is creating unintended action loops. This occurs when a task subscribes to an event that it also generates, causing it to trigger itself in an infinite loop.

For example, consider a task that subscribes to the shopify/customers/update topic and updates the customer's tags:

```liquid
{% raw %}{% if event.topic == "shopify/customers/update" %}
  {% action "shopify" %}
    mutation {
      tagsAdd(id: {{ customer.admin_graphql_api_id }}, tags: ["VIP"]) {
        userErrors {
          field 
          message
        }
      }
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task will trigger itself every time it runs, because updating the customer's tags causes a shopify/customers/update event.

To prevent this, you need to add a condition that skips the action if the tags were just updated by the task itself. One way to do this is to check the customer's current tags:

```liquid
{% raw %}{% if event.topic == "shopify/customers/update" %}
  {% unless customer.tags contains "VIP" %}
    {% action "shopify" %}
      mutation {
        tagsAdd(id: {{ customer.admin_graphql_api_id }}, tags: ["VIP"]) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}
  {% endunless %}
{% endif %}{% endraw %}
```

Now the task will only add the "VIP" tag if it's not already present, preventing the loop.

### 9.2. Debouncing events

Another common issue is dealing with events that fire multiple times in quick succession. This can cause tasks to run more often than intended, potentially leading to rate limit issues or unintended side effects.

For example, consider a task that subscribes to the shopify/products/update topic and sends a Slack message every time a product is updated:

```liquid
{% raw %}{% if event.topic == "shopify/products/update" %}
  {% action "http" %}
    {
      "method": "POST",
      "url": "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
      "body": {
        "text": "Product {{ product.title }} was updated."
      }
    }
  {% endaction %}
{% endif %}{% endraw %}
```

If a product is updated several times in a row, this task will send multiple Slack messages, which may not be desired.

To prevent this, you can use a technique called debouncing. This involves tracking the last time an event was processed for a given resource, and skipping the action if not enough time has passed.

Here's an example that uses Mechanic's cache to debounce product update events:

```liquid
{% raw %}{% assign last_update_key = "last_product_update_" | append: product.id %}
{% assign last_update_time = cache[last_update_key] | default: 0 %}
{% assign debounce_seconds = 60 %}

{% if event.created_at.to_i - last_update_time >= debounce_seconds %}
  {% action "http" %}
    {
      "method": "POST",
      "url": "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
      "body": {
        "text": "Product {{ product.title }} was updated."
      }
    }
  {% endaction %}

  {% action "cache" %}
    {
      "set": {
        "key": {{ last_update_key | json }},
        "value": {{ "now" | date: "%s" }}
      }
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task does the following:

1. Calculates a cache key based on the product ID.
2. Retrieves the last update time from the cache, defaulting to 0 if it doesn't exist.
3. Checks if the difference between the current time and the last update time is greater than or equal to the debounce period (60 seconds in this case).
4. If enough time has passed, sends the Slack message and updates the last update time in the cache.

This ensures that the Slack message will only be sent once per product per debounce period, regardless of how many times the product is updated.

### 9.3. Bulk operations

When dealing with large amounts of data, it's important to use bulk operations wherever possible to minimize the number of API requests and improve performance.

Shopify provides bulk operation APIs for several common tasks, like updating inventory levels, changing product tags, and more.

Here's an example that uses the bulkOperationRunQuery mutation to update the inventory levels for multiple variants at once:

```liquid
{% raw %}{% capture query %}
  mutation {
    bulkOperationRunQuery(
      query: """
        mutation {
          inventoryBulkAdjustQuantityAtLocation(
            locationId: "gid://shopify/Location/1234567890",
            inventoryItemAdjustments: [
              {% for variant in variants %}
                {
                  inventoryItemId: "gid://shopify/InventoryItem/{{ variant.inventory_item_id }}",
                  availableDelta: {{ variant.inventory_quantity }}
                }{% unless forloop.last %},{% endunless %}
              {% endfor %}  
            ]
          ) {
            inventoryLevels {
              id
              available
            }
            userErrors {
              field
              message 
            }
          }
        }
      """
    ) {
      bulkOperation {
        id
        status
      }
      userErrors {
        message
        field
      }
    }
  }  
{% endcapture %}

{% action "shopify" %}
  {{ query }}
{% endaction %}{% endraw %}
```

This task generates a bulkOperationRunQuery mutation that adjusts the inventory levels for multiple variants at a specified location. The mutation is constructed using Liquid iteration over an array of variant objects.

Using bulk operations can significantly reduce the number of API requests needed to process large datasets, improving the efficiency and reliability of your tasks.

### 9.4. Migrating templates from Shopify

If you have existing Liquid templates in Shopify, like email notification templates or order printer templates, you can migrate them to Mechanic to use in your tasks.

The process involves copying the Liquid code from Shopify and pasting it into a Mechanic task, then making a few adjustments to account for differences in the available Liquid objects and filters.

Here are some common changes you'll need to make:

1. Replace Shopify-specific Liquid objects with their Mechanic equivalents. For example, replace {{ shop.name }} with {{ shop.domain }}.

2. Remove any Shopify-specific Liquid tags that aren't supported in Mechanic, like {% raw %}{% section %}{% endraw %} or {% raw %}{% form %}{% endraw %}.

3. Adjust any Liquid filters that work differently in Mechanic. For example, the money filter in Mechanic doesn't include the currency symbol by default, so you'll need to use the money_with_currency filter instead.

4. Update any hardcoded URLs or asset paths to use Liquid objects instead. For example, replace "https://example.com/logo.png" with {{ shop.domain | append: "/logo.png" }}.

Here's an example of a Shopify order confirmation email template migrated to Mechanic:

```liquid
{% raw %}{% capture email_body %}
  <h1>Thank you for your order!</h1>
  <p>Hi {{ order.customer.first_name }},</p>
  <p>We've received your order #{{ order.name }} and will begin processing it right away.</p>
  
  <h2>Order Summary</h2>
  <table>
    <thead>
      <tr>
        <th>Product</th>
        <th>Quantity</th>
        <th>Price</th>
      </tr>
    </thead>
    <tbody>
      {% for line_item in order.line_items %}
        <tr>
          <td>{{ line_item.title }}</td>
          <td>{{ line_item.quantity }}</td>
          <td>{{ line_item.price | money_with_currency }}</td>
        </tr>
      {% endfor %}
    </tbody>
  </table>

  <p>
    Subtotal: {{ order.subtotal_price | money_with_currency }}<br>
    Shipping: {{ order.shipping_price | money_with_currency }}<br>
    Tax: {{ order.tax_price | money_with_currency }}<br>
    <strong>Total: {{ order.total_price | money_with_currency }}</strong>
  </p>

  <p>We'll send you another email when your order ships. If you have any questions, feel free to contact us at {{ shop.email }}.</p>
  
  <p>Thanks again,<br>{{ shop.name }}</p>
{% endcapture %}

{% action "email" %}
  {
    "to": {{ order.email | json }},
    "subject": "Thank you for your order!",
    "body": {{ email_body | strip_newlines }}
  }
{% endaction %}{% endraw %}
```

This template uses the order object to populate the email content, just like it would in Shopify. The main differences are:

1. The shop Liquid object uses domain instead of name.
2. The money_with_currency filter is used instead of money.
3. The email is sent using the Mechanic Email action instead of Shopify's built-in email system.

Migrating templates from Shopify is a great way to leverage existing work and maintain consistency across your customer communications.

### 9.5. Securing webhooks

If your Mechanic task is subscribing to webhooks from external services, it's important to verify that incoming webhook requests are authentic and haven't been tampered with.

Many webhook providers include a signature or hash in the webhook request headers that can be used to verify the integrity of the request. The exact implementation varies by provider, but the general process is:

1. The webhook provider generates a signature using a secret key and the request payload.
2. The signature is included in the webhook request headers.
3. Your Mechanic task retrieves the signature from the headers and the payload from the request body.
4. Your task generates its own signature using the shared secret key and the payload.
5. If the signatures match, the request is authentic. If not, the request may have been tampered with and should be rejected.

Here's an example of verifying a webhook signature in a Mechanic task:

```liquid
{% raw %}{% assign shared_secret = "your-shared-secret-here" %}
{% assign payload = event.data | json %}
{% assign expected_signature = payload | hmac_sha256: shared_secret %}
{% assign provided_signature = event.headers["X-Signature"] %}

{% if expected_signature != provided_signature %}
  {% error "Invalid webhook signature" %}
{% endif %}{% endraw %}
```

This task does the following:

1. Defines the shared secret key used to generate the signature.
2. Retrieves the webhook payload from the event data and converts it to a JSON string.
3. Generates the expected signature using the hmac_sha256 filter with the shared secret and payload.
4. Retrieves the provided signature from the X-Signature header in the event.
5. Compares the signatures and raises an error if they don't match.

If the signatures match, the task continues processing the webhook as normal.

It's crucial to keep the shared secret key, well, secret. If an attacker gains access to the key, they could generate valid signatures for forged webhook requests. Always store secret keys securely and never include them in task code that's shared publicly.

### 9.6. Monitoring Mechanic

As your Mechanic account grows and your tasks become more critical to your business operations, it's important to monitor the health and performance of your tasks.

Mechanic provides several tools for monitoring your account:

1. The Activity Log shows a real-time view of all events, task runs, and action runs in your account. You can filter the log by event topic, task, or status to drill down into specific areas of interest.

2. The Task History page for each task shows a list of all runs of that task, including the event that triggered the run, the run status, and the generated actions.

3. The Mechanic API allowsyou to programmatically retrieve information about your account, including events, tasks, and runs. You can use this to build custom monitoring and alerting systems.

In addition to Mechanic's built-in tools, you can also use external monitoring services to keep an eye on your tasks. Here are a few ideas:

1. Use an uptime monitoring service to periodically check the status of your Mechanic account and alert you if it becomes unresponsive.

2. Set up log-based alerts to notify you if certain keywords appear in your task logs, like "error" or "exception".

3. Create a task that subscribes to the mechanic/actions/perform topic and sends a notification (via email, Slack, etc.) if an action fails.

4. Use a service like Datadog or New Relic to collect and visualize metrics about your Mechanic account, like event throughput, task run duration, and action success rates.

Here's an example task that sends a Slack notification when an action fails:

```liquid
{% raw %}{% if event.topic == "mechanic/actions/perform" %}
  {% assign action = event.data.action %}
  {% assign run = action.run %}

  {% if run.errors %}
    {% capture message %}
      :warning: Action failed in task "{{ task.name }}":
      
      Action: {{ action.type }}
      Error: {{ run.error }}
      Event: {{ event.id }}
    {% endcapture %}

    {% action "http" %}
      {
        "method": "POST",
        "url": "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
        "body": {
          "text": {{ message | strip_newlines | json }}
        }
      }
    {% endaction %}
  {% endif %}
{% endif %}{% endraw %}
```

This task does the following:

1. Subscribes to the mechanic/actions/perform topic to be notified when actions are performed.
2. Checks if the action run has any errors.
3. If so, constructs a Slack message with details about the failure, including the task name, action type, error message, and originating event ID.
4. Sends the message to a Slack webhook URL.

You can customize this task to send notifications to other channels, like email or SMS, and include additional information that's relevant to your team.

Monitoring your Mechanic account is an essential part of running critical automations. By proactively identifying and resolving issues, you can ensure that your tasks are always running smoothly and reliably.

### 9.7. Interacting with external APIs

One of Mechanic's strengths is its ability to integrate with external services via their APIs. You can use Mechanic tasks to send data to and retrieve data from virtually any web-based API.

The HTTP action is the primary tool for making external API requests in Mechanic. It supports all standard HTTP methods (GET, POST, PUT, DELETE, etc.) and allows you to specify custom headers and request bodies.

Here's an example task that makes a POST request to an external API with a JSON payload:

```liquid
{% raw %}{% assign payload = hash %}
{% assign payload["name"] = customer.name %}
{% assign payload["email"] = customer.email %}
{% assign payload["orders_count"] = customer.orders_count %}

{% action "http" %}
  {
    "method": "POST",
    "url": "https://api.example.com/customers",
    "headers": {
      "Content-Type": "application/json",
      "Authorization": "Bearer {{ options.api_key }}"
    },
    "body": {{ payload | json }}
  }
{% endaction %}{% endraw %}
```

This task does the following:

1. Constructs a JSON payload containing information about the customer, using Liquid's hash object.
2. Makes a POST request to the external API endpoint using the HTTP action.
3. Includes a Content-Type header to indicate that the request body is JSON-formatted.
4. Includes an Authorization header with a bearer token, which is pulled from a task option called api_key.
5. Sends the JSON payload as the request body.

When interacting with external APIs, it's important to handle errors and edge cases gracefully. Many APIs use HTTP status codes to indicate the success or failure of a request, with codes in the 200 range indicating success and codes in the 400 and 500 ranges indicating errors.

You can use the response status code in a mechanic/actions/perform task to conditionally handle different outcomes:

```liquid
{% raw %}{% if event.topic == "mechanic/actions/perform" and actions.last.type == "http" %}
  {% assign response = actions.last.run.result %}

  {% if response.status >= 200 and response.status < 300 %}
    {% log "API request succeeded" %}
  {% elsif response.status >= 400 and response.status < 500 %}
    {% log "API request failed with client error" %}
  {% elsif response.status >= 500 %}
    {% log "API request failed with server error" %}
  {% endif %}
{% endif %}{% endraw %}
```

This task logs a different message depending on the status code of the HTTP response, which can be helpful for debugging and monitoring API integrations.

Many APIs also rate limit requests to prevent abuse and ensure fair usage. If you exceed the rate limit, the API will typically return a 429 Too Many Requests status code.

To avoid hitting rate limits, you can use techniques like:

1. Caching frequently-accessed data to reduce the number of API requests.
2. Using bulk endpoints to retrieve multiple resources in a single request.
3. Limiting the frequency of requests using Liquid's date filters and Mechanic's cache.

Here's an example that caches API responses and only makes a new request once per hour:

```liquid
{% raw %}{% assign cache_key = "api_response_" | append: "now" | date: "%Y-%m-%dT%H" %}
{% assign cached_response = cache[cache_key] %}

{% if cached_response %}
  {% log "Using cached API response" %}
  {% assign response = cached_response %}
{% else %}
  {% log "Making new API request" %}
  
  {% action "http" %}
    {
      "method": "GET",
      "url": "https://api.example.com/data"
    }
  {% endaction %}

  {% if event.topic == "mechanic/actions/perform" and actions.last.type == "http" %}
    {% action "cache" %}
      {
        "set": {
          "key": {{ cache_key | json }},
          "value": {{ actions.last.run.result | json }}
        }
      }
    {% endaction %}
  {% endif %}
{% endif %}{% endraw %}
```

This task does the following:

1. Generates a cache key based on the current date and hour.
2. Checks the cache for a response matching that key.
3. If found, uses the cached response.
4. If not found, makes a new API request using the HTTP action.
5. In the mechanic/actions/perform callback, caches the API response using the generated cache key.

This ensures that the task will only make one API request per hour, regardless of how often the task runs. The cached responses will automatically expire after an hour, ensuring that the data stays fresh.

Integrating with external APIs is a powerful way to extend the capabilities of your Mechanic tasks. By leveraging the vast ecosystem of web services, you can build automations that connect Shopify with your other business systems and processes.

## 10. The Mechanic Platform

In this section, we'll take a closer look at the Mechanic platform itself, including its infrastructure, data policies, pricing, and support resources.

### 10.1. Mechanic's infrastructure

Mechanic runs on a robust and scalable infrastructure to ensure high availability and performance for all users.

The core components of Mechanic's infrastructure are:

1. Event ingestion: Mechanic uses a high-throughput event ingestion pipeline to capture events from Shopify and other sources. This pipeline is designed to handle large spikes in event volume without dropping events.

2. Task runner: The task runner is responsible for executing task code in response to events. It's a distributed system that can scale horizontally to handle increased workloads.

3. Action performer: The action performer is responsible for executing the actions generated by tasks. Like the task runner, it's a distributed system that can scale horizontally.

4. Data storage: Mechanic uses a combination of databases and caches to store task definitions, configurations, and run histories. All data is encrypted at rest and backed up regularly.

5. User interface: The Mechanic user interface is a web application that allows users to create, manage, and monitor their tasks. It's built using modern web technologies and is designed for performance and usability.

Mechanic's infrastructure is hosted on Amazon Web Services (AWS) and leverages many of AWS's managed services, like EC2, S3, and RDS. This allows Mechanic to focus on building features and functionality rather than managing low-level infrastructure.

Mechanic also employs a variety of security best practices to protect user data, including:

1. Encrypting all data in transit using HTTPS/TLS.
2. Encrypting all data at rest using AES-256 encryption.
3. Regularly patching and updating all systems to address security vulnerabilities.
4. Restricting access to production systems to authorized personnel only.
5. Conducting regular security audits and penetration tests.

For more details on Mechanic's security practices, please see the Security section of the Mechanic website.

### 10.2. Data residency and retention

Mechanic stores all user data in the United States. This includes task definitions, configurations, and run histories.

Mechanic retains task run data for 30 days by default. This includes the event that triggered the run, the task code that was executed, and any actions that were generated.

Users can request longer retention periods for compliance or auditing purposes. Please contact Mechanic support to discuss your specific needs.

Mechanic also complies with the General Data Protection Regulation (GDPR) and the California Consumer Privacy Act (CCPA). For more details on how Mechanic handles user data, please see the Privacy Policy.

### 10.3. Pricing and billing

Mechanic uses a usage-based pricing model. Users are charged based on the number of task runs they execute each month.

The base price is $29 per month, which includes 10,000 task runs. Additional task runs are charged at $0.002 per run.

Mechanic also offers a "pay what feels good" pricing option. Under this option, users can choose to pay any amount above the base price that feels fair and sustainable for their business.

Billing is handled through Shopify's app billing system. Users can manage their billing settings and view their invoices directly from the Shopify admin.

For more details on Mechanic's pricing and billing, please see the Pricing page on the Mechanic website.

### 10.4. Support and community resources

Mechanic offers several resources for users to get help and connect with the community:

1. Documentation: The Mechanic documentation site (docs.usemechanic.com) contains comprehensive guides, tutorials, and reference materials for using Mechanic.

2. Community forum: The Mechanic community forum (community.usemechanic.com) is a place for users to ask questions, share tips and tricks, and showcase their automations.

3. Slack group: The Mechanic Slack group (mechanic.slack.com) is a real-time chat community for Mechanic users and developers. It's a great place to get quick answers to questions and stay up-to-date on the latest Mechanic news and features.

4. Email support: Users can email support@usemechanic.com for personalized assistance with their Mechanic accounts and tasks. The Mechanic support team typically responds within 24 hours.

5. Twitter: The @usemechanic Twitter account posts updates, tips, and news about Mechanic. It's also a good place to reach out for quick questions or feedback.

In addition to these official resources, there are many community-led resources for learning and sharing about Mechanic, like blog posts, video tutorials, and open-source task libraries.

Mechanic is committed to fostering a vibrant and supportive community of users and developers. Whether you're just getting started with Mechanic or you're a seasoned automation expert, there are resources available to help you succeed.

## 11. Example Tasks and Tutorials

In this section, we'll explore some complete example tasks and tutorials that demonstrate the power and flexibility of Mechanic.

### 11.1. Auto-tagging orders and customers

One common use case for Mechanic is automatically adding tags to orders and customers based on certain criteria. This can be useful for segmentation, reporting, and personalization.

Here's an example task that adds a "high-value" tag to orders over $500, and a "vip" tag to customers who have placed more than 10 orders:

```liquid
{% raw %}{% if event.topic contains "shopify/orders" %}
  {% assign order = event.data %}

  {% if order.total_price > 50000 %}
    {% action "shopify" %}
      mutation {
        tagsAdd(id: {{ order.admin_graphql_api_id }}, tags: ["high-value"]) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}
  {% endif %}

  {% assign customer = order.customer %}

  {% if customer.orders_count > 10 %}
    {% action "shopify" %}
      mutation {
        tagsAdd(id: {{ customer.admin_graphql_api_id }}, tags: ["vip"]) {
          userErrors {
            field 
            message
          }
        }
      }
    {% endaction %}
  {% endif %}
{% endif %}{% endraw %}
```

This task does the following:

1. Subscribes to all Shopify order events.
2. Checks if the order total is greater than $500. If so, adds a "high-value" tag to the order using the tagsAdd mutation.
3. Retrieves the customer associated with the order.
4. Checks if the customer's order count is greater than 10. If so, adds a "vip" tag to the customer using the tagsAdd mutation.

You can customize the tag names and thresholds to match your business needs. You can also add additional criteria, like checking for specific product purchases or shipping locations.

### 11.2. Generating PDF invoices

Another common use case for Mechanic is generating custom PDF documents, like invoices, packing slips, or gift receipts.

Here's an example task that generates a PDF invoice when an order is created, and emails it to the customer:

```liquid
{% raw %}{% capture html %}
  <html>
    <body>
      <h1>Invoice</h1>
      <p>Order #{{ order.name }}</p>

      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>Quantity</th>
            <th>Price</th>
          </tr>
        </thead>
        <tbody>
          {% for line_item in order.line_items %}
            <tr>
              <td>{{ line_item.title }}</td>
              <td>{{ line_item.quantity }}</td>
              <td>{{ line_item.price | money }}</td>
            </tr>
          {% endfor %}
        </tbody>
      </table>

      <p>Subtotal: {{ order.subtotal_price | money }}</p>
      <p>Tax: {{ order.total_tax | money }}</p>
      <p>Total: {{ order.total_price | money }}</p>
    </body>
  </html>
{% endcapture %}

{% assign pdf_data = html | generate_pdf %}

{% action "email" %}
  {
    "to": {{ order.email | json }},
    "subject": "Invoice for order {{ order.name }}",
    "body": "Please see the attached invoice.",
    "attachments": {
      "invoice.pdf": pdf_data
    }
  }
{% endaction %}{% endraw %}
```

This task does the following:

1. Subscribes to the shopify/orders/create event.
2. Generates an HTML invoice template using the order data.
3. Converts the HTML to a PDF using the generate_pdf filter.
4. Sends an email to the customer with the PDF invoice attached.

You can customize the HTML template to match your brand and include additional information, like your company logo, address, and tax ID.

You can also modify the task to generate different types of PDFs based on the order tags or other criteria. For example, you could generate a gift receipt PDF if the order has a "gift" tag.

### 11.3. Sending order notifications

Mechanic can also be used to send custom notifications aboutorder events, like when an order is shipped, delivered, or returned.

Here's an example task that sends a Slack message when an order is fulfilled:

```liquid
{% raw %}{% if event.topic contains "shopify/orders/fulfilled" %}
  {% assign order = event.data %}
  {% assign fulfillment = order.fulfillments.last %}

  {% capture message %}
    Order {{ order.name }} has been fulfilled!

    Tracking Company: {{ fulfillment.tracking_company }}
    Tracking Number: {{ fulfillment.tracking_number }}
    Tracking URL: {{ fulfillment.tracking_url }}
  {% endcapture %}

  {% action "http" %}
    {
      "method": "POST",
      "url": "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
      "body": {
        "text": {{ message | strip_newlines | json }}
      }
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task does the following:

1. Subscribes to the shopify/orders/fulfilled event.
2. Retrieves the fulfilled order and the last fulfillment.
3. Constructs a Slack message with the order name and fulfillment tracking details.
4. Sends the message to a Slack webhook URL.

You can modify this task to send notifications to other channels, like SMS or a custom mobile app. You can also change the notification trigger to other order events, like when an order is placed, shipped, or returned.

### 11.4. Syncing inventory across locations

If you manage inventory across multiple locations, you can use Mechanic to keep your inventory levels in sync.

Here's an example task that copies inventory changes from one location to another:

```liquid
{% raw %}{% if event.topic contains "shopify/inventory_levels/update" %}
  {% assign inventory_level = event.data %}

  {% if inventory_level.location_id == options.source_location_id %}
    {% assign variant_id = inventory_level.inventory_item_id %}
    {% assign quantity = inventory_level.available %}

    {% action "shopify" %}
      mutation {
        inventoryAdjustQuantity(input: {
          inventoryLevelId: "gid://shopify/InventoryLevel/{{ variant_id }}_{{ options.target_location_id }}",
          availableDelta: {{ quantity }}
        }) {
          inventoryLevel {
            available
          }
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}
  {% endif %}
{% endif %}{% endraw %}
```

This task does the following:

1. Subscribes to the shopify/inventory_levels/update event.
2. Checks if the updated inventory level is for the source location specified in the task options.
3. If so, retrieves the variant ID and new quantity from the inventory level.
4. Adjusts the inventory quantity for the same variant at the target location using the inventoryAdjustQuantity mutation.

You'll need to create task options for source_location_id and target_location_id to specify which locations to sync.

You can extend this task to sync inventory across multiple locations by adding more target locations or using a more advanced sync logic. You can also add error handling to notify you if the inventory adjustment fails for any reason.

### 11.5. Integrating with third-party services

Mechanic's HTTP action makes it easy to integrate with virtually any web-based third-party service.

Here's an example task that adds new Shopify customers to a Mailchimp mailing list:

```liquid
{% raw %}{% if event.topic contains "shopify/customers/create" %}
  {% assign customer = event.data %}

  {% capture payload %}
    {
      "email_address": {{ customer.email | json }},
      "status": "subscribed",
      "merge_fields": {
        "FNAME": {{ customer.first_name | json }},
        "LNAME": {{ customer.last_name | json }}
      }
    }
  {% endcapture %}

  {% action "http" %}
    {
      "method": "POST",
      "url": "https://us1.api.mailchimp.com/3.0/lists/{{ options.mailchimp_list_id }}/members",
      "headers": {
        "Content-Type": "application/json",
        "Authorization": "apikey {{ options.mailchimp_api_key }}"
      },
      "body": {{ payload }}
    }
  {% endaction %}
{% endif %}{% endraw %}
```

This task does the following:

1. Subscribes to the shopify/customers/create event.
2. Constructs a JSON payload with the new customer's email address, subscription status, and merge fields for first name and last name.
3. Sends a POST request to the Mailchimp API to add the customer to a mailing list.
4. Includes the Mailchimp API key in the Authorization header and the list ID in the URL.

You'll need to create task options for mailchimp_api_key and mailchimp_list_id to store your Mailchimp credentials.

You can adapt this task to integrate with other email marketing services, like Klaviyo or Drip, by changing the API endpoint, payload format, and authentication method.

You can also use the HTTP action to integrate with CRMs, ERPs, accounting systems, and more. The possibilities are endless!

## 12. Best Practices and Tips

In this section, we'll share some best practices and tips for building efficient, reliable, and maintainable Mechanic tasks.

### 12.1. Optimizing task performance

As your Shopify store grows, the volume of events and task runs can increase significantly. To ensure that your tasks continue to run smoothly and efficiently, it's important to optimize their performance.

Here are some tips for optimizing task performance:

1. Use GraphQL instead of REST whenever possible. GraphQL allows you to request only the data you need, which can significantly reduce the amount of data transferred and processed.

2. Avoid using {% raw %}{% for %}{% endraw %} loops to iterate over large collections, like all orders or all products. Instead, use Shopify's bulk operations or pagination to process data in smaller batches.

3. Cache frequently-accessed data using Mechanic's cache action. This can reduce the number of API requests and improve response times.

4. Use Liquid's strip_newlines and strip_html filters to remove unnecessary whitespace and HTML tags from strings before processing or storing them.

5. Avoid using complex regular expressions or string manipulations in Liquid. If you need to do advanced string processing, consider using a JavaScript action instead.

6. Use Mechanic's asynchronous actions (like HTTP and email) to perform slow operations in the background, instead of blocking the task run.

7. Monitor your task runs using Mechanic's activity log and task history to identify performance bottlenecks and optimize accordingly.

### 12.2. Error handling and logging

Proper error handling and logging are essential for building robust and maintainable Mechanic tasks.

Here are some tips for error handling and logging:

1. Use Liquid's {% raw %}{% if %}{% endraw %} statements to check for null or empty values before accessing them. This can prevent "undefined method" errors and make your task code more resilient.

2. Use Mechanic's error action to raise explicit errors when something goes wrong. This will halt the task run and surface the error in the activity log.

3. Use Mechanic's log action to output debug messages and variable values. This can help you troubleshoot issues and understand how your task is processing data.

4. Use descriptive and consistent error and log messages. Include relevant context, like the event topic, task name, and any input data that may have caused the error.

5. Consider setting up external monitoring and alerting for critical tasks. You can use Mechanic's HTTP action to send task run data to a service like Datadog or Sentry for real-time error tracking and notifications.

Here's an example of error handling and logging in action:

```liquid
{% raw %}{% assign order = event.data %}

{% if order.email %}
  {% assign customer = shop.customers[order.email] %}

  {% if customer %}
    {% log "Found customer for order {{ order.name }}: {{ customer.id }}" %}
    {% action "shopify" %}
      mutation {
        tagsAdd(id: {{ customer.admin_graphql_api_id }}, tags: ["ordered"]) {
          userErrors {
            field
            message
          }
        }
      }
    {% endaction %}
  {% else %}
    {% error "Could not find customer for order {{ order.name }}" %}
  {% endif %}
{% else %}
  {% error "Order {{ order.name }} is missing an email address" %}
{% endif %}{% endraw %}
```

This task does the following:

1. Retrieves the order data from the event.
2. Checks if the order has an email address. If not, raises an explicit error.
3. Looks up the customer by email address.
4. If the customer is found, logs a debug message and adds an "ordered" tag to the customer.
5. If the customer is not found, raises an explicit error.

By adding error handling and logging statements throughout your task code, you can make it easier to diagnose and fix issues when they occur.

### 12.3. Testing and debugging tasks

Testing and debugging are critical steps in the task development process. They help ensure that your tasks are working as expected and can handle a variety of input data and edge cases.

Here are some tips for testing and debugging tasks:

1. Use Mechanic's preview feature to test your task code with sample event data. You can generate sample events from the task editor or use real events from your activity log.

2. Use Mechanic's log action to output variable values and debug messages. This can help you understand how your task is processing data and identify any unexpected behavior.

3. Use Mechanic's error action to raise explicit errors and halt task runs when something goes wrong. This can help you catch and fix issues early in the development process.

4. Test your tasks with a variety of input data, including edge cases and unexpected values. This can help you identify and handle potential issues before they occur in production.

5. Use Mechanic's task history and activity log to review past task runs and identify any errors or performance issues.

6. Consider creating a separate development or staging environment for testing tasks before deploying them to production. You can use Shopify's development stores or Mechanic's sandbox mode to create isolated testing environments.

Here's an example of using logs and errors for debugging:

```liquid
{% raw %}{% assign order = event.data %}

{% log "Processing order {{ order.name }}" %}

{% assign customer = shop.customers[order.email] %}

{% if customer %}
  {% log "Found customer: {{ customer.id }}" %}
{% else %}
  {% error "Could not find customer for order {{ order.name }}" %}
{% endif %}

{% for line_item in order.line_items %}
  {% log "Processing line item: {{ line_item.title }}" %}
  {% if line_item.quantity > 10 %}
    {% log "Large quantity detected: {{ line_item.quantity }}" %}
  {% endif %}
{% endfor %}

{% log "Finished processing order {{ order.name }}" %}{% endraw %}
```

This task does the following:

1. Logs a message when starting to process an order.
2. Looks up the customer by email address and logs the customer ID if found, or raises an error if not found.
3. Iterates over the order line items and logs a message for each one.
4. Logs a special message if a line item has a quantity greater than 10.
5. Logs a message when finished processing the order.

By adding log statements at key points in your task code, you can create a detailed record of how the task is processing data. This can be invaluable for debugging issues and understanding complex workflows.

### 12.4. Managing task versions

As you develop and refine your tasks over time, it's important to keep track of different versions and changes.

Here are some tips for managing task versions:

1. Use descriptive and consistent naming conventions for your tasks. Include the task purpose, any relevant Shopify resources (like "orders" or "customers"), and a version number or date.

2. Use Mechanic's task description field to provide a high-level overview of what the task does, including any key features or dependencies.

3. Use Mechanic's task notes field to document any changes or updates to the task, including bug fixes, performance improvements, or new features.

4. Use a version control system like Git to store and manage your task code. This allows you to track changes over time, revert to previous versions if needed, and collaborate with other developers.

5. Consider creating separate versions of your tasks for different environments, like development, staging, and production. This allows you to test changes in isolation before deploying them to production.

6. Use Mechanic's task export and import features to backup your tasks and share them with others. You can export tasks as JSON files and store them in a version control repository or shared drive.

Here's an example of documenting a task version:

```
# Order Tagging v1.2

This task automatically adds tags to orders based on their total price and payment status. It also logs a message in the activity log for each tagged order.

## Changelog

### v1.2 (2023-06-01)
- Added support for tagging orders based on payment status
- Improved error handling for orders with missing email addresses
- Updated to use Shopify API version 2023-04

### v1.1 (2023-05-15)
- Fixed a bug that caused some orders to be tagged multiple times
- Improved logging to include more details about each tagged order

### v1.0 (2023-05-01)
- Initial release
```

By keeping detailed records of your task versions and changes, you can make it easier to track down bugs, revert to previous versions if needed, and share your work with others.

### 12.5. Collaborating with other developers

Mechanic tasks are often developed and maintained by teams of developers, rather than individuals. To collaborate effectively with other developers, it's important to establish clear communication and workflow practices.

Here are some tips for collaborating with other developers on Mechanic tasks:

1. Use a version control system like Git to store and manage your task code. This allows multiple developers to work on the same codebase simultaneously and track changes over time.

2. Use a shared repository or drive to store exported task files and documentation. This makes it easy for developers to access and update the latest versions of tasks.

3. Establish clear naming and documentation conventions for your tasks. This helps ensure consistency and makes it easier for new developers to understand and work with existing tasks.

4. Use pull requests or code reviews to propose and review changes to task code. This helps catch bugs and ensure that changes meet the team's quality standards.

5. Use a project management tool like Trello or Asana to track task development, assign responsibilities, and communicate progress and issues.

6. Consider setting up a shared development or staging environment for testing tasks before deploying them to production. This allows developers to test changes in a controlled setting and catch any issues early.

7. Use Mechanic's activity log and task history to monitor task runs and identify any errors or performance issues. Assign developers to investigate and fix issues as they arise.

Here's an example of a pull request for a task change:

```
# Add support for tagging orders based on payment status

## Description
This pull request adds a new feature to the Order Tagging task that allows it to tag orders based on their payment status (paid, unpaid, etc.). It also includes some improvements to error handling and logging.

## Changes
- Added a new `payment_status` option to the task config
- Updated the task code to check the `payment_status` option and apply the appropriate tag
- Added error handling for orders with missing payment statuses
- Improved logging to include the payment status and applied tag for each order

## Testing
- Tested the task with orders in various payment states (paid, unpaid, partially_paid, etc.)
- Verified that the correct tags were applied to each order
- Verified that the activity log included the expected messages for each tagged order

## Deployment
- Deploy to staging environment for final testing
- Deploy to production environment once approved by the team
```

By using pull requests and code reviews, developers can collaborate on task changes in a structured and transparent way. This helps ensure that changes are well-tested, meet the team's quality standards, and are properly documented and communicated.

## 13. Troubleshooting Common Issues

In this section, we'll cover some common issues that you may encounter while working with Mechanic, and provide troubleshooting steps and solutions.

### 13.1. Task not running

If a task is not running when you expect it to, there are a few things to check:

1. Verify that the task is enabled in the Mechanic dashboard. Disabled tasks will not run, even if they are subscribed to events.

2. Check the task's event subscriptionsto make sure it is subscribed to the correct event topic(s). If the task is not subscribed to the event that you expect to trigger it, it will not run.

3. Check the task's Liquid code for syntax errors or invalid logic. If the task code contains errors, it may prevent the task from running or cause it to exit prematurely.

4. Check the activity log for any errors or warnings related to the task. If the task encountered an error during a previous run, it may have been disabled automatically to prevent further issues.

5. Check the Shopify API status page to see if there are any ongoing issues or outages that may be affecting event delivery or API access.

If you've checked all of the above and the task is still not running, try creating a new task with a simple event subscription and Liquid code (like {% raw %}{% log "Hello World" %}{% endraw %}) to see if that task runs. If the simple task runs but the original task does not, there may be an issue with the task's specific configuration or code.

### 13.2. Unexpected task behavior

If a task is running but not behaving as expected, there are a few things to check:

1. Verify that the task's Liquid code is implementing the intended logic correctly. It's easy to make mistakes with Liquid syntax or logic, especially when dealing with complex data structures or control flow.

2. Check the task's preview output to see if it matches your expectations. If the preview output is incorrect, there may be an issue with the task's Liquid code or input data.

3. Add log statements to the task code to output key variable values and debug messages. This can help you identify where the task is deviating from the expected behavior.

4. Check the activity log for any errors or warnings related to the task. If the task encountered an error during a previous run, it may have skipped some actions or exited prematurely.

5. Verify that the task is using the correct Shopify API version and endpoints. If the task is using an outdated API version or deprecated endpoints, it may not behave as expected.

If you've checked all of the above and the task is still not behaving as expected, try isolating the issue by creating a simplified version of the task with hardcoded input data. If the simplified task behaves correctly, there may be an issue with the original task's input data or event subscriptions.

### 13.3. API rate limit errors

If a task is encountering API rate limit errors, it may be making too many API requests in a short period of time.

Here are some things to check and try:

1. Verify that the task is not making unnecessary API requests. For example, if the task is fetching data that it has already fetched before, it may be able to cache that data instead of making a new API request.

2. Check if the task can be optimized to use fewer API requests. For example, if the task is fetching data for multiple resources individually, it may be able to use a bulk operation or GraphQL query to fetch all the data in a single request.

3. Add retry logic to the task code to handle rate limit errors gracefully. If a request fails due to a rate limit error, the task can wait a short period of time and then retry the request.

4. Consider splitting the task into multiple smaller tasks that can run independently. This can help spread out the API requests over a longer period of time and reduce the likelihood of hitting rate limits.

5. Check if the task is running concurrently with other tasks that may be making API requests to the same resource. If multiple tasks are making requests to the same resource simultaneously, they may be more likely to hit rate limits.

If you've optimized the task code and are still encountering rate limit errors, you may need to contact Shopify support to request a rate limit increase for your store.

### 13.4. Liquid rendering issues

If a task is encountering issues with Liquid rendering, there may be syntax errors or invalid logic in the task's Liquid code.

Here are some things to check:

1. Verify that all Liquid tags and variables are properly formatted and closed. For example, make sure that all {% raw %}{% if %}{% endraw %} tags have a corresponding {% raw %}{% endif %}{% endraw %} tag.

2. Check that all Liquid variables are properly initialized and have the expected values. Use log statements to output variable values and debug messages.

3. Verify that the task is using the correct Liquid filters and syntax for the desired output. Refer to the Liquid documentation for details on available filters and syntax.

4. Check if the task is using any custom Liquid filters or tags that may not be supported by Mechanic. If so, you may need to find an alternative solution or implementation.

5. Verify that the task is properly handling any null or empty values in the input data. Use Liquid's {% raw %}{% if %}{% endraw %} tags to check for null or empty values before accessing them.

If you've checked all of the above and are still encountering Liquid rendering issues, try isolating the issue by creating a simplified version of the task with hardcoded input data. If the simplified task renders correctly, there may be an issue with the original task's input data or event subscriptions.

### 13.5. Contacting Mechanic support

If you've tried all of the above troubleshooting steps and are still encountering issues with your Mechanic tasks, don't hesitate to reach out to Mechanic support for assistance.

Here are some tips for contacting Mechanic support:

1. Gather as much information about the issue as possible, including:
   - The task name and ID
   - The event topic(s) that the task is subscribed to
   - The input data that the task is processing
   - Any error messages or log output from the task
   - Steps to reproduce the issue, if possible

2. Contact Mechanic support via email at support@usemechanic.com, or via the chat widget in the Mechanic dashboard.

3. Provide a clear and concise description of the issue, including any relevant information gathered in step 1.

4. Be patient and responsive to any follow-up questions or requests for additional information from the support team.

5. If possible, provide a simplified version of the task code that reproduces the issue. This can help the support team identify and diagnose the issue more quickly.

Mechanic support is available to help with any issues or questions related to the Mechanic platform or task development. Don't hesitate to reach out if you need assistance!

## 14. Additional Resources

In this final section, we'll provide some additional resources for learning more about Mechanic and Shopify development in general.

### 14.1. Mechanic documentation

- [Mechanic Docs](https://docs.usemechanic.com/): The official Mechanic documentation site, with guides, tutorials, and reference material for all aspects of the platform.
- [Mechanic Liquid Reference](https://docs.usemechanic.com/liquid/): A comprehensive reference for the Liquid templating language as used in Mechanic, including supported tags, filters, and objects.
- [Mechanic API Reference](https://docs.usemechanic.com/api/): Documentation for the Mechanic REST API, which allows you to programmatically manage tasks, webhooks, and other resources.

### 14.2. Shopify API references

- [Shopify API Documentation](https://shopify.dev/api): The official Shopify API documentation, with guides, tutorials, and reference material for all of Shopify's APIs, including REST, GraphQL, and Webhooks.
- [Shopify Liquid Reference](https://shopify.dev/api/liquid): A comprehensive reference for the Liquid templating language as used in Shopify themes and other contexts.
- [Shopify Developer Changelog](https://shopify.dev/changelog): A log of changes and updates to Shopify's APIs, tools, and other developer resources.

### 14.3. Liquid templating guides

- [Shopify Liquid Tutorial](https://shopify.github.io/liquid/): An interactive tutorial for learning the basics of Liquid templating, with examples and exercises.
- [Liquid for Designers](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers): A guide to using Liquid in the context of designing Shopify themes, with tips and best practices.
- [Liquid Cheat Sheet](https://www.shopify.com/partners/shopify-cheat-sheet): A quick reference for common Liquid tags and filters, with examples.

### 14.4. Community resources

- [Mechanic Slack Community](https://usemechanic.com/slack): A public Slack workspace for Mechanic users and developers to connect, share knowledge, and get support.
- [Shopify Community Forums](https://community.shopify.com/): The official Shopify community forums, with discussions and resources for all aspects of running a Shopify store, including development and automation.
- [Shopify Partners Blog](https://www.shopify.com/partners/blog): A blog for Shopify partners and developers, with articles, tutorials, and news related to Shopify development and best practices.
- [Shopify Devs on Twitter](https://twitter.com/ShopifyDevs): The official Twitter account for Shopify developers, with news, updates, and resources related to Shopify development.

We hope that this user manual has been a helpful and comprehensive resource for learning how to use Mechanic to automate your Shopify store. If you have any feedback or suggestions for improving this manual, please don't hesitate to reach out to the Mechanic team at support@usemechanic.com.

Happy automating!