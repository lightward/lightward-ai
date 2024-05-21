[Original URL: https://learn.mechanic.dev/core/tasks/options]

# Options

Tasks accept user configuration via options. Options are created dynamically, by reference: each option referenced in a task's code results in that option being added to the task's configuration form. In the option reference {{ options.foo\_bar\_\_required }}, the option key is foo\_bar\_\_required. The appearance and behavior of the option's form element is based on flags in in the option key – in this example, only the "required" flag is in use.

Mechanic flags provide only limited option validation. A task may define custom validation, by rendering error objects according to the task's its own validation logic.

## Keys

Options are made available in the options variable, which is a hash having key-value pairs for each option key and option value. The option key must only contain ASCII numbers, lowercase letters, and underscores. The option key is reformatted for use as the option name presented to the user – underscores are replaced by spaces, and the entire line is sentence-cased.

Example

Copy

    {% action "echo", options.some_value_to_echo__required_multiline %}

Because option keys are registered via static analysis, options must each be referenced using a standard lookup (e.g. options.foobar) at least once.

## Order

Options are displayed to the user in the order in which they are first referenced in the task code.

Because this may not result in a natural sequence, it can be useful to prefix task code with a comment block, explicitly referencing each option so as to force the overall order.

Copy

    {% comment %}
      Preferred option order:
    
      {{ options.foo }}
      {{ options.bar__required }}
      {{ options.baz__boolean }}
    {% endcomment %}

## Flags

Option flags control how an option appears and behaves in a task's configuration form, and also control the type and format of the option value.

Most flags may be combined with other flags, for more nuanced control.

If no flags are used for an option, an option will be made available as a plain text field, and the option value will be a string.

| 

Flag

 | 

Effect

 |
| 

required

 | 

Requires the user to populate this option before the task can be saved

 |
| 

boolean

 | 

Renders a checkbox; the option value is a boolean

 |
| 

multiline

 | 

Renders a multiline text field; the option value is a string

 |
| 

email

 | 

Renders a text field of type "email"; the option value is a string

 |
| 

number

 | 

Renders a text field of type "number", configured for value steps of 1; the option value is a number

 |
| 

code

 | 

Renders a text field that's formatted for code; the option value is a string

 |
| 

keyval

 | 

Renders a compound form element, allowing the user to provide zero or more key-value pairs; the option value is a hash, containing these key-value pairs

 |
| 

array

 | 

Renders a compound form element, allowing the user to provide zero or more values; the option value is an array, containing these values

 |

Array options have a hidden feature: once the user-configured array reaches 5 elements in size, a new "Manage in bulk" button will appear for that option. Clicking it will open a modal which allows the user to manage the array's input using a single multiline text field, in which each line represents an array element. This is a convenient way to configure larger arrays.

## Liquid

Options that allow text input are evaluated for Liquid when a task processes an event. Liquid evaluation for options occurs before it occurs for task code, which means that any Liquid variables created by task code are not available to task options.

Liquid code in task options have access to the same set of environment variables that are made available to the task code, including event, shop, cache, and any event subject variables.

Last updated 2022-05-05T16:15:02Z