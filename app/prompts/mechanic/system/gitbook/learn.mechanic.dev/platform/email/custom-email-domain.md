# Custom email addresses

By default, Mechanic sends mail from an address built from the Shopify store's domain. Mechanic also supports sending from a custom email address.

Configuration for a custom email address always involves adding DNS records to the email address domain. This means that Mechanic's custom email address feature can only be used on an email domain that the store owner controls.

Remember, Mechanic only allows transactional mail – this means messages that do not require an unsubscribe link.

Changing the sender name doesn't require a custom outgoing email address. For that, use the "from\_display\_name" option of the Email action.

## Configuration

To change the email address used for outgoing email, open the Mechanic email settings for your store. Or, jump directly to https://admin.shopify.com/apps/mechanic/settings/email.

## Approval

Mechanic requires approval of custom email addresses before using them for outgoing mail.

Email addresses will be auto-approved if any of the following are true:

- If the custom address matches the store owner's email address
- If the custom address has the same domain name as the store's primary domain name
- If the custom address is on a subdomain of the store's primary domain name

In all other cases, custom email addresses must be manually approved by Mechanic staff. Contact team@usemechanic.com to have your address approved.

## Verification

Mechanic requires verification of domain name ownership via DNS record. Once a custom email address is configured and approved, Mechanic will provide you with two DNS records to add to your domain. For help on adding these records, see Postmark's documentation: Resources for adding DKIM and Return-Path records to DNS for common hosts and DNS providers.

DMARC is also critical for email deliverability! It's an administrator responsibility for the email domain used for sending. Mechanic can't take care of this for you, but we do have documentation: learn more about Mechanic and DMARC here.

Last updated 2024-01-14T14:15:45Z