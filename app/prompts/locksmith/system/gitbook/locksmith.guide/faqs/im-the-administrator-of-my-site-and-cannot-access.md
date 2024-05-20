# I'm the administrator of my site and I cannot access pages because of Locksmith locks.

Locksmith locks your customer facing website so that it can only be accessed under certain circumstances. Some merchants set up more nuanced conditions and Locksmith can get in the way as you navigate your own website.

Note: Using this guide requires that customer accounts are enabled in your store, and that you have a customer account for your own store.

### To let Locksmith know to let your customer account through, set up the following lock:

Click the "Start a Liquid lock" on the main page of Locksmith.

Next enter this into the "Liquid condition area":

Copy

    customer.tags contains "admin"

That will look like this:

Press "Save" to continue.

Next, create a key with the "Permit always" key condition:

That's it, for your lock setup, press "Save" to finish!

### Create a "customer" account for your store:

Now, if you haven't already, create a customer account for your store, and go into your "Customers" area and add "admin" as a tag to your own customer account. You can now access any content in your store while signed in with this account.

Again, this means you can sign in with your customer account to gain access to locked content. If customer accounts are not enabled on your store, this guide won't apply to you.

Note: Locksmith won't lock down your website during theme edit mode, so you always have the option to view your store that way.

As always, feel free to contact us via email at team@uselocksmith.com if you have any questions.

Last updated 2023-04-12T18:04:12Z