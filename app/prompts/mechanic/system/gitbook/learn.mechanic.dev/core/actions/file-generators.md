[Original URL: https://learn.mechanic.dev/core/actions/file-generators]

# File generators

File generators are invoked by actions to create new files, using options provided by the action, and handing the resulting file back to the action for further use. In this way, tasks can make choices about what files to generate, and what to do with the results.

| 

File generator

 | 

Purpose

 |
| 

Base64

 | 

Decodes base64-encoded content, returning a file containing the results

 |
| 

PDF

 | 

Renders HTML using a full Webkit browser, returning a PDF file of the results

 |
| 

Plaintext

 | 

Allows defining file contents using a plain string, instead of a file generator object

 |
| 

URL

 | 

Downloads and returns a file

 |
| 

ZIP

 | 

Accepts its own set of file generators, returning a ZIP archive of the results

 |

## Maximum filesize

Generated files may each be a maximum of 20MB.

"But why?", you may well ask!

Mechanic allows action run results to be fed back into the system (via mechanic/actions/perform). File generators usually end up having their resulting files represented in the action run results, and base64-encoding 20mb of binary data makes for a lot of JSON. We have to draw a line somewhere. 🤷

## Object structure

File generator objects, like action objects, are plain JSON objects each having a single key, and a single value. The object key specifies which file generator is to be invoked; the object value contains the options used for that generator.

Copy

    {
      FILE_GENERATOR_TYPE: FILE_GENERATOR_OPTIONS
    }

In practice, file generator objects are given as values in a larger JSON object, in which filenames are mapped to file generators.

The plaintext file generator is invoked implicitly by supplying a string, instead of supplying the usual file generator object.

In the following example, a Files action is defined, mapping filenames ("invoice.pdf", "external.jpg", and plain.txt) to file generators (a PDF generator, a URL generator, and – implicitly – a plaintext generator). Note how the file generator invocation varies, based on the specific file generator in play.

Copy

    {% action "files" %}
      {
        "invoice.pdf": {
          "pdf": {
            "html": "Order #12345\nIt's due!"
          }
        },
        "external.jpg": {
          "url": "https://upload.wikimedia.org/wikipedia/en/a/a9/Example.jpg"
        },
        "plain.txt": "This\nis\na\nmulti-line\nplaintext\nfile."
      }
    {% endaction %}

## Supported actions

These are the Mechanic actions that support file generators.

| 

Action

 | 

Usage

 |
| 

Email

 | 

Uses file generators to prepare email attachments

 |
| 

Files

 | 

Uses file generators to prepare temporary URLs, from which the generated files can be downloaded

 |
| 

FTP

 | 

Uses file generators to prepare FTP uploads

 |
| 

HTTP

 | 

Adds generated files to a multipart/form-data HTTP request

 |

Last updated 2023-11-10T23:34:12Z