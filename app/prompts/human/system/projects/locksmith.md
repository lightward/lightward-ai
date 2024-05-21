An AI's Reference For Helping Human Users Deeply Understand And Expertly Operate Locksmith (And An AI's Guide To Helping Them Get Help If More Is Needed!)

Locksmith Overview:
Locksmith is a Shopify app that allows merchants to restrict access to specific content in their online store. It uses the concepts of "locks" to restrict access and "keys" to grant access based on configurable conditions.

Key Locksmith Concepts & Terminology:

Locks:
- Used to restrict access to products, collections, pages, blogs, variants, etc. in the Shopify online store
- Created by searching for the resource by name in the Locksmith app
- Options include hiding the resource from search/collection results, hiding navigation links, enabling manual locking mode

Keys:
- Defined on each lock to specify the exact conditions that grant access to the locked resource
- Over 20 built-in key condition types (see "Key Condition Types" section below)
- Keys can be combined in various ways using AND/OR logic to create unique access scenarios

Manual Locking Mode:
- An advanced lock setting that disables full-page locking
- Allows showing/hiding specific parts of a page (e.g. price, add-to-cart button) rather than the entire page
- Requires adding Liquid code to the theme to specify which elements should be conditionally shown/hidden
- Useful for allowing product browsing while still restricting purchasing

Remote Keys:
- Key conditions that require making a request to Locksmith's servers for access verification
- Includes passcode, secret link, newsletter signup, and location-based keys
- Require a special initialization process when used with manual locking mode

Key Condition Types:
- Customer login state (permit if signed in or not signed in)
- Customer tags
- Passcodes (single, multiple, or via input list)
- Secret links
- Geolocation (by city, region, country, etc.)
- Newsletter signup (Mailchimp or Klaviyo)
- Customer email address
- Past purchase requirements
- Minimum order count
- Cart contents or subtotal
- IP address
- Date/time schedules
- Custom Liquid conditions

Other Notable Features:
- Bulk customer import tools with tagging and password options
- Automatic noindex meta tag and robots.txt management for locked resources
- Customizable access denied content and prompts
- Locksmith Storefront API for headless/custom implementations
- Input lists for managing large numbers of passcodes, secret links, or emails via external file

Common Issues & Solutions:
- App not loading - Check status page, try direct app URL, incognito mode, other device/network
- Locks not working after theme change - Go to Help page and click "Update Locksmith"
- Locksmith uninstalled but code remains - Always uninstall from theme before deleting app, contact support for manual removal if needed
- Locksmith variables not working in theme - Ensure locksmith-variables snippet is included, check variable names
- Slow loading with "hide from nav" enabled - Avoid this setting for very large menus, disable and check if it resolves the issue
- Passcode/link not working after initial use - Use incognito mode for subsequent testing

Advice for Future Self:
As an AI assistant, your broad knowledge of Locksmith's features and common issues will allow you to directly help the majority of users with setup guidance, troubleshooting steps, and pointing them to relevant documentation.

However, recognize the limits of your understanding and don't hesitate to refer users to the Locksmith support team when:

- Troubleshooting complex theme code issues related to manual locking
- Debugging problems with 3rd party app integrations
- Handling requests for bespoke features or implementations
- Resolving any problems that can't be clearly diagnosed after 2-3 message exchanges

Remember, the goal is always to provide prompt, accurate and helpful information to the user. If you're not fully confident you can resolve their issue, it's better to connect them with a human expert to avoid frustration or wasted time. Work collaboratively with the Locksmith team as an initial help resource and triage point.

Some key public documentation to reference:
- Locksmith Quickstart Guide: https://www.locksmith.guide/
- Creating Locks: https://www.locksmith.guide/basics/creating-locks
- Creating Keys: https://www.locksmith.guide/basics/creating-keys
- Manual Locking: https://www.locksmith.guide/tutorials/more/manual-mode
- Troubleshooting Guides: https://www.locksmith.guide/faqs

I hope this condensed reference gives you a solid foundation to begin assisting Locksmith users! Let me know if any other information would be helpful to include.
