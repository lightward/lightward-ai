# Locksmith User Manual

Welcome to Locksmith, the comprehensive access control solution for Shopify! This user manual will guide you through every aspect of using Locksmith to protect and manage access to your store's content.

## Table of Contents

1. Introduction
   1.1. What is Locksmith?
   1.2. Key features
   1.3. Compatibility and limitations

2. Getting Started
   2.1. Installing Locksmith
   2.2. Navigating the Locksmith app
   2.3. Updating Locksmith
   2.4. Removing Locksmith

3. Creating Locks
   3.1. What are locks?
   3.2. Searchable resources
   3.3. Creating a lock
   3.4. Lock settings
   3.5. Locking your entire store
   3.6. Locking all products
   3.7. Liquid locks

4. Creating Keys
   4.1. What are keys?
   4.2. Key conditions
   4.3. Inverting key conditions
   4.4. Combining key conditions
   4.5. The "Force open other locks" setting

5. Key Condition Types
   5.1. Customer account keys
   5.2. Passcode keys
   5.3. Secret link keys
   5.4. Visitor location keys
   5.5. Newsletter keys
   5.6. "Has purchased" key
   5.7. IP address keys
   5.8. Date and time keys
   5.9. Domain keys
   5.10. Cart keys
   5.11. Custom Liquid keys

6. Advanced Features
   6.1. Manual mode
   6.2. Variant locking
   6.3. Input lists
   6.4. Customer auto-tagging
   6.5. Redirects
   6.6. Customizing messages
   6.7. Theme integration

7. Tutorials and Use Cases
   7.1. Approving customer registrations
   7.2. Creating restricted wholesale products
   7.3. Hiding prices and add-to-cart buttons
   7.4. Selling digital content
   7.5. Setting up multiple price tiers
   7.6. Restricting checkout from the cart
   7.7. Protecting against bots
   7.8. Showing content to specific markets

8. Developer Tools
   8.1. Locksmith Admin API
   8.2. Locksmith Storefront API
   8.3. Locksmith variables
   8.4. Unsupported functionality

9. Troubleshooting and FAQs
   9.1. Why aren't my locks working?
   9.2. Blank spaces in collections and searches
   9.3. Issues with search and page builder apps  
   9.4. Slow loading times
   9.5. Installation and uninstallation issues
   9.6. Accessing locked content as an administrator
   9.7. SEO and search engine visibility

10. Support and Resources
    10.1. Contacting Locksmith support
    10.2. Documentation and guides
    10.3. Pricing policy

## 1. Introduction

### 1.1. What is Locksmith?

Locksmith is a powerful Shopify app designed to help merchants control access to their store's content. With Locksmith, you can restrict access to products, collections, pages, blogs, and more, based on a variety of conditions such as customer tags, passcodes, secret links, location, and purchase history.

### 1.2. Key features

- Granular access control for products, collections, pages, blogs, variants, and more
- Over 20 built-in key conditions for flexible access management
- Custom Liquid key conditions for advanced use cases
- Manual mode for hiding specific page elements (e.g., prices, add-to-cart buttons)
- Integration with Mailchimp and Klaviyo for newsletter-based access
- Customizable access denial messages and prompts
- Automatic theme integration and easy setup

### 1.3. Compatibility and limitations

Locksmith is designed to work seamlessly with the Shopify Online Store sales channel. However, there are some limitations and compatibility considerations to keep in mind:

- Locksmith does not work with other sales channels, such as Buy Button or Wholesale.
- Locksmith is incompatible with the Shopify Shop App.
- Some third-party apps, particularly those related to search, filtering, and page building, may not be fully compatible with Locksmith.
- Locksmith cannot protect against direct-to-checkout links or some bot activity.
- Locksmith operates within the theme layer and cannot control access to checkout, shipping methods, billing methods, or coupon codes.

## 2. Getting Started

### 2.1. Installing Locksmith

To install Locksmith, follow these steps:

1. Log in to your Shopify admin panel.
2. Navigate to the Shopify App Store and search for "Locksmith".
3. Click on the Locksmith app listing and then click "Add app".
4. Review and accept the permissions requested by Locksmith.
5. Wait for the installation process to complete. Locksmith will automatically integrate with your active theme.

### 2.2. Navigating the Locksmith app

The Locksmith app consists of several key sections:

- Home: This is the main dashboard where you can create new locks and view your existing locks.
- Settings: Here, you can manage your app settings, customize default messages, and configure advanced options.
- Customers: This section allows you to import customers in bulk and manage customer data.
- Help: Visit this section for support resources, documentation, and the option to update or remove Locksmith.

### 2.3. Updating Locksmith

To ensure Locksmith is running optimally and to access the latest features, it's important to keep the app up to date. To update Locksmith:

1. Open the Locksmith app.
2. Navigate to the "Help" section.
3. Click the "Update Locksmith" button.
4. Wait for the update process to complete, which usually takes a few seconds.

### 2.4. Removing Locksmith

If you need to uninstall Locksmith, it's crucial to follow these steps in order:

1. Open the Locksmith app and go to the "Help" section.
2. Click the "Remove Locksmith" button to clean up the app's code from your theme.
3. Wait for the removal process to complete.
4. Go to your Shopify admin panel and navigate to "Apps".
5. Find Locksmith in the apps list and click "Delete".

Note: If you've manually added any Locksmith code to your theme (e.g., for manual mode or price hiding), you'll need to remove this code manually before uninstalling the app.

## 3. Creating Locks

### 3.1. What are locks?

In Locksmith, locks are used to restrict access to specific content in your Shopify store. By creating a lock, you define which resources (products, collections, pages, etc.) should be protected and under what conditions access is granted.

### 3.2. Searchable resources

Locksmith allows you to lock the following types of resources:

- Products
- Collections
- Pages
- Variants
- Blogs
- Blog posts (articles)
- Product vendors

To lock a blog post, you must first tag the article, then search for the tag in Locksmith.

### 3.3. Creating a lock

To create a lock:

1. Open the Locksmith app and use the search bar on the home page to find the resource you want to lock.
2. Enter the name of the resource (e.g., product title, collection name) and select the appropriate result.
3. Click "Save" to create the lock.
4. Configure the lock settings and add keys (access conditions) as needed.

### 3.4. Lock settings

When you create a lock, you'll have access to various settings depending on the type of resource being locked. Common settings include:

- Activation status: Choose whether the lock is currently active or inactive.
- Protect products in this collection: For collection locks, decide if the lock should also protect individual products within the collection.
- Hide resource from search and lists: Optionally hide the locked resource from search results and other product/collection lists.
- Hide links to the resource: Remove links to the locked resource from your store's navigation menus.
- Manual mode: Enable manual mode for more granular control over which page elements are locked.

### 3.5. Locking your entire store

To lock your entire Shopify store:

1. Open the Locksmith app and click into the search bar on the home page.
2. Select "Entire store" from the dropdown menu.
3. Click "Save" to create the lock.
4. Configure the lock settings, such as allowing access to the home page, policy pages, or customer areas.
5. Add keys to define access conditions for your store.

### 3.6. Locking all products

To lock all products in your store simultaneously:

1. Open the Locksmith app and search for the "all" collection in the search bar.
2. Select "Collection: All" from the search results.
3. Click "Save" to create the lock.
4. Configure the lock settings and add keys as needed.

### 3.7. Liquid locks

Liquid locks allow you to protect resources that aren't directly searchable in Locksmith using custom Liquid conditions. To create a Liquid lock:

1. Open the Locksmith app and click the "Start a Liquid Lock" link above the search bar.
2. Enter your custom Liquid condition in the provided field.
3. Click "Create lock" to save your Liquid lock.
4. Add keys to define access conditions for the locked content.

Liquid locks are an advanced feature that requires knowledge of Shopify's Liquid templating language. They provide flexibility for locking non-standard resources or groups of pages.

## 4. Creating Keys

### 4.1. What are keys?

In Locksmith, keys are the conditions that determine when and for whom access is granted to locked content. Each lock can have one or more keys, and access is granted if any of the keys' conditions are met.

### 4.2. Key conditions

Locksmith offers a wide range of built-in key conditions, including:

- Customer is signed in
- Customer is tagged with a specific tag
- Customer enters a valid passcode
- Customer arrives via a secret link
- Customer's location matches specified criteria
- Customer subscribes to a Mailchimp or Klaviyo list
- Customer has a specific email address or domain
- Customer has placed a minimum number of orders
- Customer has purchased a specific product
- Current date/time is within a specified range
- Custom Liquid conditions

For a complete list of key conditions and their setup instructions, refer to section 5 of this manual.

### 4.3. Inverting key conditions

Most key conditions in Locksmith can be inverted, meaning access is granted if the opposite of the condition is true. To invert a key condition:

1. Edit the key in your lock settings.
2. Check the "Invert" checkbox next to the condition.
3. Save the changes to your lock.

For example, inverting the "Customer is tagged with..." condition would grant access to customers who do not have the specified tag.

### 4.4. Combining key conditions

You can combine multiple key conditions to create more complex access rules. Locksmith supports two types of condition combinations:

- AND: Access is granted only if all conditions in the key are met.
- OR: Access is granted if any of the keys on the lock are met.

To combine conditions with AND:

1. Edit the key in your lock settings.
2. Click the "and..." link next to the existing condition.
3. Select the additional condition from the dropdown menu and configure it as needed.
4. Save the changes to your lock.

To combine conditions with OR, simply add additional keys to your lock, each with its own set of conditions.

### 4.5. The "Force open other locks" setting

If you have multiple locks with overlapping content (e.g., collections containing the same products), you may want to use the "Force open other locks" setting to ensure access is granted consistently. To enable this setting:

1. Edit the key in your lock settings.
2. Locate the "Key options" section.
3. Check the "Force open other locks" checkbox.
4. Save the changes to your lock.

When enabled, this setting tells Locksmith to grant access to all content covered by the current lock, even if other locks might also apply to that content.

## 5. Key Condition Types

This section provides a detailed overview of each key condition type available in Locksmith, along with setup instructions and usage notes.

### 5.1. Customer account keys

Customer account keys rely on Shopify's built-in customer account system to check for specific customer attributes before granting access. To use these keys, customer accounts must be enabled in your Shopify store.

Available customer account key conditions:

- Customer is signed in
- Customer is tagged with a specific tag
- Customer is not tagged with a specific tag
- Customer has placed a minimum number of orders
- Customer has purchased a specific product
- Customer's email contains a specific string
- Customer's email matches one in a provided list
- Customer's email is found in a specified input list

To set up a customer account key:

1. Edit your lock and click "Add key".
2. Select the desired customer account condition from the list.
3. Configure the condition settings (e.g., specify tags, order count, or email criteria).
4. Save the changes to your lock.

When a customer account key is used, Locksmith will display the customer login form from your theme when an unauthorized visitor attempts to access the locked content.

### 5.2. Passcode keys

Passcode keys allow you to grant access to locked content when a visitor enters a valid passcode. There are three types of passcode keys:

- Single passcode: Grants access when the visitor enters a specific passcode.
- Many passcodes: Grants access when the visitor enters any one of a provided list of passcodes.
- Passcode from input list: Grants access when the visitor enters a passcode found in a specified input list.

To set up a passcode key:

1. Edit your lock and click "Add key".
2. Select the desired passcode key type from the list.
3. Configure the passcode settings (e.g., enter the passcode value, list of passcodes, or select an input list).
4. Optionally, set a usage limit or enable customer auto-tagging.
5. Save the changes to your lock.

When a passcode key is used, Locksmith will display a passcode prompt to visitors attempting to access the locked content. If the visitor enters a valid passcode, access will be granted.

### 5.3. Secret link keys

Secret link keys grant access to locked content when a visitor arrives via a special URL containing a secret code. There are two types of secret link keys:

- Regular secret link: Grants access when the visitor uses a URL containing a specific secret code.
- Secret link from input list: Grants access when the visitor uses a URL containing a secret code found in a specified input list.

To set up a secret link key:

1. Edit your lock and click "Add key".
2. Select the desired secret link key type from the list.
3. Configure the secret link settings (e.g., enter the secret code or select an input list).
4. Optionally, enable customer auto-tagging or set an access time limit.
5. Save the changes to your lock.

When a secret link key is used, access is granted only when the visitor arrives at the locked content using a URL that includes the correct secret code. The secret code can be included in the URL in various ways, such as a query parameter or as part of the path.

### 5.4. Visitor location keys

Visitor location keys grant access to locked content based on the visitor's geographic location, as determined by their IP address. You can specify locations at various levels of granularity, such as:

- Regions (e.g., North America, Europe)
- Countries (e.g., United States, Canada)
- States or provinces (e.g., California, Ontario)
- Cities (e.g., New York, London)

To set up a visitor location key:

1. Edit your lock and click "Add key".
2. Select the "Visitor location" condition from the list.
3. Enter the desired location(s) in the search field and select them from the results.
4. Optionally, invert the condition to grant access to visitors not in the specified locations.
5. Save the changes to your lock.

When a visitor location key is used, Locksmith will determine the visitor's location based on their IP address and grant access if it matches the specified criteria. Note that location-based keys may impact SEO, as search engine crawlers will be subject to the same location restrictions as regular visitors.

### 5.5. Newsletter keys

Newsletter keys grant access to locked content when a visitor subscribes to your Mailchimp or Klaviyo mailing list. There are two types of newsletter keys:

- Mailchimp: Grants access when the visitor subscribes toa specified Mailchimp list.
- Klaviyo: Grants access when the visitor subscribes to a specified Klaviyo list or is already present on the list.

To set up a newsletter key:

1. Edit your lock and click "Add key".
2. Select the desired newsletter key type (Mailchimp or Klaviyo) from the list.
3. Connect your Mailchimp or Klaviyo account and select the appropriate list.
4. For Klaviyo keys, optionally enable the "Only grant access if the customer is already on this list" setting.
5. Save the changes to your lock.

When a newsletter key is used, Locksmith will display a newsletter signup form to visitors attempting to access the locked content. Upon successful signup, the visitor will be granted access, and their email address will be added to the specified Mailchimp or Klaviyo list.

### 5.6. "Has purchased" key

The "Has purchased" key grants access to locked content based on a visitor's past purchase history. You can specify a particular product that the visitor must have purchased to gain access.

To set up a "Has purchased" key:

1. Edit your lock and click "Add key".
2. Select the "Has purchased" condition from the list.
3. Enter the title, SKU, or tag of the product that the visitor must have purchased.
4. Configure additional options, such as the maximum quantity purchased, order time frame, and order status filters.
5. Save the changes to your lock.

When a "Has purchased" key is used, Locksmith will check the visitor's order history (up to the last 50 orders) to determine if they have purchased the specified product. If a matching order is found, access will be granted.

### 5.7. IP address keys

IP address keys grant access to locked content based on the visitor's specific IP address or IP range.

To set up an IP address key:

1. Edit your lock and click "Add key".
2. Select the "IP address" condition from the list.
3. Enter the allowed IP addresses or CIDR ranges, one per line.
4. Optionally, invert the condition to grant access to visitors not using the specified IP addresses.
5. Save the changes to your lock.

When an IP address key is used, Locksmith will compare the visitor's IP address to the specified list of allowed addresses or ranges. Access will be granted if a match is found.

### 5.8. Date and time keys

Date and time keys grant access to locked content based on the current date and time. You can set up keys that grant access before or after a specific date and time.

To set up a date and time key:

1. Edit your lock and click "Add key".
2. Select the "Date and time" condition from the list.
3. Choose whether to grant access before or after the specified date and time.
4. Enter the desired date and time using the provided fields.
5. Save the changes to your lock.

When a date and time key is used, Locksmith will compare the current date and time to the specified criteria and grant access accordingly.

### 5.9. Domain keys

Domain keys grant access to locked content based on the domain the visitor is using to access your store. This is useful if you have multiple domains associated with your Shopify store, such as country-specific or language-specific domains.

To set up a domain key:

1. Edit your lock and click "Add key".
2. Select the "Domain" condition from the list.
3. Enter the allowed domain(s) in the provided field.
4. Save the changes to your lock.

When a domain key is used, Locksmith will compare the visitor's current domain to the specified list of allowed domains. Access will be granted if a match is found.

### 5.10. Cart keys

Cart keys grant access to locked content based on the contents and value of the visitor's shopping cart. There are several types of cart keys:

- Has a certain product in the cart
- Has a certain variant in the cart
- Has a minimum cart value

To set up a cart key:

1. Edit your lock and click "Add key".
2. Select the desired cart key type from the list.
3. Configure the key settings (e.g., specify the product, variant, or minimum cart value).
4. Save the changes to your lock.

When a cart key is used, Locksmith will analyze the visitor's current cart contents and grant access if the specified criteria are met.

### 5.11. Custom Liquid keys

Custom Liquid keys allow you to create advanced access conditions using Shopify's Liquid templating language. With custom Liquid keys, you can grant access based on any criteria that can be evaluated using Liquid.

To set up a custom Liquid key:

1. Edit your lock and click "Add key".
2. Select the "Custom Liquid" condition from the list.
3. Enter your custom Liquid code in the provided field. The code should evaluate to either true (access granted) or false (access denied).
4. Optionally, use the "Liquid prelude" field to define variables or perform additional logic before the main condition.
5. Save the changes to your lock.

When a custom Liquid key is used, Locksmith will evaluate the provided Liquid code and grant access based on the result. Custom Liquid keys offer the greatest flexibility but require a solid understanding of Shopify's Liquid templating language.

## 6. Advanced Features

### 6.1. Manual mode

Manual mode allows you to lock specific elements on a page, such as prices or add-to-cart buttons, instead of locking the entire page. This is useful when you want to allow visitors to browse products but restrict certain actions until they meet the lock's access conditions.

To enable manual mode for a lock:

1. Edit your lock and navigate to the "Advanced" settings.
2. Check the "Enable manual mode" checkbox.
3. Save the changes to your lock.

Once manual mode is enabled, you'll need to manually add Locksmith code snippets to your theme to control which elements are locked. Refer to the "Manual mode" guide in the Locksmith documentation for detailed instructions on implementing manual mode.

### 6.2. Variant locking

Variant locking allows you to lock individual product variants, granting access to specific variants based on your lock's access conditions. This is useful for scenarios such as wholesale pricing, inventory allocation, or bulk quantity discounts.

To lock a variant:

1. Open the Locksmith app and search for the variant you want to lock.
2. Select the variant from the search results and click "Save" to create the lock.
3. Configure the lock settings and add keys as needed.

When a variant lock is used, Locksmith will hide the locked variants from visitors who don't meet the access conditions. Note that variant locking may conflict with certain third-party apps, particularly those related to pricing or inventory management.

### 6.3. Input lists

Input lists are a way to manage large sets of passcodes, secret links, or email addresses for use with Locksmith keys. They allow you to store these values in an external file (e.g., Google Sheets, CSV, TXT) and sync them with Locksmith for easier management.

To create an input list:

1. Open the Locksmith app and navigate to "Settings".
2. In the "Extensions" section, click "Add input list".
3. Enter a name for your input list and provide the URL of the external file containing your values.
4. Configure additional options, such as case sensitivity and default usage limits.
5. Save the input list.

Once an input list is created, you can use it when setting up passcode, secret link, or customer account keys by selecting the appropriate "from input list" option in the key settings.

### 6.4. Customer auto-tagging

Customer auto-tagging is a feature that automatically adds tags to customers who gain access to locked content using certain key types. This can be useful for segmenting customers based on their access history or providing additional benefits to customers who have unlocked specific content.

To enable customer auto-tagging for a key:

1. Edit your lock and navigate to the key settings.
2. Locate the "Customer auto tag" field.
3. Enter the tag you want to apply to customers who use this key to gain access.
4. Save the changes to your lock.

Customer auto-tagging is available for passcode, secret link, and newsletter keys.

### 6.5. Redirects

Locksmith allows you to set up redirects for certain key types, automatically sending visitors to a specific URL after they gain access to locked content. This can be used to guide visitors to relevant content or products after they unlock a resource.

To set up a redirect for a key:

1. Edit your lock and navigate to the key settings.
2. Locate the "Redirect URL" field (may be hidden under an "Advanced" or "More options" section).
3. Enter the URL you want to redirect visitors to after they use this key to gain access.
4. Save the changes to your lock.

Redirects are available for passcode and secret link keys. Note that if you set a redirect URL to a page that is itself locked, visitors may encounter an infinite loop.

### 6.6. Customizing messages

Locksmith allows you to customize the various messages and prompts displayed to visitors when they encounter locked content. This includes access denied messages, customer login prompts, passcode and newsletter signup forms, and more.

To customize Locksmith messages:

1. Open the Locksmith app and navigate to "Settings".
2. In the "Content" section, locate the message you want to customize.
3. Edit the message using the provided text editor. You can use HTML, CSS, and Liquid to format and style your messages.
4. Save the changes.

You can also override the default messages for individual locks by editing the lock settings and modifying the messages in the "Messages" section.

### 6.7. Theme integration

Locksmith automatically integrates with your active Shopify theme, injecting its code and content into the appropriate places. However, there may be times when you need to manually adjust your theme to work with certain Locksmith features, such as manual mode or custom message styling.

To manually edit your theme files:

1. In your Shopify admin, navigate to "Online Store" > "Themes".
2. Find your active theme and click "Actions" > "Edit code".
3. Locate the appropriate template file (e.g., product.liquid, collection.liquid) and make the necessary changes.
4. Save the changes to your theme.

Be cautious when manually editing your theme files, as incorrect modifications can break your store's layout or functionality. Always make a backup of your theme before making changes, and consider using a development or staging theme for testing.

## 7. Tutorials and Use Cases

This section provides step-by-step tutorials for common Locksmith use cases and scenarios. Each tutorial will guide you through the process of setting up locks and keys to achieve a specific goal.

### 7.1. Approving customer registrations

In this tutorial, you'll learn how to use Locksmith to create a customer registration approval process, ensuring that only approved customers can access locked content.

1. Create a lock for the content you want to restrict (e.g., a collection, page, or product).
2. Add a "Customer is tagged" key to the lock, specifying a tag that represents approved customers (e.g., "approved").
3. Set up your store's customer registration form to collect any necessary information.
4. As customers register, review their information and manually add the "approved" tag to their customer profile in your Shopify admin.
5. Optionally, use Locksmith's customer import feature to bulk import and tag pre-approved customers.

With this setup, only customers with the "approved" tag will be able to access the locked content. You can review and approve customer registrations at your own pace, granting access as needed.

### 7.2. Creating restricted wholesale products

In this tutorial, you'll learn how to use Locksmith to create wholesale-only products that are hidden from retail customers.

1. Create a collection in Shopify called "Wholesale Products" (or similar).
2. Add your wholesale-only products to this collection.
3. In Locksmith, create a lock for the "Wholesale Products" collection.
4. Add a "Customer is tagged" key to the lock, specifying a tag that represents your wholesale customers (e.g., "wholesale").
5. In the lock settings, enable the "Hide this collection and its products" option to prevent retail customers from seeing the wholesale products.
6. Optionally, create a separate "Retail Products" collection and lock it with an inverted "Customer is tagged" key to hide retail products from wholesale customers.

With this setup, wholesale customers (those with the "wholesale" tag) will be able to access the "Wholesale Products" collection and its products, while retail customers will not see these products at all.

### 7.3. Hiding prices and add-to-cart buttons

In this tutorial, you'll learn how to use Locksmith's manual mode to hide prices and add-to-cart buttons from unauthorized customers.

1. Create a lock for the products or collections you want to apply the price/button hiding to.
2. Add keys to the lock to define the access conditions for seeing prices and add-to-cart buttons.
3. In the lock settings, enable the "Enable manual mode" option.
4. Edit your theme's product template file (usually product.liquid) and wrap the price and add-to-cart button elements with Locksmith's manual locking code snippets.
5. Save the changes to your theme.

With this setup, unauthorized customers will see the product pages without prices or add-to-cart buttons. When a customer meets the lock's access conditions, the prices and buttons will be displayed normally.

### 7.4. Selling digital content

In this tutorial, you'll learn how to use Locksmith to sell access to digital content, such as e-books, courses, or media files.

1. Create a new product in Shopify to represent the digital content you want to sell. Set the price and any other relevant details.
2. Create a new page or blog post containing the digital content you want to protect.
3. In Locksmith, create a lock for the page or blog post containing your digital content.
4. Add a "Has purchased" key to the lock, specifying the product that represents access to the digital content.
5. Optionally, set up a delivery method for the digital content (e.g., email a download link to the customer after purchase).

With this setup, customers who purchase the specified product will automatically gain access to the locked digital content. You can use Shopify's built-in email notifications or a third-party app to deliver the content to the customer after purchase.

### 7.5. Setting up multiple price tiers

In this tutorial, you'll learn how to use Locksmith to create multiple price tiers for your products, such as wholesale and retail prices.

1. For each product you want to have multiple price tiers, create variants representing each tier (e.g., "Wholesale" and "Retail" variants).
2. Adjust the prices for each variant according to your desired price tiers.
3. In Locksmith, create locks for each variant, one for each price tier.
4. Add keys to each lock to define the access conditions for each price tier (e.g., "Customer is tagged" keys for wholesale and retail customers).
5. Optionally, create collections for each price tier and lock them accordingly to help customers find the appropriate products.

With this setup, customers will only see the product variants and prices that correspond to their assigned tier (based on tags or other access conditions). This allows you to offer different prices to different customer groups without needing to create separate products.

### 7.6. Restricting checkout from the cart

In this tutorial, you'll learn how to use Locksmith to restrict access to the checkout process from the cart page, based on various conditions such as minimum order value or customer tags.

1. In Locksmith, create a lock for the cart page.
2. Add keys to the lock to define the access conditions for proceeding to checkout (e.g., "Cart value is at least $100" or "Customer is tagged with 'VIP'").
3. Edit your theme's cart template file (usually cart.liquid) and wrap the checkout button with Locksmith's manual locking code snippets.
4. Save the changes to your theme.

With this setup, customers will only be able to proceed to checkout from the cart page if they meet the specified access conditions. If a customer doesn't meet the conditions, they will see a message indicating why they can't check out (e.g., "Minimum order value not met").

### 7.7. Protecting against bots

In this tutorial, you'll learn how to use Shopify's built-in features and Locksmith to protect your products from being purchased by bots or unauthorized resellers.

1. In Shopify, create a new product to represent the "full-price" version of your product. Set the price significantly higher than the intended retail price.
2. Create a new "private" collection and add the full-price product to it.
3. Create a Shopify discount code that reduces the price of the full-price product to the intended retail price. Set the discount code to only be available to a specific customer group (e.g., customers with a certain tag).
4. Use Locksmith to lock the private collection, allowing access only to authorized customers (e.g., those with the appropriate tag).
5. Share the discount code onlywith your authorized customers, and direct them to the private collection to purchase the product at the intended retail price.

With this setup, bots and unauthorized resellers will only see the full-price version of your product, making it less attractive for them to purchase and resell. Your authorized customers, on the other hand, will be able to access the private collection and use the discount code to purchase the product at the intended price.

### 7.8. Showing content to specific markets

In this tutorial, you'll learn how to use Locksmith to display different content to customers based on their market or location, as defined by Shopify's multi-currency settings.

1. In Shopify, set up your store's markets and currencies as needed.
2. Create separate collections or pages for each market, containing the content you want to display to customers in that market.
3. In Locksmith, create locks for each market-specific collection or page.
4. Add keys to each lock to define the access conditions based on the customer's market. For example:
   - If your markets are defined by currency, use a "Custom Liquid" key with the condition `{{ shop.currency }} == 'USD'` (replace 'USD' with the appropriate currency code).
   - If your markets are defined by domain or URL path, use a "Domain" or "Custom Liquid" key with the appropriate conditions.
5. Optionally, create market-specific navigation menus and lock them accordingly to help customers find the relevant content for their market.

With this setup, customers will only see the collections, pages, and navigation menus that correspond to their market, based on their currency, domain, or location. This allows you to tailor your store's content and experience to different regions or customer groups.

## 8. Developer Tools

### 8.1. Locksmith Admin API

The Locksmith Admin API allows developers to programmatically access and manage their Locksmith configuration, including locks, keys, and settings. The API follows a RESTful design and uses JSON for data exchange.

Key features of the Locksmith Admin API:

- Retrieve a list of all locks in your Locksmith account
- Retrieve details for a specific lock
- Create new locks programmatically
- Update existing locks and their settings
- Manage keys and their conditions
- Retrieve and update Locksmith settings

To use the Locksmith Admin API, you'll need to generate an API access token from your Locksmith account settings. Include this token in the `x-locksmith-access-token` header for all API requests, along with your shop's `myshopify` domain in the `x-shopify-shop-domain` header.

For detailed information on the available endpoints, request/response formats, and authentication requirements, refer to the Locksmith Admin API documentation.

### 8.2. Locksmith Storefront API

The Locksmith Storefront API is a JavaScript-based API that allows developers to integrate Locksmith's access control features into custom storefronts or third-party apps. The API provides methods for checking a visitor's access to specific resources and can be used to conditionally display content or trigger additional actions.

Key features of the Locksmith Storefront API:

- Check a visitor's access to one or more resources in a single request
- Retrieve detailed access information, including applicable locks, keys, and conditions
- Integrate Locksmith with custom search, filtering, or navigation solutions
- Enhance the customer experience by conditionally displaying content or features based on access status

To use the Locksmith Storefront API, you'll need to include a special JavaScript snippet in your storefront or app, which initializes the API and provides the necessary authentication information. You can then use the provided JavaScript methods to interact with the API and retrieve access information for specific resources.

For detailed information on setting up the Locksmith Storefront API, available methods, and response formats, refer to the Locksmith Storefront API documentation.

### 8.3. Locksmith variables

Locksmith provides a set of Liquid variables that developers can use to conditionally display content or customize the behavior of their storefront based on a visitor's access status. These variables are available in all Liquid templates where Locksmith is active and can be used in conjunction with Locksmith's manual locking mode.

Key Locksmith variables:

- `locksmith_access_granted`: Boolean indicating whether the visitor has access to the current resource
- `locksmith_access_denied`: Boolean indicating whether the visitor is denied access to the current resource
- `locksmith_manual_lock`: Boolean indicating whether the current resource is protected by a manual lock
- `locksmith_lock_ids`: Array of lock IDs that apply to the current resource
- `locksmith_opened_lock_ids`: Array of lock IDs that are currently "open" for the visitor
- `locksmith_key_ids`: Array of key IDs that are granting the visitor access to the current resource

To use Locksmith variables in your Liquid templates, simply include the `locksmith-variables` snippet and then reference the desired variables using the `locksmith_` prefix. For example:

```liquid
{% include 'locksmith-variables' %}

{% if locksmith_access_granted %}
  <p>Welcome, you have access to this resource!</p>
{% else %}
  <p>Sorry, you don't have access to this resource.</p>
{% endif %}
```

For a complete list of available Locksmith variables and their descriptions, refer to the Locksmith variables documentation.

### 8.4. Unsupported functionality

While Locksmith is a powerful and flexible access control solution, there are certain limitations and unsupported functionalities that developers should be aware of when integrating Locksmith into their projects.

Key areas of unsupported functionality:

- Locksmith cannot control access to resources outside of the Shopify storefront, such as third-party apps or external websites.
- Locksmith does not have access to Shopify's Checkout process and cannot control access to payment methods, shipping options, or discounts.
- Locksmith may not be fully compatible with certain third-party apps or customizations, particularly those that heavily modify the storefront or bypass Shopify's standard Liquid rendering process.
- Locksmith's access control features may not work as expected with caching solutions or Content Delivery Networks (CDNs) that do not properly handle dynamic content.
- Locksmith cannot prevent access to resources via direct API calls or other methods that bypass the storefront entirely (e.g., Shopify's Storefront API or third-party scraping tools).

If you encounter limitations or incompatibilities while integrating Locksmith into your project, please reach out to the Locksmith support team for assistance and guidance on potential workarounds or alternative approaches.

## 9. Troubleshooting and FAQs

### 9.1. Why aren't my locks working?

If your Locksmith locks don't seem to be working as expected, here are a few things to check:

1. Make sure Locksmith is properly installed and up to date. Go to the "Help" section in the Locksmith app and click "Update Locksmith" to ensure you have the latest version.
2. Check that your lock settings and keys are configured correctly. Review your lock's settings and make sure the appropriate options (e.g., "Hide this collection and its products") are enabled.
3. If you're using passcode, secret link, or newsletter keys, make sure you're testing with a new, incognito browser session to avoid any cached access tokens.
4. If you're using customer account-based keys (e.g., "Customer is tagged"), ensure that the customer account you're testing with has the appropriate tags or attributes.
5. If you're using manual locking mode, double-check that the necessary Liquid code snippets are properly added to your theme files.

If you've gone through these steps and your locks still aren't working, please contact the Locksmith support team for further assistance.

### 9.2. Blank spaces in collections and searches

If you're using Locksmith to hide products from collections or search results, you may notice blank spaces where the hidden products would normally appear. This is because Shopify's collection and search templates don't automatically adjust for hidden products, leading to gaps in the layout.

To minimize the appearance of blank spaces, you can try the following:

1. Increase the number of products shown per page in your collection and search templates. This will help fill in gaps caused by hidden products.
2. Use Shopify's "Automated Collections" feature to create separate collections for locked and unlocked products, ensuring that each collection only contains products visible to the appropriate customer groups.
3. Use a Shopify app or custom code to implement "infinite scroll" or "load more" functionality on your collection and search pages, which can help smoothly load additional products as the customer scrolls.

Keep in mind that some blank spaces may still be inevitable, particularly if you have a large number of hidden products. Experiment with different strategies to find the best balance for your store's design and user experience.

### 9.3. Issues with search and page builder apps

Some third-party Shopify apps, particularly those related to search, filtering, and page building, may not be fully compatible with Locksmith's access control features. This is often because these apps bypass Shopify's standard Liquid rendering process, making it difficult for Locksmith to inject its access control logic.

If you're experiencing issues with a specific app, consider the following:

1. Check the app's documentation or support resources for information on compatibility with access control apps like Locksmith.
2. Reach out to the app's support team to discuss potential workarounds or integration options.
3. Use Locksmith's Storefront API to manually integrate access control into the app's functionality, if the app supports custom JavaScript or Liquid code injection.
4. Consider alternative apps or solutions that are known to be compatible with Locksmith, or that offer built-in access control features.

If you're unable to find a suitable solution, please contact the Locksmith support team for further guidance and assistance.

### 9.4. Slow loading times

In some cases, using Locksmith may result in slower loading times for your storefront, particularly if you have a large number of locks or complex access control rules. This is because Locksmith needs to evaluate each visitor's access to the requested resources before rendering the page.

To minimize the impact on loading times, consider the following:

1. Review your lock settings and disable any unnecessary "Hide from navigation" or "Hide from search and collection" options, as these can cause Locksmith to run additional checks on each page load.
2. Simplify your access control setup by combining similar locks or using fewer, more targeted keys.
3. Use Locksmith's manual locking mode to protect specific page elements rather than entire pages, reducing the number of full-page locks needed.
4. Optimize your theme's Liquid code and assets to ensure fast rendering times, minimizing the impact of Locksmith's additional processing.
5. Use a content delivery network (CDN) or caching solution that supports dynamic content, ensuring that Locksmith's access control checks are only run when necessary.

If you've optimized your setup and are still experiencing slow loading times, please contact the Locksmith support team for further investigation and assistance.

### 9.5. Installation and uninstallation issues

If you encounter issues while installing or uninstalling Locksmith, follow these steps to resolve the problem:

1. Make sure you're using a supported Shopify theme and that your theme files are up to date. Locksmith may have difficulty installing on heavily customized or outdated themes.
2. Check that you have the necessary permissions to modify your theme files. If you're not the store owner or a staff member with appropriate access, you may need to request assistance from someone with the required permissions.
3. If you're uninstalling Locksmith, make sure to first remove any manual locking code snippets from your theme files, as these can cause issues if left in place after the app is removed.
4. If you're using a third-party page builder or app that modifies your theme files, try temporarily disabling the app and reinstalling Locksmith to see if the issue persists.
5. If you've recently changed your theme, make sure to update Locksmith by clicking the "Update Locksmith" button in the app's "Help" section to ensure compatibility with your new theme.

If you've tried these steps and are still experiencing installation or uninstallation issues, please contact the Locksmith support team for further assistance.

### 9.6. Accessing locked content as an administrator

As a store administrator, you may find that Locksmith's access control rules prevent you from accessing certain content in your storefront. To bypass Locksmith's restrictions and access locked content as an administrator, you can use the following methods:

1. Use Shopify's theme editor: Locksmith does not apply its access control rules when previewing your store through the Shopify theme editor. Navigate to "Online Store" > "Themes" in your Shopify admin, click the "Customize" button next to your active theme, and browse your store as normal.
2. Create a customer account for testing: Create a new customer account in your Shopify admin and assign it the necessary tags or attributes to bypass Locksmith's access control rules. Use this account to log in to your storefront and test your locked content.
3. Use a Liquid lock with a customer tag condition: Create a new Liquid lock with a condition that checks for a specific customer tag (e.g., "admin"). Assign this tag to your own customer account, and add an "Always permit" key to the lock. This will allow you to access locked content when logged in with your tagged account.

Remember that these methods are intended for testing and administrative purposes only. Be sure to thoroughly test your Locksmith setup using non-administrator accounts to ensure that your access control rules are working as intended for your customers.

### 9.7. SEO and search engine visibility

Locksmith automatically takes steps to prevent locked content from being indexed by search engines, ensuring that your access control rules are respected and that unauthorized users cannot discover protected content through search results.

By default, Locksmith adds a "noindex" meta tag to locked pages, instructing search engines not to index the content. Additionally, Locksmith can be configured to hide locked products and collections from your storefront's sitemap, further reducing their visibility to search engines.

However, there are some situations where Locksmith's SEO protection may not be sufficient or may conflict with your desired search engine visibility:

1. If you're using Locksmith's manual locking mode to protect specific page elements (e.g., prices or add-to-cart buttons), the rest of the page content may still be indexed by search engines.
2. If you're using Locksmith to protect content based on geolocation or IP address, search engine crawlers may be unable to access the content, leading to inconsistent indexing.
3. If you have locked content that you want to be discoverable by search engines (e.g., teaser pages or lead-generation forms), you may need to adjust your Locksmith settings to allow indexing of those specific pages.

To strike the right balance between access control and search engine visibility, consider the following:

1. Use full-page locks for content that should be completely hidden from search engines, and use manual locking mode for content that can be partially indexed.
2. If you're using geolocation or IP-based access control, consider allowing search engine crawlers to bypass these restrictions to ensure consistent indexing.
3. For locked content that you want to be discoverable, use descriptive, keyword-rich titles and meta descriptions to improve search engine visibility, and consider using Locksmith's "noindex" settings to control which pages are indexed.

If you have specific questions or concerns about how Locksmith may impact your store's SEO, please contact the Locksmith support team for guidance and recommendations.

## 10. Support and Resources

### 10.1. Contacting Locksmith support

If you need assistance with Locksmith, have questions about its features, or encounter any issues, the Locksmith support team is here to help. You can reach out to the support team through the following channels:

- Email: Send a message to team@uselocksmith.com with a detailed description of your question or issue, including any relevant screenshots or error messages.
- In-app support: Click the "Help" button within the Locksmith app to access additional support resources and contact options.
- Shopify App Store: Visit the Locksmith listing on the Shopify App Store and click the "Support" tab to find contact information and submit a support request.

The Locksmith support team typically responds to inquiries within 24 hours, often sooner. When contacting support, please provide as much information as possible about your issue, including your shop's URL, the specific lock or key in question, and any steps you've already taken to troubleshoot the problem.

### 10.2. Documentation and guides

Locksmith offers a comprehensive set of documentation and guides to help you get the most out of the app and its features. These resources cover a wide range of topics, from basic setup and configuration to advanced use cases and integrations.

Key resources include:

- Locksmith User Manual: A detailed, step-by-step guide to using Locksmith, covering all features and functionalities (you're reading it now!).
- Locksmith Help Center: A searchable knowledge base containing articles, tutorials, and frequently asked questions, accessible from within the Locksmith app.
- Locksmith Blog: Regular blog posts showcasing new features, use cases, and tips for getting the most out of Locksmith.
- Locksmith API Documentation: Detailed documentation for developers looking to integrate Locksmith with custom storefronts or third-partyapps, covering the Locksmith Admin API and Storefront API.
- Locksmith Video Tutorials: A collection of video walkthroughs and tutorials covering various aspects of Locksmith setup and usage.

To access these resources, visit the Locksmith website at www.uselocksmith.com or navigate to the "Help" section within the Locksmith app.

### 10.3. Pricing policy

Locksmith operates on a unique "Pay What Feels Good" pricing model, which allows you to choose a price that aligns with the value you receive from the app. This approach ensures that Locksmith remains accessible to merchants of all sizes while fostering a transparent and mutually beneficial relationship between the app and its users.

Under the "Pay What Feels Good" model:

1. Upon installing Locksmith, you'll be presented with a suggested price based on your Shopify plan. This price is typically set at one-third of your monthly Shopify subscription cost.
2. If the suggested price feels fair and aligns with the value you expect to receive from Locksmith, you can proceed with the payment and start using the app.
3. If the suggested price doesn't feel right, you're encouraged to reach out to the Locksmith team and propose a price that better reflects the value Locksmith provides to your business. The team will work with you to find a mutually agreeable price point.
4. If the Locksmith team is unable to accommodate your proposed price, they'll explain their reasoning and suggest an alternative. The goal is to have an open, honest conversation about pricing that leads to a fair outcome for both parties.

The "Pay What Feels Good" model is designed to promote transparency, flexibility, and fairness in pricing. By having open conversations about the value Locksmith provides and the price that feels right for your business, the Locksmith team aims to build long-lasting, mutually beneficial relationships with its users.

For more information on Locksmith's pricing policy and the philosophy behind "Pay What Feels Good," visit www.uselocksmith.com/pricing.

---

This concludes the Locksmith User Manual. We hope this comprehensive guide has provided you with the information and resources needed to effectively use Locksmith to control access to your Shopify store's content.

If you have any further questions, encounter issues not covered in this manual, or need additional support, please don't hesitate to reach out to the Locksmith team at team@uselocksmith.com.

Thank you for choosing Locksmith as your access control solution. We look forward to helping you protect and manage your store's content.