<!--
  1. https://developer.helpscout.com/mailbox-api/endpoints/conversations/threads/list/
  2. copy <section> tag to outerHTML
  3. pass through https://mixmark-io.github.io/turndown/
  -->

List Threads
============

Threads are by default sorted by `createdAt` (from newest to oldest).

Request[](#request)

---

Copy

      GET /v2/conversations/123/threads HTTP/1.1
      Authorization: Bearer oauth_token

Response[](#response)

---

Copy

      HTTP/1.1 200 OK
      Content-Type: application/hal+json

      {
        "_embedded" : {
          "threads" : [ {
            "id" : 1234,
            "type" : "customer",
            "status" : "active",
            "state" : "published",
            "action" : {
              "type" : "manual-workflow",
              "text" : "You ran the Assign to Spam workflow",
              "associatedEntities" : { }
            },
            "body" : "this is what i have to say: I love your service.",
            "source" : {
              "type" : "email",
              "via" : "customer"
            },
            "customer" : {
              "id" : 29418,
              "first" : "Vernon",
              "last" : "Bear",
              "photoUrl" : "http://whatever-path-to-url/image.jpg",
              "email" : "vbear@mywork.com"
            },
            "createdBy" : {
              "id" : 29418,
              "type" : "customer",
              "first" : "Vernon",
              "last" : "Bear",
              "photoUrl" : "http://whatever-path-to-url/image.jpg",
              "email" : "vbear@mywork.com"
            },
            "assignedTo" : {
              "id" : 1234,
              "type" : "team",
              "first" : "Jack",
              "last" : "Sprout",
              "email" : "jack.sprout@gmail.com"
            },
            "savedReplyId" : 10,
            "to" : [ "to1@somewhere.com", "to2@somewhere.com" ],
            "cc" : [ "cc1@somewhere.com", "cc2@somewhere.com" ],
            "bcc" : [ "bcc1@somewhere.com", "bcc2@somewhere.com" ],
            "createdAt" : "2015-06-05T20:18:33Z",
            "openedAt" : "2015-06-07T10:01:25Z",
            "rating" : {
              "customerId" : 1234,
              "rating" : "great",
              "comments" : "Great job!"
            },
            "scheduled" : {
              "scheduledBy" : 4,
              "createdAt" : "2024-06-10T10:20:30Z",
              "scheduledFor" : "2034-06-10T10:20:30Z",
              "unscheduleOnCustomerReply" : false
            },
            "_embedded" : {
              "attachments" : [ {
                "id" : 1234,
                "filename" : "photo1.jpg",
                "mimeType" : "image/jpeg",
                "width" : 600,
                "height" : 800,
                "size" : 20191,
                "_links" : {
                  "self" : {
                    "href" : "..."
                  },
                  "data" : {
                    "href" : "..."
                  },
                  "web" : {
                    "href" : "..."
                  }
                }
              } ]
            },
            "_links" : {
              "assignedTo" : {
                "href" : "..."
              },
              "createdByCustomer" : {
                "href" : "..."
              },
              "customer" : {
                "href" : "..."
              }
            }
          } ]
        },
        "_links" : {
          "self" : {
            "href" : "..."
          },
          "first" : {
            "href" : "..."
          },
          "last" : {
            "href" : "..."
          },
          "page" : {
            "href" : "...",
            "templated" : true
          }
        },
        "page" : {
          "size" : 25,
          "totalElements" : 0,
          "totalPages" : 0,
          "number" : 0
        }
      }

Moved or merged conversations[](#moved-or-merged-conversations)

---

When a conversation is merged with another conversation, it is no longer accessible using the old ID. [Get Conversation](/mailbox-api/endpoints/conversations/get) endpoint will return a HTTP `301 Moved Permanently` status code and the response will contain a `Location` header with the URI of the new conversation.

This request will return a HTTP `404 Not Found` in such case. If you suspect the conversation you are trying to change was merged, call the [Get Conversation](/mailbox-api/endpoints/conversations/get) endpoint to get a new conversation location.

Response fields[](#response-fields)

---

Path

Type

Description

`.id`

`Number`

Unique identifier

`assignedTo`

`Object`

The [user](../../../users/get) assigned to this thread.

`status`

`String`

[Thread status](#thread-status), accepted values:
`active`
`closed`
`nochange`
`pending`
`spam`

`state`

`String`

[Thread state](#thread-state), accepted values:
`draft`
`hidden`
`published`
`review`

`.action.type`

`String`

Internal action type

`.action.text`

`String`

Human friendly description of the action. Applicable for thread type `lineitem` only

`.action.associatedEntities`

`Object`

Contains IDs of entities associated with the action: workflow, user, mailbox, originalConversation.

`body`

`String`

Thread text content

`source.type`

`String`

Originating type of the thread, one of:
`api`
`beacon`
`channel`
`chat`
`consumer`
`coreapi`
`csv`
`cvs`
`desk`
`docs`
`email`
`emailfwd`
`heymarket`
`internal`
`jira`
`manual`
`mobile`
`notification`
`orchestration`
`support`
`unknown`
`uservoice`
`web`
`workflows`
`zendesk`

`source.via`

`String`

Originating source of the thread, one of:
`user`
`customer`

`customer`

`Object`

If thread type is message, this is the customer associated with the conversation. If thread type is customer, this is the the customer who initiated the thread.

`createdBy`

`Object`

Who created this thread. The `type` property will specify whether it was created by a [`user`](../../../users/get) or a [`customer`](../../../customers/get).

`savedReplyId`

`Number`

ID of Saved reply that was used to create this Thread

`type`

`String`

[Thread type](#thread-type), accepted values:
`beaconchat`
`chat`
`customer`
`forwardchild`
`forwardparent`
`lineitem`
`message`
`note`
`phone`

`to`

`Array`

Email address from the `to:` field

`cc`

`Array`

Email address from the `cc:` field

`bcc`

`Array`

Email address from the `bcc:` field

`createdAt`

`String`

Creation date

`openedAt`

`String`

When this thread was viewed by the customer. Only applies to threads with a `type` of message.

`linkedConversationId`

`String`

The parent or child conversation ID/identifier for a forwarded conversation

`rating`

`Object`

Customer-provided Rating details for the thread. Only applies to threads with a `type` of message.

`scheduled`

`Object`

Schedule details

`_embedded.attachments`

`Array`

Conversation attachments

Rating Response Fields[](#rating-response-fields)

---

Response fields[](#response-fields-1)

---

Path

Type

Description

`customerId`

`Number`

The ID of the customer who provided the rating

`rating`

`String`

Rating enumeration, one of `great`, `not_good`, `okay`

`comments`

`String`

Optional comment left by the customer

Schedule Response Fields[](#schedule-response-fields)

---

Response fields[](#response-fields-2)

---

Path

Type

Description

`scheduledBy`

`Number`

User ID that scheduled the thread

`sendAsId`

`Number`

Original draft author that will be used for sending the scheduled thread.

`createdAt`

`String`

When the thread was scheduled (ISO 8601 date string)

`scheduledFor`

`String`

When the thread will be sent (ISO 8601 date string)

`unscheduleOnCustomerReply`

`Boolean`

Whether a new customer reply should automatically unschedule the thread.

Attachment Response Fields[](#attachment-response-fields)

---

Response fields[](#response-fields-3)

---

Path

Type

Description

`[].id`

`Number`

Unique identifier

`[].filename`

`String`

File name

`[].mimeType`

`String`

Mime type

`[].width`

`Number`

Width in pixels - not guaranteed to be present

`[].height`

`Number`

Height in pixels - not guaranteed to be present

`[].size`

`Number`

Size in bytes - not guaranteed to be present

Resource Links[](#resource-links)

---

Relation

Description

`web`

Link to the attachment in the web application for easier download

`data`

Link to Get Data endpoint

Thread Type[](#thread-type)

---

`lineitem` represents a change of state on the conversation. This could include, but not limited to, the conversation was assigned, the status changed, the conversation was moved from one mailbox to another, etc. A line item won’t have a body, to/cc/bcc lists, or attachments. When a conversation is forwarded, a new conversation is created to represent the forwarded conversation.

`forwardparent` is the type set on the thread of the original conversation that initiated the forward event.

`forwardchild` is the type set on the first thread of the new forwarded conversation.

Thread State[](#thread-state)

---

A state of `underreview` means the thread has been stopped by Collision Detection and is waiting to be confirmed (or discarded) by the person that created the thread.

A state of `hidden` means the thread was hidden (or removed) from customer-facing emails.

Thread Status[](#thread-status)

---

Thread status is only updated when there is a status change. Otherwise, the status will be set to `nochange`.
