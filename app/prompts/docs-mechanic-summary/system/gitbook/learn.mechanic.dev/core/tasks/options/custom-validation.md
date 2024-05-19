# Custom validation

A task may enforce custom validation for options by including validation logic in its code, inspecting the current value of an option and rendering an error object if the option does not meet its criteria.

A modification to a task option will always result in a new preview being rendered. In this way, a task developer may provide the user with immediate feedback on their task configuration.

## Example

In this example, a task begins by validating an option called "A positive number". The only flags on this option are "required" and "number", meaning that Mechanic's involvement is limited to making sure the user fills in this task option with a number.

Once the option is filled in, the task preview will be rendered. If the user has entered a zero, or a negative number, the error tag is used to generate an error object. The error message will then be shown to the user, and they will be prevented from saving the task until they provide valid input.

Copy

    {% if options.a_positive_number__required_number <= 0 %}
      {% error "The option 'A positive number' must be greater than zero." %}
    {% endif %}
    
    {% action "cache", "set", "a_positive_number_to_remember", options.a_positive_number__required_number %}

[PreviousOptions](/core/tasks/options)[NextPreviews](/core/tasks/previews)

Last updated 2022-05-05T16:15:10Z