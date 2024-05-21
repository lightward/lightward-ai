[Original URL: https://learn.mechanic.dev/faq/how-do-i-add-an-unsubscribe-link-to-my-emails]

# How do I add an unsubscribe link to my emails?

Mechanic doesn't permit bulk email messages, in which the same content is sent to many customers at once. As a rule of thumb: if an email requires an unsubscribe link, it shouldn't be sent using Mechanic. (Learn more about this.)

In the rare case that an email does warrant an unsubscribe link, use {{ customer.unsubscribe\_url }} to add a link, like this:

Copy

    Unsubscribe

This property of the customer object points to a Mechanic-powered URL that...

1. Turns off the "Accepts marketing" property of the related customer, in their Shopify records
2. Gives the customer a link to return them to the Shopify store's online storefront

If your task code doesn't have a customer object, you might have to write some different Liquid code to achieve the same ends. The idea is to call the unsubscribe\_url attribute of the appropriate customer object, regardless of what specific variable holds the customer object.

Last updated 2021-06-14T23:12:53Z