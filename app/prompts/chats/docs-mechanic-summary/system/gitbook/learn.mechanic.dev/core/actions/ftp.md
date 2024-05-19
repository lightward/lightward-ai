# FTP

Upload and download files via FTP, FTPS, or SFTP.

The FTP action can upload and download files via FTP, FTPS, or SFTP. The files to be uploaded are evaluated using file generators. Downloaded file data is available either as an UTF-8 string, or as a base64-encoded string, and can be used in followup task runs via mechanic/actions/perform.

A connecting service like Couchdrop can be used to relay these uploads on to other cloud locations, like Dropbox, Google Drive, and Amazon S3.

A single FTP action may download a maximum of 20MB of data, across all downloaded files.

## Options

### General options

| Option | Type | Notes |
| --- | --- | --- |
| 

protocol

 | 

"ftp", "ftps", or "sftp"

 | 

The protocol to use for connection; inferred if omitted

 |
| 

host

 | 

String, required

 | 

The hostname or IP address of the destination server

 |
| 

port

 | 

Number, optional

 | 

The server port to connect to

 |
| 

user

 | 

String, required

 | 

The username for authentication

 |
| 

password

 | 

String, optional

 | 

The password for authentication

 |
| 

uploads

 | 

Hash, optional

 | 

An object whose keys are file paths (relative or absolute), and whose values are file generators

 |
| 

downloads

 | 

Array, optional

 | 

File path strings (relative or absolute) to download

 |

### FTP options

| Option | Type | Notes |
| --- | --- | --- |
| 

mode

 | 

String, optional

 | 

May be set to "ascii"; defaults to "binary"

 |

### FTPS options

| Option | Type | Notes |
| --- | --- | --- |
| 

verify

 | 

Boolean, optional

 | 

May be set to false to ignore SSL certificate errors

 |

### SFTP options

| Option | Type | Notes |
| --- | --- | --- |
| 

private\_key\_pem

 | 

String, optional

 | 

A complete PEM-formatted private key for authentication

 |
| 

verify

 | 

Boolean, optional

 | 

May be set to true in combination with "known\_hosts" to validate the host

 |
| 

known\_hosts

 | 

String, optional

 | 

An sshd-compatible known\_hosts file (docs, helpful article)

 |

### User authentication

The user option is always required.

When connecting to an FTP or FTPS server, authenticate with the password option.

When connecting to an SFTP server, authenticate using either password or private\_key\_pem, or both. PEM certificates may be given directly in the task code:

Copy

    {% capture private_key_pem %}
    -----BEGIN OPENSSH PRIVATE KEY-----
    l0UGrDQWWbOpUsLENHwD5ya478pmRXarmDj5Wh31B54nmuq7be4ZKD5eh9nEV42JCl4mX6
    ...
    pZ/WFoT82brhooSfJDue14C0Y=
    -----END OPENSSH PRIVATE KEY-----
    {% endcapture %}
    
    {% action "ftp" %}
      {
        "host": "example.com",
        "port": 22,
        "user": "sftp_user",
        "private_key_pem": {{ private_key_pem | json }}
        "uploads": {
          "success.txt": "hooray!"
        }
      }
    {% endaction %}

### Uploads and downloads

Both uploads and downloads allow the task author to define file paths. If only the filename is given (e.g. "sample.pdf"), the file will be resolved in the home directory of the user. If a relative path (e.g. "subdirectory/sample.pdf") or absolute path (e.g. "/tmp/sample.pdf") is given, it will be respected accordingly.

Each individual file operation (i.e. each upload or download) will be attempted a maximum of 3 times within the FTP/FTPS/SFTP session, retrying if an error occurs during upload or download.

#### Example

This example action results in (a) an upload to an absolute path, starting from the server root, (b) an upload to a nested directory within the user's home folder, and (c) an upload to a nested directory in another user's home folder (which may fail, depending on filesystem permissions).

Copy

    {% action "ftp" %}
      {
        ...
        "uploads": {
          "/absolute/path/to/success.txt": "hooray!",
          "relative/path/to/success.txt": "hooray!",
          "../another/relative/path/to/success.txt": "hooray!"
        }
      }
    {% endaction %}

## Result

In Mechanic, actions are performed after their originating task run concludes. Actions are not performed inline during the task's Liquid rendering.

To inspect and respond to the results of an HTTP action, add a task subscription to mechanic/actions/perform, allowing the action to re-invoke the task with the action result data.

Learn more: Responding to action results

An FTP action returns the following data structure, most useful in combination with mechanic/actions/perform (see Responding to action results):

Copy

    {
      "log": "connect: ftp.couchdrop.io, 21\n< 220 Couchdrop FTPD\n> USER ********\n< 331 Username ok, send password.\n> PASS******** \n< 230 Welcome ******** \n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,153).\n> STOR journal.txt\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,98).\n> STOR table.csv\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,135).\n> STOR invoice.pdf\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,101).\n> STOR secure.zip\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,100).\n> STOR external.jpg\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,183).\n> RETR journal.txt\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n> TYPE I\n< 200 Type set to: Binary.\n> PASV\n< 227 Entering passive mode (178,128,9,71,234,149).\n> RETR table.csv\n< 125 Data connection already open. Transfer starting.\n< 226 Transfer complete.\n> TYPE I\n< 200 Type set to: Binary.\n",
      "uploads": {
        "invoice.pdf": {
          "size": 7232
        },
        "secure.zip": {
          "size": 205
        },
        "external.jpg": {
          "size": 27661
        }
      },
      "downloads": {
        "journal.txt": {
          "size": 12,
          "data": "hello world!",
          "data_base64": "aGVsbG8gd29ybGQh"
        },
        "table.csv": {
          "size": 27,
          "data": "Title,SKU\nRed T-Shirt,TEE-R",
          "data_base64": "VGl0bGUsU0tVClJlZCBULVNoaXJ0LFRFRS1S"
        }
      }
    }

Note that each uploaded and downloaded file is keyed by the path provided for that file in the action's options. Downloaded file data is available as a UTF-8 string; for binary data that cannot be represented in UTF-8, use the base64-encoded version, possibly in concert with the decode\_base64 filter.

## Testing

If a server is unavailable for testing, consider using Couchdrop, with their hosted storage service. This is a (nearly) configuration-free avenue for testing, using my.couchdrop.io for FTP, FTPS, or SFTP.

Alternatively, ngrok can be used to create a public tunnel to a local FTP or SSH server. By running ngrok tcp 22 (adjusting for the appropriate local port), ngrok will generate a temporary public host and port that's appropriate for use while testing.

Uploads are processed before downloads; it can be useful to test by uploading a file, and then immediately downloading it again:

Copy

    {% action "ftp" %}
      {
        "host": "ftp.couchdrop.io",
        ...
        "uploads": {
          "hello-world.txt": "hello world!"
        },
        "downloads": [
          "hello-world.txt"
        ]
      }
    {% endaction %}

## Example

This task compiles all SKUs with their titles and prices, and uploads it as a CSV every night or on demand.

SubscriptionsCode

Copy

    mechanic/scheduler/daily
    mechanic/user/trigger

Copy

    {% assign csv_rows = array %}
    
    {% assign header = "SKU,Title,Price" | split: "," %}
    {% assign csv_rows[0] = header %}
    
    {% for product in shop.products %}
      {% for variant in product.variants %}
        {% assign title = variant.title %}
        {% if title == "Default Title" %}
          {% assign title = product.title %}
        {% endif %}
    
        {% assign row = array %}
        {% assign row[row.size] = variant.sku %}
        {% assign row[row.size] = title %}
        {% assign row[row.size] = variant.price %}
    
        {% assign csv_rows[csv_rows.size] = row %}
      {% endfor %}
    {% endfor %}
    
    {% capture filename %}product-export-{{ "now" | date: "%Y-%m-%d" }}.csv{% endcapture %}
    
    {% action "ftp" %}
      {
        "host": "example.com",
        "port": 21,
        "user": "anonymous",
        "password": null,
        "uploads": {
          {{ filename | json }}: {{ csv_rows | csv | json }}
        }
      }
    {% endaction %}

[PreviousFiles](/core/actions/files)[NextHTTP](/core/actions/http)

Last updated 2023-11-18T19:38:52Z