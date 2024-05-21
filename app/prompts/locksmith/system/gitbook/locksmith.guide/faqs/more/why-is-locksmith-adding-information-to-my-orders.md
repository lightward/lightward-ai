[Original URL: https://www.locksmith.guide/faqs/more/why-is-locksmith-adding-information-to-my-orders]

# Why is Locksmith adding information to my orders?

## Why is this happening?

For key conditions like passcodes, secret links, and country limits, Locksmith adds system information to the visitor's cart. This is how we keep things fast – the cart is the only place that Shopify can store visit-specific information.

This means that, on checkout, this data can make it all the way into your order records. If this is happening, you'll see something like this in your order information:

If you have a large number of keys in your shop, this value can get quite large!

Note: You may see Locksmith notes in the order even if the order came from a customer that does not have access to any of your locked content. Depending on your Locksmith settings, it may be necessary to cache the fact that the current customer does indeed not have access, which still keeps server pings to a minimum (and helps speed things up, as per the above).

## A (partial) solution

Locksmith will go out of its way to let you know that this might happen. You'll see a notice like this in your lock settings:

To allow Locksmith to automatically remove its information from an order's "Additional Details", head to your Locksmith settings area, and enable the "Remove Locksmith information from orders" setting at the end of the page. The setting looks like this:

After you enable this setting, Locksmith will ask you for the additional permissions needed for updating your order records. Once you grant permission, Locksmith will take care of keeping its data out of your orders from that point onward.

## Locksmith notes still appearing in confirmation emails or third party apps?

The above setting does NOT help in all cases, particularly when your order information is sent off before Locksmith has the chance to remove its own information.

If you are having issues with this, your best bet is to contact us via email at team@uselocksmith.com and we can go through your other options with you.

## Removed Locksmith but still noticing order notes?

The notes are stored on the customer's browser, and the traces of this can still end up in the "Additional Details" section of some incoming orders. If you've deleted Locksmith, seeing these in your orders is not an indication that Locksmith is still embedded in your theme, just that the customer in question is running on the same browser "session" that they were running when you still had Locksmith installed on your store. You should see these drop off over time. However, if they are causing you issues, let us know at team@uselocksmith.com - we can help you out by adding a script to your theme that will delete the Locksmith cache from their browser as soon as customers visit (and before they place their next order).

Last updated 2022-10-25T21:59:35Z