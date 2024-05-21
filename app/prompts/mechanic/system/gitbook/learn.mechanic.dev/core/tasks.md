[Original URL: https://learn.mechanic.dev/core/tasks]

# Tasks

In Mechanic, a task is a bundle of logic and configuration, that responds to and interprets events. The result of a task can define actions, which are the task's opportunities to have an effect on the world.

A task responds to events based on its subscriptions. When an event is received that matches a subscription, the task processes the event using its code. The code has access to the event data; it also has access to the user's task configuration, through options. Task code is written in Liquid, and is responsible for rendering a series of JSON objects (including action, error, and log objects), defining work to be performed once task rendering is complete.

A task uses its preview to communicate ahead of time the work it intends to do. Previews are important for users, and are also important for Mechanic itself – Mechanic looks to the task preview to understand what permissions a task requires.

Tasks may be written from scratch, or installed from the Mechanic library (available in-app and on GitHub). Once installed, a task's code may be modified at any time.

Working on getting better at task-writing? See Practicing writing tasks, and Writing a high-quality task.

## Example

This very basic task subscribes to shopify/customers/create, and renders an Email action, using an email subject and body taken from user-configured options.

SubscriptionsCodeExport

Copy

    shopify/customers/create

Copy

    {% action "email" %}
      {
        "to": {{ options.email_recipient__email_required | json }},
        "subject": {{ options.email_subject__required | json }},
        "body": {{ options.email_body__multiline_required | newline_to_br | json }},
        "from_display_name": {{ shop.name | json }}
      }
    {% endaction %}

Copy

    {"name":"Customer signup alerts","options":{"email_recipient __email_required":"aesha@example.com","email_subject__ required":"A new customer has signed up: {{ customer.email }}","email_body __multiline_required":"Hi! View this customer's details online:\n\nhttps://{{ shop.domain }}/admin/customers/{{ customer.id }}\n\n-Mechanic"},"script":"{% action \"email\" %}\n {\n \"to\": {{ options.email_recipient__ email_required | json }},\n \"subject\": {{ options.email_subject __required | json }},\n \"body\": {{ options.email_body__ multiline_required | newline_to_br | json }},\n \"from_display_name\": {{ shop.name | json }}\n }\n{% endaction %}","subscriptions":["shopify/customers/create"],"online_store_javascript":null,"order_status_javascript":null,"docs":null,"subscriptions_template":"shopify/customers/create","shopify_api_version":"2022-04","liquid_profiling":false,"perform_action_runs_in_sequence":false,"halt_action_run_sequence_on_error":false,"preview_event_definitions":[]}

Last updated 2023-08-13T23:23:57Z