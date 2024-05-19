# I'm the administrator of my site and I cannot access pages because of Locksmith locks.

Locksmith locks your customer facing website so that it can only be accessed under certain circumstances. Some merchants set up more nuanced conditions and Locksmith can get in the way as you navigate your own website.

Note: Using this guide requires that customer accounts are enabled in your store, and that you have a customer account for your own store.

### To let Locksmith know to let your customer account through, set up the following lock:

Click the "Start a Liquid lock" on the main page of Locksmith.

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5f0696972c7d3a10cbaa4287%2Ffile-UvH2jyCKZZ.png&width=768&dpr=4&quality=100&sign=5c48a601ff8c18dc2407fd513a84499984abb7437edcb8caba265e1938105b99)

Next enter this into the "Liquid condition area":

Copy

    customer.tags contains "admin"

That will look like this:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5e1cee9204286364bc93d581%2F5e1cee218d16c.png&width=768&dpr=4&quality=100&sign=c835baf545c3ecdf30dcd924d468eb88a543b9bad983381348c090a85ede1b75)

Press "Save" to continue.

Next, create a key with the "Permit always" key condition:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5e1cee922c7d3a7e9ae625bd%2F5e1cee21de111.png&width=768&dpr=4&quality=100&sign=07719adbffd597cfcf64149d27c5f58914c6baad11766d9e288b74ad860fe718)

That's it, for your lock setup, press "Save" to finish!

### Create a "customer" account for your store:

Now, if you haven't already, create a customer account for your store, and go into your "Customers" area and add "admin" as a tag to your own customer account. You can now access any content in your store while signed in with this account.

Again, this means you can sign in with your customer account to gain access to locked content. If customer accounts are not enabled on your store, this guide won't apply to you.

Note: Locksmith won't lock down your website during theme edit mode, so you always have the option to view your store that way.

As always, feel free to contact us via email at team@uselocksmith.com if you have any questions.

[PreviousWhat should I do if my site is loading slowly?](/faqs/what-should-i-do-if-my-site-is-loading-slowly)[NextMore FAQs...](/faqs/more)

Last updated 2023-04-12T18:04:12Z