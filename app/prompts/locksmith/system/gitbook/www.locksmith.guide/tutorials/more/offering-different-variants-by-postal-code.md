# Offering different variants by postal code

In this tutorial, we'll talk about configuring a Shopify store to...

- Prompt the visitor to enter their postal code upon arrival
- Only display variants that have their "Postal code" option set to equal the postal code that the visitor entered

To do this, we'll use a series of variant locks, and one shop lock. We'll also use passcode key conditions, leveraging the ability to use a single passcode entry to activate many passcode keys at once.

### Demo store

We've set up a store that contains a couple of sample products, with a handful of supported postal codes.

View demo store (password: locksmith)

### Instructions

#### 1. Configure your product variants

For each of your products, add an option labeled "Postal code". Add one variant for each postal code that you want to support.

In the demo store linked above, here's how the variants are displayed in Shopify, for one of the sample product:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5f875a97c9e77c0016217dc2%2Ffile-Emom5NTJnc.png&width=768&dpr=4&quality=100&sign=b7be6a5427b13c753310af6699bad6585581f2fbc46a7d258cf37fd973b980cc)

#### 2. Lock each variant option

Open the Locksmith app. Using Locksmith's search box, locate each variant option, one at a time:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5f875afb52faff0016aeff5d%2Ffile-k2wckdQsWW.png&width=768&dpr=4&quality=100&sign=aeb7c887bb42b5b5ad3935bd0ea602ae185449a47dfa19904093ea208e66d3fe)

Select the matching item, and continue to save the lock.

On the next screen, add a passcode key, setting the passcode to the same value as the postal code:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5f875b8746e0fb001798d091%2Ffile-PaiQiFP0P9.gif&width=768&dpr=4&quality=100&sign=2928819f67a393536b4196881eb8b14c670288645efbd72f1c2eb3318a4d52d9)

Save the lock.

Repeat for each of your postal codes, resulting in one lock per postal code variant option.

#### 3. Create a lock for the entire online storefront

Back on the home screen of Locksmith, use the "Add lock" form to create a lock that covers the entire online store.

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fd33v4339jhl8k0.cloudfront.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F5f875c3dcff47e001a58e791%2Ffile-AZ8KcONBXO.gif&width=768&dpr=4&quality=100&sign=8b07a3e06cd005a59d35ddfae136a6ebdbd52ad004580ee816e7132c54b26e34)

On the next screen, add a key that permits if the visitor enters one of many passcodes. Configure the passcode list to contain each of the postal codes that you support.

#### 4. Test! :)

You're done! When visitors arrive at your online store, they'll be prompted to enter their postal code. If it's one of the codes on your list, Locksmith will let them in, and will now only show them variants that match the postal code they entered.

Your final Locksmith locks list should look something like this:

To try out the customer side of this, see the demo store linked at the beginning of this article.

[PreviousGranting access to variants by visitor input](/tutorials/more/granting-access-to-variants-by-visitor-input)[NextLocking products by tag](/tutorials/more/locking-products-by-tag)

Last updated 2022-06-29T07:19:39Z