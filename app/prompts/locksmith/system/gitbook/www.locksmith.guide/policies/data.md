# Data policy

Locksmith only accesses what it needs to, and only stores on its servers what it must. We work hard to make securing your content easy, while keeping our systems safe and efficient in the process.

This document contains a summary of what data Locksmith accesses and why, and concludes with a summary of what data Locksmith does and doesn't keep on its servers.

## Accessing your Shopify data

When you install Locksmith for the first time, you'll be prompted to grant access to several areas of your Shopify store, with a screen that looks like this:

Each of these permissions has a purpose. Let's review them:

### View Shopify account data

This is a required permission for every Shopify app. It allows us to identify your store.

### View products

We use this permission to allow you to search for and protect your products and collections.

### Manage orders

This permission is only requested when you've elected to have Locksmith remove its metadata from your orders – which is only relevant when using certain types of key conditions. For more about this, see Why is Locksmith adding information to my orders?.

### Manage customers

We use this permission to record access decisions for your customers, to perform auto-tagging (as configured) and to allow our support team to view customer details to help merchants with troubleshooting.

### Manage your Online Store

Locksmith lives in your online store's theme. We use this permission to install, maintain, and remove (at your request) Locksmith's code.

## Storing your Shopify data

### Where Locksmith's data is stored

All of our data is stored on encrypted volumes in the US.

### What Locksmith stores

- We keep a copy of your shop's basic details (name, domain name, owner name, email address, Shopify account type, etc) for basic bookkeeping and support.
- Lock and key configuration is stored exclusively on Locksmith's servers. This configuration is used to generate code to be inserted into your shop's theme (see "Manage your Online Store", above), but the configuration itself is stored on our end.
- We may store temporary copies of your theme's files, to make any updates to those files as fast as possible.
- For content protected by server keys in version v5 exclusively, we may store a temporary copy of the content as viewed by the visitor. This content is never transmitted unencrypted. The temporary copy expires automatically, and is used only to speed up the visitor experience.

### What Locksmith doesn't store

- We do not store any of your customer data. While we may access a customer's account for purposes of applying tags or updating metafields, or for debugging purposes, no customer data is stored on Locksmith's servers.
- We do not store any of your shop's order data. We may access your order data if you've configured Locksmith to do so (see Why is Locksmith adding information to my orders?), but no order data is stored on Locksmith's servers.

[PreviousPrivacy policy](/policies/privacy)[NextContact us](/policies/contact)

Last updated 2022-11-10T00:32:23Z