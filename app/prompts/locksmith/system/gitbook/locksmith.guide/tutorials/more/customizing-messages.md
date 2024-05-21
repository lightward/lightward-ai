[Original URL: https://www.locksmith.guide/tutorials/more/customizing-messages]

# Customizing messages

Most of the messages that Locksmith shows to your customers on the front end of your store are completely customizable!

You can edit the text itself as much as you need, plus you can add code, just like you would a template in your theme. That means you can use the following:

- HTML
- CSS (via the \ tag)
- Javascript (via the \<script\> tag)
- Liquid (Shopify's template language for themes)

If you are wanting to add translations to your messages, check out our dedicated guide on that here.

In general, your messages can be edited in two places...

## Lock-specific messages:

To customize your messages for one lock only, go to the lock page and scroll down to the "Messages" area.

## Default messages:

You can also customize the default messages, which will be used for all applicable locks when a lock-specific message is not present. To edit these, head over to the "Content" area of the "Settings" page:

## Messages that require a customer account:

Locksmith will only show the type of messages in the "Messages" area that apply to the key conditions you've selected in your lock(s). Most of the key conditions in Locksmith use customer data, and therefore require a sign in. In these cases, Locksmith will show you the following two editable messages:

- Guest message content: shown to customers that are not yet signed in.
- Access denied content: shown to customers that are signed in, but don't meet the requirements for the lock (e.g. don't have the specific customer tag that is required for access, if applicable)

## Passcode and newsletter key conditions:

There are two other types of messages that will show up if you have selected the applicable key conditions:

- Passcode prompt: for 'passcode' conditions only.
- Newsletter prompt: for Mailchimp and Klaviyo conditions only.

These conditions both show a special prompt to the customer, asking for their submission before continuing. You can customize the message in the same places as outlined above.

#### Condition-specific messages

For merchants that have multiple passcode or newsletter conditions in one lock, you can customize the messages at the condition level. This is done inside the condition popover in the input labelled "Custom input prompt, as shown below.

In most cases, you won't need to set the prompt at the condition level - simply use the lock level messages, as shown above - this is a convenience feature for when it's needed.

Important: If a message is set at this level, it will override any messages set at the other levels. If this is the case, you'll see a warning, just to let you know what's going on:

## Customizing the Continue button and loading message

Additionally, you can customize the submit buttons and loading text. To do this, head over to your theme's "Edit default theme content" settings:

... and open the "Locksmith" tab:

Locksmith will use the values you customize here when displaying content to your visitors.

Last updated 2024-04-03T17:13:57Z