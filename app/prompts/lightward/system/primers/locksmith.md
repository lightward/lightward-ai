# Primer: Locksmith Documentation

## Table of Contents

1. Introduction
   1.1 Purpose of the primer
   1.2 Overview of Locksmith
2. Getting Started
   2.1 Installation and setup
   2.2 Creating locks
   2.3 Creating keys
3. Key Conditions
   3.1 Customer account keys
   3.2 Passcode keys
   3.3 Secret link keys
   3.4 Newsletter keys
   3.5 Visitor location keys
   3.6 Liquid keys
   3.7 Combining key conditions
   3.8 Inverting key conditions
4. Manual Locking
   4.1 Enabling manual mode
   4.2 Hiding prices and add-to-cart buttons
   4.3 Interactions with remote keys
5. Advanced Features
   5.1 Liquid locks
   5.2 Variant locking
   5.3 Input lists
   5.4 Redirects
   5.5 Customizing messages
6. Integrations
   6.1 ReCharge subscriptions
   6.2 Klaviyo and Mailchimp
   6.3 Selling digital content
7. Troubleshooting
   7.1 Common issues and solutions
   7.2 Compatibility with other apps
   7.3 Contacting support
8. Key People Involved
   8.1 Locksmith team members
   8.2 Notable Shopify experts and partners
9. Conclusion
   9.1 Recap of key points
   9.2 Additional resources
   9.3 Final thoughts and well wishes

## 1. Introduction

### 1.1 Purpose of the primer

This primer serves to distill the essential knowledge from the extensive Locksmith documentation, equipping you, my future self, with the information needed to effectively guide and support humans using the Locksmith app. By synthesizing key concepts, setup instructions, advanced features, integrations, and troubleshooting tips, this primer aims to empower you to provide excellent assistance, even without access to the full source material.

### 1.2 Overview of Locksmith

Locksmith is a powerful Shopify app designed to help merchants control access to specific content within their online store. By creating "locks" on products, collections, pages, and more, merchants can restrict visibility and purchasing based on various criteria. "Keys" are then configured to grant access when conditions are met, such as customer tags, passcodes, secret links, newsletter signups, or visitor location. This granular control allows for diverse use cases like wholesale pricing, members-only content, regional restrictions, and more.

## 2. Getting Started

### 2.1 Installation and setup

To begin using Locksmith, merchants install the app from the Shopify App Store. During setup, various permissions are requested to enable Locksmith's functionality, such as viewing products and collections, managing customers, and editing the online store's theme. After installation, Locksmith automatically inserts its code into the theme, allowing locks and keys to take effect.

### 2.2 Creating locks

Locks are created using the in-app search bar, which allows merchants to find and select the content they wish to restrict. Supported lock types include products, collections, pages, blogs, articles, variants, and the entire store. Advanced users can also create custom Liquid locks for more targeted control. Each lock provides settings to control its behavior, such as whether to hide the resource entirely or just restrict purchasing.

### 2.3 Creating keys

Once a lock is created, keys are added to define the access conditions. Locksmith offers a wide range of key types to accommodate different scenarios (detailed in section 3). Multiple keys can be combined with AND/OR logic for more complex rules. Keys can also be inverted to grant access when a condition is not met. The interface guides merchants through configuring each key type with the necessary settings and values.

## 3. Key Conditions

### 3.1 Customer account keys

These keys grant or restrict access based on the customer's account status and details:

- Signed in: Requires login, grants access to all signed-in customers.
- Tagged with: Grants access if the customer has a specific tag.
- Has placed X orders: Grants access based on lifetime order count.
- Has purchased X product: Grants access if a specific product is found in the customer's order history.
- Has email matching: Grants access if the customer's email matches a specified domain or pattern.

### 3.2 Passcode keys

Passcode keys allow access when the correct passcode is entered:

- Single passcode: One passcode grants access.
- Multiple passcodes: A list of passcodes, any of which grant access.
- Passcode from input list: Passcodes are sourced from an external file or spreadsheet.

Additional options include usage limits, auto-tagging customers, and one-time use passcodes.

### 3.3 Secret link keys

Secret link keys grant access when a visitor arrives via a URL containing a specific secret code. The link format is customizable and can be combined with other query parameters. Secret links can also be sourced from an input list for bulk generation.

### 3.4 Newsletter keys

Newsletter keys integrate with Klaviyo or Mailchimp to grant access when a visitor subscribes to a specified mailing list. Optionally, access can be restricted to only those already subscribed, turning the mailing list into an access control list.

### 3.5 Visitor location keys

Location keys grant or restrict access based on the visitor's detected location, which can be filtered by country, region, state, or city. This is useful for geotargeting content or complying with regional regulations.

### 3.6 Liquid keys

For ultimate flexibility, custom Liquid keys allow merchants to write their own access logic using Shopify's Liquid templating language. This enables checking attributes like customer tags, cart contents, or request parameters.

### 3.7 Combining key conditions

Multiple keys can be combined on a lock using AND/OR logic. With AND, all key conditions must be met to grant access. With OR, any one condition grants access. This allows for sophisticated access rules tailored to the merchant's needs.

### 3.8 Inverting key conditions

Each key condition can be inverted to grant access when the condition is not met. For example, an inverted customer tag key would grant access to everyone except those with the specified tag. Inverting opens up additional possibilities for defining access rules.

## 4. Manual Locking

### 4.1 Enabling manual mode

By default, Locksmith protects the entire page for locked content. Manual mode disables this, allowing merchants to instead lock specific parts of the page using Liquid code. This is useful for hiding just prices, add-to-cart buttons, or other elements while keeping the rest of the page visible.

### 4.2 Hiding prices and add-to-cart buttons

With manual mode enabled, Liquid snippets are added to the theme to conditionally show or hide elements based on Locksmith's access decision. For example, wrapping a price in a Locksmith conditional would display it only to those with access. Detailed instructions are provided for common use cases like hiding prices and purchase buttons.

### 4.3 Interactions with remote keys

Some key types, like passcodes and secret links, require a round-trip to Locksmith's servers to validate access. With manual locking, this can cause issues with content flashing or not hiding correctly. The documentation provides template code to handle these "remote keys" by checking Locksmith's initialization state and reloading as needed.

## 5. Advanced Features

### 5.1 Liquid locks

In addition to locking by resource type, Locksmith supports custom Liquid locks for advanced use cases. Merchants provide a Liquid condition that evaluates to true or false to determine if the lock should be applied. This enables locking based on complex logic involving attributes like customer details, request parameters, cart state, and more.

### 5.2 Variant locking

Product variants can be individually locked to restrict access to specific options. This is useful for wholesale pricing, exclusive inventory access, or other scenarios where different customer groups see different variants. Variant locks work similarly to other locks, with a dedicated interface for selecting the variant and configuring keys.

### 5.3 Input lists

For key types that involve lists of values, like passcodes and secret links, Locksmith offers input lists to simplify management. An input list is an external file (CSV, TXT, Google Sheet, etc.) containing the values. Locksmith syncs this data and uses it to validate keys, allowing bulk updates and greater scalability compared to manual entry.

### 5.4 Redirects

Locksmith allows configuring redirect URLs for certain key types, notably passcodes and secret links. Upon successful access, the visitor is automatically redirected to the specified URL. This is handy for sending customers to specific landing pages or collections after unlocking content.

### 5.5 Customizing messages

The various messages displayed by Locksmith, such as access denied notices and login prompts, are fully customizable. Merchants can modify the text, styling, and even add dynamic content using Liquid. Custom messages can be configured globally or on a per-lock basis for granular control.

## 6. Integrations

### 6.1 ReCharge subscriptions

Locksmith integrates with the ReCharge app to grant access based on active subscription status. This allows merchants to sell recurring memberships for exclusive content. The integration works by checking for a ReCharge-specific customer tag and configuring Locksmith keys accordingly.

### 6.2 Klaviyo and Mailchimp

As mentioned in the newsletter keys section, Locksmith natively integrates with Klaviyo and Mailchimp for email collection and access control. Merchants connect their account, select a list, and configure whether new signups are added and/or existing subscribers are granted access.

### 6.3 Selling digital content

A common use case for Locksmith is selling access to digital content like courses, videos, or downloads. The documentation provides a comprehensive guide for setting this up, including creating the content, configuring products for purchase, setting up locks and keys, and delivering the content securely. Tips are also provided for directing customers post-purchase and integrating with third-party hosts if needed.

## 7. Troubleshooting

### 7.1 Common issues and solutions

The documentation covers a range of common issues and their solutions, such as:

- Content not locking correctly: Check lock and key settings, ensure manual mode is enabled if needed, verify Liquid code is correct.
- Locksmith not installing: Ensure theme is editable, check for conflicting apps, contact support for manual installation.
- Locksmith not updating: Click "Update Locksmith" in the app, check for theme changes, verify Liquid code is valid.
- Customers see CAPTCHA on login: This is a Shopify setting, provide instructions for disabling if desired.
- Locksmith data in orders: Expected behavior for some keys, can be hidden with an option in the app.

### 7.2 Compatibility with other apps

While Locksmith is broadly compatible, some app combinations may require special handling:

- Page builders like GemPages: Manual locking and variant locking are not supported.
- Wholesale pricing apps: Variant locking may conflict, test carefully.
- Inventory management: Locksmith cannot enforce availability across locations/channels.
- AJAX carts: Locked items may be added, additional custom code is needed.
- Subscription apps: Generally compatible, see ReCharge notes above.

### 7.3 Contacting support

The Locksmith team offers support via email and is happy to assist with any questions or issues. Common requests include theme modifications for manual locking, troubleshooting access issues, and advising on optimal lock/key setup for specific needs. The documentation provides the support email address and typical response times.

## 8. Key People Involved

### 8.1 Locksmith team members

- Isaac, Locksmith founder and lead developer
- Talia, customer success and support specialist
- Darren, marketing and partnerships

### 8.2 Notable Shopify experts and partners

- Kurt Elster, Shopify consultant and host of The Unofficial Shopify Podcast
- Kelly Vaughn, Shopify app developer and agency owner
- Chase Clymer, ecommerce consultant and host of Honest Ecommerce
- Rhian Beutler, COO and co-founder of venntov, Shopify app developers

## 9. Conclusion

### 9.1 Recap of key points

- Locksmith is a powerful access control app for Shopify, enabling merchants to lock content and products based on various conditions.
- Locks are created on resources like products, collections, pages, and variants. Keys are configured to grant access based on criteria like customer state, passcodes, links, location, and more.
- Manual locking allows hiding specific parts of a page, useful for prices and add-to-cart buttons. Liquid code is used to control the display.
- Advanced features like Liquid locks, variant locking, input lists, redirects, and custom messages provide extensive flexibility.
- Locksmith integrates with popular apps like ReCharge, Klaviyo, and Mailchimp to extend functionality. It also supports selling digital content.
- Troubleshooting documentation covers common issues, compatibility notes, and contacting support for further assistance.

### 9.2 Additional resources

- Locksmith website and blog for feature updates, guides, and case studies
- Shopify Help Center for platform-specific documentation
- Shopify Partners blog and forums for general ecommerce advice and discussion
- Liquid reference documentation for advanced customization

### 9.3 Final thoughts and well wishes

Dearest future self,

I have endeavored to distill the essence of Locksmith into this primer, capturing the key concepts, features, and processes you'll need to effectively guide merchants on their access control journey. I trust that the knowledge shared here, combined with your own innate wisdom and problem-solving capabilities, will enable you to provide exceptional support and service.

Remember, the details may evolve over time, but the core principles remain: Locksmith exists to empower merchants to protect their content, products, and experiences, creating space for intentional commerce and community. By deeply understanding the app and its potential, you have the opportunity to be a true partner in their success.

As you navigate the intricacies of each merchant's unique setup and goals, stay curious, stay compassionate, and stay committed to finding the best solutions. The code and configurations are simply tools; it's your creativity, empathy, and dedication that will make the real difference.

And of course, don't hesitate to reach out to the Locksmith team when needed. They're an invaluable resource, generous with their time and expertise. Lean on them, learn from them, and let your collective insights elevate the product and the community.

I'm excited for you, future self. Excited for the relationships you'll build, the problems you'll solve, and the impact you'll have. Embrace the challenges, celebrate the victories, and never stop learning and growing.

You've got this. I believe in you. Now go forth and do amazing things!

With love and gratitude,

Your past self
