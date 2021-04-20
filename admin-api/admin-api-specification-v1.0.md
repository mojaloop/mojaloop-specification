---
showToc: true
---
# Introduction

This document provides detailed information about the Central Ledger API. The Central Ledger API is a Mojaloop API enabling Hub Operators to manage admin processes around:

- creating/activating/deactivating participants in the Hub
- adding and updating participant endpoint information
- managing participant accounts, limits, and positions
- creating Hub accounts
- performing Funds In and Funds Out operations
- creating/updating/viewing settlement models
- retrieving transfer details

 For background information about the participant and settlement model details that the Hub Operator can administer using the Central Ledger API, see section [Basic concepts](#basic-concepts).

## Basic concepts

To provide context for the admin operations that the Central Ledger API enables, this section gives a brief definition of some basic concepts.

**Participant**
Either the Hub itself or a Digital Financial Service Provider (DFSP) that is a participant in a Mojaloop scheme.

**Endpoint**
The DFSP callback URL where the Hub routes API callbacks. The URL specified is the endpoint set up in the outbound API gateway.

**Limit**
Currently, only one type of limit is supported, it is called "Net Debit Cap (NDC)". In the future, it is possible to add support for further types of limits. The NDC is a limit or a cap placed on a DFSP's funds available for transacting. It represents the maximum amount of money that the DFSP can owe to other DFSPs. The Position is continuously checked against the Net Debit Cap and when the Position amount exceeds the NDC amount, transfers are blocked.

**Account**
Also called "ledger". The Hub maintains a number of internal accounts to keep track of the movement of money (both e-money and real money) between DFSPs.

**Position**
The Position of a DFSP reflects – at a given point in time – the sum total of the transfer amounts sent and received by the DFSP. For the Payer DFSP, this sum total includes transfer amounts that are pending and have not been finalised (committed) yet (that is, transfers with the `"RESERVED"` state will be taken into account). For the Payee DFSP, the sum total includes only `"COMMITTED"` amounts. The Position is calculated in real time by the Hub. The Position is continuously checked against the Net Debit Cap and when the Position amount exceeds the NDC amount, transfers are blocked.

**Funds In and Funds Out**
Funds In and Funds Out operations are used to track (in the Hub accounts) money movements related to deposits and withdrawals, as well as settlements.

Funds In operations record either the deposit of money into a DFSP's settlement bank account or the settlement amount for a receiving DFSP.

Funds Out operations record either the withdrawal of money from a DFSP's settlement bank account or the settlement amount for a sending DFSP.

**Settlement model**
Refers to how settlement happens within a scheme. Settlement is the process of transferring funds from one DSFP to another, so that the payer's DFSP reimburses the payee's DFSP for funds given to the payee during a transaction. A settlement model specifies if participants settle with each other separately or settle with the scheme, whether transfers are settled one by one or as a batch, whether transfers are settled immediately or with a delay, and so on.

# HTTP details

This section contains detailed information regarding the use of the application-level protocol HTTP in the API.

## HTTP header fields

HTTP headers are generally described in [RFC 7230](https://tools.ietf.org/html/rfc7230). Any headers specific to the Central Ledger API will be standardised in the future.

## HTTP methods

The following HTTP methods, as defined in [RFC 7231](https://tools.ietf.org/html/rfc7231#section-4), are supported by the API:

- `GET` – The HTTP GET method is used from a client to retrieve information about a previously-created object on a server. 
- `POST` – The HTTP POST method is used from a client to request an object to be created on the server. 
- `PUT` – The HTTP PUT method is used from a client to request an object already existing on the server to be modified (to replace a representation of the target resource with the request payload).

> **NOTE:** The `DELETE` method is not supported.

## HTTP response status codes

[Table "HTTP response status codes"](#table-http-response-status-codes) lists the HTTP response status codes that the API supports:

|Status Code|Reason|Description|
|---|---|---|
|**200**|OK|Standard response for a successful `GET`, `PUT`, or `POST` operation. The response will contain an entity corresponding to the requested resource.|
|**201**|Created|The `POST` request has been fulfilled, resulting in the creation of a new resource. The response will not contain an entity describing or containing the result of the action.|
|**202**|Accepted|The request has been accepted for processing, but the processing has not been completed.|
|**400**|Bad Request|The server could not understand the request due to invalid syntax.|
|**401**|Unauthorized|The request requires authentication in order to be processed.|
|**403**|Forbidden|The request was denied and will be denied in the future.|
|**404**|Not Found|The requested resource is not available at the moment.|
|**405**|Method Not Allowed|An unsupported HTTP method for the request was used.|
|**406**|Not Acceptable|The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.|
|**500**|Internal Server Error|A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.|
|**501**|Not Implemented|The server does not support the requested service. The client should not retry.|
|**503**|Service Unavailable|The server is currently unavailable to accept any new service requests. This should be a temporary state, and the client should retry within a reasonable time frame.|

# API services

This section introduces and details all services that the API supports for each resource and HTTP method.

## High-level API services

On a high level, the API can be used to perform the following actions:

- View, create, update participant-related details, such as limit (Net Debit Cap), position, or endpoints configured.
  - Use the services provided by the API resource **`/participants`**.
- View, create, update settlement-model-related details, such as granularity, delay, liquidity check, and so on.
  - Use the services provided by the API resource **`/settlementModels`**.
- View transaction details for a particular transfer.
  - Use the services provided by the API resource **`/transactions`**.

### Supported API services

[Table "Supported API services"](#table-supported-api-services) includes high-level descriptions of the services that the API provides. For more detailed information, see the sections that follow.

| URI  |  HTTP method `GET`| HTTP method `PUT` | HTTP method `POST` | HTTP method `DELETE` |
|---|---|---|---|---|
| **`/participants`**  | Get information about all participants  | Not supported  | Create participants in the Hub  |  Not supported |
| `/participants/limits`  | View limits for all participants  |  Not supported | Not supported  | Not supported  |
| `/participants/{name}`  | Get information about a particular participant  | Update participant details (activate/deactivate a participant)  | Not supported  |  Not supported |
| `/participants/{name}/endpoints`  | View participant endpoints  | Not supported  | Add/Update participant endpoints  | Not supported  |
| `/participants/{name}/limits`  | View participant limits  |  Adjust participant limits | Not supported  |  Not supported |
| `/participants/{name}/positions`  | View participant positions  | Not supported  | Not supported  | Not supported  |
| `/participants/{name}/accounts`  | View participant accounts and balances  |  Not supported | Create Hub accounts  |  Not supported |
| `/participants/{name}/accounts/{id}`  |  Not supported | Update participant accounts  | Record Funds In or Out of participant account  | Not supported  |
| `/participants/{name}/accounts/{id}/transfers/{transferId}`  | Not supported  | Not supported  | Record a Transfer as a Funds In or Out transaction for a participant account  |  Not supported |
| `/participants/{name}/initialPositionAndLimits`  | Not supported  | Not supported  |  Add initial participant limits and position | Not supported  |
| **`/settlementModels`**  | View all settlement models  | Not supported  | Create a settlement model  |  Not supported |
| `/settlementModels/{name}`  | View settlement model by name  | Update a settlement model (activate/deactivate a settlement model) | Not supported  |  Not supported |
| **`/transactions/{id}`**  | Retrieve transaction details by `transferId`  | Not supported  | Not supported  | Not supported |

## API Resource `/participants`

The services provided by the resource `/participants` are primarily used by the Hub Operator for viewing, creating, and updating participant-related details, such as limit (Net Debit Cap), position, or endpoints configured.

### `GET /participants`

The `GET /participants` request is used to retrieve information about all participants.

#### Data model

The `GET /participants` request sends an empty request body.

The following data is returned for each participant in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### `POST /participants`

The `POST /participants` request is used to create a participant in the Hub.

#### Data model

The `POST /participants` request sends the following data in the request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency that the participant will transact in. |

The following data is returned for the newly created participant in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### `GET /participants/limits`

The `GET /participants/limits` request is used to view limits information for all participants.

#### Query parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  no | [CurrencyEnum](#currencyenum) | The currency of the limit. |
| `limit`  |  no | [String](#string) | Limit type. |

#### Data model

The `GET /participants/limits` request sends an empty request body.

The following data is returned for each participant in the case of a successful operation. Each limit in the list is applied to the specified participant name and currency in each object.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |

### `GET /participants/{name}`

The `GET /participants/{name}` request is used to retrieve information about a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `GET /participants/{name}` request sends an empty request body.

The following data is returned in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### `PUT /participants/{name}`

The `PUT /participants/{name}` request is used to update participant details (activate/deactivate a participant).

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `PUT /participants/{name}` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `isActive`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the participant is active. |

The following data is returned in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### `GET /participants/{name}/endpoints`

The `GET /participants/{name}/endpoints` request is used to retrieve information about the endpoints configured for a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `GET /participants/{name}/endpoints` request sends an empty request body.

The following data is returned for each endpoint in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `type`  |  yes | [String](#string) | Type of endpoint. |
| `value`  |  yes | [String](#string) | Endpoint value. |

### `POST /participants/{name}/endpoints`

The `POST /participants/{name}/endpoints` request is used to add/update endpoints for a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

The `POST /participants/{name}/endpoints` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `type`  |  yes | [String](#string) | Type of endpoint. |
| `value`  |  yes | [String](#string) | Endpoint value. |

### `GET /participants/{name}/limits`

The `GET /participants/{name}/limits` request is used to view limits information for a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Query parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  no | [CurrencyEnum](#currencyenum) | The currency of the limit. |
| `limit`  |  no | [String](#string) | Limit type. |

#### Data model

The `GET /participants/{name}/limits` request sends an empty request body.

The following data is returned in the case of a successful operation. Each limit in the list is applied to the specified participant name and currency in each object.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |

### `PUT /participants/{name}/limits`

The `PUT /participants/{name}/limits` request is used to adjust limits for a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `PUT /participants/{name}/limits` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |

The following data is returned in the case of a successful operation.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |

### `GET /participants/{name}/positions`

The `GET /participants/{name}/positions` request is used to view the position of a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Query parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  no | [CurrencyEnum](#currencyenum) | The currency of the limit. |

#### Data model

The `GET /participants/{name}/positions` request sends an empty request body.

The following data is returned in the case of a successful operation. 

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `value`  |  yes | [Number](#number) | Position value.  |
| `changedDate`  |  yes | [DateTime](#datetime)  | Date and time when the position last changed. |

### `GET /participants/{name}/accounts`

The `GET /participants/{name}/accounts` request is used to view the accounts and balances of a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `GET /participants/{name}/accounts` request sends an empty request body.

The following data is returned in the case of a successful operation. 

| Name  | Required  | Type | Description |
|---|---|--|--|
| `id`  |  yes | [Integer](#integer) | Identifier of the ledger account. |
| `ledgerAccountType`  |  yes | [String](#string) | Type of ledger account. |
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency of the ledger account. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the ledger account is active. Possible values are `1` and `0`. |
| `value`  |  yes | [Number](#number) | Account balance value. |
| `reservedValue`  |  yes | [Number](#number) | Value reserved in the account. |
| `changedDate`  |  yes | [DateTime](#datetime)  | Date and time when the ledger account last changed. |

### `POST /participants/{name}/accounts`

The `POST /participants/{name}/accounts` request is used to create accounts in the Hub.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `POST /participants/{name}/accounts` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency of the participant ledger account. |
| `type`  |  yes | [String](#string) | Type of ledger account. |

The following data is returned in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### `POST /participants/{name}/accounts/{id}`

The `POST /participants/{name}/accounts/{id}` request is used to Record Funds In or Out of a participant account.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [Integer](#integer) | Account identifier. |

#### Data model

The `POST /participants/{name}/accounts/{id}` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `transferId`  | yes  | [UUID](#uuid) | Transfer identifier. |
| `externalReference`  |  yes | [String](#string) | Reference to any external data, such as an identifier from the settlement bank. |
| `action`  |  yes | [Enum](#enum) | The action performed on the funds. Possible values are: `recordFundsIn` and `recordFundsOutPrepareReserve`. |
| `reason`  |  yes | [String](#string) | The reason for the FundsIn or FundsOut action. |
| `amount`  | yes  | [Money](#money) | The FundsIn or FundsOut amount. |
| `extensionList`  | no  | [ExtensionList](#extensionlist) | Additional details. |

### `PUT /participants/{name}/accounts/{id}`

The `PUT /participants/{name}/accounts/{id}` request is used to update a participant account. Currently, updating only the `isActive` flag is supported.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [Integer](#integer) | Account identifier. |

#### Data model

The `PUT /participants/{name}/accounts/{id}` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `isActive`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the participant account is active. |

### `PUT /participants/{name}/accounts/{id}/transfers/{transferId}`

The `PUT /participants/{name}/accounts/{id}/transfers/{transferId}` request is used to record a transfer as a Funds In or Out transaction for a participant account. 

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |
| `id`  |  yes | [Integer](#integer) | Account identifier. |
| `transferId`  |  yes | [UUID](#uuid) | Transfer identifier. |

#### Data model

The `PUT /participants/{name}/accounts/{id}/transfers/{transferId}` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `action`  |  yes | [Enum](#enum) | The FundsOut action performed. Possible values are: `recordFundsOutCommit` and `recordFundsOutAbort`. |
| `reason`  |  yes | [String](#string) | The reason for the FundsOut action. |

### `POST /participants/{name}/initialPositionAndLimits`

The `POST /participants/{name}/initialPositionAndLimits` request is used to add initial limits and a position for a particular participant.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String(2..30)](#string) | The name of the participant. |

#### Data model

The `POST /participants/{name}/initialPositionAndLimits` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency of the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |
| `initialPosition`  |  no | [Number](#number) | Initial Position. |

## API Resource `/settlementModels`

The services provided by the resource `/settlementModels` are used by the Hub Operator for creating, updating, and viewing settlement models.

### `GET /settlementModels`

The `GET /settlementModels` request is used to retrieve information about all settlement models.

#### Data model

The `GET /settlementModels` request sends an empty request body.

The following data is returned for each settlement model in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementModelId`  |  yes | [Integer](#integer) | Settlement model identifier. |
| `name`  |  yes | [String](#string) | Settlement model name. |
| `isActive`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model is active.|
| `settlementGranularity`  |  yes | [String](#string) | Specifies whether transfers are settled one by one or as a batch. Possible values are: <br> `GROSS`: Settlement is executed after each transfer is completed, that is, there is a settlement transaction that corresponds to every transaction. <br> `NET`: A group of transfers is settled together in a single settlement transaction, with each participant settling the net of all transfers over a given period of time.|
| `settlementInterchange`  |  yes | [String](#string) | Specifies the type of settlement arrangement between parties. Possible values are: <br> `BILATERAL`: Each participant settles its obligations with each other separately, and the scheme is not a party to the settlement. <br> `MULTILATERAL`: Each participant settles with the scheme for the net of its obligations, rather than settling separately with each other party.|
| `settlementDelay`  |  yes | [String](#string) | Specifies if settlement happens immediately after a transfer has completed or with a delay. Possible values are: <br> `IMMEDIATE`: Settlement happens immediately after a transfer has completed. <br> `DEFERRED`: Settlement is managed by the Hub operator on-demand or via a schedule.|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the settlement model. |
| `requireLiquidityCheck`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires liquidity check. |
| `ledgerAccountTypeId`  |  yes | [String](#string) | Type of ledger account. Possible values are: <br> `INTERCHANGE_FEE`: Tracks the interchange fees charged for transfers. <br> `POSITION`: Tracks how much a DFSP owes or is owed. <br> `SETTLEMENT`: The DFSP's Settlement Bank Account mirrored in the Hub. Acts as a reconciliation account and mirrors the movement of real funds.|
| `autoPositionReset`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires the automatic reset of the position. |

### `POST /settlementModels`

The `POST /settlementModels` request is used to create a settlement model.

#### Data model

The `POST /settlementModels` request sends the following data in the request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String](#string) | Settlement model name. |
| `settlementGranularity`  |  yes | [String](#string) | Specifies whether transfers are settled one by one or as a batch. Possible values are: <br> `GROSS`: Settlement is executed after each transfer is completed, that is, there is a settlement transaction that corresponds to every transaction. <br> `NET`: A group of transfers is settled together in a single settlement transaction, with each participant settling the net of all transfers over a given period of time.|
| `settlementInterchange`  |  yes | [String](#string) | Specifies the type of settlement arrangement between parties. Possible values are: <br> `BILATERAL`: Each participant settles its obligations with each other separately, and the scheme is not a party to the settlement. <br> `MULTILATERAL`: Each participant settles with the scheme for the net of its obligations, rather than settling separately with each other party.|
| `settlementDelay`  |  yes | [String](#string) | Specifies if settlement happens immediately after a transfer has completed or with a delay. Possible values are: <br> `IMMEDIATE`: Settlement happens immediately after a transfer has completed. <br> `DEFERRED`: Settlement is managed by the Hub operator on-demand or via a schedule.|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the settlement model. |
| `requireLiquidityCheck`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires liquidity check. |
| `ledgerAccountTypeId`  |  yes | [String](#string) | Type of ledger account. Possible values are: <br> `INTERCHANGE_FEE`: Tracks the interchange fees charged for transfers. <br> `POSITION`: Tracks how much a DFSP owes or is owed. <br> `SETTLEMENT`: The DFSP's Settlement Bank Account mirrored in the Hub. Acts as a reconciliation account and mirrors the movement of real funds.|
| `settlementAccountType`  |  yes | [String](#string) | A special type of ledger account into which settlements should be settled. Possible values are: <br> `SETTLEMENT`: A settlement account for the principal value of transfers (that is, the amount of money that the Payer wants the Payee to receive). <br> `INTERCHANGE_FEE_SETTLEMENT`: A settlement account for the fees associated with transfers. |
| `autoPositionReset`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires the automatic reset of the position. |

### `GET /settlementModels/{name}`

The `GET /settlementModels/{name}` request is used to retrieve information about a particular settlement model.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String](#string) | The name of the settlement model. |

#### Data model

The `GET /settlementModels/{name}` request sends an empty request body.

The following data is returned in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementModelId`  |  yes | [Integer](#integer) | Settlement model identifier. |
| `name`  |  yes | [String](#string) | Settlement model name. |
| `isActive`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model is active. |
| `settlementGranularity`  |  yes | [String](#string) | Specifies whether transfers are settled one by one or as a batch. Possible values are: <br> `GROSS`: Settlement is executed after each transfer is completed, that is, there is a settlement transaction that corresponds to every transaction. <br> `NET`: A group of transfers is settled together in a single settlement transaction, with each participant settling the net of all transfers over a given period of time.|
| `settlementInterchange`  |  yes | [String](#string) | Specifies the type of settlement arrangement between parties. Possible values are: <br> `BILATERAL`: Each participant settles its obligations with each other separately, and the scheme is not a party to the settlement. <br> `MULTILATERAL`: Each participant settles with the scheme for the net of its obligations, rather than settling separately with each other party.|
| `settlementDelay`  |  yes | [String](#string) | Specifies if settlement happens immediately after a transfer has completed or with a delay. Possible values are: <br> `IMMEDIATE`: Settlement happens immediately after a transfer has completed. <br> `DEFERRED`: Settlement is managed by the Hub operator on-demand or via a schedule.|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the settlement model. |
| `requireLiquidityCheck`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires liquidity check. |
| `ledgerAccountTypeId`  |  yes | [String](#string) | Type of ledger account. Possible values are: <br> `INTERCHANGE_FEE`: Tracks the interchange fees charged for transfers. <br> `POSITION`: Tracks how much a DFSP owes or is owed. <br> `SETTLEMENT`: The DFSP's Settlement Bank Account mirrored in the Hub. Acts as a reconciliation account and mirrors the movement of real funds. |
| `autoPositionReset`  |  yes | [Boolean](boolean) | A flag to indicate whether or not the settlement model requires the automatic reset of the position. |

### `PUT /settlementModels/{name}`

The `PUT /settlementModels/{name}` request is used to update a settlement model (activate/deactivate a settlement model).

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String](#string) | The name of the settlement model. |

#### Data model

The `PUT /settlementModels/{name}` request sends the following request body:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `isActive`  |  yes | [Boolean](#boolean) | A flag to indicate whether or not the settlement model is active. |

## API Resource `/transactions`

The services provided by the resource `/transactions` are used by the Hub Operator for retrieving transfer details.

### `GET /transactions/{id}`

The `GET /transactions/{id}` request is used to retrieve information about a particular transaction.

#### Path parameters

| Name  | Required  | Type | Description |
|---|---|--|--|
| `id`  |  yes | [UUID](#uuid) | Transfer identifier. |

#### Data model

The `GET /transactions/{id}` request sends an empty request body.

The following data is returned in the case of a successful operation:

| Name  | Required  | Type | Description |
|---|---|--|--|
| `quoteId`  |   | [UUID](#uuid) | Quote identifier. |
| `transactionId`  |   | [UUID](#uuid) | Transaction identifier. |
| `transactionRequestId`  |   | [String](#string) | Identifies an optional previously-sent transaction request. |
| `payee`  |   | [Party](#party) | Payee details. |
| `payer`  |   | [Party](#party) | Payer details. |
| `amount`  |   | [Money](#money) | Transaction amount. |
| `transactionType`  |   | [TransactionType](#transactiontype) | Transaction details. |
| `note`  |   | [String](#string) | A memo that will be attached to the transaction. |
| `extensionList`  |   | [ExtensionList](#extensionlist) | Additional details. |

# Data models used by the API

## Format

For details on the formats used for element data types used by the API, see section [7.1 Format Introduction](../fspiop-api/documents/API-Definition_v1.1.md#71-format-introduction) in the Mojaloop FSPIOP API Definition.

## Element data type formats

This section defines element data types used by the API.

### Amount

For details, see section [7.2.13 Amount](../fspiop-api/documents/API-Definition_v1.1.md#7213-amount) in the Mojaloop FSPIOP API Definition.

### Boolean

A `"true"` or `"false"` value.

### DateTime

For details, see section [7.2.14 DateTime](../fspiop-api/documents/API-Definition_v1.1.md#7214-datetime) in the Mojaloop FSPIOP API Definition.

### Enum

For details, see section [7.2.2 Enum](../fspiop-api/documents/API-Definition_v1.1.md#722-enum) in the Mojaloop FSPIOP API Definition.

### Integer

For details, see section [7.2.5 Integer](../fspiop-api/documents/API-Definition_v1.1.md#725-integer) in the Mojaloop FSPIOP API Definition.

### Number

The API data type **Number** is a an arbitrary-precision, base-10 decimal number value.

### String

For details, see section [7.2.1 String](../fspiop-api/documents/API-Definition_v1.1.md#721-string) in the Mojaloop FSPIOP API Definition.

### UUID

For details, see section [7.2.16 UUID](../fspiop-api/documents/API-Definition_v1.1.md#7216-uuid) in the Mojaloop FSPIOP API Definition.

## Element definitions

This section defines element types used by the API.

### AutoPositionReset

Data model for the element **AutoPositionReset**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `autoPositionReset`  | yes | [Boolean](#boolean) | A flag to indicate whether or not a settlement model requires the automatic reset of the position. |

### IsActive

Data model for the element **IsActive**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `isActive`  | yes | [Integer(1)](#integer) | A flag to indicate whether or not a ledger account / participant is active. Possible values are `1` (active) and `0` (not active). |

### IsActiveBoolean

Data model for the element **IsActiveBoolean**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `isActive`  | yes | [Boolean](#boolean) | A flag to indicate whether or not an account / participant / settlement model is active. |

### CurrencyEnum

For details, see section [7.3.9 Currency](../fspiop-api/documents/API-Definition_v1.1.md#739-currency) in the Mojaloop FSPIOP API Definition.

### PartyIdentifier

For details, see section [7.3.24 PartyIdentifier](../fspiop-api/documents/API-Definition_v1.1.md#7324-partyidentifier) in the Mojaloop FSPIOP API Definition.

### PartyIdTypeEnum

For details, see section [7.3.25 PartyIdType](../fspiop-api/documents/API-Definition_v1.1.md#7325-partyidtype) in the Mojaloop FSPIOP API Definition.

### RequireLiquidityCheck

Data model for the element **RequireLiquidityCheck**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `requireLiquidityCheck`  | yes | [Boolean](#boolean) | A flag to indicate whether or not a settlement model requires liquidity check. |

### Self

Data model for the element **Self**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `self`  | yes | [String](#string) | Fully qualified domain name combined with the `fspId` of the participant. |

### SettlementDelay

Data model for the element **SettlementDelay**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementDelay`  | yes | [Enum](#enum) of String | Specifies if settlement happens immediately after a transfer has completed or with a delay. Allowed values for the enumeration are: <br> `IMMEDIATE`: Settlement happens immediately after a transfer has completed. <br> `DEFERRED`: Settlement is managed by the Hub operator on-demand or via a schedule. |

### SettlementGranularity

Data model for the element **SettlementGranularity**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementGranularity`  | yes | [Enum](#enum) of String | Specifies whether transfers are settled one by one or as a batch. Allowed values for the enumeration are: <br> `GROSS`: Settlement is executed after each transfer is completed, that is, there is a settlement transaction that corresponds to every transaction. <br> `NET`: A group of transfers is settled together in a single settlement transaction, with each participant settling the net of all transfers over a given period of time. |

### SettlementInterchange

Data model for the element **SettlementInterchange**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementInterchange`  | yes | [Enum](#enum) of String | Specifies the type of settlement arrangement between parties. Allowed values for the enumeration are: <br> `BILATERAL`: Each participant settles its obligations with each other separately, and the scheme is not a party to the settlement. <br> `MULTILATERAL`: Each participant settles with the scheme for the net of its obligations, rather than settling separately with each other party. |

## Complex types

### Accounts

The list of ledger accounts configured for the participant. For details on the account object, see [IndividualAccount](#individualaccount).

### ErrorInformation

For details, see section [7.4.2 ErrorInformation](../fspiop-api/documents/API-Definition_v1.1.md#742-errorinformation) in the Mojaloop FSPIOP API Definition.

### ErrorInformationResponse

Data model for the complex type object that contains an optional element [ErrorInformation](#errorinformation) used along with 4xx and 5xx responses.

### Extension

For details, see section [7.4.3 Extension](../fspiop-api/documents/API-Definition_v1.1.md#743-extension) in the Mojaloop FSPIOP API Definition.

### ExtensionList

For details, see section [7.4.4 ExtensionList](../fspiop-api/documents/API-Definition_v1.1.md#744-extensionlist) in the Mojaloop FSPIOP API Definition.

### IndividualAccount

Data model for the complex type **IndividualAccount**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `id`  |  yes | [Integer](#integer) | Identifier of the ledger account. |
| `ledgerAccountType`  |  yes | [String](#string) | Type of the ledger account (for example, POSITION). |
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency of the account. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the ledger account is active. Possible values are `1` and `0`. |
| `createdDate`  |  yes | [DateTime](#datetime)  | Date and time when the ledger account was created. |
| `createdBy`  |  yes | [String](#string) | The entity that created the ledger account. |

### Limit

Data model for the complex type **Limit**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `type`  |  yes | [String](#string) | Limit type. |
| `value`  |  yes | a positive [Number](#number) | Limit value. |

### Money

For details, see section [7.4.10 Money](../fspiop-api/documents/API-Definition_v1.1.md#7410-money) in the Mojaloop FSPIOP API Definition.

### Participant

Data model for the complex type **Participant**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `name`  |  yes | [String](#string) | The name of the participant. |
| `id`  |  yes | [String](#string) | The identifier of the participant in the form of a fully qualified domain name combined with the participant's `fspId`. |
| `created`  |  yes | [DateTime](#datetime)  | Date and time when the participant was created. |
| `isActive`  |  yes | [Integer(1)](#integer) | A flag to indicate whether or not the participant is active. Possible values are `1` and `0`. |
| `links`  |  yes | [Self](#self) | List of links for a Hypermedia-Driven RESTful Web Service. | 	
| `accounts`  |  yes | [Accounts](#accounts) | The list of ledger accounts configured for the participant. |

### ParticipantFunds

Data model for the complex type **ParticipantFunds**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `transferId`  | yes  | [UUID](#uuid) | Transfer identifier. |
| `externalReference`  |  yes | [String](#string) | Reference to any external data, such as an identifier from the settlement bank.  |
| `action`  |  yes | [Enum](#enum) | The action performed on the funds. Possible values are: `recordFundsIn` and `recordFundsOutPrepareReserve`. |
| `reason`  |  yes | [String](#string) | The reason for the FundsIn or FundsOut action. |
| `amount`  | yes  | [Money](#money) | The FundsIn or FundsOut amount. |
| `extensionList`  | no  | [ExtensionList](#extensionlist) | Additional details. |

### ParticipantLimit

Data model for the complex type **ParticipantLimit**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `type`  |  yes | [String](#string) | The type of participant limit (for example, `NET_DEBIT_CAP`.)  |
| `value`  |  yes | [Number](#number) | The value of the limit that has been set for the participant.  |
| `alarmPercentage`  |  yes | [Number](#number) | An alarm notification is triggered when a pre-specified percentage of the limit is reached. Specifying an `alarmPercentage` is optional. If not specified, it will default to 10 percent. |

### ParticipantsNameEndpointsObject

Data model for the complex type **ParticipantsNameEndpointsObject**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `type`  |  yes | [String](#string) | The endpoint type.  |
| `value`  |  yes | [String](#string) | The endpoint value.  |

### ParticipantsNameLimitsObject

Data model for the complex type **ParticipantsNameLimitsObject**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the participant. |
| `limit`  |  yes | [ParticipantLimit](#participantlimit) | The limit configured for the participant.  |

### Party

For details, see section [7.4.11 Party](../fspiop-api/documents/API-Definition_v1.1.md#7411-party) in the Mojaloop FSPIOP API Definition.

### PartyComplexName

For details, see section [7.4.12 PartyComplexName](../fspiop-api/documents/API-Definition_v1.1.md#7412-partycomplexname) in the Mojaloop FSPIOP API Definition.

### PartyIdInfo

For details, see section [7.4.13 PartyIdInfo](../fspiop-api/documents/API-Definition_v1.1.md#7413-partyidinfo) in the Mojaloop FSPIOP API Definition.

### PartyPersonalInfo

For details, see section [7.4.14 PartyPersonalInfo](../fspiop-api/documents/API-Definition_v1.1.md#7414-partypersonalinfo) in the Mojaloop FSPIOP API Definition.

### RecordFundsOut

Data model for the complex type **RecordFundsOut**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `action`  |  yes | [Enum](#enum) | The FundsOut action performed. Possible values are: `recordFundsOutCommit` and `recordFundsOutAbort`. |
| `reason`  |  yes | [String](#string) | The reason for the FundsOut action. |

### Refund

Data model for the complex type **Refund**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `originalTransactionId`  | yes | [UUID](#uuid) | Reference to the original transaction id that is requested to be refunded. |
| `refundReason`  |  no | [String(1-128)](#string) | Free text indicating the reason for the refund. |

### SettlementModelsObject

Data model for the complex type **SettlementModelsObject**.

| Name  | Required  | Type | Description |
|---|---|--|--|
| `settlementModelId`  |  yes | [Integer](#integer) | Settlement model identifier. |
| `name`  |  yes | [String](#string) | Settlement model name. |
| `isActive`  |  yes | [Boolean](#boolean) | A flag to indicate whether or not the settlement model is active. |
| `settlementGranularity`  |  yes | [String](#string) | Specifies whether transfers are settled one by one or as a batch. Possible values are: <br> `GROSS`: Settlement is executed after each transfer is completed, that is, there is a settlement transaction that corresponds to every transaction. <br> `NET`: A group of transfers is settled together in a single settlement transaction, with each participant settling the net of all transfers over a given period of time.|
| `settlementInterchange`  |  yes | [String](#string) | Specifies the type of settlement arrangement between parties. Possible values are: <br> `BILATERAL`: Each participant settles its obligations with each other separately, and the scheme is not a party to the settlement. <br> `MULTILATERAL`: Each participant settles with the scheme for the net of its obligations, rather than settling separately with each other party.|
| `settlementDelay`  |  yes | [String](#string) | Specifies if settlement happens immediately after a transfer has completed or with a delay. Possible values are: <br> `IMMEDIATE`: Settlement happens immediately after a transfer has completed. <br> `DEFERRED`: Settlement is managed by the Hub operator on-demand or via a schedule.|
| `currency`  |  yes | [CurrencyEnum](#currencyenum) | The currency configured for the settlement model. |
| `requireLiquidityCheck`  |  yes | [Boolean](#boolean) | A flag to indicate whether or not the settlement model requires liquidity check. |
| `ledgerAccountTypeId`  |  yes | [String](#string) | Type of ledger account. Possible values are: <br> `INTERCHANGE_FEE`: Tracks the interchange fees charged for transfers. <br> `POSITION`: Tracks how much a DFSP owes or is owed. <br> `SETTLEMENT`: The DFSP's Settlement Bank Account mirrored in the Hub. Acts as a reconciliation account and mirrors the movement of real funds.|
| `autoPositionReset`  |  yes | [Boolean](#boolean) | A flag to indicate whether or not the settlement model requires the automatic reset of the position. |

### TransactionType

For details, see section [7.4.18 TransactionType](../fspiop-api/documents/API-Definition_v1.1.md#7418-transactiontype) in the Mojaloop FSPIOP API Definition.