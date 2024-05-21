[Original URL: https://www.locksmith.guide/keys/more/limiting-the-scope-of-variant-locks-using-the-product-tag-key-condition]

# Limiting the scope of variant locks using the product tag key condition

By default, Locksmith's variant locks apply to all matching option/value combinations. For example, you'll typically see something like this:

Once a variant lock is created, you can limit which products it applies to by using the key condition labelled "If the product is tagged with":

You'll use any existing product tags to denote which products you want the variant lock to apply to, or create new product tags if needed.

If you want the lock to apply to variants on one product tag only, and leave all other products untouched, for example, you'll use an inverted key condition like so:

Then, as a separate key, add in your conditions for access to the product. So if you want to allow access to the variant with a sign in, that will look like this:

The result of this is that all matching variants will automatically be unlocked if the product is NOT tagged with "Snowboard". In other words, the variant lock will only apply to products tagged with "Snowboard".

Last updated 2024-02-01T17:56:20Z