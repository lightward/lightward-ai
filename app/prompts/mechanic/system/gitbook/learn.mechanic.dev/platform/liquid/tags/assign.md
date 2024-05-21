[Original URL: https://learn.mechanic.dev/platform/liquid/tags/assign]

# assign

The assign tag is a native feature of Liquid. In Mechanic-flavored Liquid, the assign tag is extended to support assigning within arrays and hashes.

Assignment into arrays and hashes is always by value, never by reference.

"Assignment by value" means that the result of the assignment will never dynamically change.

Copy

    {% assign foo = "bar" %}
    {% assign x = array %}
    {% assign x["foo"] = foo %}
    
    {% assign foo = "qux" %}

At the end of this example, x.foo still contains "bar", even though the value of the original foo variable has changed.

## Assigning into arrays

Arrays support assignment by index, using integer lookups.

CodeOutput

Copy

    {% assign x = array %}
    {% assign x[0] = "one" %}
    {% assign x[x.size] = "two" %}
    
    {% assign the_third_zero_based_index = 2 %}
    {% assign x[the_third_zero_based_index] = "three" %}
    
    {{ x | json }}

Copy

    ["one","two","three"]

## Assigning into hashes

Hashes support assignment by key, using string lookups.

CodeOutput

Copy

    {% assign x = hash %}
    {% assign x["one"] = 1 %}
    {% assign x["two"] = 2 %}
    
    {% assign three = "three" %}
    {% assign x[three] = 3 %}
    
    {{ x | json }}

Copy

    {"one":1,"two":2,"three":3}

Last updated 2021-04-05T20:03:24Z