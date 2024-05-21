[Original URL: https://www.locksmith.guide/tutorials/more/input-lists]

# Input lists

How to use Locksmith's Input List feature to work with large numbers of inputs

Locksmith gives you the ability to use input lists for managed sets of passcodes, secret links, or email addresses. They're useful when you have a very large number of possible inputs.

Note: Any time you have 1000+ inputs, it is recommended to use input lists over their vanilla counterparts. Input lists can handle millions of entries, so you have a lot of flexibility here.

## Step 1: Add your inputs to an external file

Input lists are stored externally! So you'll need to create a file that is accessible via a URL, adding all of the values to it that you would like to use.

The most straightforward way to do it is to simply use Google sheets: https://www.google.com/sheets

Google Sheets must be formatted as a document having a single column of input values, one value per row.

### Supported file formats

In addition to Google Sheets, sources may be of the following formats:

- TXT (one input value per line)
- CSV (a single column of input values, one value per row)
- JSON (an array of strings)
- Microsoft Excel XLSX (a spreadsheet having a single column of input values, one per row)
- JSON array provided by a Mechanic cache endpoint (read more about Mechanic here)

Important: The source file must be either unauthenticated OR must be a Google Sheet or Google Doc that has been shared with the following email address: input-lists@locksmith-app.iam.gserviceaccount.com. If you send a notification directly to this email address, it may bounce. However, as long as the document is properly shared with that email address, Locksmith will be able to access it.

## Step 2: Locksmith Configuration

Input lists are configured in your Locksmith account settings. To find this area, open the Locksmith app and go to the Settings area (using the left-hand navigation):

Input lists are available in the "Extensions" area:

### Options

An input list has four options:

- Name
- Source URL
- Input values are case-sensitive (enable to require an exact case match)
- Default usage limit per input list item - allows you to specify a default usage limit for any items that you add to the list. This is a great way to add unique inputs - simply enter 1 as the usage limit and each input can only be used once.

### Syncing

When an input list is synchronized with its source, any new items found in the source file will be added to Locksmith's copy of the list. Any items that are no longer found in the source file will be removed from Locksmith's copy of the list.

Input lists that are sourced from Google Drive will be automatically synchronized whenever the source file is changed. (When used with Google Sheets, this allows for interesting flexibility: one could use a Google Form that saves data to a Google Sheets file, which then feeds into an input list. Whenever the form is submitted, Locksmith would automatically sync a new value into the input list.)

All other input lists are automatically synchronized on a regular basis (currently at midnight UTC, subject to change without notice).

All input lists may be synchronized manually, by using the "Sync input list" button for the respective list.

## Step 3: Use with specific key conditions

Once you've created at least one input list, you may use it when configuring a new key condition in your lock settings, by choosing one of the "Permit if..." options that mentions input lists. When adding keys to you locks, use the corresponding options...

### Email Addresses

When configuring your key condition, select the "Permit if the customer has an email address from an input list…" option to have Locksmith compare customer inputs with items in your input list:

More information on using customer account key conditions here:

[pageCustomer account keys](/keys/customer-account-keys)
### Passcodes

When configuring your key condition, select the "Permit if the customer gives a passcode from an input list…" option to have Locksmith compare customer input with items in your input list

As with Locksmith's other passcode conditions, you may configure this condition to "remember" returning customers who are logged in. If this option is enabled, Locksmith will compare previously-accepted passcodes from the customer's records with current items in the selected input list. This means that removing previously-used items from the input list will result in the relevant returning customers being "forgotten".

More information on using passcodes here:

[pagePasscode keys](/keys/passcode-keys)
### Secret links

When configuring your key condition, select the "Permit if the customer arrives using a secret link code from an input list…" option to match the visitor's current URL with items in your input list:

As with standard secret link keys, Locksmith will be trying to find matching secret link codes in the following parts of the URL:

- The URL's "search" portion. For example, in a URL that looks like "https://example.com/?foo=bar&baz&ls=qux", Locksmith will consider items in your input list having the value "foo=bar&baz&ls=qux".
- Any component in the URL's "search" portion. For example, in a URL that looks like "https://example.com/?foo=bar&baz&qux", Locksmith will consider items in your input list having one of these values: "foo=bar", "baz", "ls=qux".
- The "ls" query parameter, if present. For example, in a URL that looks like "https://example.com/?foo=bar&baz&ls=qux", Locksmith will consider items in your input list having the value "qux".

This means that you may form your shared URLs in any of the following ways, using an example secret link code of "foobar" to illustrate:

- https://example.com/?foobar
- https://example.com/?ls=foobar

Feel free to combine either option with other query parameters, like so:

- https://example.com/?foobar&utm\_source=baz&...
- https://example.com/?ls=foobar&utm\_source=baz&...

As with Locksmith's other secret link condition, you may configure this condition to "remember" returning customers who are logged in. If this option is enabled, Locksmith will compare previously-accepted secret link codes from the customer's records with current items in the selected input list. This means that removing previously-used items from the input list will result in the relevant returning customers being "forgotten".

More information on using secret links here:

[pageSecret link keys](/keys/secret-link-keys)

Last updated 2022-11-09T05:56:34Z