# Judge.me

### What is Judge.me?

Judge.me helps you collect and display reviews about your products and Shopify store. This increases your conversion rate, organic traffic, and buyer engagement by leveraging your user-generated content.

### Judge.me --\> Mechanic

Judge.me sends Mechanic events when a new review is created (judgeme/review/create) and when a review is updated (judgeme/review/updated).

The data for each review is available in an environment variable called review. Its contents exactly mirror event.data.review.

#### Event data samples

judgeme/review/created

Copy

    {
      "event": "review/created",
      "platform": "shopify",
      "review": {
        "body": "fulfiment",
        "created_at": "2019-05-02T08:39:09+00:00",
        "curated": "ok",
        "featured": false,
        "hidden": false,
        "id": 434,
        "ip_address": null,
        "pictures": [
          {
            "urls": {
              "small": "https://small",
              "compact": "https://compact",
              "huge": "https://huge",
              "original": "https://original"
            },
            "hidden": false
          }
        ],
        "product_external_id": 0,
        "rating": 5,
        "reviewer": {
          "accepts_marketing": true,
          "email": "o+import11@o.com",
          "external_id": null,
          "id": 602,
          "name": "ob ",
          "phone": null,
          "source_email": "o@o.com",
          "tags": null,
          "unsubscribed_at": null
        },
        "source": "admin",
        "title": null,
        "updated_at": "2019-05-02T08:39:09+00:00",
        "verified": "not-yet"
      },
      "shop_domain": "foobar.myshopify.com"
    }

judgeme/review/updated

Copy

    {
      "event": "review/updated",
      "platform": "shopify",
      "review": {
        "body": "fulfiment",
        "created_at": "2019-05-02T08:39:09+00:00",
        "curated": "ok",
        "featured": false,
        "hidden": false,
        "id": 434,
        "ip_address": null,
        "pictures": [
          {
            "urls": {
              "small": "https://small",
              "compact": "https://compact",
              "huge": "https://huge",
              "original": "https://original"
            },
            "hidden": false
          }
        ],
        "product_external_id": 0,
        "rating": 5,
        "reviewer": {
          "accepts_marketing": true,
          "email": "o+import11@o.com",
          "external_id": null,
          "id": 602,
          "name": "ob ",
          "phone": null,
          "source_email": "o@o.com",
          "tags": null,
          "unsubscribed_at": null
        },
        "source": "admin",
        "title": null,
        "updated_at": "2019-05-02T08:39:09+00:00",
        "verified": "not-yet"
      },
      "shop_domain": "foobar.myshopify.com"
    }

Requires enabling the Mechanic integration within Judge.me; see Judge.me's integration announcement.

Last updated 2023-07-28T19:44:59Z