<!--
  1. https://developer.helpscout.com/mailbox-api/endpoints/conversations/get/
  2. copy <section> tag to outerHTML
  3. pass through https://mixmark-io.github.io/turndown/
  -->

# Get Conversation

## Request[](#request)

Copy

    GET /v2/conversations/123 HTTP/1.1
    Authorization: Bearer oauth_token

## Path Parameters[](#path-parameters)

`/v2/conversations/{conversationId}`

## URL Parameters[](#url-parameters)

Parameter

Type

Examples

Description

`embed`

`enumeration`

`embed=threads`

Allows embedding/loading of sub-entities, allowed values are:
`threads`

## Moved or merged conversation[](#moved-or-merged-conversation)

When a conversation is merged with another conversation, it is no longer accessible. The request will return a HTTP `301 Moved Permanently` status code and the response will contain a `Location` header with the URI of the new conversation for 60 days after the merge. After 60 days, the old conversation URL will return a `404 Not Found` in response to a GET request.

## Response[](#response)

Copy

    HTTP/1.1 200 OK
    Content-Type: application/hal+json

    {
      "id" : 123,
      "number" : 12,
      "threads" : 2,
      "type" : "email",
      "folderId" : 11,
      "status" : "closed",
      "state" : "published",
      "subject" : "Help",
      "preview" : "Preview",
      "mailboxId" : 13,
      "assignee" : {
        "id" : 99,
        "type" : "user",
        "first" : "Mr",
        "last" : "Robot",
        "email" : "none@nowhere.com"
      },
      "createdBy" : {
        "id" : 12,
        "type" : "customer",
        "email" : "bear@acme.com"
      },
      "createdAt" : "2012-03-15T22:46:22Z",
      "closedBy" : 14,
      "closedByUser" : {
        "id" : 14,
        "type" : "user",
        "first" : "Clo",
        "last" : "Ser",
        "photoUrl" : "pic.jpg",
        "email" : "closer@closers.com"
      },
      "closedAt" : "2012-03-16T14:07:23Z",
      "userUpdatedAt" : "2012-03-16T14:07:23Z",
      "customerWaitingSince" : {
        "time" : "2012-07-24T20:18:33Z",
        "friendly" : "20 hours ago"
      },
      "source" : {
        "type" : "email",
        "via" : "customer"
      },
      "tags" : [ {
        "id" : 9150,
        "color" : "#929499",
        "tag" : "vip"
      } ],
      "cc" : [ "bear@normal.com" ],
      "bcc" : [ "bear@secret.com" ],
      "primaryCustomer" : {
        "id" : 238604,
        "type" : "customer",
        "first" : "Rob",
        "last" : "Robertovic",
        "email" : "rob@acme.com"
      },
      "snooze" : {
        "snoozedBy" : 4,
        "snoozedUntil" : "2024-06-03T12:00:00Z",
        "unsnoozeOnCustomerReply" : true
      },
      "nextEvent" : {
        "time" : "2024-06-03T12:00:00Z",
        "eventType" : "snooze",
        "userId" : 4,
        "cancelOnCustomerReply" : true
      },
      "customFields" : [ {
        "id" : 8,
        "name" : "Account Type",
        "value" : "8518",
        "text" : "Free"
      }, {
        "id" : 6688,
        "name" : "Account Status",
        "value" : "33077",
        "text" : "Trial"
      } ],
      "_embedded" : {
        "threads" : [ ]
      },
      "_links" : {
        "self" : {
          "href" : "..."
        },
        "mailbox" : {
          "href" : "..."
        },
        "primaryCustomer" : {
          "href" : "..."
        },
        "createdByCustomer" : {
          "href" : "..."
        },
        "closedBy" : {
          "href" : "..."
        },
        "threads" : {
          "href" : "..."
        },
        "assignee" : {
          "href" : "..."
        },
        "web" : {
          "href" : "..."
        }
      }
    }

## Response fields[](#response-fields)

Path

Type

Description

`id`

`Number`

Unique identifier

`number`

`Number`

Number

`threads`

`Number`

Number of threads the conversation has

`type`

`String`

Type of the conversation, one of:
`chat`
`email`
`phone`

`folderId`

`Number`

Id of the folder

`status`

`String`

Status of the conversation, one of:
`active`
`all`
`closed`
`open`
`pending`
`spam`

`state`

`String`

State of the conversation, one of
`deleted`
`draft`
`published`

`subject`

`String`

Subject

`preview`

`String`

Preview text from the most recent thread in the conversation

`mailboxId`

`Number`

Mailbox ID

`assignee`

`Object`

Who the conversation is assigned to. Contains a name, id and email of the user

`createdBy`

`Object`

Id, email and type of who created the conversation

`createdAt`

`String`

UTC time when the conversation was created

`closedBy`

`Number`

Id of the user that closed the conversation

`closedAt`

`String`

UTC time when the conversation was closed

`userUpdatedAt`

`String`

UTC time when the last user update occurred; equal to `customerWaitingSince` if a no user action since the last customer action

`customerWaitingSince`

`Object`

Object containing the timestamp of when the conversation was last updated

`source.via`

`String`

Originating source of the conversation, one of:
`user`
`customer`

`source.type`

`String`

Originating type of the conversation, one of:
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

`tags`

`Array`

List of tags

`cc`

`Array`

List of emails that are cc’d

`bcc`

`Array`

List of emails that are bcc’d

`primaryCustomer`

`Object`

The primary customer in the conversation

`customFields`

`Array`

[Custom field](./#custom-fields) values

`closedByUser`

`Object`

Object containing details of the user that closed the conversation

`snooze`

`Object`

Snooze data

`snooze.snoozedBy`

`Number`

The user that snoozed this conversation

`snooze.snoozedUntil`

`String`

Until when is this conversation snoozed

`snooze.unsnoozeOnCustomerReply`

`Boolean`

Whether a new customer reply should automatically unsnooze this conversation

`nextEvent`

`Object`

Next event data

`nextEvent.time`

`String`

ISO 8601 date string

`nextEvent.eventType`

`String`

One of: snooze, scheduled

`nextEvent.userId`

`Number`

Who created the next event

`nextEvent.cancelOnCustomerReply`

`Boolean`

Whether a new customer reply should automatically cancel the next event

`_embedded.threads`

`Array`

List of threads - embedded on demand - see the `embed` param

## Response fields[](#response-fields-1)

Path

Type

Description

`time`

`String`

UTC time since the last reply sent to the customer

`friendly`

`String`

Friendly string version of the waiting period

## Response fields[](#response-fields-2)

Path

Type

Description

`id`

`Number`

Custom field’s unique ID

`name`

`String`

Custom field’s name

`value`

`String`

Custom field’s value. The value type depends on custom field type. It contains an option ID for the dropdown custom field type, for example.

`text`

`String`

Custom field’s text value. It is equal to `value` for all the fields with the exception of dropdown - it contains option label in case of dropdowns.

## Resource Links[](#resource-links)

Relation

Description

`mailbox`

[The mailbox of where the conversation resides](../../mailboxes/get)

`primaryCustomer`

[The primary customer of the conversation](../../customers/get)

`createdByCustomer`

[The customer who created the conversation](../../customers/get)

`createdByUser`

[The user who created the conversation](../../users/get)

`closedBy`

[The user who closed the conversation](../../users/get)

`threads`

[conversation threads](../threads/list)

`assignee`

[User who is assignee (owner) of the conversation](../../users/get)

`web`

Link that will open this conversation in Help Scout web application (might require login)
