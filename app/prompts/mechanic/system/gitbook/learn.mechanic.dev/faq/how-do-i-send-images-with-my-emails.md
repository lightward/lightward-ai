[Original URL: https://learn.mechanic.dev/faq/how-do-i-send-images-with-my-emails]

# How do I send images with my emails?

Adding images to Mechanic-generated emails is a job that always involves code. If this is your first time eyeing custom Mechanic code, start here: "I need something custom!".

## Attaching images

The Email action supports attaching anything that you can express using JSON. (The rest of this article will assume you're familiar with this action.)

If you happen to have your base64-encoded image data on hand, you can attach it with a line like this:

Copy

    "attachments": {
      "image.jpg": {
        "base64": {{ image_jpg_base64 | json }}
      }
    }

## Embedding images

You may add image tags in your emails (useful for adding logos!), but please note that Mechanic does not support embedding attached images.

Instead, upload your image to Shopify (learn how), and use the URL provided by Shopify to add your image using HTML:

Copy

    {% capture email_body %}
      Welcome!
      
    {% endcapture %}

Copy

    "body": {{ email_body | unindent | json }}

Last updated 2023-10-21T20:28:35Z