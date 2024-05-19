# A Locksmith Overview

Locksmith is a simple yet powerful tool to help you make sure the right people see the right things in your Shopify store. In the spirit of the name of our app - ✨ Locksmith ✨ - you'll be using "locks" to determine what content in your store is restricted and using "keys" to denote how, when, and who gets access.

## Locks

Locks are created using the search bar within our Locksmith app. You can search for most resources in your store by name. More in depth information on the in-app search bar here:

[pageCreating locks](/basics/creating-locks)

A lock restricts access to something on your shop.

You can lock:

- Your entire shop
- Pages
- Products
- Collections
- Prices - more information here.
- The shopping cart
- The login page
- The registration page (type 'register' into the Locksmith search bar)
- Product variants
- And more, with custom Liquid locks: Create a custom lock by clicking the Start a Liquid Lock link above the Locksmith search bar..

After searching, once you select the search result you want to hide and click Save. You'll see some useful options, such as:

- Is the lock currently active?
- Should it also protect the products in this collection? (Disabling this means only the collection page itself will be locked.)
- Should it hide the collection, and it's products, from search results and other lists?
- Should it hide links to this resource from navigation?
- Under Advanced: Is this a manual lock? (More on that here.)

You'll see different options depending on what type of resource you’ve locked.

## Keys

A key permits access to the locked resource based on your criteria. They are created on the lock page using the "+ Add key" button:

Keys allow you to specify the exact conditions that give your customers access to the locked resource.

- Check out the full list of keys in the dropdown menu on a lock page.
- You can also create your own custom keys with Liquid. Create a custom key by choosing custom Liquid from the keys menu.

More information on creating keys here:

[pageCreating keys](/basics/creating-keys)
## Chaining (Combining) conditions together: OR versus AND

Locksmith gives you flexibility to add multiple keys and logically combine them together to create unique unlock conditions.

### OR

- When you set up your key, you can create another key right away, by clicking on Add Another Key. This button allows you to add another separate key to your lock.
- Keys connected by the OR operator can individually open your lock whether or not the conditions on the other keys are met.

This allows you to specify multiple different conditions that a customer can use to access. When used, a customer only needs to meet one of the conditions in order to access.

Notice that there are multiple key symbols, and each key is preceded by "Permit if the customer..." text:

### AND

- Adds another condition to the current key. Choose your first key, and then click the link to the right labeled "and..." to add a second condition.
- If you connect key conditions with AND, all of those conditions must be met before the visitor gets access.

Notice that there is only one key symbol for each key, and each condition is inset under the symbol and text:

[pageCombining key conditions](/keys/more/combining-key-conditions)
## Inverting Keys

Use the inverse of a key for added flexibility.

- In the key, click the "invert" box in the upper right.
- This creates the opposite effect for the key.
- For example: Permit if the customer is not visiting from the United States. --When used on the Locations key.

Our guide that explains this a bit more is here:

[pageInverting conditions in Locksmith](/keys/more/inverting-conditions-in-locksmith)
## The "force open other locks" setting

If you have created several locks that cover overlapping content (e.g. locked collections with some of the same products inside), you may want to turn ON the "force open other locks" key setting. This setting tells Locksmith to grant access to all of the content covered by the current lock, even if other locks might apply:

[pageUsing the "Force open other locks" setting](/keys/more/using-the-force-open-other-locks-setting)

Let us know if you have any questions for us! You can contact us via email at team@uselocksmith.com.

[PreviousQuick Start](/)[NextCreating locks](/basics/creating-locks)

Last updated 2023-11-12T22:31:39Z