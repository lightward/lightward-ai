# How can I reduce memory usage of my task?

Instant fixes are hard to come by for this kind of problem. If you need help with your task code, here's where to find assistance.

Memory efficiency is a dynamic problem. Here are some tips for task code when memory constraints become a factor.

## Look for loops.

Any time a data set is iterated upon, any memory inefficiencies within the loop have a chance to be multiplied in severity.

## Look for large assignments.

Remember that Liquid variable assignments (i.e. any use of the assign tag) are always by value, not by reference. This can lead to surprise memory exhaustion with large values. Check on your assignments, concatenations, captures, etc.

## Look for opportunities to split up the work.

A single task run has a limited amount of memory available to it, but you can generate as many task runs as you like. If you need to "fork" into multiple task runs, use Event actions to create events with just enough data to create multiple tightly-scoped task runs.

## Consider bulk operations.

Task runs responding to mechanic/shopify/bulk\_operation are allocated more memory than regular task runs. If you aren't already using one, consider whether your use case could be achieved using a bulk operation.

[PreviousCan I add another store to my existing Mechanic subscription?](/faq/can-i-add-another-store-to-my-existing-mechanic-subscription)[NextHow do I connect PayPal to Shopify with Mechanic?](/faq/how-do-i-connect-paypal-to-shopify-with-mechanic)

Last updated 2024-01-21T19:23:44Z