[Original URL: https://learn.mechanic.dev/platform/liquid/keyword-literals/hash]

# hash

The hash keyword literal may be used in any Liquid code to instantiate a hash.

Hashes support assignment by key. The keys and values filters may be used to quickly access an array of hash keys or values, respectively.

The term "hash" comes from Ruby. In Ruby (docs), "A Hash is a dictionary-like collection of unique keys and their values."

In Mechanic's Liquid implementation, a hash can only have string keys.

## Example

Copy

    {% assign sizes = hash %}
    {% assign sizes["S"] = "Small" %}
    {% assign sizes["M"] = "Medium" %}
    {% assign sizes["L"] = "Large" %}
    
    {% assign size_abbreviations = sizes | keys %}
    {% assign size_labels = sizes | values %}
    
    {% for keyval in sizes %}
      {% assign size_abbreviation = keyval[0] %}
      {% assign size_label = keyval[1] %}
    
      {{ size_abbreviation }}: {{ size_label }}
    {% endfor %}

Last updated 2021-09-23T15:49:20Z