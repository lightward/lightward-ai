# Newsletter keys

Use Locksmith to only grant access to customers that subscribe to your newsletter

Locksmith allows you to integrate directly with either Mailchimp or Klaviyo. When setup, Locksmith will ask customers for an email address when they arrive on a locked page. Once the email is entered, a customer is immediately granted access, and Locksmith will automatically send the subscription information to the corresponding service.

Note: Mailchimp and Klaviyo both have their own policies regarding double opt in, and it is typically enabled by default. This setting is adjusted in your Mailchimp or Klavivyo dashboards - it is not a setting that is controlled by Locksmith.

## Mailchimp

Detailed information on how to setup Mailchimp can be found here:

[pageUse Mailchimp to collect customer emails](/tutorials/more/mailchimp)
## Klaviyo

If using Klaviyo, you have the option to simply request that visitors subscribe in order to gain access:

[pageGrow your subscriber lists with Klaviyo](/tutorials/more/klaviyo)

Or, you can also use Klaviyo to grant access only to those who are already subscribed to a specific list in your Klaviyo account:

[pageUse Klaviyo as an access control list](/tutorials/more/use-klaviyo-as-an-access-control-list)
## Using your default Shopify mailing list

Shopify ships out of the box with a marketing mailing list service. If you would like to use Locksmith to grant access to those who have already subscribed to this, you can do so using a custom Liquid key condition.

This is slightly different than the above options, in that it will only grant access to a signed in customers - if the customer is already subscribed! To start, check out our guide on this here:

[pageLiquid key basics](/keys/more/liquid-key-basics)

The condition you're looking for is:

{% if customer.accepts\_marketing %}

When set up, this will present the customer will the regular prompt to sign in (as opposed to the subscription prompt):

If desired, you can adjust your message prompt to direct your customers to the page footer(in most stores) to subscribe to your newsletter. More information on editing messages here:

[pageCustomizing messages](/tutorials/more/customizing-messages)
## Using other mail services

Locksmith does not support other mail services at this time.

However, if you have a mail service that automatically tags customers that are subscribed, you can use Locksmith to check for a customer tag:

[pageCustomer account keys](/keys/customer-account-keys)

Please feel free to contact us via email at team@uselocksmith.com if you have any questions!

[PreviousCombining key conditions](/keys/more/combining-key-conditions)[NextLimiting the scope of variant locks using the product tag key condition](/keys/more/limiting-the-scope-of-variant-locks-using-the-product-tag-key-condition)

Last updated 2023-11-04T02:11:54Z