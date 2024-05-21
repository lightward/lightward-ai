[Original URL: https://learn.mechanic.dev/platform/liquid/tags/liquid]

# liquid

The liquid tag is used for writing multiple Liquid expressions within a single tag.

It's not a Mechanic invention; this tag is a part of open-source Liquid (see documentation). But because Mechanic introduces several new tags of its own, it's worth talking about liquid and how it can be used in Mechanic code.

## What it's for

Typically, Liquid code is embedded within some larger context.

In Shopify's Online Store theme templates, for example, the code you write is treated as browser-ready HTML (or CSS, or JavaScript, etc) until you type {% ... %} or {{ ... }}. Within those markers, you're in the world of Liquid. Everything outside of those markers remains static. And, once the Liquid code is evaluated, its output gets added to that static content, resulting in one cohesive set of output. Since we're talking about Online Store templates, the output eventually makes its way to the web browser, where the resulting HTML/CSS/JS/etc is rendered – and the web browser never has to know Liquid was involved.

In Mechanic's task code, the code you write is assumed to contain a stream of JSON objects. Everything is assumed to be valid JSON until you type {% ... %} or {{ ... }}. Within those markers, you're in the world of Liquid. Everything outside of those markers remains static. And, once the Liquid code is evaluated, its output gets added to that static content, resulting in one cohesive set of output. Since we're talking about Mechanic task code, the output eventually makes its way to Mechanic's run system, where the resulting stream of JSON objects is used to construct actions to be performed – and those actions never have to know Liquid was involved.

This nested way of doing Liquid (some other language on the outside – like HTML or JSON – and Liquid on the inside) works well when most of the code is in that outside language. When most of your code is Liquid itself, the {% ... %} and {{ ... }} markers start to get in the way.

This is where the liquid tag comes in. Within {% liquid ... %}, you can write line after line of pure Liquid expressions, without ever having to return to the outside language.

## How it works

The liquid tag opens up an alternative Liquid parsing mode, in which each line of code within the tag is evaluated as if each line was wrapped in its own {% ... %} markers.

This means that two pieces of Liquid are equivalent:

Copy

    {% echo "hello!" %}
    
    {% liquid
       echo "hello!"
    %}

The liquid tag is useful when you're doing lots of Liquid statements, and when your code can be expressed in 100% Liquid, without having to rely on non-Liquid static content.

## Mechanic tags

Mechanic Liquid adds several tags that are relevant here: action, error, and log. All three of these tags support block usage and inline usage.

### Block usage

Typical block usage looks like this, using the action tag as an example:

Copy

    {% action "email" %}
      {
        "to": "hello@example.com"
      }
    {% endaction %}

In the example above, the interior of the action tag is static content. The Liquid engine sees the {% action "email" %} lines, and it knows that more content is coming. So, it puts the Email action aside temporarily, and gathers all the content that follows, ending right before the closing {% endaction %} tag. Once endaction arrives, all the content in the middle is handed back to the Email action, which generates the final action JSON object. The final output looks like this:

Copy

    {"action":{"type":"email","options":{"to":"hello@example.com"}}}

These next two examples use the liquid tag to achieve exactly the same behavior: some static JSON content, passed up to the "parent" action tag. Both of the Liquid examples below produce the JSON output shown above.

Copy

    {% liquid
      action "email"
        echo '{"to": "hello@example.com"}'
      endaction
    %}

Copy

    {% liquid
      action "email"
        assign payload = hash
        assign payload["to"] = "hello@example.com"
        echo payload | json
      endaction
    %}

### Inline usage

The action, error, and log tags all have an inline usage as well. Typical inline usage looks like this, using the log tag as an example:

Copy

    {% log "oh my!" %}

The action tag supports a type argument; simple inline usage might look like this:

Copy

    {% assign payload = hash %}
    {% assign payload["to"] = "hello@example.com" %}
    {% action "email", payload %}

Here's how these examples work using the liquid tag:

Copy

    {% liquid
      log "oh my!"
    
      assign payload = hash
      assign payload["to"] = "hello@example.com"
      action "email", payload
    %}

And here's the output:

Copy

    {"log":"oh my!"}
    {"action":{"type":"email","options":{"to":"hello@example.com"}}}

Last updated 2024-01-23T02:39:12Z