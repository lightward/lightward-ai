[Original URL: https://learn.mechanic.dev/platform/liquid/keyword-literals/array]

# array

The array keyword literal may be used in any Liquid code to instantiate an array.

Arrays support assignment by index. Many other operations are supported using array filters.

## Example

Copy

    {% assign weekdays = array %}
    {% assign weekdays[0] = "Monday" %}
    {% assign weekdays[1] = "Tuesday" %}
    {% assign weekdays[2] = "Wednesday" %}
    {% assign weekdays[3] = "Thursday" %}
    {% assign weekdays[4] = "Friday" %}
    {% assign weekdays[5] = "Saturday" %}
    {% assign weekdays[6] = "Sunday" %}
    
    {% for weekday in weekdays %}
      {{ forloop.index0 }}: {{ weekday }}
    {% endfor %}
    
    {% assign weekdays[weekdays.size] = "A NEW WEEKDAY, DYNAMICALLY INDEXED???" %}

Last updated 2023-11-08T16:17:43Z