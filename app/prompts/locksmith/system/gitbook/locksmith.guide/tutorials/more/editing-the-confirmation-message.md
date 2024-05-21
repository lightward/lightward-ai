[Original URL: https://www.locksmith.guide/tutorials/more/editing-the-confirmation-message]

# Confirmation key condition

Ask for a simple confirmation before granting access to content in your Shopify Online Store sales channel.

This is a straightforward key condition that allows access solely based on if the customer confirms the prompt that you set. Something like the following:

To use, simply choose the key condition labelled "Permit if the customer confirms the prompt":

## Set the desired prompt

Common use-cases/examples include:

- Please confirm that you are over the age of 21
- By clicking 'Yes', you agree to our Terms of Service for accessing this page
- Confirm if you have read the prerequisite material to access this advanced module
- Please confirm that you have not experienced any recent health complications that could prevent you from fully engaging with this experience
- etc

Any message that you decide to use can be added directly to the Messages area:

You can also add messages directly to the condition setup if you need unique messages per condition. Or, you can set default messages the Settings \> Messages area of the Locksmith app, and leave Lock \> Messages blank to use it.

## Changing the button text

If you need to use something other than "Confirm" as your button text, this is done through your theme.

1. Go to Online Store \> Themes \> "Edit default theme content". More info on that, from Shopify, here.
2. Find the Locksmith tab, and edit the button as needed:

## Adding text after the button

If you want to add text that shows up after the button, simply use {{ locksmith\_confirmation\_form }} to denote where the form will show up. Then add more text as desired:

This results in the following, when Locksmith renders the prompt on button for your visitors:

## Translations

You'll need to follow the regular workflow for translating anything in your theme. To get started with that, you'll likely want to use Shopify's free Translate and Adapt app, or one of the paid apps from the app store. More info on this, from Shopify, here.

Once you have a language/locale/translation set up for your theme, you'll see a Locksmith \> "Confirmation button text" area which you can edit as needed, for each of your languages. In the Translate and Adapt app, that looks like this:

To add translatable messages to the input prompt, check out or guide here:

[pageAdding translations to your Locksmith messages](/tutorials/more/adding-translations-to-your-locksmith-messages)

Last updated 2024-03-18T21:41:45Z