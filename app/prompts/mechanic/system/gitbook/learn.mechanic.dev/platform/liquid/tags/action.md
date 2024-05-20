# action

The action tag renders an action object in JSON, which in turn defines work to be performed by an action.

## Syntax

This tag has several usage styles, each style resulting in valid JSON for an action object.

As with nearly all Liquid tags, the action tag supports Liquid variables. This means that the action type and options may be given using variables (instead of scalar values, like strings).

### Block syntax

This usage style offers the lightest form of abstraction, in that it only abstracts away { "action": ... } layer of the resulting JSON object. Use this style when it's necessary to also provide meta information for an action, in addition to the action's type and options.

LiquidJSON

Copy

    {% action %}
      {
        "type": "http",
        "options": {
          "method": "post",
          "url": "https://postman-echo.com/post",
          "body": {{ event.data | json }}
        },
        "meta": {
          "mode": "initial_request"
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "http",
        "options": {
          "method": "post",
          "url": "https://postman-echo.com/post",
          "body": null
        },
        "meta": {
          "mode": "initial_request"
        }
      }
    }

### Block typed syntax

🏆 This is the most common style of usage. The action type is given as an argument to the Liquid tag itself, and the action options are given in JSON in the tag's body.

LiquidJSON

Copy

    {% action "http" %}
      {
        "method": "post",
        "url": "https://postman-echo.com/post",
        "body": {{ event.data | json }}
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "http",
        "options": {
          "method": "post",
          "url": "https://postman-echo.com/post",
          "body": null
        }
      }
    }

### Tag syntax, positional options

Useful for action types that accept an array of options, this usage style accepts the action type as the first tag argument, and the following two or more positional arguments are used as options. This syntax does not have a closing {% endaction %} tag.

LiquidJSON

Copy

    {% action "cache", "set", "foo", "bar" %}

Copy

    {
      "action": {
        "type": "cache",
        "options": [
          "set",
          "foo",
          "bar"
        ]
      }
    }

### Tag syntax, mapped options

This usage style is appropriate for action types that accept a single-level, un-nested object of options. The action type is given as the first argument, and the mapping of values that follow is used as the action's options. This syntax does not have a closing {% endaction %} tag.

LiquidJSON

Copy

    {% action "echo", foo: "bar", baz: "qux" %}

Copy

    {
      "action": {
        "type": "echo",
        "options": {
          "foo": "bar",
          "baz": "qux"
        }
      }
    }

### Tag syntax, single option

This usage style accepts two arguments: the action type, and the action options. The action options may be given as a simple scalar value, or may be given as a variable reference to any Liquid variable. This syntax does not have a closing {% endaction %} tag.

Liquid

Copy

    {% action "echo", "foo" %}
    
    {% assign action_options = hash %}
    {% assign action_options["foo"] = "bar" %}
    
    {% action "echo", action_options %}

Copy

    {
      "action": {
        "type": "echo",
        "options": "foo"
      }
    }
    
    {
      "action": {
        "type": "echo",
        "options": {
          "foo": "bar"
        }
      }
    }

Last updated 2024-01-23T00:39:00Z