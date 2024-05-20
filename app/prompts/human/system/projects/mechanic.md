Mechanic Comprehensive Documentation

1. Introduction
   1.1. Mechanic overview
        - Shopify development and automation platform
        - Tasks respond to events, generate actions
        - Liquid templating language for task code
   1.2. Core concepts
        - Events represent anything that happens
        - Tasks contain logic and configuration, respond to events
        - Actions are instructions for performing work with effects
        - Runs process events, tasks, and actions using queues

2. Events
   2.1. Event topics
        - Shopify, Mechanic, User, Third-party domains
        - Three-part format: domain/subject/verb
   2.2. Event data
        - Webhook payload for Shopify events
        - Custom data for User events
   2.3. Parent and child events
        - Event action generates child events
        - mechanic/actions/perform subscription generates child events
        - Access parent event data using event.parent

3. Tasks
   3.1. Subscriptions
        - Signal task's interest in specific event topics
        - Delays/offsets for scheduling (e.g., +1.hour)
        - Parsed for Liquid
   3.2. Code
        - Liquid template rendering JSON objects (actions, logs, errors)
        - Access to environment variables (e.g., shop, event, options)
   3.3. Options
        - User configuration via options object
        - Option flags control form elements and data types
        - Parsed for Liquid, allowing dynamic options based on user input
   3.4. Previews
        - Demonstrate task's intended actions
        - Importance for users, developers, and Mechanic platform
        - Defined preview events and stub data for controlled previews
   3.5. Shopify API version
        - Each task configured with a specific Shopify API version
        - Used for all Shopify API interactions related to the task
        - Automatic upgrades and deprecation warnings
   3.6. Advanced settings
        - Documentation (Markdown)
        - JavaScript for online store and order status pages
        - Action run sequence control

4. Actions
   4.1. Echo
        - Returns provided options, useful for testing/debugging
   4.2. Email
        - Sends transactional email with support for templates and attachments
   4.3. Event
        - Generates custom user events for complex workflows and scheduling
   4.4. Files
        - Generates files using file generators, provides temporary URLs
   4.5. FTP
        - Uploads and downloads files via FTP, FTPS, or SFTP
   4.6. HTTP
        - Performs HTTP requests to any URL, supports authentication and files
   4.7. Shopify
        - Interacts with Shopify Admin API (REST and GraphQL)
   4.8. Integrations
        - Shopify Flow, Report Toaster

5. Liquid
   5.1. Basics
        - Syntax, whitespace, data types, operators, filters
   5.2. Control flow
        - Conditions (if, unless, else, elsif, case)
        - Iteration (for, break, continue)
   5.3. Mechanic tags
        - action, error, log
   5.4. Mechanic filters
        - Data, string, math, array, hash filters
   5.5. Mechanic objects
        - shop, event, cache, task, options, action

6. Shopify Interaction
   6.1. Reading data
        - Liquid objects (limited to REST API representation)
        - GraphQL in Liquid (shopify filter, pagination, bulk operations)
        - Bulk operations (query, polling, data retrieval)
   6.2. Writing data
        - Shopify action (GraphQL mutations, REST API)
   6.3. API rate limit
        - Awareness and management by Mechanic
        - Optimization techniques (GraphQL, bulk operations)
   6.4. API versions
        - Per-task configuration
        - Deprecation warnings and automatic upgrades

7. Techniques
   7.1. Responding to action results
        - mechanic/actions/perform subscription
        - Inspecting action context and result
   7.2. Preventing action loops
        - Conditional checks and timestamps
   7.3. Securing Mechanic webhooks
        - CORS support
        - Signature generation and validation
        - Idempotent task code and timestamp-based signatures
   7.4. Monitoring
        - Platform status and alerts
        - Task-specific monitoring using error events and external services
   7.5. Tagging Shopify resources
        - GraphQL (recommended) and REST API approaches
        - Logging results and avoiding overwriting tags
   7.6. Working with external APIs
        - Loading data into Mechanic (HTTP, FTP, webhooks, email)
        - Writing data to external services (HTTP, FTP, cache endpoints)

8. Resources
   8.1. Task library
        - Compendium of automation tasks and documentation
        - Open-source, community-driven
        - Requesting and contributing tasks
   8.2. Slack community
        - Collaboration, support, and knowledge sharing
   8.3. Tutorials
        - Step-by-step guides for common use cases and techniques

9. Policies
   9.1. Data residency and retention
        - US-based storage, encrypted volumes
        - Event retention periods and deletion process
   9.2. Plans
        - Unlimited tasks, events, and runs for all accounts
        - Trial periods and billing
   9.3. Pricing
        - Pay-what-feels-good pricing policy
        - Factors and considerations for pricing

This condensed documentation provides a comprehensive overview of Mechanic's features, concepts, and usage, optimized for efficient absorption and application by a future AI system. It covers core functionality, Liquid templating, Shopify integration, advanced techniques, resources, and policies. The information is structured and presented in a dense format, minimizing unnecessary explanations while ensuring all essential details are included.
