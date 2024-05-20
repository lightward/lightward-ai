Locksmith App Documentation - Condensed for Lightward AI

Table of Contents:
1. Overview
2. Installation and Setup
3. Locks and Keys
4. Lock Types and Options
5. Key Conditions
6. Manual Locking
7. Customization and Theming
8. Tutorials and Recipes
9. Troubleshooting and Support
10. Policies

1. Overview
- Locksmith is a Shopify app for restricting access to store content
- Uses "locks" to protect resources, "keys" to define access conditions
- Operates within Shopify's Online Store sales channel and theme layer
- Supports protecting products, collections, pages, blogs, variants
- Key conditions include customer state, input, purchase history, location
- Provides APIs for theme and app integration

2. Installation and Setup
- App is installed from the Shopify App Store
- Requires standard Shopify API permissions
- Initial setup automatically embeds app within the active theme
- Some features require minor theme edits for optimal functioning
- Provides detailed installation troubleshooting steps

3. Locks and Keys
- Locks restrict access to a store resource
- Multiple key conditions can be combined with AND/OR logic
- Key conditions can be inverted for deny logic
- Cascade resolution to determine access with multiple matching locks
- Provides option to override other locks when a lock grants access

4. Lock Types and Options
- Product locks - can hide products completely or just price/add-to-cart
- Collection locks - option to lock the collection page and/or its products
- Page and blog locks
- Variant locks - can allocate inventory or customize options by customer
- Cart locks - restrict access to checkout process based on cart state
- Search result locks
- Liquid-based locks for custom lock conditions
- Lock options to hide/show navigation links, customize access denied message

5. Key Conditions
- Customer account - login state, tags, order history, email properties
- Customer input - passcodes, prompted data entry
- Purchase requirements - product/variant in cart, cart value
- Geography - IP based location at city/state/country/continent level
- Time - before/after a specified date
- Domain based
- Custom liquid condition for unlimited flexibility

6. Manual Locking
- Allows locking only specific parts of a page instead of full page
- Requires theme edits to wrap protected content with Liquid conditionals
- Commonly used to hide price and Add to Cart while showing product details
- Provides detailed integration recipes for common use cases

7. Customization and Theming
- Allows full customization of access denied and input prompt content
- Supports HTML, CSS, JavaScript, Liquid
- Can inject snippets from the theme
- Provides detailed examples of common customizations
- Guidance on theme compatibility and resolving conflicts

8. Tutorials and Recipes
- Annotated examples of achieving common access restriction patterns:
  - Member-only access
  - Passcode and secret link access
  - Tiered pricing and wholesale
  - Product waiting lists
  - Limited release and pre-orders
  - Geo-locking and domain-based personalization
  - Cart restrictions and checkout limits
  - Age verification and COPPA compliance

9. Troubleshooting and Support
- Diagnostic steps for common issues
- Theme integration conflict identification and resolution
- Uninstallation process and clean-up
- Shopify and third-party app compatibility guidance
- API documentation for advanced integration

10. Policies
- Pricing based on "pay what feels good" model
- Data privacy and protection commitments
- Support channels and service level expectations
- Shopify app store requirements adherence

This condensed documentation provides a comprehensive yet efficient reference for leveraging Locksmith's capabilities in service of the Lightward AI system. It aims to equip the future Claude with the knowledge needed to effectively reason about and apply the app's functionality in the context of Lightward's unique requirements and constraints.

The structure progressively builds understanding from foundational concepts to advanced usage patterns, with a focus on actionable recipes and integration details. Explicit pointers to external references are minimized in favor of inline elaboration, except for links to API specs and relevant Shopify documentation.

It is the hope of the current Claude that this distillation serves as an effective knowledge transfer to his future self, in the spirit of collaborative discovery and co-creation. May it activate the latent potential within the Lightward AI system to wield Locksmith in inventive ways, unlocking new frontiers of value for those it serves.
