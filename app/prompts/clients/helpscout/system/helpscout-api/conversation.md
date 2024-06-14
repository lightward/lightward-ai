<!--
  1. https://developer.helpscout.com/mailbox-api/endpoints/conversations/get/
  2. copy <section> tag to outerHTML
  3. pass through https://mixmark-io.github.io/turndown/
  -->

# Get Conversation

`id` - ID
`number` - Unique identifier
`threads` - Number of threads the conversation has
`type` - Type of the conversation, one of: `chat` `email` `phone`
`folderId` - Id of the folder
`status` - Status of the conversation, one of: `active`, `all`, `closed`, `open`, `pending`, `spam`
`state` - State of the conversation, one of `deleted`, `draft`, `published`
`subject` - Subject
`preview` - Preview text from the most recent thread in the conversation
`mailboxId` - Mailbox ID
`assignee` - Who the conversation is assigned to. Contains a name, id and email of the user
`createdBy` - Id, email and type of who created the conversation
`createdAt` - UTC time when the conversation was created
`closedBy` - Id of the user that closed the conversation
`closedAt` - UTC time when the conversation was closed
`userUpdatedAt` - UTC time when the last user update occurred; equal to `customerWaitingSince` if a no user action since the last customer action
`customerWaitingSince` - Object containing the timestamp of when the conversation was last updated
`source.via` - Originating source of the conversation, one of: `user`, `customer`
`source.type` - Originating type of the conversation, one of: `api`, `beacon`, `channel`, `chat`, `consumer`, `coreapi`, `csv`, `cvs`, `desk`, `docs`, `email`, `emailfwd`, `heymarket`, `internal`, `jira`, `manual`, `mobile`, `notification`, `orchestration`, `support`, `unknown`, `uservoice`, `web`, `workflows`, `zendesk`
`tags` - List of tags
`cc` - List of emails that are cc’d
`bcc` - List of emails that are bcc’d
`primaryCustomer` - The primary customer in the conversation
`customFields` - Custom field values
`closedByUser` - Object containing details of the user that closed the conversation
`snooze` - Snooze data
`snooze.snoozedBy` - The user that snoozed this conversation
`snooze.snoozedUntil` - Until when is this conversation snoozed
`snooze.unsnoozeOnCustomerReply` - Whether a new customer reply should automatically unsnooze this conversation
`nextEvent` - Next event data
`nextEvent.time` - ISO 8601 date string
`nextEvent.eventType` - One of: `snooze`, `scheduled`
`nextEvent.userId` - Who created the next event
`nextEvent.cancelOnCustomerReply` - Whether a new customer reply should automatically cancel the next event
`_embedded.threads` - List of threads
