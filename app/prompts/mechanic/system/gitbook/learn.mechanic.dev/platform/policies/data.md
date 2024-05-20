# Data

## Residency

Mechanic stores all data in the US, on encrypted volumes provided by Crunchy Data and AWS. Data encryption keys are managed by Crunchy Data.

For more details, see Crunchy Data's Security documentation.

## Retention of events

An event is retained for a default of 15 days after the event is considered "complete" (see below). To set a different retention period for your Mechanic account, email team@usemechanic.com.

For stores that have uninstalled Mechanic, events will be retained for the same retention period after the event's latest activity, whether or not an event is "complete".

Mechanic's datastores keep rolling backups for a period of 7 days. This means that a deleted event will be included in backups for 7 days after deletion.

Retained event information includes:

- Event data (for Shopify events, this means the payload of the related webhook)
- Task runs for those events (i.e. the result of rendering task Liquid with the related event data)
- Action runs for those events, and their results

For the purposes of data retention, an event is considered "complete" when all of the following are true:

1. The event has no related runs which are pending (i.e. event/task/action runs that have neither succeeded nor failed)
2. The event's descendent events, up to five generations, have no related runs that are pending (see Parent and child events)

The content of event data varies based on the tasks configured for your Mechanic account. A task that monitors customer events will result in Mechanic storing customer data, for example. Similarly, a task that monitors order events will result in Mechanic storing order data (which includes customer data). However, tasks that simply scan orders or customers in bulk (perhaps on a schedule, or upon request) may not necessarily store order or customer data.

### Examples

#### Immediate deletion

1. A customer creates an account.
2. Shopify sends Mechanic a customer creation event, containing all of that customer's data.
3. A merchant-configured Mechanic task sends that customer an email; no other activity is performed.
4. 15 days later, by policy, Mechanic deletes the customer creation event (which contain the customer's data), and the related runs (which contain everything needed to send them the email).

#### Delayed deletion

1. A store staff member creates a customer order.
2. Shopify sends Mechanic an order creation event, containing the order's data and the customer's data.
3. A merchant-configured Mechanic task is scheduled to run 30 days in the future, at which time it will send a follow-up customer email.
4. 15 days after the order was created, Mechanic checks the order creation event, and discovers that a task run is still pending. The event is not deleted.
5. 30 days after the order was created, the task runs, generating an "email" action run which sends the customer follow-up later.
6. Shortly thereafter, Mechanic checks the order creation event, finds that all related runs have been completed, and deletes the event (which contains the order's data and the customer's data), and the related task and action runs (which contain all details for the customer follow-up email).

#### Recursively delayed deletion

1. A store has an unusual data retention period: their Mechanic account is configured to delete events after 1 day.
2. A customer is tagged "member".
3. Shopify sends Mechanic a customer update event, containing all of that customer's data.
4. A merchant-configured Mechanic task observes this event. Noting the addition of the customer tag, this task checks the both the current event and the last 5 events (keep reading) to ensure that the customer has placed at least 1 order every 24 hours, untagging if they have not. The task observes that there is no parent event, so the only activity it performs is to schedule a follow-up event for 1 day later. The follow-up event's data includes the customer's ID, and their current number of orders.
5. 1 day after the customer was tagged, the task runs again. It queries Shopify for the customer's updated order count. It compares this number with the order count provided by the current event (which it had scheduled for itself earlier). Observing that the customer has placed 1 more order since last time, the task leaves the "member" tag in place, and schedules a follow-up event for 1 day later. As before, the follow-up event's data includes the customer's ID, and their current number of orders.
6. Shortly thereafter, Mechanic checks the original customer update event. It discovers that the event's runs are all completed. It notices that the event has a child event (i.e. the event scheduled in step #3), who also has all of its events completed. It notices that the child event also has a child event (i.e. the event scheduled in step #4), and that this event has a pending run. Therefore, Mechanic does not delete the original event.
7. 2 days after the customer was tagged, steps #4 and #5 are repeated.
8. 3 days after the customer was tagged, steps #4 and #5 are repeated.
9. 4 days after the customer was tagged, steps #4 and #5 are repeated.
10. 5 days after the customer was tagged, steps #4 and #5 are repeated.
11. 6 days after the customer was tagged, step #4 is repeated. However, when Mechanic checks the original customer update event, it finds that the 5 following generations of child events all have completed runs. At this time, the original customer update event is deleted (containing the customer's data), along with its related task and action runs (containing the customer ID and then-current order count). Every day thereafter, until such time as the customer fails to place an order during the previous day, Mechanic will delete one additional event, and its related runs.

#### Deletion after Mechanic is uninstalled

1. A store staff member creates a customer order.
2. Shopify sends Mechanic an order creation event, containing the order's data and the customer's data.
3. A merchant-configured Mechanic task is scheduled to run 90 days in the future, at which time it will send a follow-up customer email.
4. The next day, Mechanic is removed from the store's apps list.
5. 15 days later, because Mechanic has been uninstalled, Mechanic deletes the order creation event even though it is not considered complete.

Last updated 2023-10-10T14:57:03Z