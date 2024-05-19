# Adding translations to your Locksmith messages

This guide shows you how to use the translation filter built into Liquid to simplify translating your Locksmith messages

## Step 1 - Edit your Locksmith message

Start by adding something like the following to one of your Locksmith messages. More info on Locksmith messages here. You can use whatever keys you like, as long as it's prefixed with locksmith:

Copy

    {{ "locksmith.foo.bar" | t }}

Make sure to include the quotes. In the app that looks like this:

Based on what you enter there, this will trigger a Locksmith update which will automatically edit (all of) the locale files in your theme so that they include a new editable and translatable attribute. This is an example of what that might look like from within the locale files in your theme:

You can add this to any of Locksmith's messages, including the access denied content, guest message content, passcode prompt, etc.

## Step 2 - Adding the translations to your theme and locales

#### Default locale theme content

You can immediately open Online Store \> Themes \> "Edit default theme content" to edit what is shown there for your default language. If you're not sure how to edit the default content in your theme, check out Shopify's guide on that here.

When editing the default theme content, you'll now see a Locksmith tab, with a section that corresponds to what you added to the section above:

#### Translations

You'll need to install the free Translate and Adapt app from Shopify, or one of the other 3rd party alternatives. More info on how to use the Translate and Adapt app here.

If you've added the Translate and Adapt app to your store, you'll see the link to it from within the "Theme content" area. While you can open the app from your apps list, you can also open directly from there:

Once inside the "Translate and Adapt" app, scroll down to find the Theme \> "default theme content" area and press on it.

Then, similarly to above, you'll see a Locksmith section that you are free to edit as much as you need.

Do this for all of your store languages.

## Important caveat

The messages added with the above method are managed by Locksmith. If you delete the declaration in your messages (the {{ "locksmith.foo.bar" | t }} part), the corresponding messages will be deleted from (all of) your locale files.

If you want a persistent message, that isn't directly connected to, managed by, or deleted by Locksmith. You'll need to go with a more manual approach. Additionally, there are apps out there that can manage this kind of thing automatically.

Add this same entry into all desired locales files, and update the "Enter Passcode" to the specific language. Next, in your passcode prompt message, use the translate filter on that variable. Here's an example:

[PreviousDisabling Locksmith for certain theme files](/tutorials/more/disabling-locksmith-for-certain-theme-files)[NextRedirecting using Locksmith](/tutorials/more/redirecting-using-locksmith)

Last updated 2024-03-08T00:27:30Z