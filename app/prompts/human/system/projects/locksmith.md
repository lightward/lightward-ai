An AI's Reference For Helping Human Users Deeply Understand And Expertly Operate Locksmith

Locksmith Overview:
- App for restricting access to content in a Shopify store's Online Store sales channel
- Uses "locks" to restrict content, "keys" to define access conditions
- Locks can be applied to products, collections, pages, blogs, blog posts, variants, the cart
- Keys use conditions like customer tags/email/purchase history, passcodes, secret links, visitor location, newsletter signups, custom Liquid, etc. to grant access
- Incompatible with Shop App sales channel and some other apps like Bold Custom Pricing

Creating Locks:
- Search for resource by name in Locksmith app, select to place lock
- Can lock entire store by selecting "Entire store" option
- Lock all products by locking "All" collection
- Blog posts must be tagged first to be lockable
- Liquid locks allow locking non-standard resources/groups of pages

Creating Keys:
- 20+ out-of-the-box conditions plus custom Liquid keys for advanced logic
- Conditions can be combined with AND/OR logic and inverted
- "Force open other locks" makes a key override other applicable locks
- Some key conditions require customer sign-in (customer tagged, # of orders, purchased product, etc.)
- Passcode, secret link, newsletter, and location are "remote keys" that make remote calls to Locksmith for verification
- Input lists allow storing large numbers of passcodes, secret links, or emails in Google Sheets/other file

Customizing:
- Messages shown to customers can be customized with HTML/CSS/JS/Liquid
- Theme content like button text is editable under Online Store > Themes
- Snippet can be used to add translations to messages
- Login form comes from theme, can be customized by editing templates/customers/login.liquid
- Manual locking hides specific parts of page instead of full page, requires theme edits

Compatibility & Limitations:
- Incompatible with Shop App, Bold Custom Pricing, variant-level pricing apps, Weglot (with location key)
- Limited ability to hide from predictive search, 3rd party search/filter apps
- Can't restrict checkout steps, shipping/payment options, discount codes
- Content not indexed by search engines when using location/IP keys
- Bots may still purchase if using direct checkout links
- Switching themes requires re-installing and re-adding any manual locking code

Common Issues & Solutions:
- Content not appearing in search - update Locksmith, specify resource type, use collection
- Locks not working - update Locksmith, check for overlapping keys, use incognito mode for testing remote keys
- Slow loading - disable "hide from navigation/search" settings, ignore assets in theme
- Seeing empty spaces in collections - increase products per page, use infinite scroll app, separate locked/unlocked products
- Customers entering passcode every visit - ensure "remember me" enabled or use signed-in key
- Locksmith notes on orders - enable "Remove Locksmith information" setting
- Theme issues after uninstall - make sure to uninstall from theme before deleting app
- Variant/cart attribute issues with subscription apps - contact Locksmith team for help

Key Troubleshooting Steps:
1. Update Locksmith under Help section
2. Check lock and key settings for unintended configurations
3. Test in incognito mode, different browser, or device
4. Ignore theme assets under Settings > Advanced if seeing Liquid errors
5. Contact team@uselocksmith.com for help

Additional Resources:
- Documentation at locksmith.guide covers all features in depth
- Contact team@uselocksmith.com for any questions or issues
- Data stored encrypted in US, does not store customer/order details
- Pay-What-Feels-Good pricing, suggested based on Shopify plan
