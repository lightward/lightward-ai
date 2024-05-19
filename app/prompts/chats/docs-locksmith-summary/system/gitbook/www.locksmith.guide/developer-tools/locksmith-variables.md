# Locksmith variables

Locksmith comes with two opportunities for programmatic interaction: manual mode, and the storefront API. Both APIs expose a set of variables, representing Locksmith's understanding of the resource in play, and the current visitor's authorization for that resource.

For more information on how these variables are exposed in both APIs, see their respective documentation pages:

- Manual mode
- The Locksmith storefront API

### Variable definitions

- "locked" – Can be true or false, depending on whether or not the resource has any active locks that apply to it.
- "initialized" – Only relevant when server keys are in play; is true or false, depending on whether or not Locksmith has had an opportunity to initialize the visitor's session; access decisions cannot be made until initialization is complete. If "initialized" is false, trigger a refresh of the page to allow Locksmith to finish initializing.
- "scope" – A string describing the type of resource being analyzed. Can be values like "product", "collection", "article", etc.
- "access\_granted" – Can be true or false, depending on whether or not Locksmith has determined that the current visitor may view the content.
- "access\_denied" – Can be true or false; the opposite of "access\_granted".
- "manual\_lock" – Can be true or false, depending on whether or not all applicable locks have manual mode engaged.
- "server\_lock" – Can be true or false, depending on whether or not a server key must be evaluated for Locksmith to complete the visitor's authorization.
- "hide\_resource" – Can be true or false, depending on whether or not the visitor is permitted to see the resource when it occurs in a list (e.g. search results, or product lists shown in a collection).
- "hide\_links\_to\_resource" – Can be true or false, depending on whether or not the visitor is permitted to see navigation links to the resource, in the store's navigation menus.
- "lock\_ids" – An array of string IDs, identifying the set of locks that apply to the given resource.
- "opened\_lock\_ids" – An array of integer IDs, identifying the subset of locks that are currently considered "open" for the current visitor.
- "key\_ids" – An array of integer IDs, identifying the keys involved in opening the locks listed in "opened\_lock\_ids".

Note: Using the render tag with manual mode will result in string representations of booleans and arrays. Using the include tag will result in arrays of integer IDs being represented as arrays of string IDs. For more details, see Manual mode.

[PreviousLocksmith Storefront API](/developer-tools/locksmith-storefront-api)[NextUnsupported functionality](/developer-tools/unsupported-functionality)

Last updated 2022-08-09T02:25:58Z