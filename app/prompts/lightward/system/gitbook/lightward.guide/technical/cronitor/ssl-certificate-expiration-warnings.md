# SSL certificate expiration warnings

We have Cronitor monitors (love that language) keeping an eye on all the spots we accept HTTP traffic. These monitors are configured to verify SSL certificates. This monitoring comes with certificate expiration warnings, which can't be selectively disabled. These warnings are safe to ignore, since Fly manages our certs automatically.

Last updated 2023-12-15T17:24:13Z