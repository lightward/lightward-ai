# Syntax

Liquid is a template language, which means that it uses special syntax to mark the places where Liquid code starts and ends. In this way, Liquid code can be used to fill in calculated values in a larger document.

In Shopify, Liquid is usually found in HTML templates. In Mechanic, Liquid is usually found in JSON templates.

## Liquid with output

When using the {{ code }} syntax, the result of the Liquid code inside will form output.

In the following example, this syntax is used to output the string "world". When this template is rendered, it will produce Hello, world.

Copy

    Hello, {{ "world" }}

## Liquid without output

When using the `

Copy

    

` syntax, the Liquid code inside is given the opportunity to perform work without generating output. This syntax is for preparing and modifying variables (using tags like assign), or for specifying control flow (using conditions or iteration).

In the following example, a variable is assigned, modified with a new variable, and is finally rendered as output.

Copy

    {% assign scope = "world" %}
    {% assign message = "Hello, " | append: scope %}
    
    {{ message }}

[PreviousBasics](/platform/liquid/basics)[NextData types](/platform/liquid/basics/types)

Last updated 2023-11-08T15:48:43Z