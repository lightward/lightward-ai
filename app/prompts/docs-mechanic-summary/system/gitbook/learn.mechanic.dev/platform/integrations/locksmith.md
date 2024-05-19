# Locksmith

Access control, for anything in your online store :)

### What is Locksmith?

As a tool, Locksmith's power comes from a super-versatile yet super-simple idea: locks to protect your content, and keys to let different people in. Locksmith is made by Lightward (us) the same makers as Mechanic. Give Locksmith a try today!

Once you've locked something, use keys to grant access if the customer…

- has a certain tag
- is signed in
- gives a certain passcode
- arrives via a secret link
- is not signed in
- does not have a certain tag
- gives one of many passcodes
- subscribes to your Mailchimp list or newsletter
- subscribes to your Klaviyo list or newsletter
- has one of many email addresses
- the customer's email contains something specific
- has purchased a specific product
- has placed at least x orders
- has a certain product in their cart
- has a certain variant in their cart
- has at least $x in their cart
- has a certain IP address
- is visiting from a certain country
- is visiting before a certain date and time
- is visiting after a certain date and time

Or, grant access using any custom condition by using a little Liquid code.

### Locksmith --\> Mechanic Integration

Every time access is granted to a resource on a store using Locksmith, an event is sent to Mechanic with the following payload for the locksmith/sessions/ping event topic

locksmith/sessions/ping

Copy

    "event": {
        "keys": [
          {
            "_id": 74,
            "options": {
              "inverse": false,
              "force_open": null
            },
            "conditions": [
              {
                "_id": 100,
                "type": "passcode",
                "options": {
                  "passcode": "hello",
                  "passcode_uses_left": null,
                  "input_prompt": null,
                  "input_masked": false,
                  "customer_remember": true,
                  "customer_autotag": null
                }
              }
            ],
            "lock": {
              "_id": 86,
              "_title": "Short Sleeve T-Shirt",
              "_has_resource": true,
              "_resource_path": "products/short-sleeve-t-shirt",
              "_resource_url": "https://example.myshopify.com/products/short-sleeve-t-shirt",
              "_resource_admin_url": "https://example.myshopify.com/admin/products/756455899231",
              "_resource_type_for_humans": "product",
              "_resource_description": "A product, with the handle \"short-sleeve-t-shirt\"",
              "_updated_at": "2018-06-21T20:52:42.111Z",
              "_notices": [
                {
                  "status": "info",
                  "title": "This product will still appear in search results and collection lists.",
                  "description": "To change this, update the lock settings."
                }
              ],
              "resource_id": 756455899231,
              "resource_type": "product",
              "resource_options": {},
              "enabled": true,
              "options": {
                "hide_links_to_resource": false,
                "hide_resource": false,
                "manual": false
              }
            }
          }
        ],
        "params": {
          "passcode(100)": "hello",
          "passcode": "hello"
        },
        "customer": {
          "id": 2056359493,
          "email": "test@example.com",
          "accepts_marketing": false,
          "created_at": "2015-12-07T00:50:51-05:00",
          "updated_at": "2018-06-21T18:08:21-04:00",
          "first_name": "Isaac",
          "last_name": "Bowen",
          "orders_count": 41,
          "state": "enabled",
          "total_spent": "119.99",
          "note": "",
          "verified_email": true,
          "phone": null,
          "tags": "bar, foobar, Wholesaler"
        },
        "cart_token": "b96b8309b1d4002bd5336644c79d3e80"
      }
    }

Webhooks can be enabled by visiting your Locksmith Settings page, and clicking "Enable Mechanic events" under the Extensions heading:

Please email team@uselocksmith.com if you need help enabling webhooks to be sent to Mechanic.

[PreviousJudge.me](/platform/integrations/judge.me)[NextReport Toaster](/platform/integrations/report-toaster)

Last updated 2023-09-25T19:43:59Z