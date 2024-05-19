# Data types

In Liquid, different kinds of data have different types. Each type describes the nature of its data.

Some of the documentation below is specific to Mechanic Liquid, and may not apply to Shopify Liquid, or to other Liquid implementations.

## String

A string contains a series of characters, forming text.

Copy

    {% assign my_name = "Matt" %}

## Integer, Float

Liquid supports both two number types: integers (whole numbers) and floats (numbers having decimal precision).

Copy

    {% assign a_int = 99 %}
    {% assign a_float = 99.99 %}

## Boolean

Copy

    {% assign is_mechanic_awesome = true %}
    {% assign is_it_warm_outside = false %}

## Nil

Borrowing from Ruby's concept of nil, Liquid's nil is an empty value that is returned when Liquid code has no results. It evaluates to false in conditionals statements, and outputs nothing when printing out text.

If a variable reference comes up missing, Liquid will silently use nil instead without raising an error.

In Liquid, null is not a keyword literal. But, because null is also typically not used as a variable name in Mechanic Liquid code, and because Liquid uses nil when a variable is not found, it works out: {% assign foo = null %} results in assigning foo a value of nil. (Unless, of course, null was previously assigned to something else, e.g. {% assign null = "something else" %}.)

Copy

    {% if order.email %}
      There is an email address
    {% endif %}

LiquidOutput when not nilOutput when nil

Copy

    email address: {{ order.email }}

Copy

    email address: joe@joegmail.com

Copy

    email address:

## Array

An array is a value that itself contains an ordered list of other values. Each value has an index, representing the order in which each value occurs in the list.

### Creating an array

Liquid supports creating arrays of strings using the split filter. In Mechanic, arrays can be created using the array literal.

The array literal is unique to Mechanic Liquid. Arrays cannot be created in this way using Shopify Liquid.

Copy

    {% assign an_array_of_strings = "one,two,three" | split: "," %}
    {% assign also_an_array_of_strings = "1,2,3" | split: "," %}
    
    {% assign an_empty_array = array %}

### Iterating through arrays

Copy

    {% for customer_tag in customers.tags %}
      {{ customer_tag }}
    {% endfor %}

### Accessing an array element

Copy

    {{ customers.tags[0] }}
    {{ customers.tags[1] }}

### Array filters

Mechanic includes a variety of array filters, useful for transforming arrays or retrieving specific values.

## Object

An object is any value that has attributes (also known as properties). The name of an attribute is known as its key; the data stored for an attribute is known as its value. In Mechanic, some objects have additional intelligence of their own, like the Shop object.

### Iterating through objects

Objects may be traversed using for loops.

Copy

    {% assign object = hash %}
    {% assign object["foo"] = "bar" %}
    {% assign object["baz"] = "qux" %}
    
    {% for keyval in object %}
      {% assign key = keyval[0] %}
      {% assign value = keyval[1] %}
    
      {{ key }}: {{ value }}
    {% endfor %}

### Accessing an object property

All of the following examples return the same value.

Copy

    {% assign foo = '{"foo":"bar"}' | parse_json %}
    
    1. {{ foo.bar }}
    2. {{ foo["bar"] }}
    
    {% assign key = "bar" %}
    3. {{ foo[key] }}

## Hash

In Mechanic, a hash is a simple type of object that has no additional intelligence at all; it only contains keys and values. It can be constructed by the developer using code.

### Creating a hash

In Mechanic, hashes can be created using the hash literal, or by using any of the "parse" filters.

This only applies to Mechanic Liquid. Hashes cannot be created in Shopify Liquid.

Copy

    {% assign a_hash_object = hash %}
    {% assign a_hash_object["key"] = "value" %}
    
    {% assign a_hash_from_json = '{"foo":"bar"}' | parse_json %}

### Iterating through hashes

Hashes may be traversed using for loops, like other objects. For convenience, Mechanic also supports extract an array of hash keys using the keys filter, or object values using the values filter. The resulting arrays may also be used with a for loop, like any array.

Copy

    {% assign object = hash %}
    {% assign object["foo"] = "bar" %}
    {% assign object["baz"] = "qux" %}
    
    {% for keyval in object %}
      {% assign key = keyval[0] %}
      {% assign value = keyval[1] %}
    
      {{ key }}: {{ value }}
    {% endfor %}
    
    {% assign keys = object | keys %}
    {% for key in keys %}
      {{ key }}: {{ object[key] }}
    {% endfor %}
    
    {% assign values = object | values %}
    {% for value in values %}
      {{ value }}
    {% endfor %}

[PreviousSyntax](/platform/liquid/basics/syntax)[NextVariables](/platform/liquid/basics/variables)

Last updated 2022-08-11T06:43:18Z