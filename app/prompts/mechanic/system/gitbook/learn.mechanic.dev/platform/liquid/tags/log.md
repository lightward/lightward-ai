[Original URL: https://learn.mechanic.dev/platform/liquid/tags/log]

# log

The log tag generates a log object.

## Syntax

This tag has several usage styles, each style resulting in a valid action object.

### Block syntax

LiquidJSON

Copy

    {% log %}
      {
        "foo": "bar"
      }
    {% endlog %}

Copy

    {
      "log": {
        "foo": "bar"
      }
    }

### Tag syntax, single argument

LiquidJSON

Copy

    {% log "foobar" %}

Copy

    {
      "log": "foobar"
    }

### Tag syntax, mapped arguments

LiquidJSON

Copy

    {% assign details = hash %}
    {% assign details["foo"] = "bar" %}
    
    {% log message: "Something to remember", details: details %}

Copy

    {
      "log": {
        "message": "Something to remember",
        "details": {
          "foo": "bar"
        }
      }
    }

Last updated 2021-04-05T20:03:26Z