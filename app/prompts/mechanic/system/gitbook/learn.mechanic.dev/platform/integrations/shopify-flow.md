[Original URL: https://learn.mechanic.dev/platform/integrations/shopify-flow]

# Shopify Flow

Mechanic allows developers to integrate their work with Shopify Flow via an official Flow connector, sending triggers to Shopify using Mechanic's Flow action, and receiving events from Shopify using custom event topics in the user domain.

## What is Flow?

Flow is Shopify's answer to automation for Plus merchants: a graphical tool that allows for defining automation using flowchart-like structures.

From Flow's app store listing:

> Shopify Flow is an ecommerce automation solution that was purpose-built to help solve the unique challenges that Shopify merchants face. With Flow, you can build workflows to automate tasks, campaigns, and processes within your store and across your apps.

### Flow terminology

As an automation tool itself, Flow has its own terms for the components of automation.

#### Workflow

A package of configuration, containing a trigger, zero or more conditions, and one or more actions. Analogous to a Mechanic task.

#### Trigger

An event from Shopify or another connector (like Mechanic), which can be used to set workflows. Analogous to a Mechanic event.

#### Condition

A logical check which evaluates some data (possibly provided by the trigger), and steers the workflow towards specific actions. Loosely analogous to the code in a Mechanic task.

#### Action

Work to be performed, at the conclusion of a workflow's run. Directly analogous to a Mechanic action.

Both Mechanic and Flow use the term "action"! When working on both of these platforms together, keep an eye out for this term, and make sure you understand which platform's definition is relevant.

## Connecting Mechanic

Mechanic's Flow connector works in both directions: Mechanic → Flow, and Flow → Mechanic.

- Beginning on the Mechanic side, the Flow action sends data to Flow, arriving in the form of a trigger, and setting off the Flow workflows configured there.
- Beginning on the Flow side, the Mechanic action sends data to Mechanic, arriving in the form of a new event, setting off the Mechanic tasks configured there.

### Mechanic → Flow

Shopify Flow workflows are triggered from the Mechanic side, using Mechanic's Flow action. There are four triggers to choose from: General, Customer, Order, and Product. Mechanic's Flow action can produce any one of these four triggers, depending on the action options given.

On the Flow side, workflows may be configured to listen for any of these four Mechanic triggers.

#### Triggers

- General Send user-defined data to a Shopify Flow workflow.
- Customer Send a customer ID to be pulled up in context in Shopify Flow. Send user-defined data to a Shopify Flow workflow.
- Order Send a order ID to be pulled up in context in Shopify Flow. Send user-defined data to a Shopify Flow workflow
- Product Send a product ID to be pulled up in context in Shopify Flow. Send user-defined data to a Shopify Flow workflow

#### User-defined data

All four triggers include the following user-defined data variables, given as options to the Flow action. If a variable is omitted from the action's options, Mechanic will still send it to Flow, using a default value.

#### Usage

To choose between trigger types, choose between defining exactly one specific Shopify resource ID (i.e. for a customer, order, or product, resulting in the appropriate resource trigger), or omitting a resource ID entirely (resulting in the General trigger).

Copy

    {% action "flow" %}
      {
        {% comment %}
          If you want your Mechanic Flow trigger to be associated
          with a Shopify resource, you may include its numeric ID
          below. Only one resource at a time is supported. Leave
          this out entirely to use the General Mechanic Flow trigger.
        {% endcomment %}
        "customer_id": 1234567890,
        "order_id": 1234567890,
        "product_id": 1234567890,
    
        {% comment %}
          Keep as many of the following as you like. Any omitted
          keys *will* be submitted anyway, using the default value
          given below. If you don't want to use Mechanic's default
          value, make sure to *keep* the key in place below, setting
          it to whatever you like.
        {% endcomment %}
        "user_boolean": false,
        "user_email": "hey@mechanic.invalid",
        "user_number": 0,
        "user_string": "",
        "user_url": "https://mechanic.invalid/"
      }
    {% endaction %}

On the Flow side, configure workflows to start with the appropriate Mechanic trigger.

### Flow → Mechanic

The Mechanic action, in Flow, sends new events to Mechanic.

| Option | Notes |
| --- | --- |
| 

Event topic

 | 

Required; must start with "user/", resulting in an event in the User domain.

 |
| 

Event data

 | 

Optional; must be valid JSON.

 |
| 

Task ID

 | 

Optional; restricts processing of the resulting event to a single Mechanic task. Note that the task must still subscribe to the event topic for it to receive these events.

 |

The resulting Mechanic event will have a topic and data reflecting the Flow action configuration. Event data is available to tasks via event.data, as usual. (For more on how to use event data, see Event object.)

When using Flow's template variables for event data, remember to use the json Liquid filter as necessary, for making template variables safe for use in event data. Here's an example of event data, using template variables and the json filter:

Copy

    {
      "customer_email": {{ customer.email | json }},
      "customer_note": {{ customer.note | json }}
    }

If the event data configuration results in invalid JSON, the resulting Mechanic event will contain data reflecting the JSON error encountered. Here's an example:

Copy

    {
      "__error": {
        "message": "An event was received from Flow with invalid JSON in its event data. Check the originating workflow's configuration and resolve the issue there. (Hint: the `json` Liquid filter is often useful in cases like this!)",
        "invalid_event_data_json": "{\n \"user_boolean\": true,\n \"user_email\": \"heyhey@mechanic.invalid\",\n \"user_number\": 5,\n \"user_string\": \"asdfasdf\",\n \"user_url\": \"https://google.com/\",\n \"mechanic_task_id\": \"6c461365-ae83-46c4-b33e-a0d7c81b03d5\",\n \"mechanic_event_topic\": \"mechanic/user/trigger\",\n \"mechanic_event_inspector_url\": \"https://mechanic-dev-isaac.myshopify.com/admin/apps/mechanic-dev-isaac/~/events/659df64b-7622-4bc4-924c-dda268c737b2?task_run_id=cd49135a-cdcc-452b-9338-4fa3288bd577\",,,\n}"
      }
    }

Last updated 2023-07-28T19:51:48Z