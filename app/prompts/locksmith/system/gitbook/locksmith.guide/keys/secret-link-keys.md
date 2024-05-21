[Original URL: https://www.locksmith.guide/keys/secret-link-keys]

# Secret link keys

Note: Some marketing and email services (such as Klaviyo or Mailchimp) may automatically add tracking information to the end of a URL to monitor clicks or other metrics. This code will also need to be separated from the secret link's extension code using an ampersand (&). See the Secret link formatting section of this guide for more information.

Testing: We strongly recommend testing your secret links in the same manner they will be sent to customers before launching a marketing campaign or exclusive sale. This ensures that customers receive a functioning link.

In Locksmith, a "secret link" is a Shopify URL that contains a "secret code" on the end of it, like this:

https://example.com/products/example?ls=FoO-rNBaTquJgqh1tbXjEQ

When a locked resource has a secret link key, only visitors who arrive via that link will be able to view the resource. This makes secret links useful for secret sales, or for offering specific products that are only available via certain ad campaigns.

## Setup

To configure a secret link, start by creating a lock (If you need more information on creating a lock, start with our guide here).

Then, in the lock settings, follow the prompts to create a secret link key:

### Secret link types

#### Regular secret links

This will generate a single secret link for you that can immediately copy and use. You can also enter a custom secret link code if preferred. The setup is very straightforward (shown in the screenshot above).

#### Secret links from an input list

It is also possible to use secret links in conjunction with our input list feature. Input lists allow you to store a list of links in a google sheet or other outside file source. This is great for merchants that want to easily create a large list of unique secret links that can be used. Go here for information on setting up input lists. To use the input list version, select it instead of the regular secret link key condition type.

Input lists also allow you to create usage limits on your secret links (usage limits are not possible for the single secret link option). So, for example, you could create a large list of secret links that could each only be used one(the input list guide, link just above, gives more information on setting this up). Or, you could simply add in a single secret link with a large usage limit.

To use the input list version of the secret link key, select it from the key dropdown:

## How secret links work

Secret links consist of two parts:

- The secret link code (top box): This is the "secret" part of the link, which you can change to whatever you like.
- The full secret link (bottom box): This is the link you send your customers, or whoever should see the locked content. It's the regular URL for your locked content, with the secret link code appended to it. Click the copy button to copy to your clipboard.

Want your link code to be something different? You can simply change that, and it will update the full link:

### Secret link formatting

It's important to note that the secret link code must be an exact match in order to work. If the customer accidentally adds a character to the end of that link, they won't get access.

Having said that, there is some flexibility on how the URL is constructed. The secret link code can be presented in several, valid ways, illustrated here:

- https://example.com/?ls=MYSUPERSECRETLINK
- https://example.com/?another\_parameter=ABC123&ls=MYSUPERSECRETLINK
- https://example.com/?ls=MYSUPERSECRETLINK&another\_parameter=ABC123&...
- https://example.com/products/my-product?variant=32213744255111¤ty=USD&ls=MYSUPERSECRETLINK

Please note that the secret link must use URL-friendly characters in order to be evaluated correctly.

Acceptable characters are:

- Alphanumeric: 0-9a-zA-Z
- Special characters: $-\_.+!\*'()

## Usage notes

### Returning visitors

Once a visitor arrives via a secret link, Locksmith will remember their access for a while. If you're testing, this can make it look like the key is no longer working. For more on this, see Why isn't my passcode, secret link, or newsletter key working?.

The secret link key condition also has a "Grant access for a limited time" option that can revoke a customer's access after a set amount of time passes from initial use. Details on using this option are here: Grant access for a limited time when using passcodes or secret links

Note: removing a secret link from a lock, or changing a secret link's extension code will revoke access for any customers who used the original secret link.

### Re-using secret link codes

If you've got several secret link keys, across different locks, any keys that re-use the same secret code will all be activated when one link is used. This way, you can unlock several pieces of content across your store, using only a single secret link.

### Using a vendor's referral link as a secret code

If you're using a referral service (or any other service that generates a URL with a specific code at the end), you can use the referral URL's "querystring" as the secret code for your key.

For example, if you're using a referral URL that looks like https://example.com/?rfsn=abc123, you may set your secret link code to "rfsn=abc123", and your Locksmith key will Just Work™.

### Restricting where locked content is revealed

If your lock has been configured for resource hiding, the successful use of a secret link will reveal the hidden resource across your online store. If you'd like to make sure that your locked product (for example) can only ever be viewed on its product page, and never via store search or collection listings, add a second condition to your key which limits the key's usage to only the product page.

To do this, use the "and..." link next to your existing key, and select the "(custom Liquid)" option. Fill in the Liquid condition with request.page\_type == "product", as shown below.

The result: your secret link key will continue to work normally, but the access afforded by the key will only work when the visitor is literally on a product page. This means that the key will not kick in when the visitor is (for example) looking at search results, which means that the product will remain hidden in those places.

## Somethings to be mindful of when sending customers secret links

- It "ls=" hasn't been included at the beginning of the secret link code. A secret link code can still work without this, but if a customer is visiting your store for the first time, Shopify may be unsure of what the code at the end of the URL is doing and could redirect customers to the homepage before the lock is opened. This might make it appear as though the secret link isn't working. However, a second attempt usually succeeds. Including "ls=" at the beginning of the secret link code should prevent this issue.
- If you're sending out a marketing email or similar communication, make sure to test the email first. Sometimes the wrong or incomplete secret link can be added, or the marketing email can unexpectedly modify or add additional information to the URL.
- If additional information is being added to the URL, ensure that it is separated from the secret link code using an ampersand (&). This allows Locksmith to differentiate the secret link code from other information. See the Secret link formatting section of this guide for more information.

Last updated 2024-05-08T21:08:10Z