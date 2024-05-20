# Receiving email

Every Shopify store that uses Mechanic has its own, dedicated email address, named after the store's myshopify.com subdomain and located at mail.usemechanic.com. A store at example.myshopify.com would be assigned the address example@mail.usemechanic.com.

For a working example task from Mechanic's library, see Forward incoming email to another address

## Event

Every incoming email message results in a new Mechanic event.

### Topic

mechanic/emails/received

### Data

Postmark (Mechanic's email provider) parses your incoming mail, and hands its JSON representation to Mechanic to use as event data. Refer to Postmark's email parsing guide to see how Postmark thinks about this. The data you receive in Mechanic is as you see in that documentation, with one difference: where Postmark uses keys like "ReplyTo" and "HtmlBody", Mechanic uses keys like "reply\_to" and "html\_body".

Specifically, you'll have access to these attributes, all available in the email object:

- "attachments" – an array, containing objects with the keys "name", "content", "content\_type", "content\_length", and "content\_id"
- "cc" – a string containing the full "CC" list, including names and email addresses
- "cc\_full" – an array, containing objects with the keys "email", "name", and "mailbox\_hash"
- "date" – an ISO8601 string indicating when the email was received by Postmark; use this with the date filter
- "from" – a string containing the email address of the sender
- "from\_full" – an object with the keys "email", "name", and "mailbox\_hash"
- "from\_name" – a string containing the name of the sender
- "headers" – an array, containing objects with the keys "name" and "value"
- "html\_body" – a string, containing the HTML email body
- "message\_id" – a string that uniquely identifies this message; include this when contacting support
- "reply\_to" – a string, containing the reply-to address
- "stripped\_text\_reply" – a string, containing Postmark's attempt at isolating only the reply portion of an email; see the "StrippedTextReply" section of Postmark's documentation
- "subject" – a string! :)
- "text\_body" – a string, containing the plaintext email body
- "to" – a string containing the full "To" list, including names and email addresses
- "to\_full" – an array, containing objects with the keys "email", "name", and "mailbox\_hash"

Last updated 2024-01-14T14:31:14Z