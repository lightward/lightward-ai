# Working with external APIs

## Loading data into Mechanic

Mechanic is an event-driven platform. This means that all data used by Mechanic needs to arrive in the form of an event. (The only exception here is Shopify itself: see Interacting with Shopify).

To create events using third-party data, use one of these techniques:

- Use the HTTP action to request the data you require, subscribing to mechanic/actions/perform to actually use the downloaded data.
- Use Couchdrop's Shared Links feature with an external FTP server or other cloud storage provider, to make any file available via a secret URL. Then, use the HTTP action to request that data.
- Use Mechanic's webhooks to POST your data directly to Mechanic.
- Use inbound email to deliver your data to Mechanic, either in the message body or as an attachment. See Receiving email.
- If you only need to move files around, without actually using the file contents, use the Files action with the URL file generator to download external files to a temporary Mechanic URL.

## Writing data to an external service

- Use the HTTP action, using standard HTTP requests, with options for authenticating with custom headers.
- Use the FTP action to upload data to third-party locations. Optionally, use a connecting service like Couchdrop to connect to another cloud storage provider (e.g. Dropbox, Google Drive, S3, etc).
- Use a cache endpoint to save your data to an unguessable URL, where an external service may download it.

## Examples

- Task: Send an SMS via Nexmo when a product is created
- Task: Send new customer signups to IFTTT
- Task: Add new customers to GetResponse

[PreviousResponding to action results](/techniques/responding-to-action-results)[NextJSON Web Signatures](/techniques/working-with-external-apis/json-web-signatures)

Last updated 2023-11-08T14:58:39Z