[Original URL: https://learn.mechanic.dev/platform/liquid/basics/whitespace]

# Whitespace

Outside of Liquid statements, all whitespace is preserved. This can result in whitespace that is unwieldy (for example, while formatting GraphQL queries).

To avoid this, use hyphens just inside of Liquid statement openings and closings, as in the following:

- {{- eats\_whitespace\_on\_the\_left }}
- {%- assign eats\_whitespace\_on\_the\_left = true %}
- {{ eats\_whitespace\_on\_the\_right -}}
- {% assign eats\_whitespace\_on\_the\_right = true -%}
- {{- eats\_whitespace\_on\_both\_sides -}}
- {%- assign eats\_whitespace\_on\_both\_sides -%}

Learn more from Shopify: see Whitespace control.

## Example

Copy

    {%- capture message -%}
      This is a message.
    {%- endcapture -%}
    
    {% capture message -%}
      This is a message.
    {% endcapture -%}
    
    {{- customer.name -}}
    {{ customer.name -}}
    {{- customer.name }}

Last updated 2021-04-05T20:03:22Z