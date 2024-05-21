[Original URL: https://learn.mechanic.dev/core/actions/integrations/flow]

# Flow

The Flow action sends data to Shopify Flow, arriving as one of four possible Flow triggers.

This page is about the Mechanic action that sends data to Shopify Flow. For a review of Mechanic's entire integration with Flow, see Shopify Flow.

## Options

### Resource options

The Flow action accepts at most one resource option, identifying a specific Shopify resource, and resulting in a resource-specific Flow trigger. If no resource option is provided, Mechanic will use the General trigger.

These resource options only accept fully-numeric resource IDs (i.e. 12345). They do not accept global IDs (i.e. gid://shopify/Customer/12345).

| Resource option | Flow trigger |
| --- | --- |
| 

customer\_id

 | 

"Mechanic sent customer data"

 |
| 

product\_id

 | 

"Mechanic sent product data"

 |
| 

order\_id

 | 

"Mechanic sent order data"

 |
| 

(when no resource option is given)

 | 

"Mechanic sent general data"

 |

### Data options

This action also sends user-defined data, with one option available for each of Flow's supported datatypes. These options are always sent to Flow, even if they're omitted from the action definition; when omitted, their values are set to the documented default.

| Option | Type | Default |
| --- | --- | --- |
| 

user\_boolean

 | 

Boolean

 | 

false

 |
| 

user\_email

 | 

Email address

 | 

"hey@mechanic.invalid"

 |
| 

user\_number

 | 

Number

 | 

0

 |
| 

user\_string

 | 

String

 | 

""

 |
| 

user\_url

 | 

URL

 | 

"https://mechanic.invalid/"

 |

## Usage

For a detailed review of usage, see Shopify Flow.

Last updated 2021-11-08T20:19:43Z