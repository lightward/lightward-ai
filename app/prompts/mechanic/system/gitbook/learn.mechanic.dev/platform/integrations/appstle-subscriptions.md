# Appstle Subscriptions

### What is Appstle Subscriptions?

Recurring orders, comprehensive subscription management tools, loyalty benefits, 1-click checkout, churn control, build-a-box, and more.

Learn more on the Appstle Subscriptions Shopify App Store listing.

### What does this integration do?

You can trigger your Mechanic tasks and take action when events happen in Appstle Subscriptions.

### Connecting Appstle Subscriptions to Mechanic

Enable the Mechanic integration under App integrations in the Appstle Subscriptions app:

### Appstle Subscriptions → Mechanic

After enabling the integration in the Appstle Subscriptions app, your events will be sent to Mechanic, and any tasks that subscribe to these event topics will receive the events:

#### Event topics

- appstle\_subscriptions/subscriptions/create Occurs when a subscription is created.
- appstle\_subscriptions/subscriptions/activate Occurs when a subscription is activated.
- appstle\_subscriptions/subscriptions/cancel Occurs when a subscription is cancelled.
- appstle\_subscriptions/subscriptions/next\_order\_date\_change Occurs when the next order data of a subscription is changed.
- appstle\_subscriptions/subscriptions/pause Occurs when a subscription is paused.
- appstle\_subscriptions/subscriptions/update Occurs when a subscription is updated.
- appstle\_subscriptions/billings/create Occurs when billing for a subscription is created.
- appstle\_subscriptions/billings/failure Occurs when billing for a subscription fails.
- appstle\_subscriptions/billings/interval\_change Occurs when billing for a subscription changes.

Sample event payload

Copy

    {
      "shop": "test-subscription.myshopify.com",
      "type": "subscription.created",
      "data": {
        "__typename": "SubscriptionContract",
        "id": "gid://shopify/SubscriptionContract/3344444",
        "createdAt": "2023-07-11T12:21:23Z",
        "updatedAt": "2023-07-11T12:21:23Z",
        "nextBillingDate": "2023-09-11T12:00:00Z",
        "status": "ACTIVE",
        "deliveryPrice": {
          "__typename": "MoneyV2",
          "amount": "0.0",
          "currencyCode": "USD"
        },
        "lastPaymentStatus": null,
        "billingPolicy": {
          "__typename": "SubscriptionBillingPolicy",
          "interval": "MONTH",
          "intervalCount": 2,
          "anchors": [
            
          ],
          "maxCycles": null,
          "minCycles": null
        },
        "deliveryPolicy": {
          "__typename": "SubscriptionDeliveryPolicy",
          "interval": "MONTH",
          "intervalCount": 2,
          "anchors": [
            
          ]
        },
        "lines": {
          "__typename": "SubscriptionLineConnection",
          "edges": [
            {
              "__typename": "SubscriptionLineEdge",
              "node": {
                "__typename": "SubscriptionLine",
                "id": "gid://shopify/SubscriptionLine/6b67e8d4-bafb-4ea8-98ff",
                "sellingPlanId": "gid://shopify/SellingPlan/222222",
                "sellingPlanName": "Test pay as you go",
                "productId": "gid://shopify/Product/2222",
                "sku": "",
                "title": "Bethesda iPad Sleeve",
                "variantId": "gid://shopify/ProductVariant/2222",
                "quantity": 1,
                "customAttributes": [
                  
                ],
                "lineDiscountedPrice": {
                  "__typename": "MoneyV2",
                  "amount": "100.0",
                  "currencyCode": "USD"
                },
                "variantImage": {
                  "__typename": "Image",
                  "transformedSrc": "https://cdn.shopify.com/s/files/1/0773/0954/2711/products/7794_1024x1024_c248b115-9ba2-4774-80d6-7160ac691c31.jpg?v=1685615556"
                },
                "variantTitle": "Black",
                "currentPrice": {
                  "__typename": "MoneyV2",
                  "amount": "100.0",
                  "currencyCode": "USD"
                },
                "discountAllocations": [
                  
                ],
                "pricingPolicy": null,
                "taxable": true
              }
            }
          ]
        },
        "customerPaymentMethod": {
          "__typename": "CustomerPaymentMethod",
          "id": "gid://shopify/CustomerPaymentMethod/2222",
          "instrument": {
            "__typename": "CustomerCreditCard",
            "billingAddress": {
              "__typename": "CustomerCreditCardBillingAddress",
              "address1": "321 Line Avenue",
              "city": "Shreveport",
              "country": "United States",
              "countryCode": "US",
              "province": "California",
              "provinceCode": "CA",
              "zip": "94087"
            },
            "brand": "visa",
            "expiresSoon": false,
            "expiryMonth": 3,
            "expiryYear": 2030,
            "firstDigits": "424242",
            "lastDigits": "4242",
            "maskedNumber": "•••• •••• •••• 4242",
            "name": "Test Testy",
            "revocable": false
          },
          "revokedAt": null,
          "revokedReason": null
        },
        "deliveryMethod": {
          "__typename": "SubscriptionDeliveryMethodShipping",
          "address": {
            "__typename": "SubscriptionMailingAddress",
            "address1": "321 Line Avenue",
            "address2": null,
            "city": "Shreveport",
            "company": null,
            "country": "United States",
            "countryCode": "US",
            "firstName": "Test",
            "lastName": "Testy",
            "name": "Test Testy",
            "phone": null,
            "province": "California",
            "provinceCode": "CA",
            "zip": "12345"
          },
          "shippingOption": {
            "__typename": "SubscriptionDeliveryMethodShippingOption",
            "title": "Economy",
            "presentmentTitle": "Economy",
            "description": null,
            "code": "Economy"
          }
        },
        "originOrder": {
          "__typename": "Order",
          "id": "gid://shopify/Order/122344",
          "name": "#1010",
          "fulfillmentOrders": {
            "__typename": "FulfillmentOrderConnection",
            "edges": [
              {
                "__typename": "FulfillmentOrderEdge",
                "node": {
                  "__typename": "FulfillmentOrder",
                  "fulfillAt": "2023-07-11T12:00:00Z",
                  "id": "gid://shopify/FulfillmentOrder/12233",
                  "status": "OPEN"
                }
              }
            ]
          }
        },
        "customer": {
          "__typename": "Customer",
          "id": "gid://shopify/Customer/12233",
          "email": "test@testtest123.com",
          "displayName": "Test Testy",
          "firstName": "Test",
          "lastName": "Testy",
          "phone": null
        },
        "discounts": {
          "__typename": "SubscriptionManualDiscountConnection",
          "edges": [
            
          ]
        },
        "note": null,
        "customAttributes": [
          
        ]
      }
    }

Last updated 2023-08-01T16:23:59Z