# Creating locks

How to use Locksmith's in-app search bar to create a lock

Locksmith uses the idea of locks to restrict access to specific content in your store. You can granularly control which content is restricted by adding a lock to the applicable resource.

Use the search bar within Locksmith to place a lock on any content within your Shopify "Online Store". To use it, search for your resource by name:

Hint: Use specific search terms such as "Long Sleeved T-shirt". Pasting in URLs won't work in most cases.

### What is searchable

Here are the types of resources that you are able to lock (and search for) from within Locksmith:

- Products
- Collections
- Pages: more info on Shopify pages here
- Variants: more info on Shopify product variants here
- Blogs: more info on Shopify blogs here
- Blog posts (also called articles): You must tag an article first, and then the article tag will be searchable. More info on blog posts here
- Product vendors

### Specifying a resource type when searching

Locksmith allows you to specify the resource type to search for. This is helpful when you get many results from search term, but they aren't what you're looking for.

Try this syntax in the search bar:

- product:snowboard
- collection:snowboards
- page:about snowboards
- blog:life is snowboarding

Hint: If you are attempting to search for one of the above resources, and it doesn't show up, the first thing to do is to update Locksmith(see "Updating Locksmith" below), which will update Locksmith's list of searchable resources in your store.

### What is not searchable

- Product tags: to lock a group of products with the same tag create an Automated Collection, and then lock the collection using Locksmith.
- Third party apps
- Any page that is not located inside of your Online Store
- Menus and menu links: Menu links are not directly searchable, but they can still be hidden from unauthorized access, as long as they point to one of the resource types in the list at the top of this page. In this case, just make sure the option to "Hide any links to this [resource] in your shop’s navigation menus" is turned on (under Settings) for the corresponding lock.

### Locking your entire store

Simply click into the search bar:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2F277214568-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-MUeGWHuijBPr8Og1Gta%252Fuploads%252Fp16tHdFSe1yRflLslJMd%252FScreenshot%25202024-05-01%2520at%25207.03.12%2520PM.png%3Falt%3Dmedia%26token%3Debe20010-d285-4824-9744-5cd329548e52&width=768&dpr=4&quality=100&sign=386b42fb124a1880e70b920e1aa68311ba05da3acfd211205a503f8aafb44edd)

Once you do that, you'll see "Entire store" show up in the dropdown as an option to lock:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2F277214568-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-MUeGWHuijBPr8Og1Gta%252Fuploads%252FFrLzVd72wBDWqtpa7ZVT%252FScreenshot%25202024-05-01%2520at%25207.03.58%2520PM.png%3Falt%3Dmedia%26token%3D01f56059-a5e3-4393-bba1-4f1c06d37654&width=768&dpr=4&quality=100&sign=3107195d4e8d7a712e68c79bd53de382b39ca5ee2f847535f7baa88ba3a10ced)

#### Excluding resources form the store lock

The store lock's settings page has a few options for excluding resources from the store lock, so they remain accessible to everyone. Those options include:

- Allow access to the home page
- Allow access to policy pages
- Allow access to customer areas

For resources that you would like to exclude form the store lock that aren't covered by those lock options, we have guide on excluding content from locks here:

[pageExcluding content from locks](/keys/more/excluding-content-from-locks)
### Locking all products in your store

By default, Shopify stores feature an 'All' collection that automatically encompasses all products in the store. Locking this collection offers an efficient method to secure all products in your Shopify store simultaneously, without the need to lock the entire store. This collection can be locked just like any other collection. Search for the collection title 'all', select 'Collection: All' from the list of results, and follow the steps to create your lock.

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2F277214568-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-MUeGWHuijBPr8Og1Gta%252Fuploads%252FKCNNQcdyKxeUAqbvUnOT%252F2024-05-01%252019.07.23.gif%3Falt%3Dmedia%26token%3D5b801b63-d870-4a10-80bc-678d666ec0d7&width=768&dpr=4&quality=100&sign=6293fb3468a1ca21887d5ad57081fed71ab8d31ae5101297d6547b2fbb49c2bf)

### Still having trouble?

If you are searching for something like a product or a collection (or something else that is definitely searchable), and it just isn't showing up, you may just need to switch up your search terms.

- Try using fewer (but more specific) search terms.
- Keep in mind that pasting in the URL of the item you are trying to search will not work in most cases, you will need to search by name.
- For variants that aren't appearing in search results, try including some information about the variant option. For example: "Color" equals "blue".

### Updating Locksmith

If you've created something recently and it's not showing up, an update to Locksmith can help.

1. Open the Locksmith app and navigate to the "Help" page 2. Click on the "Update Locksmith" button:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2F277214568-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-MUeGWHuijBPr8Og1Gta%252Fuploads%252FArG2aXcSq8zmtxkqfMAq%252FScreen%2520Shot%25202022-11-08%2520at%25208.13.42%2520PM.png%3Falt%3Dmedia%26token%3Db3bbe45e-cf08-4110-a260-8fc594db09a7&width=768&dpr=4&quality=100&sign=da84d7c6a146febefa86ef8293f2eab9486423f82f825ede4f023174ba95e9ed)

3. When the green bar at the bottom of the screen disappears, the update is finished. This should only take a handful of seconds.

### A note about Liquid locks

Locksmith also gives you the ability to create "Liquid locks". This can allow you to target nonstandard resources or groups of pages in your store with Locksmith locks that are otherwise not directly searchable. You can start a Liquid lock by clicking into the search bar and selecting "Start a Liquid Lock":

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2F277214568-files.gitbook.io%2F%7E%2Ffiles%2Fv0%2Fb%2Fgitbook-x-prod.appspot.com%2Fo%2Fspaces%252F-MUeGWHuijBPr8Og1Gta%252Fuploads%252FJNY2VWYebrRR05wlq5xQ%252F2024-05-01%252019.12.16.gif%3Falt%3Dmedia%26token%3D347ff39b-712a-40cb-a86f-7c899c393eea&width=768&dpr=4&quality=100&sign=78a6d59ddb3b5c022efbf68630cc3ac5569a77a4a5f144be899e4f06175a767a)

If you think a Liquid lock could help you, try your hand at some Liquid code, or you can always write in to us for any questions about a specific use case.

Our more in depth guide on that is here:

[pageLiquid locking basics](/tutorials/more/liquid-locking-basics)

As always, if you have questions or issues please feel free to get in touch with us at team@uselocksmith.com.

Last updated 2024-05-01T23:14:30Z