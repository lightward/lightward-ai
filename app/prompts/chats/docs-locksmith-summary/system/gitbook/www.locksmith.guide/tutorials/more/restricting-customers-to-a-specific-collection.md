# Restricting customers to a specific collection

With Locksmith, it is simple to lock down a specific collection, so that it can only be viewed by a specific set of customers. However, some merchants want to take it one step further and make sure that those customers can only access their collection, while the rest of the store is restricted to them.

### Part 1: Create the collection lock

Add a lock to the collection that you want these customers to access. Use the search bar in Locksmith to search for the collection by name:

Under "Keys", choose how these customers will gain access. You can use whatever method of access you want. The most common way of granting access in this scenario is to use "customer tags" to grant access:

Make sure the "Force open other locks" setting is turned on for this lock. Use the following guide to do this: Using the "Force open other locks" setting . This setting is important.

### Part 2: Create a lock covering the rest of the store

In order to make sure that these customers can't see the rest of your store, you need to actually add a lock to your "entire shop":

For your key condition, you need to use the "invert" option to obtain the opposite of the first key condition:

Use the guide here if you need more guidance on how to invert your key condition:

[pageInverting conditions in Locksmith](/keys/more/inverting-conditions-in-locksmith)

If this is a private collection, no further action necessary. If the collection is meant to be viewed by all customers, you'll also want to use the "force open other locks" setting on the lock for the entire store.

[PreviousCustomizing the passcode form](/tutorials/more/customizing-the-passcode-form)[NextPasscode-specific redirects](/tutorials/more/passcode-specific-redirects)

Last updated 2023-11-04T18:42:29Z