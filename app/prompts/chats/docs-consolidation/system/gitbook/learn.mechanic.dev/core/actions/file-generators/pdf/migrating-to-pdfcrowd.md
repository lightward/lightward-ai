# Migrating to Pdfcrowd

Mechanic accounts created prior to July 12, 2021 default to using wkhtmltopdf instead of Pdfcrowd. This rendering engine uses a version of WebKit from 2012, and therefore does not support many features of the modern web.

We strongly encourage all users to migrate to Pdfcrowd, which uses a modern release of Chrome for rendering HTML.

This page is about migrating to Pdfcrowd. To learn more about using Pdfcrowd, see the PDF file generator documentation.

## Switching to Pdfcrowd

For accounts created prior to July 12, 2021, an option labeled "Opt in to Pdfcrowd" is available in the Mechanic account settings. To start using Pdfcrowd for the entire account, enable this option, and click the "Save settings" button.

Or, to start using Pdfcrowd with just a single file generator, add "\_\_force\_pdfcrowd": true to the PDF generator options.

Copy

    {% action "files" %}
      {
        "migration_test.pdf": {
          "html": "hello world!",
          "__force_pdfcrowd": true
        }
      }
    {% endaction %}

### Pdfcrowd options

See https://pdfcrowd.com/doc/api/html-to-pdf/http/ for a complete list of rendering options supported by Pdfcrowd.

### wkhtmltopdf options

This wkhtmltopdf option list is given as a reference while migrating to Pdfcrowd. Don't build new wkhtmltopdf-specific functionality using these options.

collate, no-collate, grayscale, image-dpi, image-quality, lowquality, margin-bottom, margin-left, margin-right, margin-top, orientation, page-height, page-size, page-width, no-pdf-compression, title, outline, no-outline, outline-depth, background, no-background, default-header, encoding, disable-external-links, enable-external-links, disable-forms, enable-forms, images, no-images, load-media-error-handling, minimum-font-size, exclude-from-outline, include-in-outline, page-offset, disable-smart-shrinking, enable-smart-shrinking, disable-toc-back-links, enable-toc-back-links, zoom, footer-center, footer-font-name, footer-font-size, footer-html, footer-left, footer-line, no-footer-line, footer-right, footer-spacing, header-center, header-font-name, header-font-size, header-html, header-left, header-line, no-header-line, header-right, header-spacing, replace, disable-dotted-lines, toc-header-text, toc-level-indentation, disable-toc-links, toc-text-size-shrink

To use options from the list above, add them alongside "html":

Copy

    {
      "pdf": {
        "html": "This is a document.",
        "page-width": "6in",
        "page-height": "6in",
        "margin-top": "0.75in",
        "margin-right": "0.75in",
        "margin-bottom": "0.75in",
        "margin-left": "0.75in"
      }
    }

## 

[PreviousPDF](/core/actions/file-generators/pdf)[NextPlaintext](/core/actions/file-generators/plaintext)

Last updated 2023-10-13T19:50:12Z