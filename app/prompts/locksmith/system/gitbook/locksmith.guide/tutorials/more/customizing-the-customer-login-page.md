# Customizing the customer login page

Customizing the login form shown on a page locked by Locksmith in your Shopify Online Shop

If you are using Shopify's new customer account system, the login form comes directly from Shopify (as opposed to coming from the theme) so editing the login form is not possible. However, using this guide, you can still edit Locksmith's landing page (which links to the login form).

Whenever you use Locksmith to require your visitors to log in with their customer account, Locksmith will automatically pull in your theme's customer login form, with a message of your choosing added just above it.

You can customize the message in two places:

- Using the sidebar navigation, go to Settings \> Messages \> Guest message content. This is where you can edit the default message that is applied to all locks.
- On the lock page, find Messages \> Guest message content. This is where you can edit the lock-specific message, which overrides the default.

Copy

    This content is protected - please log in with your customer account to continue.

You can customize this message using as much HTML, CSS, and Liquid as you need!

Also, keep in mind that the "Guest message content" only applies to pages locked by keys that actually require a login. If your lock does not require a login, you may need to edit one of the other fields under "Lock Messages".

There are many ways to customize this page which the rest of this guide will cover!

## 1. Customizing the login form itself

Since Locksmith is just grabbing the login template directly from your theme, you'll need to head into your theme to edit it. Shopify has a guide dedicated to doing this here. Using that guide you can do things like remove the "Register" link from your login form or edit the styling in other ways.

Important: Anytime you edit the login template in your theme, you'll want to make sure that Locksmith is using the updated version of it. To do this, go to the Help area within the Locksmith app and press the "Update Locksmith" button there.

## 2. Adding the registration form to this page

Easy! Just add the following into the "Guest message content" area.

Copy

    {{ locksmith_customer_register_form }}

Once again, this is just grabbing the registration page from your theme. If you've edited your registration template and you aren't seeing it updated here, head to the "Help" area within the Locksmith app and press the "Update Locksmith" button to see the latest version on your lock page.

## 3. Editing the placement of the login form in relation to your lock message

By default, the "Guest message content" is displayed in its entirety as the first thing on the page (after the header) followed by the login form. You have the ability to change this: display the message after the login form, or perhaps add content before and after the login form. To do this, use the following in your "Guest message content" area:

Copy

    {{ locksmith_customer_login_form }}

This will determine the placement of your login form and you're then free to add any content before/after it.

## 4. Remove the login form from the page entirely!

If you don't want your customers to see the login form on this page for whatever reason, you can remove it by just adding this to your "Guest message content":

Copy

    {% comment %}
      {{ locksmith_customer_login_form }}
    {% endcomment %}

You can then add the rest of your message alongside that code.

## 5. The Locksmith message isn't visible on the locked page, or its partially hidden

If the message is nowhere to be seen, it's probably just hidden under your header. Some themes don't add padding directly to the header and rely on the template to have its own padding. Since Locksmith replaces the template's code with its own content, it may be necessary to add the padding to it. This is usually as easy as adding this to the beginning of your "Guest message content":

Copy

    

Of course, you can adjust the number as needed.

As always, feel free to contact us at team@uselocksmith.com if you need help with this.

## 6. Centering the message on the lock page

To get the text on this page centered, change the beginning \ tag to the following:

Copy

    

If you've removed the beginning \ tag, just add a new one :) And, of course, make sure to close it with \ at the end of your text.

## 7. Placing the lock message within the login form itself

There are a few reasons you might want this. For example, if your login form is preceded by a heading or some breadcrumbs, you may want to insert the Locksmith-specific message beneath the heading, but above the email and password fields.

This gets a bit technical, so if you need a hand, just hit that message button in the lower-right corner! :)

To customize where your guest content message appears, open up the code editor for your Shopify theme ( here's how!), and open the file templates/customers/login.liquid. You might see something like this:

Copy

    Login{% form 'customer_login' %} {{ form.errors | default_errors }}
    
      Email Address
      
      Password
      
      
    {% endform %}

Add the code \
    
    {% form 'customer_login' %}
      {{ form.errors | default_errors }}
    
    
      Email Address
      
      Password
      
      
    {% endform %}

Next, head to the "Settings" tab of your Locksmith account, and scroll down to the "Guest message content" field. Use a value like the example below to (a) customize your guest message, and (b) have Locksmith display your login template with your custom message injected into it:

Copy

    {% capture locksmith_message %} Please login below! :){% endcapture %}{{ locksmith_customer_login_form | replace: '', locksmith_message }}

That's it! :D You've just customized the login form's display using pure Liquid - congratulations, and feel free to experiment until the result is just right for your shop. :)

## Something else not covered here?

Let us know by emailing us at: team@uselocksmith.com

Last updated 2023-12-29T17:30:43Z