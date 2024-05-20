# Grant access for a limited time when using passcodes or secret links

How to use Locksmith's 'timeout' feature to limit access time

This feature is available only when using "passcode" or "secret link" key conditions. In specific, the following key conditions types: Permit if the customer...

- gives the passcode
- gives one of many passcodes
- gives a passcode from an input list
- arrives via a secret link
- arrives using a secret link from an input list

The setup is pretty straightforward. You'll see the corresponding option, when setting up one of the above key condition types, and can adjust the time period like so:

## Caveats

#### 1. Using this setting with the "Remember for signed-in customers"

Since most folks using the timeout setting are wanting to heavily limit their customers' access period, we typically recommend that anyone using the timeout setting makes sure to turn the "Remember for signed-in customers" setting OFF. While the two settings can technically be used together, doing this can provide you the most consistent results.

That being said, if, for any reason, you have set a longer access period (months, years), it may actually make more sense to keep the "Remember for signed-in customers" setting turned on. This will help Locksmith maintain access (via customer metafields) for the full period of time, as long as the customer is signed in.

#### 2. Access time is evaluated at time of page load

As stated under the option itself, Locksmith won't refresh the page for the visitors, so visitors' access period will only time out when they load or refresh a page.

#### 3. The setting won't apply retroactively

When adding this setting to an already-existing key condition, it will only be applied to new visitors. As in, it will not apply retroactively.

If you do want to reset access for all visitors, the easiest way to do this is to delete your key condition( press the "Remove" button on the condition) and recreate it with a different passcode or secret link.

#### 4. Every time a visitor uses the same passcode or secret link, the timeout timer for that particular passcode/link is reset

In other words, the timer is always based on the most recent Locksmith submission/validation. If a customer resubmits a passcode or re-uses a secret link, the timer starts from then, even if that code/link was already used.

To prevent this kind of thing, you can set up your codes/links so that they have limited uses (or even one use only). Check out the corresponding guides for more information on how to do that:

- Secret links
- Passcodes

#### 5. When using the timeout feature, do not use the same passcodes or secret links as you are using in your key conditions that do not time out

Using the same passcodes or secret links for key conditions that time out, as those that do not time out will result in none of your key conditions timing out as expected.

#### 6. On rare occasions, page caching may prevent visitors access from timing out

It is possible for pages in your online store to be cached based on Shopify features and Theme settings. This may prevent the page from timing out exactly when expected. Because of this, the setting should be considered to be simply an extra tool in your toolbox, and not depended on to be exact and precise.

#### 

Last updated 2023-04-13T21:26:23Z