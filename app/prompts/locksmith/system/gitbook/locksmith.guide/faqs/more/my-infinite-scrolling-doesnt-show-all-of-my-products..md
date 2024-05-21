[Original URL: https://www.locksmith.guide/faqs/more/my-infinite-scrolling-doesnt-show-all-of-my-products.]

# My infinite scrolling doesn't show all of my products.

## Background

In general, collections with infinite scrolling work like this:

1. The page loads with the first set of products, from page 1.
2. The user scrolls down to the end, your shop loads page 2 in the background, and then inserts the products from page 2 after all of the products already on the screen.
3. Repeat step 2, for each additional page available.
4. When the next page, loaded in the background, is found to have no products on it, your shop stops trying to load additional pages.

With Locksmith, Step 4 is where things get interesting.

Product hiding is a frequently-used feature of Locksmith - it allows you to mix your protected and unprotected products in the same collection, ensuring that your customers see only the products they should see.

A side-effect of this is that each page of your collection may not be "full". For example, if your page size is 10, a user that is authorized to see everything will see 10 products on page 1, but a user who's only authorized to see 5 products will only see 5 products, even if page 2 has more products available.

(We have a whole article about this here: Improving collection filtering.)

Now, imagine that you have a collection for which the user can see 10 products on page 1, 10 products on page 2, zero products on page 3, and another 10 products on page 4. This might be annoying without infinite scrolling, but with infinite scrolling it becomes impossible for the user to reach the last set of products. Remember: in step 4 of the infinite scrolling process, when an empty page is encountered, the shop stops trying to load more products.

## Solutions

1. Increase the page size (usually configurable in your theme settings), so that there are never any empty pages of products. It's much easier to accidentally have an empty page if each page is limited to a small number of products, and much harder to have that happen if you use the maximum page size of 50.
2. Or, hire a theme developer to alter the infinite scrolling code for your theme, so that it only stops trying to load more products after encountering several empty pages, instead of after only encountering one.

## Notes

- This doesn't apply to server keys (e.g. passcodes, secret links). In most cases, infinite scrolling will not work with these keys. If it doesn't work in your theme, there is no workaround, short of disabling infinite scrolling, or going with a new theme entirely.

Last updated 2022-08-09T02:23:29Z