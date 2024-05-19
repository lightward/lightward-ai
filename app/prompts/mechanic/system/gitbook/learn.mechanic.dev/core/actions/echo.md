# Echo

The Echo action has no effects: it returns the options that are given. This action can be useful for testing or debugging, by temporarily replacing some other action with an Echo action having the same options. In this way, a developer can safely get feedback on what data is in play, without side effects.

## Options

This action accepts any and all options, restricted only in that they must be valid JSON values (as with all results of task code).

### Forcing an error

If the Echo action is given a "\_\_error" option, it will raise that error when the action run is performed. Use this feature when it's useful to indicate an issue with a task run, without marking the entire task run as a failure (as would be the case when using an error object).

LiquidJSON

Copy

    {% action "echo", __error: "Forcing an error!" %}

Copy

    {
      "action": {
        "type": "echo",
        "options": {
          "__error": "Forcing an error!"
        }
      }
    }

## Examples

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

LiquidJSON

Copy

    {% action "echo", "foo", "bar", "baz" %}

Copy

    {
      "action": {
        "type": "echo",
        "options": [
          "foo",
          "bar",
          "baz"
        ]
      }
    }

LiquidJSON

Copy

    {% action "echo", "foo" %}

Copy

    {
      "action": {
        "type": "echo",
        "options": "foo"
      }
    }

LiquidJSON

Copy

    {% action "echo" %}
      {
        "foo": "bar",
        "baz": "qux"
      }
    {% endaction %}

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

[PreviousCache](/core/actions/cache)[NextEmail](/core/actions/email)

Last updated 2023-11-18T19:38:52Z