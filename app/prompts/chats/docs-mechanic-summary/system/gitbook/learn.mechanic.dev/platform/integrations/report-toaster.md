# Report Toaster

Mechanic allows developers to integrate directly with Report Toaster to retrieve and update data. Use Report Toaster's powerful reporting engine to retrieve and operate on your Shopify data.

Report Toaster is offered by Cloudlab. Get assistance with this integration at support.cloudlab.com, or by emailing support@cloudlab.com.

## What is Report Toaster?

Report Toaster is a Shopify app that allows merchants to access their data in ways not possible via the Shopify Admin.

From Report Toaster's app store listing:

> Introducing Report Toaster, created by Cloudlab. The most powerful reporting and analytics app available for Shopify merchants. Access any data in your store to create, schedule and export custom reports across all of your sales channels. You can also select from our list of over 80 pre-built reports.

### Terminology

Some terms to know when using Report Toaster.

#### Pre-Built Reports

Any report that comes included when the Report Toaster app is installed. Report Toaster includes over 80 pre-built reports.

#### My Reports

The set of reports customized and saved by a Report Toaster user. Each account will have its own unique set of "My Reports".

#### Report ID

Used to uniquely identify any Report Toaster report. Found in the URL when navigating to a specific report, as in the example below with the Report ID being v\_qygPGcofjQ.

> https://reporttoaster.cloudlab.com/my-reports/v\_qygPGcofjQ

## Action

The Report Toaster integration includes a report\_toaster action which can be used to perform one or more operations on data within Report Toaster.

This action accepts two options, one specifying a Report Toaster operation, and the other varying based on the specified operation.

| Option | Description |
| --- | --- |
| 

operation

 | 

Required; The name of the operation to run as part of the Report Toaster action. Available types are "report" and "update".

 |
| 

[varies, see Report or Update usage]

 | 

Required; see specific usage documentation

 |

### Report

The Report operation is used to run a report using the Report Toaster engine. The report can be from Pre-Built reports or My Reports.

This operation is most useful in concert with the report\_toaster/reports/create webhook, by which a task may take the resulting report and pass to another service, or parse to complete additional tasks.

Report results can be returned inline, in which case there will be a 10MB limit. Alternatively, a file URL can be returned in a variety of formats.

| Operation option | Description |
| --- | --- |
| 

reports

 | 

Required; an array of objects defining the reports that will be executed. See below for the report options.

 |

#### Report object definition

| Report option | Description |
| --- | --- |
| 

id

 | 

Required; a string specifying the unique identifier for a pre-defined report to be executed

 |
| 

file

 | 

Optional; an object describing a file to be returned when inline JSON results are not desired. Available file formats are "json", "csv", and "pdf"

 |
| 

meta

 | 

Optional; an object providing context for the report execution. This value will be returned with the report\_toaster/reports/create webhook

 |

#### Basic Example: Single operation returning JSON Data (limit 10 MB)

Copy

    {% action "report_toaster" %}
      { 
        {% comment %}
          Generate one or more reports. When each report is complete, a
          'report_toaster/reports/create' event will be created with the result.
        {% endcomment %}
        "operation": "report",
      
        {% comment %}
          This batch array identifies one or more reports to be run.
        {% endcomment %}
        "batch": [
          {
            {% comment %}
              The id of one of your 'My Reports'. This id is on the query string
              when you run the report in Report Toaster.
            {% endcomment %}
            "id": "vVYKue9k7P",
      
            {% comment %}
              Optional custom context that will be returned with the report
              data in the 'report_toaster/reports/create' event.
            {% endcomment %}
            "meta": {
              "internal_request_id": "something something",
              "task_id": {{ task.id | json }}
            }
          }
        ]
      }
    {% endaction %}

#### Basic Example: Batch operation - return one CSV file and two JSON

Copy

    {% action "report_toaster" %}
      {
        {% comment %}
          Generate one or more reports. When each report is complete, a
          'report_toaster/reports/create' event will be created with the result.
        {% endcomment %}
        "operation": "report",
    
        {% comment %}
          This batch array identifies one or more reports to be run.
        {% endcomment %}
        "batch": [
          {
            {% comment %}
              The id of one of your 'My Reports'. This id is on the query string
              when you run the report in Report Toaster.
            {% endcomment %}
            "id": "v_t3a23v4e23",
    
            {% comment %}
              Optionally set this to create a download link to the report data
              instead of returning the report data in the event. Options are
              'json', 'csv' and 'pdf'. If csv then include_headers can be used
              to turn headers on/off - they are included if ommitted
            {% endcomment %}
            "file": {
              "format": "csv"
             ,"include_headers": false
            },
    
            {% comment %}
              Optional custom context that will be returned with the report
              data in the 'report_toaster/reports/create' event.
            {% endcomment %}
            "meta": {
              "internal_request_id": "something something",
              "task_id": {{ task.id | json }}
            }
          },
          { "id": "v_123" },
          { "id": "v_456" }
        ]
      }
    {% endaction %}

### Update

The Update operation is used to update some data in the Report Toaster dataset. Results will be returned as part of the standard mechanic/actions/perform webhook.

The update operation will be limited to attributes that are intended for update via external sources.

| Operation option | Description |
| --- | --- |
| 

[the name of the model to be updated; currently, only "Order" is supported]

 | 

Required; an array of update objects which use the Merge/Patch format. Current limitations are as follows: 1. The "id" attribute must be used to identify an Order. 2. Currently only "shipping\_cost" and "transaction\_fees" can be updated.

 |

#### Basic Example: Update shipping costs

Copy

    {% action "report_toaster" %}
      {
        {% comment %}
          Update operation to update values in Report Toaster
        {% endcomment %}
        "operation": "update",
    
        {% comment %}
          Update any number of orders with their corresponding shipping costs 
          and/or transaction fees
        {% endcomment %}
        "Order": [
          { "id": 4192644956357, "shipping_cost": 6.54 },
          { "id": 4192637419717, "transaction_fees": 5.32 },
          { "id": 4192651182277, "shipping_cost": 4.76, "transaction_fees": null }
        ]
      }
    {% endaction %}

## Event topics

The Report Toaster action sends webhook events to Mechanic, reporting back on the results of an action.

### report\_toaster/reports/create

Occurs when a Report Toaster report has been created and is available for download.

#### Basic Example: Return JSON data

Copy

    {
      "id": "vVYKue9k7P",
      "name": "30-Day Summary", 
      "data": {....},
      "meta": {
        "internal_request_id": "something something",
        "task_id": "fc3872b8-66a0-4ffb-bcaf-6f1b4a966aba"
      },
      "definition": {....}
    }

#### Basic Example: Return file

Copy

    {
      "id": "vVYKue9k7P",
      "name": "30-Day Summary", 
      "file": {
        "format": "pdf",
        "url": "https://example.com/report.pdf"
        "size": 1234567
      },
      "meta": {
        "internal_request_id": "something something",
        "task_id": "fc3872b8-66a0-4ffb-bcaf-6f1b4a966aba"
      },
      "definition": {....}
    }

### report\_toaster/reports/fail

Occurs when a requested Report Toaster report has failed.

#### Basic Example

Copy

    {
      "id": "vVYKue9k7P",
      "name": "30-Day Summary",
      "error": {....},
      "meta": {
        "internal_request_id": "something something",
        "task_id": "fc3872b8-66a0-4ffb-bcaf-6f1b4a966aba"
      },
      "definition": {....}
    }

[PreviousLocksmith](/platform/integrations/locksmith)[NextShopify Flow](/platform/integrations/shopify-flow)

Last updated 2023-07-28T17:54:04Z