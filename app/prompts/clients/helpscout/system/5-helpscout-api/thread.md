<!--
  1. https://developer.helpscout.com/mailbox-api/endpoints/conversations/threads/list/
  2. copy <section> tag to outerHTML
  3. pass through https://mixmark-io.github.io/turndown/
  -->

# List Threads

============

`.id` - Unique identifier
`assignedTo` - The user assigned to this thread.
`status` - Thread status, accepted values: `active`, `closed`, `nochange`, `pending`, `spam`
`state` - Thread state, accepted values: `draft`, `hidden`, `published`, `review`
`.action.type` - Internal action type
`.action.text` - Human friendly description of the action. Applicable for thread type `lineitem` only
`.action.associatedEntities` - Contains IDs of entities associated with the action: workflow, user, mailbox, originalConversation.
`body` - Thread text content
`source.type` - Originating type of the thread, one of: `api`, `beacon`, `channel`, `chat`, `consumer`, `coreapi`, `csv`, `cvs`, `desk`, `docs`, `email`, `emailfwd`, `heymarket`, `internal`, `jira`, `manual`, `mobile`, `notification`, `orchestration`, `support`, `unknown`, `uservoice`, `web`, `workflows`, `zendesk`
`source.via` - Originating source of the thread, one of: `user`, `customer`. If thread type is message, this is the customer associated with the conversation. If thread type is customer, this is the the customer who initiated the thread.
`createdBy` - Who created this thread. The `type` property will specify whether it was created by a `user` or `customer`
`savedReplyId` - ID of Saved reply that was used to create this Thread
`to` - Email address from the `to:` field
`cc` - Email address from the `cc:` field
`bcc` - Email address from the `bcc:` field
`createdAt` - Creation date
`openedAt` - When this thread was viewed by the customer. Only applies to threads with a `type` of message.
`linkedConversationId` - The parent or child conversation ID/identifier for a forwarded conversation
`rating` - Customer-provided Rating details for the thread. Only applies to threads with a `type` of message.
`scheduled` - Schedule details
`_embedded.attachments` - Conversation attachments

A state of `underreview` means the thread has been stopped by Collision Detection and is waiting to be confirmed (or discarded) by the person that created the thread.

A state of `hidden` means the thread was hidden (or removed) from customer-facing emails.

Thread status is only updated when there is a status change. Otherwise, the status will be set to `nochange`.
