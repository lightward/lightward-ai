[Original URL: https://www.locksmith.guide/keys/customer-account-keys]

# Customer account keys

Many of Locksmith's key conditions use the customer account system that comes by default with all Shopify stores to check for specific customer attributes before granting access. These are detailed below.

Note: Locksmith does not create a separate account system or customer database! In order to use customer accounts with Locksmith, you'll first need to make sure that customer accounts are activated in your store.

When these key conditions are used, Locksmith will ask that a customer signs in first, whenever a customer tries to access the locked content in your store. Locksmith does so by automatically displaying the login template from your theme:

Some of the options available to you include checking if the customer...

- is signed in This condition requires all customers to log in. Once they're logged in, they'll be granted access to the locked resource.
- is tagged with… This condition first requires all visitors to log in with a customer account. Once the customer has logged into their account, they'll be granted access if their customer account has the tag you've chosen in Locksmith.
- is not tagged with… This condition grants access if the visitor is not signed in with a customer account, or if they are signed in with a customer account that does not have the specified tag.
- has placed at least x orders This condition requires the visitor to be logged in with their customer account. If their lifetime order count is at least the number that you specify, they'll be granted access.
- has purchased… This condition requires the visitor to be logged in with their customer account, prompting them to log in if they aren't already. If their last 50 orders contain a certain product (identified by SKU, title, or by product tag), they'll be granted access.
- the customer's email contains… This condition requires the visitor to be logged in with their customer account. If their email address matches some text that you specify (say, "@mycompany.com"), they'll be granted access.
- has one of many email addresses This condition requires the visitor to be logged in with their customer account. If their email address is on the list that you specify, they'll be granted access. Simply to set up, but not recommend if you have a large number of email addresses. See below for an alternate option.
- has an email from an input list This condition requires the visitor to be logged in with their customer account. If their email address is on the list that you specify, they'll be granted access. This key condition is different than the above, in that it leverages Locksmith's input list feature, which lets you use a very large number of of email addresses. While not hard to set up, it does require a few more steps than the one-of-many-email-addresses key condition above.

## Inverting key conditions

Don't forget that all key conditions can be inverted! Which just means that Locksmith will check for the opposite of the original condition. More info on that here:

[pageInverting conditions in Locksmith](/keys/more/inverting-conditions-in-locksmith)
## Liquid key conditions

If the list above does not include the exact customer attribute that you are wanting to check, you have the flexibility to use any Liquid attribute that Shopify makes available on the customer object. This is done by using a "custom Liquid" key condition.

Most notably, this would allow you to use customer metafields in order to grant access. More complete information on custom liquid key conditions - including setup guide - here:

[pageLiquid key basics](/keys/more/liquid-key-basics)
## More information related to customer accounts

Here are a few more links to guides that you might find useful as you set up Locksmith to work with your customer account system:

[pageApproving customer registrations](/tutorials/approving-customer-registrations)[pageCustomizing the customer login page](/tutorials/more/customizing-the-customer-login-page)[pageCustomizing the registration form](/tutorials/more/customizing-the-registration-form)[pageCustomizing messages](/tutorials/more/customizing-messages)

As always, please feel free to reach out to us directly via email at team@uselocksmith.com if you have any questions!

Last updated 2023-09-29T21:20:42Z