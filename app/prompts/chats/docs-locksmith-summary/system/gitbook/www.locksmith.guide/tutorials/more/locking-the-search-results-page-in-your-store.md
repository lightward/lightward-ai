# Locking the search results page in your store

To get started, search for "search" from within Locksmith, like so:

... and click on the "Search" search result. (So much searching!)

That's it! :)

## Protecting search forms, using Liquid code

Out of the box, this lock only protects the /search url of your shop (as in https://myexampleshop.com/search).

To hide the search boxes that your theme may include elsewhere in your shop, open up the Liquid file that contains the search form in question, and locate the actual search form. Wrap it with Liquid that looks like this:

Copy

    {% include 'locksmith-variables', locksmith_scope: 'search' %}
    
    {% if locksmith_access_granted %}  
      
    {% endif %}

As you can see, this does require manual coding. If you need a hand with this, let us know! :)

[PreviousLocking the customer registration form](/tutorials/more/locking-the-customer-registration-form)[NextHow to clear cache for a single website](/tutorials/more/how-to-clear-cache-for-a-single-website)

Last updated 2022-08-09T02:34:13Z