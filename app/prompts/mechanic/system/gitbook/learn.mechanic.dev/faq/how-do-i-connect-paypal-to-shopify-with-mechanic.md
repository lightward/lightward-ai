# How do I connect PayPal to Shopify with Mechanic?

To integrate PayPal transactions into your Shopify orders, leverage the Import PayPal transactions as Shopify orders Mechanic task. Follow the steps provided to seamlessly connect the two platforms. ❤️

### 1. Setup a Mechanic webhook that PayPal can send your transactions to

- Under settings in the Mechanic app setup a new webhook. You'll give the webhook a name (PayPal) and a topic (user/payppal/ipn) as shown below.
- One you click save you'll have copy the webhook URL which you'll need to configure PayPal to send your transactions.

### 2. Setup PayPal to send you transactions to Mechanic

- Next, log in to your PayPal account and use this link to jump to the Instant Payment Notification (IPN) settings screen.
- Click the Choose IPN Settings button and then paste in your Mechanic webhook URL from Step 1 and choose the option to Receive IPN Messages and click Save.

### 3. Install and configure the Mechanic task

- Install the task: https://tasks.mechanic.dev/import-paypal-transactions-as-shopify-orders
- Configure the task to taste and save :) Here's a sample configuration:

Last updated 2024-04-19T18:27:05Z