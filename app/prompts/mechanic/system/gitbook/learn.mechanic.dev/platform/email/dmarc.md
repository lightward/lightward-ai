[Original URL: https://learn.mechanic.dev/platform/email/dmarc]

# DMARC

DMARC is an email authentication measure, increasingly important for deliverability. Learn more about DMARC here.

By default, Mechanic tasks send email using the domainmail.usemechanic.com, which is properly configured for DMARC. If you're using Mechanic's default email configuration, DMARC is handled for you. There are no steps you need to take.

Emails sent using a custom email address move the responsibility for DMARC to the email domain administrator. If you're using a custom email address, make sure that the domain you're using is properly configured for DMARC. (Mechanic can't help with this part.)

## Set up DMARC configuration

We recommend using DMARC configuration and monitoring by Postmark. (They're Mechanic's email provider! We're not paid for this endorsement; we just like what they make.)

- Free (and still very good): https://dmarc.postmarkapp.com/
- Premium (i.e. more complete tooling): https://dmarcdigests.com/
- Product comparison: https://dmarc.postmarkapp.com/#comparison

## Verify DMARC configuration

Once you've got your DMARC policy configured (no matter what strategy or tooling you've adopted), you can use this tool to make sure that it's set up properly.

- https://dmarcian.com/dmarc-inspector/

Last updated 2024-01-14T14:15:45Z