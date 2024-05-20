# Creating scheduled CSV feeds

In this tutorial, you'll learn how to create a feed of your shop's data, and make it available on your online store, at a URL like https://example.com/pages/feed.

Tip: The data you generate can be imported directly into Google Sheets. Learn more: Can I send data to Google Sheets?

This technique has several limitations:

- Shopify doesn't support delivering the feed contents as plaintext. To get technical, this means that the feed will always be delivered with a content type of text/html.
- Because this task stores feed values as a shop metafield, feeds created with this technique may only contain and display up to 65,535 characters.

To move beyond these, consider using the FTP action to upload your feed to your own server.

## Instructions

### 1. Create your task.

Start with our example task, using the "Try this task" button to add it to your account:

Task: Create a product inventory feed

Immediately after adding the task, run it by clicking the "Run task" button. This will populate your shop's records with the initial value of the feed.

This task replicates Shopify's own product inventory CSV export. Feel free to make changes to the script, and don't hesitate to get in touch if you have questions. :)

### 2. Create a page template, called "page.feed.liquid".

This is the template that will be responsible for displaying your feed contents, without the usual page formatting that your shop's theme usually applies.

To do this, navigate to the "Themes" section of your Shopify admin (under "Online Store", or by searching for "themes"). Then, under the "Actions" menu for your current theme, click the "Edit code" link.

Next, click "Add a new template".

Then, select the option for creating a "page" template, of type "liquid", and fill in the text box with the name "feed" (or another template name to your liking).

Next, fill in the template contents with the following:

Copy

    {%- layout none -%}
    {{- shop.metafields.mechanic.feed -}}

... and click the "Save" button. Your template should look like this:

### 3. Create a new page to use as your feed.

Navigate to the "Pages" section of the Shopify admin (under "Online Store"), and click the "Add page" button (or search the admin for "add page"). Name the page "Feed" (or another name of your liking), and change the page template to "page.feed.liquid".

Save the page.

### You're done!

Open up the page you just created, and you should see the contents of your feed. :) If you have any questions, head to our community Slack.

Last updated 2023-10-30T06:18:36Z