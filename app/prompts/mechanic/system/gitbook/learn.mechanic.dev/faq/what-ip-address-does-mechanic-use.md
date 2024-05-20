# What IP address does Mechanic use?

In general, Mechanic uses dynamically-assigned IP addresses, and does not support static or fixed IP addresses for outgoing or inbound requests.

## HTTP actions

The HTTP action supports HTTPS, HTTP, and SOCKS5 proxies, allowing you to set up your own proxy server with a static IP address, passing your Mechanic requests through it. Using this strategy, you can control the client IP addresses used for your outbound requests. This can be useful for API vendors that have IP address restrictions. Learn more: Actions / HTTP / Using a proxy.

## Outbound email

Mechanic itself doesn't offer any guarantees about IP addresses used for outgoing mail. However, in practice, our email provider Postmark does offer such a list: ​ ​https://postmarkapp.com/support/article/800-ips-for-firewalls#outbound ​ Mechanic doesn't offer any representation of Postmark's commitment to those addresses. While it's unlikely, the possibility exists that Mechanic would use another email provider (with different IPs) in the future.

Mechanic works with Postmark to use DKIM message signing and Return-Path routes, both of which are strong signals for deliverability. The requisite DNS configuration for these features is part of validating any custom email address used in Mechanic.

Last updated 2023-03-13T23:07:32Z