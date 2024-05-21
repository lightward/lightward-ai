[Original URL: https://www.locksmith.guide/developer-tools/unsupported-functionality]

# Unsupported functionality

Here's a list of interesting ways to interact with Locksmith. None of these are officially supported. We can't troubleshoot your custom code. :)

## Create locks via the API

Example API payload:

Copy

    https://uselocksmith.com/api/unstable/lock
    
    payload:
    
    create_key_payload = {
    "resource_id": shopify_product_id,
    "resource_type": "product",
    "resource_options": {},
    "enabled": True,
    "options": {
    "hide_links_to_resource": False,
    "hide_resource": False,
    "hide_resource_from_sitemaps": False,
    "manual": False,
    "noindex": True
    },
    "keys": [
    {
    "options": {
    "customer_autotag": "",
    "force_open": False,
    "redirect_url": "",
    "inverse": False
    },
    "conditions": [
    {
    "type": "secret_link",
    "inverse": False,
    "options": {
    "customer_remember": True,
    "secret_link_code": secret_link_code
    }
    }
    ]
    }
    ]
    }

## Working with passcodes and secret links

The passcode and secret link can be extracted using the following:

Locksmith.params.passcode

Locksmith.params.secret\_link

Example usage: add the passcode as a cart attribute with javascript:

Copy

    
      window.addEventListener('load', () => {
        if (Locksmith.params.passcode) {
          $.post('/cart/update.json', { attributes: { passcode: Locksmith.params.passcode } })
        }
      });
    

Second example: Do the same thing, but add the "secret" part of the secret link instead:

Copy

    
      window.addEventListener('load', () => {
        if (Locksmith.params.secret_link) {
          $.post('/cart/update.json', { attributes: { passcode: Locksmith.params.passcode } })
        }
      });
    

## Working with Passcode/Secret Link expiry in UNIX timestamp

When you've set an expiration time in the passcode or secret link keys, you can see the expiration time as a UNIX timestamp. That's found in cart.json between the "-" and the ":" in the Locksmith entry:

The number before the "-" is the key id that was used to open the lock. What's after the colon is not valuable.

## Clearing the Locksmith cart attribute

Locksmith adds information as a cart attribute when using remote keys. You can clear that manually with something like this. This triggers when the page loads:

Copy

    
      window.addEventListener('load', () => {
        document.cookie="locksmith-params={};path=/;";
        $.post('/cart/update.json', {attributes: {locksmith: null}});
        document.cookie="locksmith-params={};path=/;";
      });
    

## 

## Redirecting after customer registration

Copy

    
      (function() {
        var current_url = window.location.href;
        var REDIRECT_PATH = '{{ current_url }}{% if collection %}/collections/{{ collection.handle }}{% endif %}/products/{{ product.handle }}';
    
        var selector = '#create_customer, form[action$="/account"][method="post"]',
            $form = document.querySelectorAll(selector)[0];
    
        if ($form) {
          $redirect = document.createElement('input');
          $redirect.setAttribute('name', 'return_to');
          $redirect.setAttribute('type', 'hidden');
          $redirect.value = REDIRECT_PATH;
          $form.appendChild($redirect);
        }
      })();
    

## Removing product information from Shopify Analytics in the page source

Sometimes, Shopify Analytics, Google Analytics, or Web Pixels can leave bits of information about your locked products in the page source. Locksmith can't filter that, since it's outside of your theme, but you may be able to replace the content with null values for just your locked resources.

Here's an example of how that might work with Shopify Analytics scripts:

Copy

    {% comment %}
      Find Shopify's analytics code and replace it with something free of
      potentially-sensitive details, if Locksmith thinks access should be denied.
    {% endcomment -%}
    ​
    {% capture replacement_script_tag -%}
      window.ShopifyAnalytics = window.ShopifyAnalytics || {};
      window.ShopifyAnalytics.meta = window.ShopifyAnalytics.meta || {};
      window.ShopifyAnalytics.meta.currency = '{{ cart.currency.iso_code }}';
    {%- endcapture -%}
    ​
    {% if locksmith_access_denied -%}
      {% assign content_for_header_pieces = content_for_header | split: "" -%}
      {% for piece in content_for_header_pieces -%}
        {% unless piece contains "window.ShopifyAnalytics = window.ShopifyAnalytics || {};" -%}
          {% continue -%}
        {% endunless -%}
    ​
        {% assign complete_script_tag = piece | split: "" | first | prepend: "" | append: "" -%}
        {% assign content_for_header = content_for_header | replace: complete_script_tag, replacement_script_tag -%}
        {% break -%}
      {% endfor -%}
    {% endif -%}

Last updated 2024-04-04T22:04:26Z