[Original URL: https://learn.mechanic.dev/platform/liquid/keyword-literals/newline]

# newline

The newline keyword literal represents the newline control character: \n. It's useful for navigating or assembling strings.

## Filter support

Besides its natural uses in building strings, newline has a special purpose within these string filters:

- newline\_to\_br – When used with newline, this filter will replace instances of "\r\n", and then instances of "\n".
- replace – When used with newline as its first argument, this filter will replace instances of "\r\n", and then instances of "\n".
- split – When used with newline, this filter will split by "\r\n" when present, and then by "\n".

Under the hood, each of these scenarios uses the regular expression /\r?\n/.

## Example

Copy

    {% assign message = "Hello!" | append: newline | append: newline %}
    {% assign message = message | append: "This is a new paragraph!" %}
    
    {% capture lines %}
    foo
    bar
    baz
    {% endcapture %}
    
    {% assign words = lines | split: newline %}
    {% assign tags = lines | replace: newline, ", " %}

Last updated 2021-04-05T20:03:23Z