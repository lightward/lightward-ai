# Webhooks

A Mechanic webhook allows data to be submitted directly to Mechanic, resulting in a new event having a particular topic, containing the submitted data. Webhooks are called with simple HTTP POST requests, which means they can be called from any programming language, and from many applications.

Mechanic's webhook API includes CORS support for all origins, making these requests available for use in online user experiences.

This article is an introduction to webhooks. To get started quickly, see Creating a Mechanic webhook.

Tools like Postman (docs) can be useful for exercising Mechanic webhooks without code, for verifying their behavior.

## Configuration

- Name — Something to remember this webhook by ✨
- Event topic — The topic used for events created via this webhook
- Event data mode — Either "Auto" or "Full request"; see below
- Webhook URL — A unique, permanent, webhook-specific URL, supplied by Mechanic after creating the webhook

### Event data mode

Each webhook has a choice of modes used to translate request data into event data.

Changing a webhook's event data mode takes effect immediately for all incoming requests. It does not apply retroactively, i.e. it has no impact on webhook events that were received prior to the change.

#### Auto (default)

In "Auto" mode, event data is the result of merging an interpreted hash of parameters from the request body with an interpreted hash of parameters from the request query string.

If no parameters from the request body are found, or if parsing the request body fails for any reason, event data is set to parameters from the request query string.

If no structured parameters are found from either the request body or the request query string, event data is set to the request body in string form. If the string is blank (i.e. zero-length or consisting only of whitespace), event data is set to null.

#### Full request

In "Full request" mode, event data is set to a hash with the following keys:

| Key | Type | Notes |
| --- | --- | --- |
| 

body\_base64

 | 

Base64-encoded string

 | 

The raw request body, encoded in base64

 |
| 

body

 | 

Hash or null

 | 

The interpreted set of structured parameters from the request body, or null if parsing fails for any reason

 |
| 

client\_ip

 | 

String

 | 

The IP address of the requesting client

 |
| 

headers

 | 

Hash

 | 

Represents the request headers, keyed by lowercased header names, containing arrays of string values (⚠️ see warning below)

 |
| 

mime\_type

 | 

String or null

 | 

The MIME type of the request as interpreted from the content-type request header, or null if that header was not found

 |
| 

query\_string

 | 

String or null

 | 

Contains everything after the "?" character in the request URL, or null if no such value was found

 |
| 

query

 | 

Hash or null

 | 

Contains the interpreted set of structured parameters from the query string, or null if none were found

 |
| 

request\_id

 | 

UUID string

 | 

Uniquely identifies the request, having the same value found in the original webhook request response in the x-request-id header

 |
| 

webhook\_id

 | 

UUID string

 | 

Identifies the Mechanic webhook which handled the request

 |

Decode the base64-encoded request body with Liquid, using Mechanic's decode\_base64 filter.

Copy

    {% assign raw_request_body = event.data.body_base64 | decode_base64 %}

Mechanic's webhook request header representation has an important limitation: the array of header values is currently limited to a size of one (1). If multiple request headers are given using the same header name, their values will be concatenated with commas and represented in a single string, as the sole array element.

This means that a request which defines both X-Foo: Bar and X-Foo: Baz headers will be represented thusly:

Copy

    "headers": {
      "x-foo": [
        "Bar,Baz"
      ]
    }

Let us first acknowledge that this is ridiculous. 💯 ✅

As of this writing (2023-03-08), an upstream provider of Mechanic's does not have proper support for requests containing repeated header names. Mechanic's behavior here is a compromise chosen (1) to allow us to resolve this in the future without requiring a change to the format of this representation, and (2) for consistency with HTTP action's response format.

When this issue is resolved, the header example above will be represented as follows:

Copy

    "headers": {
      "x-foo": [
        "Bar",
        "Baz"
      ]
    }

Task code that reads webhook request headers should take these two possible representations into account.

Sample "Full request" event data

Copy

    {
      "body_base64": "LS0tLS0[...]S0NCg==",
      "body": {
        "file_upload": {
          "content_base64": "iVBORw0[...]K5CYII=",
          "mime_type": "image/png",
          "name": "tiny.png",
          "size": 1265
        },
        "key": "value",
        "hash": {
          "key": "hash_value"
        },
        "array": [
          "array_value"
        ]
      },
      "client_ip": "8.8.8.8",
      "headers": {
        "content-length": [
          "1759"
        ],
        "content-type": [
          "multipart/form-data; boundary=----WebKitFormBoundaryqcjvhXaEdqng2TkC"
        ],
        "x-custom": [
          "Value"
        ],
        "x-foo": [
          "Bar,Baz"
        ]
      },
      "mime_type": "multipart/form-data",
      "query_string": "key=value&hash[key]=hash_value&array[]=array_value",
      "query": {
        "key": "value",
        "hash": {
          "key": "hash_value"
        },
        "array": [
          "array_value"
        ]
      },
      "request_id": "a8723f25-20ff-4b89-a46c-73fc387a16d3",
      "webhook_id": "d166806f-1f79-4283-b4b4-80a38ee04431"
    }

## Requests

The Mechanic webhook API only accepts POST requests. (All other methods will receive a 405 Method Not Allowed response.)

Mechanic's webhook API includes CORS support for all origins, making these requests available for use in online user experiences.

### File uploads

File uploads are supported via multipart/form-data webhook requests. Each uploaded file will be represented in event data (regardless of event data mode) as a structured hash having the following keys:

- content\_base64 — A base64 string representation of the file content
- mime\_type — The MIME type of the file, as declared in the headers for that file
- name — The original name of the file, as declared in the headers for that file
- size — An integer reflecting the size of the file in bytes

Decode base64-encoded file content with Liquid, using Mechanic's decode\_base64 filter.

Copy

    {% assign file = event.data.body.my_upload %}
    {% assign raw_file_content = file.content_base64 | decode_base64 %}

File upload sample representation

Copy

    {
      "my_upload": {
        "content_base64": "PD94bWw[...]mc+Cg==",
        "mime_type": "image/svg+xml",
        "name": "logo.svg",
        "size": 12345
      }
    }

### Client-specific endpoints

When configuring an integration with external apps and services, some require specific behavior from webhook hosts – usually for the purposes of validating a webhook before it's enabled. Mechanic includes specific support for some known webhook clients; request new ones at mechanic.canny.io.

A webhook invocation signals its client selection via a path suffix. Given a webhook URL of webhooks.mechanic.dev/0000..0000, a client-specific endpoint for Ship24 (for example) would be available at webhooks.mechanic.dev/0000..0000/ship24.

| 

Client

 | 

Webhook suffix

 | 

Behavior notes

 | 

 |
| 

Asana

 | 

asana

 | 

Supports the X-Hook-Secret header for the handshake phase

 | 

Docs

 |
| 

Ship24

 | 

ship24

 | 

Supports HEAD requests for webhook verification

 | 

Docs

 |

### Examples

With cURL:

Copy

    curl -X POST -F foo=bar https://webhooks.mechanic.dev/abcdef12-3456-abcd-ef12-3456abcdef12

Copy

    curl -X POST -H "content-type: application/json" -d @data.json https://webhooks.mechanic.dev/abcdef12-3456-abcd-ef12-3456abcdef12

With fetch:

Copy

    const data = {
      some_data: 'yep here it is',
    };
    
    fetch(
      'https://webhooks.mechanic.dev/0000-0000',
      {
        method: 'post',
        body: JSON.stringify(data),
        headers: {
          'content-type': 'application/json'
        },
      }
    ).then(console.log);

With jQuery:

Copy

    $.post('https://webhooks.mechanic.dev/0000-0000', { foo: 'bar' });

Copy

    $.ajax({
      url: 'https://webhooks.mechanic.dev/0000-0000',
      method: 'POST',
      data: { foo: 'bar' }
    });

Copy

    let data = { foo: 'bar' };
    
    $.ajax({
      url: 'https://webhooks.mechanic.dev/0000-0000',
      method: 'POST',
      headers: {
        'content-type': 'application/json'
      },
      data: JSON.stringify(data)
    });

## Responses

A properly-formatted webhook request will always receive a 204 No Content response, even in the case of an incorrect webhook ID in the URL.

If an active webhook ID was used, then an event will be created with the submitted data. The event will be run asynchronously, along with any generated task and action runs that follow.

### Webhook request ID

All POST requests to webhooks.mechanic.dev will receive an x-request-id response header, containing a UUID. This ID can be used as a search term when looking up a Mechanic event, and can be referenced in Liquid as a part of the Event object via event.webhook\_request\_id.

### Retrieving run results

The webhook ingress API is solely for ingesting data to form a new event. Because of this, the webhook response necessarily does not contain any data resulting from the runs that might follow. (To further explain the point: there could be zero task runs that follow, or many, and there are no hard guarantees for when those runs would finish.)

This means that the caller must use another avenue for retrieving the results of any generated runs. In general, there are three options for this:

- For a consistently re-occurring call with a single caller, the task responding to the webhook event may write its results to the Mechanic cache, allowing the caller to retrieve results using a cache endpoint.
- For calls with variable or multiple callers, use the webhook request ID by reading the x-request-id response header in your client code, and by referencing event.webhook\_request\_id in your task's Liquid code in. Tasks responding to the webhook event should store their results keyed by that UUID, using an external storage mechanism (possibly via the HTTP or FTP actions).
- For calls triggered by customer activity on an online Shopify storefront, consider (a) requiring the customer to be logged in, (b) sending the customer ID in the webhook request data, (c) storing task results in a customer metafield (using the Shopify action), and (d) using storefront Liquid to render the content of that metafield, polling until a value is present.

Last updated 2023-04-02T21:54:06Z