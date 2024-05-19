# Customizing the passcode form

Locksmith gives you flexibility in how you can customize the passcode form!

Here are some of the many different ways you can edit the passcode form!

## 1. Add content that is displayed before the form.

This is the default behavior for the message. You can add as much content as you need, including text, images and backgrounds, by simply adding code directly to the "Passcode prompt" area, found on the lock page, under Messages:

 ![](https://www.locksmith.guide/~gitbook/image?url=https%3A%2F%2Fs3.amazonaws.com%2Fhelpscout.net%2Fdocs%2Fassets%2F5ddd799f2c7d3a7e9ae472fc%2Fimages%2F6179b6139ccf62287e5f0638%2Ffile-A4L7rINXDU.png&width=768&dpr=4&quality=100&sign=38a181921d6c735fe707bbd8e6ca6c6a8e497fbb865ebe6762ddd508f3de8198)

Any code that you add to this area will be rendered normally, as if adding it to the theme. Including:

- HTML - using regular HTML tags
- CSS - using \ your CSS code here \
- Javascript - using \ your javascript code here \
- Liquid - using regular Liquid syntax

## 2. Add content after the form

Simply use {{ locksmith\_passcode\_form }} to denote where the form itself will go, and then add in content that you want to display before and after it.

Copy

    Please enter the passcode to continue: 
    
    {{ locksmith_passcode_form }}
    
     Content to be displayed after the form 

## 3. Editing the "Continue" and "One moment..." text

This is not done in the Locksmith app, but rather in the theme's "Edit default theme content" settings:

Once in the "Theme content" settings, you'll need to go to the "Locksmith" tab, which is typically not visible right away:

So then finally, you can edit the text itself, under the Locksmith tab:

Note: This step only changes the wording for your default language. If you are using multiple languages in your store, you'll also need to go through the "Localize" step. Check out Shopify's guide on doing that here.

Editing the "Cancel" button text used in the manually triggered passcode form

Locksmith's manual mode can be used to hide specific parts of your theme, such as the add-to-cart button, instead of hiding the entire product page. In this case, the passcode form needs to be 'manually triggered' to present the form to customers, using a custom passcode button.

This is covered in our price hiding guide here: Hiding product prices and/or the add to cart button

The manually triggered passcode form includes a 'Cancel' button that can be used to close the passcode form, revealing the product page again.

To edit the text for this button, some CSS will need to be added to the 'Passcode prompt' message field. The following example code can be used for that, replacing the 'Close' text with your own.

Copy

    
        .or-cancel a:nth-child(1) {
            visibility: hidden;
            position: relative;
        }
        .or-cancel a:nth-child(1):after {
            content: "Close";
            visibility: visible;
            position: absolute;
            top: 0;
            left: 0;
            color:black
        }
    

## 4. Replacing or editing the form itself

Some merchants want more control over the form itself, not just the text that is shown alongside it. This could just be for more granular edits to the way it looks, or to perform more complicated javascript operations on the text input.

Although we can help troubleshoot, if you choose to override the form, the coding and style is up to you, we are not able to create a new form for you.

To do this, simply use the "Passcode prompt" area to put in your new form. Since you're overriding the form, you'll need to add in all the code for the new form. To begin, copy/paste this entire section (including the script!) into the Messages \> Passcode prompt area. Then, edit as needed:

Copy

    
      
        Enter the passcode to continue: 
        
        CONTINUE
      
    
    
    
      var passcodeForm = document.getElementById("locksmith_passcode_form");
      passcodeForm.addEventListener('submit', function (event) {
        event.preventDefault();
        var passcode = document.getElementById("locksmith_passcode").value;
        /* REMOVE THIS LINE and insert any desired transforms to passcode here */
        Locksmith.submitPasscode(passcode, event);
      });
    

If you need to perform text transforms (e.g. downcasing the text for case-insensitivity), do that in the marked area in the script above.

Editing tips

- Changing the form too extensively (editing the text input, script, classes/ids) could cause the passcode not to be submitted correctly, so try to stick as close to the above as possible.
- Locksmith will look for the \ tag with the "locksmith\_passcode\_form" id, so that's something to keep in mind if you see that Locksmith is still rendering the default form when overriding:

Copy

    
      ...rest of form code...
    

## 5. Editing other specific elements on the form

Here are a few examples of how you might use CSS to style your passcode messages. You can put these directly in your passcode messages in Locksmith (making sure to surround them with the \ ... \ tag), or add them to the stylesheets in your theme.

* * *

Target the 'Continue' button by ID

Copy

    #locksmith_passcode_submit { color: blue; }

* * *

Target the input field by class

Copy

    #locksmith_passcode { border 1px solid red; }

* * *

Center the continue button

Copy

    .locksmith-passcode-container p:last-child { text-align: center; }

* * *

Showing a message when the customer enters the wrong passcode

Copy

    form.locksmith-authorization-failed::before {
      content: 'The passcode you have entered is invalid. Please enter another passcode.';
      color: red;
    }

* * *

Add a background image to the entire page

Copy

    body {
      background-image: url('https://YOUR-URL-HERE') !important;
    }

* * *

Add a background image to only the form area

Copy

    #locksmith-content {
      background-image: url('https://YOUR-URL-HERE');
      background-size: 100%;
      background-repeat: no-repeat;
    }

* * *

Add placeholder text to the passcode entry field using javascript

With jquery:

Copy

     setTimeout(() => { $('#locksmith_passcode').attr('placeholder', 'This is a placeholder!'); }, 10); 

With vanilla javascript:

Copy

    document.querySelector('#locksmith_passcode').setAttribute('placeholder', 'Enter password');

* * *

While we cannot make extensive custom edits to your form for you, if you have any questions you can contact us via email at team@uselocksmith.com

[PreviousCustomizing the registration form](/tutorials/more/customizing-the-registration-form)[NextRestricting customers to a specific collection](/tutorials/more/restricting-customers-to-a-specific-collection)

Last updated 2024-04-03T17:33:06Z