# Condition

Condition tags are useful for making decisions about what code to run, based on some specific value under inspection.

Often, condition tags are concerned with whether a value is truthy or falsey. In Liquid, only the values false and nil are falsey; all other values are truthy.

For further discussion on how Liquid treats values, see their documentation: Truthiness and falsiness in Liquid.

## if

An if tag is always paired with an endif tag. The code between these tags only runs if the condition in the if tag evaluates to something truthy.

Copy

    {% if options.test_mode__boolean %}
      {% action "echo" summaries %}
    {% endif %}

## unless

Identical in style to the if tag, the unless tag only executes the code it contains if the condition is falsey.

Copy

    {% unless options.default_tracking_url_template contains "TRACKING_NUMBER" %}
      {% error %}{{ "Placeholder 'TRACKING_NUMBER' is missing." | json }}{% enderror %}
    {% endunless %}

## else

An else tag can be added within if, unless, and case blocks. The code that follows the else tag is run if the condition above it does not run.

Copy

    {% if customer.email != empty %}
      {% assign email = customer.email %}
    {% else %}
      {% log "Customer had no email" %}
    {% endif %}

Copy

    {% unless customer.email == empty %}
      {% assign email = customer.email %}
    {% else %}
      {% log "Customer had no email" %}
    {% endif %}

## elsif

An elsif tag adds a second condition to an if or unless block. If the condition above it does not run, the next elsif tag will be evaluated – and if its condition is truthy, the code that follows it will run.

Any number of elsif tags may be added within if or unless blocks.

Copy

    {% assign today = "tuesday" %}
    
    {% if today == "monday" %}
      {% log "it's monday!" %}
    {% elsif today == "tuesday" %}
      {% log "it's tuesday!" %}
    {% endif %}

Copy

    {% assign today = "tuesday" %}
    
    {% unless today == "tuesday" %}
      {% log "it's not tuesday!" %}
    {% elsif today == "tuesday" %}
      {% log "it's tuesday!" %}
    {% endif %}

## case, when

The case and endcase tag pair contain a series of when tags, and optionally an else tag. The value specified in the case tag is inspected, and Liquid then looks for a when tag that has a matching value. If one is found, that when tag gets to run its code. If no match is found, the code for the else tag (if given) is run.

Copy

    {% case order.cancel_reason %}
      {% when "customer" %}
        {% assign cancel_reason = "It was the customer." %}
      {% when "fraud" %}
        {% assign cancel_reason = "It was fraud!" %}
      {% when "inventory" %}
        {% assign cancel_reason = "It was due to inventory issues." %}
      {% else %}
        {% assign cancel_reason = "It was something unknown." %}
    {% endcase %}

[PreviousControl flow](/platform/liquid/basics/control-flow)[NextIteration](/platform/liquid/basics/control-flow/iteration)

Last updated 2021-06-08T21:38:15Z