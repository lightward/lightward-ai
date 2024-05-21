[Original URL: https://www.locksmith.guide/tutorials/more/granting-access-to-variants-by-visitor-input]

# Granting access to variants by visitor input

Locksmith's variant locking feature results in automatic hiding of variants that the visitor doesn't have access to. If you're using keys that are based on things that don't require customer input (say, "permit if the customer is signed in"), then revealing those variants is automatic: if the customer qualifies, the variants appear.

If you're using keys that require visitor input, like passcodes or email addresses, then an intermediate step needs to be added to the customer experience, allowing them to actually enter their information. This doesn't happen automatically, and without it, the visitor won't have a way of accessing the hidden variants.

## Setup

### 1. Create a dedicated "sign in" page

In the Shopify admin area, head to the "Online Store" section, and open up your "Pages" list. Create a page that's just for customers who are shopping the particular variant(s) that you want to help them unlock. Add menu links to this page, if necessary and where appropriate.

### 2. Lock the page

Back in Locksmith, search for the page, and create a lock for it.

### 3. Add a passcode key to the page lock, using the same passcode as your variant lock

Here's where it comes together: by adding a passcode key that uses the same passcode as your variants, the customer's successful passcode entry here will result in the variant locks automatically opening, because they'll register the presence of the same passcode.

A bonus, if you're using multiple variant locks: Because locks can have multiple keys, there's an opportunity here for you to add multiple passcode keys here, one for each of the different variant locks you've got. This is a useful strategy if you're preparing variants for separate audiences - this allows you to have a single "sign in" page, where everyone can gain access to their respective variants.

### 4. Optional: configure the key to redirect to your product

If you like, use the key's advanced settings to add an automatic redirect, routing the customer to the right product page when they enter the right passcode. You can find this setting by clicking the triple-dot icon, to the right of the key condition.

As noted in step 3, this also works with multiple passcode keys. Simply add the right redirect to each passcode key, and the customers will be routed to the right place after entering their passcode.

Last updated 2022-06-29T07:18:30Z