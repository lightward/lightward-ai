[Original URL: https://learn.mechanic.dev/platform/email/templates]

# Email templates

A Mechanic account may be configured with one or more email templates, used by the Email action to render email content using a Liquid that can be shared across tasks. Email templates have access to Liquid template variables named after each option in the Email action, including any custom options added by the task author.

Unless configured otherwise, each email will use the email template named "default", if it exists.

## Configuration

Navigate to your Mechanic settings (it's the "Settings" link in the upper right), and head to the "Email templates" tab. Click the "New email template" link to start editing your new template.

To learn more about formatting messages with HTML, CSS, and images, see Message formatting.

To pass custom variables along to the email template, specify them as additional options to the Email action. To learn more about this technique, see Creating template variables.

## Specifying a template

Mechanic will always default to using the template named "default", when present. Feel free to add additional templates – just remember to update your task(s) to use the appropriate template.

Here's an example email action, specifying a non-default template:

Copy

    {% action "email" %}
      {
        "to": "hello@example.com",
        "subject": "Hello world",
        "body": "It's a mighty fine day!",
        "template": "welcome"
      }
    {% endaction %}

## Migrating from Shopify

Shopify's notification templates may be manually migrated over to Mechanic. To learn more, see Migrating templates from Shopify to Mechanic.

Last updated 2022-04-11T10:27:58Z