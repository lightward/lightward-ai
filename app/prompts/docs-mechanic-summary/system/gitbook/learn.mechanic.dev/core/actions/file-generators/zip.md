# ZIP

The ZIP file generator accepts an options object, specifying a set of files (themselves defined using file generators) to be compressed into a single ZIP file. The resulting ZIP file may optionally be password-protected.

## Options

| 

Option

 | 

Description

 |
| 

files

 | 

Required; an object specifying a set of filenames mapped to file generators

 |
| 

password

 | 

Optional; a string specifying a password to use for encrypting the file

 |

Copy

    {
      "zip": {
        "files": FILENAMES_AND_FILE_GENERATORS,
        "password": PASSWORD
      }
    }

## Example

LiquidJSON

Copy

    {% action "files" %}
      {
        "secure.zip": {
          "zip": {
            "password": "opensesame",
            "files": {
              "confirmations.txt": "this data is protected with zipcrypto encryption",
              "image.png": {
                "url": "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
              },
              "receipt.pdf": {
                "pdf": {
                  "html": "!!"
                }
              }
            }
          }
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "files",
        "options": {
          "secure.zip": {
            "zip": {
              "password": "opensesame",
              "files": {
                "confirmations.txt": "this data is protected with zipcrypto encryption",
                "image.png": {
                  "url": "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
                },
                "receipt.pdf": {
                  "pdf": {
                    "html": "!!"
                  }
                }
              }
            }
          }
        }
      }
    }

[PreviousURL](/core/actions/file-generators/url)[NextRuns](/core/runs)

Last updated 2022-05-05T17:56:14Z