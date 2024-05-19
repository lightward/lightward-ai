# PDF

The PDF file generator accepts an object containing an HTML string, and uses Pdfcrowd to render it as a PDF document. Pdfcrowd employs the Chromium Embedded Framework for HTML rendering, which uses the same foundation as Google Chrome. This allows Mechanic to generate PDFs with modern CSS and JavaScript features, including chart libraries and web fonts.

Mechanic accounts created prior to July 12, 2021 use a different rendering engine by default. Learn about migrating to Pdfcrowd

## Options

| 

Option

 | 

Description

 |
| 

html

 | 

Required; a string containing the HTML, CSS and JavaScript to be rendered

 |
| 

...

 | 

Additional Pdfcrowd API options supported; see below

 |

Copy

    {
      "pdf": {
        "html": HTML,
        ...
      }
    }

## Pdfcrowd options

The PDF generator supports all rendering-related options of the Pdfcrowd API, using version 20.10.

For a complete list of options, see https://pdfcrowd.com/doc/api/html-to-pdf/http/.

### Debugging

If it's unclear why something isn't rendering properly, start by testing the HTML being used in a Pdfcrowd playground, at https://pdfcrowd.com/playground/html-to-pdf. If the issue is reproducible in the playground, use the "Help" button along the left-hand sidebar to get the ID of your specific playground, and instructions for contacting Pdfcrowd support with the details of your test.

## Example

LiquidJSON

Copy

    {% capture html %}
    
    
    
    p { font-family: 'Liu Jian Mao Cao', cursive; }
    
    Almost before we knew it, we had left the ground.
    
    
    
    
      // from https://plotly.com/javascript/getting-started/
      TESTER = document.getElementById('tester');
    	Plotly.newPlot( TESTER, [{
    	x: [1, 2, 3, 4, 5],
    	y: [1, 2, 4, 8, 16] }], {
    	margin: { t: 0 } } );
    
    {% endcapture %}
    
    {% action "files" %}
      {
        "file.pdf": {
          "pdf": {
            "html": {{ html | json }},
            "page_width": "7in",
            "page_height": "5in",
            "margin_top": "10mm",
            "margin_right": "10mm",
            "margin_bottom": "10mm",
            "margin_left": "10mm"
          }
        }
      }
    {% endaction %}

Copy

    {
      "action": {
        "type": "files",
        "options": {
          "file.pdf": {
            "pdf": {
              "html": "\n\n\n\np { font-family: 'Liu Jian Mao Cao', cursive; }\n\nAlmost before we knew it, we had left the ground.\n\n\n\n\n // from https://plotly.com/javascript/getting-started/\n TESTER = document.getElementById('tester');\n\tPlotly.newPlot( TESTER, [{\n\tx: [1, 2, 3, 4, 5],\n\ty: [1, 2, 4, 8, 16] }], {\n\tmargin: { t: 0 } } );\n\n",
              "page_width": "7in",
              "page_height": "5in",
              "margin_top": "10mm",
              "margin_right": "10mm",
              "margin_bottom": "10mm",
              "margin_left": "10mm"
            }
          }
        }
      }
    }

[PreviousBase64](/core/actions/file-generators/base64)[NextMigrating to Pdfcrowd](/core/actions/file-generators/pdf/migrating-to-pdfcrowd)

Last updated 2023-10-13T20:01:06Z