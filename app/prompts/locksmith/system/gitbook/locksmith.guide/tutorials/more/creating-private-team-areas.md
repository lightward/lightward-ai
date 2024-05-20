# Creating private team areas

Locksmith can be used to create separate areas of your store for different teams, clubs, organizations, or other groups. These areas are intended to be private, only for the eyes of those members.

There are two common approaches for determining access, and for routing customers to the right area:

- Using customer data to only reveal the customer's area
- Using passcodes to redirect customers to the right area

Caution: Because of the involvement of setting this up, the limitations of the navigation, etc, it is not recommended to try to set this up if you have more than 10-15 unique customer groups.

## Using customer data to only reveal the customer's area

Use this approach if you know your customers will already have registered customer accounts, and if you're able to use customer tags (or other piece of customer information) to identify a customer as belonging to a certain team.

1. Create a collection for each of your groups
2. Use Locksmith to create locks for each of your teams' collections. Make sure each lock is configured to hide menu links from unauthorized visitors.
3. On each lock, add a key that applies to the group of customers that will be accessing this group of collection. Use a key condition that uses data from the customer's Shopify record - customer tags would be the simplest option.
4. Add links to each of your team collections to your shop's main navigation menu.
5. To direct customers to their content: create a brand new page called "Team Login" (or whatever makes sense in your case.. This page will only be used to ask customers for their credentials and then point them to the navigation bar. You can edit the content of the page to say something like: "You're signed in! Use the navigation bar to access your collection".

With this setup, customers will visit the "Team Login" page and sign in. After this is done, the navigation link that applies to them will appear and they will be able to access their collection from the navigation bar.

## Using passcodes to redirect customers to the right area

Use this approach if you want your customers to self-direct themselves, by entering a secret code. This way, the customer does not have to log in: they only have to type in a valid passcode, and Locksmith will route them to the right area for them.

1. Use Locksmith to create locks for each of your teams' collections.
2. On each lock, add a passcode key, choosing a unique passcode that is not shared with any other collection lock.
3. Create a new page in your online store, called "Team access" (or similar). Create a lock for this page with Locksmith.
4. On this page lock, add one passcode key per team, creating an identical set of keys to those you created for your collections. Then, for each key, click the triple-dot icon on the right, and set the "Redirect URL" option to the URL for the collection associated with that passcode. For an illustration of this, see our guide on passcode-specific redirects.

With this setup, you can direct your customers to this page, and Locksmith itself will redirect them to the appropriate area, once they've entered a valid passcode.

Last updated 2024-03-21T20:07:17Z