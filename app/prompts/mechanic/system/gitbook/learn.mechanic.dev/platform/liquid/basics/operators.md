# Operators

An operator is a statement that evaluates some code, and makes a decision about what to do next. Operators can be used for comparing two values, inspecting a single value, or evaluating whether or not some code returns true.

For further discussion on how Liquid treats values, see their documentation: Truthiness and falsiness in Liquid.

## Comparison operators

If b = 6, the table below illustrates the comparison operators and the way they interact with b:

| 

Operator

 | 

Description

 | 

Example

 | 

Result

 |
| 

==

 | 

equal to

 | 

b == 6

 | 

true

 |
| 

!=

 | 

not equal

 | 

b != 6

 | 

false

 |
| 

\>

 | 

greater than

 | 

b \> 5

 | 

true

 |
| 

\<

 | 

less than

 | 

b \< 6

 | 

false

 |
| 

\>=

 | 

greater than or equal to

 | 

b \>= 6

 | 

true

 |
| 

\<=

 | 

less than or equal to

 | 

b \<= 6

 | 

true

 |

### Examples

Copy

    {% assign order_qualifies = false %}
    
    {% if order.cancelled_at == blank and cancel_risk %}
      {% assign order_qualifies = true %}
    {% endif %}

Copy

    {% if has_product != true %}
      {% log "Order has no products; skipping" %}
      {% assign send_email = false %}
    {% endif %}

### Testing for blank, empty

Liquid supports equality/inequality testing a value against blank or empty. In this way, Liquid allows the author to ask, "is this value blank?", or "is this value empty?"

#### Blank

Quoting from the Rails API:

> An object is blank if it's false, empty, or a whitespace string. For example, nil, '', ' ', [], {}, and false are all blank.

Copy

    {% assign empty_string = "" %}
    {% assign whitespace_string = " " %}
    {% assign non_blank_string = " !! " %}
    {% assign non_empty_array = "1,2,3" | split: "," %}
    {% assign empty_hash = hash %}
    
    {% comment %}
      The following `if` statements all pass.
    {% endcomment %}
    {% if empty_string == blank %}
    {% if whitespace_string == blank %}
    {% if non_blank_string != blank %}
    {% if non_empty_array != blank %}
    {% if empty_hash == blank %}

#### Empty

An array, hash, or string can be tested for emptiness. An array is empty if it has no elements; a hash is empty if it has no key-value pairs; a string is empty if its length is zero.

A string that only contains whitespace is not empty, but it is blank!

Copy

    {% assign empty_string = "" %}
    {% assign whitespace_string = " " %}
    {% assign non_blank_string = " !! " %}
    {% assign non_empty_array = "1,2,3" | split: "," %}
    {% assign empty_hash = hash %}
    
    {% comment %}
      The following `if` statements all pass.
    {% endcomment %}
    {% if empty_string == empty %}
    {% if whitespace_string != empty %}
    {% if non_blank_string != empty %}
    {% if non_empty_array != empty %}
    {% if empty_hash == empty %}

## Contains operator

The contains operator is used to check for the existence of a substring in a string, or for a specific element in an array.

### Substring containment

Copy

    {% if email_domain contains "@" %}
      {% error "Do not include '@' symbols in email domains. Thanks!" %}
    {% endif %}

### Array element containment

Copy

    {% assign product_tags = "foo, bar, baz" | split: ", " %}
    {% assign product_is_tagged_bar = false %}
    
    {% if product_tags contains "bar" %}
      {% assign product_is_tagged_bar = true %}
    {% endif %}

## Logical operators

Liquid has two logical operators: and and or.

If b = 3 and c = 6, the table below illustrates the logical operators in Liquid, and the way they interact with b and b:

| 

Operator

 | 

Example

 | 

Result

 |
| 

and

 | 

b \< 2 and c \< 6

 | 

false

 |
| 

or

 | 

b \< 2 or c \< 6

 | 

true

 |

### Check if both the shipping address and billing are blank

Copy

    {% if order.shipping_address != blank and order.billing_address != blank %}
      {% comment %} do something {% endcomment %}
    {% endif %}

### Check if tag equals blank or a customer's tags contains a certain tag

Copy

    {% if tag == blank or customer.tags contains tag %}
      {% comment %} do something {% endcomment %}
    {% endif %}

Last updated 2021-06-08T21:37:52Z