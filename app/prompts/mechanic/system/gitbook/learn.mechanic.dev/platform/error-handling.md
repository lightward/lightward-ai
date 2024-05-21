[Original URL: https://learn.mechanic.dev/platform/error-handling]

# Error handling

Get actionable visibility into event, task, and action errors

Mechanic creates error events when an error occurs during an event run, a task run, or an action run. Each run type has its own error event topic. You can subscribe to these error topics to take action based on these errors (e.g. to send an email letting you know an error has occurred).

There are three error topics that Mechanic can throw: mechanic/errors/action, mechanic/errors/event, mechanic/errors/task.

## Subscriptions

Any task may subscribe to error events.

If a task subscribes only to error events, it's qualified to receive all such error events, across all runs in the same Mechanic account.

If a task subscribes to other non-error topics, too, the task will only receive its own mechanic/errors/task and mechanic/errors/action events. It won't be able to receive mechanic/errors/event events.

## Topics

### mechanic/errors/action

This occurs when an action run encounters an error. (Examples: a server connection failure during an FTP action, or a missing or invalid receipient email address during an Email action.)

### mechanic/errors/event

This occurs when an event filter fails.

### mechanic/errors/task

This occurs when a task run fails. (Examples: a task run exceeds Mechanic's memory limits, a Liquid parsing or rendering failure, or encountering an error object.)

## Event data

Copy

    {
      "message": "Received a Shopify error (resource invalid): Add at least 1 product",
      "event": {
        "id": "ebaa2ab5-fc48-4a5e-8591-11111",
        "topic": "mechanic/user/trigger",
        "source": "user",
        "created_at": "2023-06-13T17:03:27.244Z",
        "webhook_request_id": null,
        "flow_action_run_id": null,
        "run": {
          "id": "2a0af1ac-3931-4478-abc7-11111",
          "result": null,
          "result_meta": {
            "shopify_admin_api_time_ms": 0,
            "shopify_admin_graphql_api_cost": 0,
            "shopify_admin_rest_api_requests_count": 0,
            "shopify_admin_graphql_api_requests_count": 0
          },
          "error": null,
          "ok": true,
          "started_at": "2023-06-13T17:03:39.118Z",
          "stopped_at": "2023-06-13T17:03:39.126Z",
          "elapsed_time_ms": 7,
          "run_at": "2023-06-13T17:03:27.249Z",
          "enqueued_at": "2023-06-13T17:03:27.410Z",
          "attempts": 1
        }
      },
      "task": {
        "id": "1250304e-313c-49a2-acc2-111111",
        "name": "Test Draft order",
        "event_topics": [
          "mechanic/user/trigger",
          "mechanic/actions/perform"
        ],
        "options": {},
        "script": "{% if event.topic == \"mechanic/user/trigger\" or event.preview %} \n {% action \"shopify\" %}\n [\n \"create\",\n \"draft_order\",\n {\n \"customer\": {\n \"id\": 1111\n },\n \"line_items\": []\n }\n ]\n{% endaction %}\n\n{% else %}\n\n{% action \"echo\" action.result %}\n \n{% endif %}\n",
        "created_at": "2023-06-13T16:50:28.950Z",
        "updated_at": "2023-06-13T17:03:22.946Z",
        "subscriptions": [
          "mechanic/user/trigger",
          "mechanic/actions/perform"
        ],
        "enabled": true,
        "online_store_javascript": null,
        "order_status_javascript": null,
        "docs": null,
        "shopify_access_scopes_required": [
          "write_draft_orders"
        ],
        "subscriptions_template": "mechanic/user/trigger\nmechanic/actions/perform",
        "shopify_api_version": "2023-04",
        "liquid_profiling": false,
        "perform_action_runs_in_sequence": false,
        "halt_action_run_sequence_on_error": false,
        "run": {
          "id": "292a750b-2687-498f-8616-1223",
          "error": null,
          "ok": true,
          "started_at": "2023-06-13T17:03:49.284Z",
          "stopped_at": "2023-06-13T17:03:49.291Z",
          "elapsed_time_ms": 6,
          "run_at": "2023-06-13T17:03:39.125Z",
          "enqueued_at": "2023-06-13T17:03:39.286Z",
          "result_meta": {
            "shopify_admin_api_time_ms": 0,
            "shopify_admin_graphql_api_cost": 0,
            "shopify_admin_rest_api_requests_count": 0,
            "shopify_admin_graphql_api_requests_count": 0
          },
          "attempts": 1
        }
      },
      "action": {
        "type": "shopify",
        "options": [
          "create",
          "draft_order",
          {
            "customer": {
              "id": 12344
            },
            "line_items": []
          }
        ],
        "meta": null,
        "run": {
          "id": "d60820a4-d9d0-43a8-a56e-11111",
          "result": null,
          "error": "Received a Shopify error (resource invalid): Add at least 1 product",
          "ok": false,
          "started_at": "2023-06-13T17:03:56.770Z",
          "stopped_at": "2023-06-13T17:03:57.075Z",
          "elapsed_time_ms": 304,
          "run_at": "2023-06-13T17:03:49.289Z",
          "enqueued_at": "2023-06-13T17:03:49.513Z",
          "result_meta": {
            "shopify_admin_graphql_api_cost": 0,
            "shopify_admin_graphql_api_requests_count": 0,
            "shopify_admin_rest_api_requests_count": 1,
            "shopify_admin_api_time_ms": 295.04
          },
          "attempts": 1
        }
      }
    }

## Example task

You can install our error reporter task here.

Last updated 2023-11-18T20:16:03Z