[Original URL: https://learn.mechanic.dev/platform/liquid/basics/comments]

# Comments

This page's content comes from https://shopify.dev/docs/api/liquid/tags#comment.

## Comment tag

Prevents an expression from being rendered or output.

Any text inside comment tags won't be output, and any Liquid code will be parsed, but not executed.

Copy

    {% comment %} This is a comment in Liquid {% endcomment %}

Copy

    {% comment %} 
      This is a comment in Liquid 
    {% endcomment %}

## Inline comments

Inline comments prevent an expression inside of a tag {% %} from being rendered or output.

You can use inline comment tags to annotate your code, or to temporarily prevent logic in your code from executing.

You can create multi-line inline comments. However, each line in the tag must begin with a #, or a syntax error will occur.

Copy

    {% # this is a comment %}
    
    {% # for i in (1..3) -%}
      {{ i }}
    {% # endfor %}
    
    {%
      ###############################
      # This is a comment
      # across multiple lines
      ###############################
    %}

## Inline comments inside liquid tags

You can use inline comment tags inside liquid tags. The tag must be used for each line that you want to comment.

Copy

    {% liquid
      # this is a comment
      assign topic = 'Learning about comments!'
      echo topic
    %}

Last updated 2023-11-08T16:20:48Z