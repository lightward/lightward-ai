# error

The error tag generates an error object.

## Syntax

This tag has several usage styles, each style resulting in a valid action object.

### Block syntax

LiquidJSON

Copy

    {% error %}
      {
        "foo": "bar"
      }
    {% enderror %}

Copy

    {
      "error": {
        "foo": "bar"
      }
    }

### Tag syntax, single argument

LiquidJSON

Copy

    {% error "foobar" %}

Copy

    {
      "error": "foobar"
    }

### Tag syntax, mapped arguments

LiquidJSON

Copy

    {% assign details = hash %}
    {% assign details["foo"] = "bar" %}
    
    {% error message: "Something went wrong!", details: details %}

Copy

    {
      "error": {
        "message": "Something went wrong!",
        "details": {
          "foo": "bar"
        }
      }
    }

Last updated 2021-04-05T20:03:25Z