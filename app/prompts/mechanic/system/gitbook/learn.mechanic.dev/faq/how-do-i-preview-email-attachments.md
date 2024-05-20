# How do I preview email attachments?

### What won't work

For tasks that use the Email action, you'll see a preview of the email itself in the task preview area.

This preview includes an "Expand preview" button, which then allows you to send a copy of the message to the email address of your choice.

Importantly, this feature does not include attachments. (Under the hood, this is because compiling attachments can take an unpredictable amount of system resources, making this job best served by Mechanic's run system.)

### What will work

The best way to approach this is by creating a brand new task, which...

- ... subscribes to mechanic/user/trigger, allowing you to run the task on demand
- ... uses the Files action, using the same data that you're using in your "email" action's attachments

(This technique leverages the fact that Mechanic generates files in the same way, across the "email" and "files" actions; see File generators for more on this.)

In order to make this work, you may need to pull in data needed for your files. For example, if you're working on an email attachment based on order data, you may need to pull in a sample order object, like this:

Copy

    {% assign order = shop.orders[1234567890] %}

Using this technique gives you a dedicated workspace, in the form of a task, for iterating on your file attachments. Once you have your attachment-generating code the way you want it, bring that code back to your original task.

Last updated 2021-04-18T00:57:02Z