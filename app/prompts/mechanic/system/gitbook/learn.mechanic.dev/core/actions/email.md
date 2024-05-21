[Original URL: https://learn.mechanic.dev/core/actions/email]

# Email

The Email action is for sending email. ✅ It supports the store's email templates, and supports attachments constructed by file generators.

## Restrictions

Mechanic sends email via Postmark, our email provider. Currently, Mechanic only supports Postmark's transactional message stream, which means that marketing and other bulk mail may not be sent. To learn more about what is and isn't a transactional message, see Postmark's article: "What are Transactional emails?".

## Options

| 

Option

 | 

Description

 |
| 

to

 | 

Required; an array or comma-delimited string of recipient addresses

 |
| 

subject

 | 

Required; a string specifying the message subject

 |
| 

body

 | 

Required; an HTML string of body content; supports HTML and CSS

 |
| 

cc

 | 

Optional; an array or comma-delimited string of cc addresses

 |
| 

bcc

 | 

Optional; an array or comma-delimited string of bcc addresses

 |
| 

reply\_to

 | 

Optional; a single reply-to address

 |
| 

from\_display\_name

 | 

Optional; a string controlling the name (but not the address) of the sender

 |
| 

template

 | 

Optional; a string naming an email template from the current Mechanic account

 |
| 

attachments

 | 

Optional; an object specifying files to attach, using file generators

 |
| 

...

 | 

Additional options may be provided, and will be made available to email templates as variables, named after each option

 |

## Message formatting

### HTML and CSS

Mechanic parses each email body for HTML and CSS, allowing authors to use \ tags without having to think about email client compatibility.

If you're simply trying to add formatted text and aren't ready to dig into the code yourself, try using a tool like wordtohtml.net to quickly generate usable HTML.

### Embedded images

Images may be embedded using the \<img\> tag, but must be hosted independently. Shopify provides basic file hosting, appropriate for uploading images for use with Mechanic emails. To learn more, see Uploading files to your website.

## Changing the sender address

This action only supports sending from a single address (regardless of the sender name, as controlled by the from\_display\_name option).

By default, the sender address is a Mechanic address based on the store's myshopify.com subdomain. For example, the store example.myshopify.com will default to having its mail sent from example@mail.usemechanic.com.

Changing the sender address involves adding it to the store's Mechanic account, and then configuring the email domain name with some DNS records for verification.

For more on this, see Custom email domain.

## Template

To achieve easily reusable headers and footers, Mechanic can be configured with one or more email templates, available in the Mechanic account settings. To learn more about configuring email templates, see Email templates.

To use a specific email template with the Email action, use the template option to specify the name of the desired email template.

### Creating email template variables

All options used with the Email action will be made available as Liquid variables for the email template. This means that standard options may be used, like {{ subject }} and {{ body }}, and also custom options: passing in an "order\_data" option, containing order data, may allow the email template to show the order name via {{ order\_data.name }}.

Note that custom options, like all task options, must be provided using standard JSON. This means that the data made available to email templates will be derived from plain JSON values.

For example, consider this action:

Copy

    {% action "email" %}
      {
        "to": "customer@example.com",
        "subject": "Thanks for your order!",
        "template": "order_acknowledgement",
        "order_data": {{ order | json }}
      }
    {% endaction %}

The template named "order\_acknowledgement" could include the following Liquid, and get the expected results:

Copy

    This is the first item: {{ order_data.line_items.first.title }}

But, because order\_data is a plain hash based entirely on JSON data, instead of being an enhanced order object (see Environment variables), the following Liquid usage would fail:

Copy

    Remember order {{ order_data.customer.orders.any.first.number }}, your first ever?

## Attachments

This action supports attachments given in Mechanic's file generator format. This structure allows the sender to construct a variety of files, including ad-hoc text-based files, PDFs rendered from HTML, files dynamically downloaded from external locations, and ZIP files containing any other files.

For more on this, see File generators.

## Examples

### Simple

LiquidJSON

Copy

    {% action "email" %}
      {
        "to": "hello@example.com",
        "subject": "Hello world",
        "body": "It's a mighty fine day!",
        "reply_to": {{ shop.customer_email | json }},
        "from_display_name": {{ shop.name | json }}
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "email",
        "options": {
          "to": "hello@example.com",
          "subject": "Hello world",
          "body": "It's a mighty fine day!",
          "reply_to": "store@example.com",
          "from_display_name": "Example Store"
        }
      }
    }

### Using HTML

LiquidJSON

Copy

    {% capture email_body %}
      <b>Hello!</b>
    
      It's fantastic to see you!
    {% endcapture %}
    
    {% action "email" %}
      {
        "to": "hello@example.com",
        "subject": "Hello world",
        "body": {{ email_body | unindent | strip | newline_to_br | json }}
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "email",
        "options": {
          "to": "hello@example.com",
          "subject": "Hello world",
          "body": "<b>Hello!</b><br />\n<br />\nIt's fantastic to see you!"
        }
      }
    }

### Using attachments

LiquidJSON

Copy

    {% action "email" %}
      {
        "to": "test@example.com",
        "subject": "An image test",
        "body": "Please see attached. :)",
        "attachments": {
          "a_configured_image_from_the_web.png": {
            "url": "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
          }
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "email",
        "options": {
          "to": "test@example.com",
          "subject": "An image test",
          "body": "Please see attached. :)",
          "attachments": {
            "a_configured_image_from_the_web.png": {
              "url": "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
            }
          }
        }
      }
    }

Last updated 2023-11-18T19:38:52Z