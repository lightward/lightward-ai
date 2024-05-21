[Original URL: https://learn.mechanic.dev/platform/liquid/basics/filters]

# Filters

Filters transform a value into something else. Filters are separated by the pipe symbol: |. Filters can be chained, performing several transformations in a sequence.

See Mechanic filters for a complete list of filters supported by Mechanic Liquid.

Liquid filters should not be confused with event filters, which are used to conditionally ignore incoming events.

## Example syntax

Copy

    {{ order.billing_address.zip | upcase }}
    
    {% assign full_name = customer.first_name | append: " " | append: customer.last_name %}

Last updated 2024-05-08T16:18:39Z