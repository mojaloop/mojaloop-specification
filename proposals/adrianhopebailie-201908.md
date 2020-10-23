---
Change Request ID: 18
Change Request Name: Template for Change Request
Prepared By: Adrian Hope-Bailie (Coil)
Solution Proposal Status: In review
Approved/Rejected Date: N/A
---

# Proposal - Update API for ILPv4 and Cross-Currency

- [Proposal - Update API for ILPv4 and Cross-Currency](#proposal---update-api-for-ilpv4-and-cross-currency)
  - [Document History](#document-history)
  - [Change Request Background](#change-request-background)
    - [Upgrading to Interledger Protocol version 4](#upgrading-to-interledger-protocol-version-4)
    - [Generation of the Condition and Fulfillment](#generation-of-the-condition-and-fulfillment)
    - [Binding the Transaction to the Condition and Fulfillment](#binding-the-transaction-to-the-condition-and-fulfillment)
    - [Cross-Currency and Cross-Border Support](#cross-currency-and-cross-border-support)
      - [A Note on Payee Privacy](#a-note-on-payee-privacy)
    - [Regulatory Data Exchange](#regulatory-data-exchange)
    - [Connecting to non-Mojaloop systems](#connecting-to-non-mojaloop-systems)
    - [Generalizing Transaction Outcome Notifications](#Generalizing-Transaction-Outcome-Notifications)
  - [Proposed Solution](#proposed-solution)
    - [Upgrading to Interledger Protocol version 4](#upgrading-to-interledger-protocol-version-4-1)
    - [Generation of the Condition and Fulfillment](#generation-of-the-condition-and-fulfillment-1)
    - [Binding the Transaction to the Condition and Fulfillment](#binding-the-transaction-to-the-condition-and-fulfillment-1)
    - [Cross-Currency and Cross-Border Support](#cross-currency-and-cross-border-support-1)
      - [Update `Party`](#update-party)
      - [Add `AccountList` and `Account` data types](#add-accountlist-and-account-data-types)
      - [Specify accountAddress in the Quote and Transfer to assist with routing](#specify-accountaddress-in-the-quote-and-transfer-to-assist-with-routing)
    - [Regulatory Data Exchange](#regulatory-data-exchange-1)
      - [Add `ParticipantList`, `Participant` and `Rate` data model](#add-participantlist-participant-and-rate-data-model)
      - [`RateValue` data type:](#ratevalue-data-type)
        - [`RateValue` Regular Expression](#ratevalue-regular-expression)
      - [Add `RequiredDataList`, `ProvidedDataList` and `ProvidedData`](#add-requireddatalist-provideddatalist-and-provideddata)
      - [Fees and Rates](#fees-and-rates)
      - [Regulatory Data](#regulatory-data)
    - [Connecting to non-Mojaloop systems](#connecting-to-non-mojaloop-systems-1)
    - [Generalizing Transaction Outcome Notifications](#Generalizing-Transaction-Outcome-Notifications-1)
  - [Data Model Changes](#data-model-changes)
  - [Examples](#examples)

## Document History

| Version | Date       | Author             | Change Description         |
| ------- | ---------- | ------------------ | -------------------------- |
| 1.0     | 2019-08-29 | Adrian Hope-Bailie | Initial draft              |
| 1.1     | 2019-11-12 | Adrian Hope-Bailie | Updates following workshop |
| 1.2     | 2020-10-05 | Lewis Daly         | Updates to include thirdparty transaction notifications |

## Change Request Background

### Upgrading to Interledger Protocol version 4

The current API is aligned with a legacy version of the Interledger protocol
(v1). This proposal seeks to align the API to ILPv4, not only for the sake of
deprecating what is an outdated implementation, but also to enable us to use the
latest open source Interledger components.

In an Interledger transaction, messages (ILP packets) are passed between
participants with an existing settlement relationship. The message headers carry
the details of the transfer from the one participant to the other whereas the
payload of the packet is **end-to-end** data that is used to convey transaction
information from the payer to the payee.

In the context of the Interledger protocol and the API, we consider **a transfer
between two DFSPs** as analogous to **the exchange of ILP packets** between
nodes. i.e. Execution of the `/transfer` API represents a single "hop" in a,
potentially "multi-hop" transaction.

In the API the **end-to-end** data is carried in the `Transaction` object
(currently encoded inside the ILPv1 packet payload)

> **NOTE**: In the future we may wish to explore modelling a Mojaloop network
> such that the switch is also a "node" and the transfer from DFSP to DFSP is
> modelled as two "hops" instead of one. This would enable the switch to apply
> dynamic fees to the transfers.

In ILPv1, the ILPv1 packet was enveloped in what was called a "ledger protocol"
message. Ledger protocols were used between nodes and their shared ledger, and
contained the details of the transfer including the condition, expiry and
transfer amount. The ILPv1 packet contained the `ILP address` of the payee, the
`destination amount` and the end-to-end `data` payload.

In ILPv4, the protocol was adjusted to be used directly between nodes via a
"bilateral protocol". In the bilateral protocol model the detail of the transfer
between the the two nodes is now included in the ILPv4 packet headers,
including:

- The `transfer amount`
- The `execution condition`
- The `transfer expiry`

The `destination amount` was dropped from the packet headers as this is
sensitive data and is expected to be part of the end-to-end payload (possibly
even encrypted).

In Interledger terminology the `/transfer` API is therefor a bilateral protocol
(carrying the details of the transfer between nodes), however it is missing the
ILP address of the payee, essential to routing if the transfer is part of a
"multi-hop" transaction.

Another change in ILPv4 is that the fulfillment packet contains a data payload.

This change means that data that was previously conveyed in the `/transaction`
API can be carried in the callback of the `/transfer` API and the `/transaction`
API can be deprecated.

### Generation of the Condition and Fulfillment

As we align the the API with ILPv4 it is necessary to define a data element in
the callback of the `/quote` API to carry data sent by the payee that it expects
to be unchanged and returned in the subsequent `/transfer` API call. (Currently
payee systems use the encoded ILPv1 packet)

This field is used by the payee to generate the fulfilment and condition so it
must be returned unchanged to the payee in order to fulfil the transfer. To
satisfy this requirement it is recommended that the field is sent as text and
that the payee use this to carry base64 encoded binary data.

The content of the field is at the discretion of the payee and MAY contain data
(such as the quote and transaction details) that it can use to ensure the
fulfilment and condition are cryptographically bound to the transaction.

### Binding the Transaction to the Condition and Fulfillment

The current API specification recommends a mechanism for deriving the
fulfillment, and therefor the condition, using an HMAC of the ILPv1 packet.

This binds the values to the transaction (since the ILPv1 packet contains the
`Transaction` object) however this cannot be verified without the payee
disclosing the key used in the HMAC operation.

In this proposal we recommend a replacement for this recommendation which would
make it possible for the participants in a transaction verify that the
fulfillment was derived from the `Transaction` object.

### Cross-Currency and Cross-Border Support

The current API defines a flow for discovery of the payee and payee details
using a combination of the `GET /parties` and `GET /participants` APIs.

Ultimately this results in the sending DFSP getting a response which provides
details of the payee. It is anticipated that the sending DFSP will use this
information (such as `Party.name`) to render appropriate options to the sender
for making a payment.

It is not currently possible to determine the currencies of the payee's accounts
from the `Party` data model in the `PUT /parties` callback .

Page 80 of the API specification suggests that the API support a query string
for the purposes of filtering:

> This HTTP request should support a query string (see Section 3.1.3 for more
> information regarding URI syntax) for filtering of currency. To use filtering
> of currency, the HTTP request GET /participants/<Type>/<ID>?currency=XYZ
> should be used, where XYZ is the requested currency.

However this only allows the sender to filter out payees that would require a
cross-currency transfer, it doesn't allow the sender to determine the currency
of the payee's account if the sender is willing to make a cross-currency
transfer.

#### A Note on Payee Privacy

The design of a mechanism for the discovery of accounts, and routing of quotes
and payments to those accounts, needs to be done in a privacy preserving manner.
It should not be possible during the lookup flow for a sender to discover more
information about the receiver than the receiver is prepared to share or than is
needed to make the payment.

If the payee has multiple accounts in different currencies that it can receive
payments into then these should be indexed in the lookup using opaque
identifiers.

This proposal suggests the use of an `AccountAddress` which is derived by the
Payee FSP and can be ephemeral so as to preserve the privacy of the Payee. The
`AccountAddress` assists in routing the subsequent quotes and transfers both
through the payment networks but also to the correct account at the Payee FSP.

### Regulatory Data Exchange

Transactions that cross-borders often have stringent data collection
requirements to comply with KYC, anti-money-laundering and other regulations.

In this proposal we define a new data element, `Participants`, which is passed
in the `POST /quotes` request, `PUT /quotes` response callback and
`POST /transfers` request response.

It provides a mechanism for participants in the transaction to both request and
provide such data securely and also for the route of the quoting cycle messages
to be recorded so it can be used to route the subsequent transfer.

### Connecting to non-Mojaloop systems

It is possible (and likely) that there will be a need to initiate and terminate
transactions in a Mojaloop system when the counter-party is not in a Mojaloop
system (or even a system that supports real-time clearing).

In this case it is important for the CNP that is bridging the Mojaloop system to
the other system(s) to be able to express and expected clearing time for
transactions.

### Generalizing Transaction Outcome Notifications

v1.1 of the FSPIOP-API introduced a new optional notification for the PayeeFSP. The
PayeeFSP can request a notification from the switch by sending a `PUT /transfers/{id}`
request to the switch with a `transferState` of `RESERVED`.

With the addition of Thirdparty APIs, there is a greater need for flexibility in 
delivering transaction outcome notifications to other interested participants, such as
a Payment Initiation Service Providers (PISPs) or  Cross Network Provider (CNPs).

This proposal includes a new `Subscribers` data element to be included in 
1. the request body of the `POST /quotes` request, and
2. inside the  `Transaction` object, which is exchanged during the `PUT /quotes` and `POST /transfers` requests.

`Subscribers` allows the Payer and Payee participants to include themselves and 
other parties they might be acting on the behalf of to the list of subscribers. Upon the
conclusion of a transaction, the switch can then use this list of subscribers to send
notifications to all interested parties.


## Proposed Solution

### Upgrading to Interledger Protocol version 4

The concrete changes proposed to the API to align with ILPv4 are:

1. Remove `ilpPacket` from the `POST /transfer` request.
2. Add the `Transaction` object as a property of the `POST /transfer` request
   (previously sent as the payload of the embedded ILPv1 packet).
3. Define a new optional property of the `POST /quotes` request to carry the
   account address of the payee. This data element will be an ASCII string with
   a length restriction of 1023 characters.
4. Add a `TransactionResult` to the `/transfer` response callback.

Since ILPv4 does not use quoting, the destination address of a message is
provided in the transfer. This is different to the Open FSP API which requires a
quote cycle preceding a transaction.

When using the API routing of a multi-hop transaction is determined during the
quote cycle and the path of the transaction that follows must be the same as the
path determined during quoting.

As a result the destination address is not included in the transfer but rather
in the `POST /quotes` request. The route for a transfer that is part of a
multi-hop transaction is thereby predetermined by the preceding quote.

With these changes the combination of the `POST /quotes` and `POST /transfers`
requests are a direct mapping from the ILPv4 prepare packet:

| ILP Prepare | API                           |
| ----------- | ----------------------------- |
| destination | `POST /quotes#accountAddress` |
| amount      | `POST /transfers#amount`      |
| expiry      | `POST /transfers#expiry`      |
| condition   | `POST /transfers#condition`   |
| payload     | `POST /transfers#transaction` |

and the `PUT /transfers` response callback is a direct mapping from the ILPv4
fulfill packet

| ILP Prepare | API                                |
| ----------- | ---------------------------------- |
| fulfillment | `PUT /transfers#fulfillment`       |
| payload     | `PUT /transfers#transactionResult` |

### Generation of the Condition and Fulfillment

The generation of the condition and fulfilment is done by the payee FSP. The
current specification recommends that the input into this algorithm is the ILPv1
packet which is sent in the `PUT /quotes` response callback from the payee fsp
and then sent back in the `POST /transfers` request.

This allows the payee to regenerate the values from the `POST /transfers`
request and ensure that the transaction has not changed.

However, the ILPv1 packet has been removed from the `PUT /quotes` response
callback as it is no longer passed in the `POST /transfers` request.

This proposal defines a new data element; `EchoData` that is used as the input
to this algorithm and mandates that this data is passed in the `PUT /quote`
response callback and the `POST /transfer` request.

This data element is a variable length UTF-8 string with a maximum length of 10
KB. This allows the payee to encode any data of their choosing in the field.

Binary data can be base64 encoded and/or encrypted at the discretion of the
payee (or as defined by the scheme, see below).

The API mandates (to ensure interoperability) that the `EchoData` received by a
payer FSP in a `PUT /quote` response callback is sent unmodified in the
corresponding `POST /transfers` request.

It is up to the payee to validate this data and also regenerate the fulfilment
and condition from this data to ensure the integrity of the transfer with regard
to the original quote.

### Binding the Transaction to the Condition and Fulfillment

The scheme may mandate that `EchoData` data include the `Transaction` or some
derivative thereof so that the `Transaction` is cryptographically bound to the
condition and fulfillment.

In order to verify that the fulfillment is a derivative of the transaction but
also ensure that it cannot be guessed by any party other than the payee FSP, it
should be constructed from 2 distinct 16 byte halves.

The first half is a derivative of the `Transaction` object which can be
validated by any participant. The second half is also a derivative of the
`Transaction` object but is derived using a secret known only to the payee FSP.

The algorithm has two inputs:

1.  The UTF-8 encoded JSON object that represents the `Transaction`: **tx**
2.  A 128 bit secret held by the payee FSP: **secret**

This algorithm depends on two standard cryptographic algorithms:

1.  SHA-256: As defined in [RFC 6234](https://tools.ietf.org/html/rfc6234)
2.  AES-CMAC: As defined in [RFC 4493](https://tools.ietf.org/html/rfc4493)

The steps are as follows:

1.  Let **txDigest** be the result of deriving the SHA-256 hash digest of
    **tx**.
2.  Let **txPrefix** be the first 16 bytes of **txDigest** (which is 32 bytes).
3.  Let **txSecret** be the result of deriving the AES128 CMAC of **txDigest**
    using **secret** as the key.
4.  Let **fulfillment** be the concatenation of **txPrefix** and **txSecret**.
5.  Let **condition** be the result of deriving the SHA-256 hash digest of
    **fulfillment**.
6.  Let **echoData** be the result of base64 encoding **tx**

Upon completion of this algorithm the payee FSP will assign the following values
to the `/quote` response callback:

| Output        | `PUT /quote` response callback |
| ------------- | ------------------------------ |
| **condition** | `PUT /quote#condition`         |
| **echoData**  | `PUT /quote#echoData`          |

Upon receipt of a `POST /transfer` request the payee FSP will perform the
following steps (at least) to verify the incoming data and ensure the integrity
of the `Transaction`.

This includes ensuring that `POST /transfer#transaction` and
`POST /transfer#echoData` are _semantically equal_. The purpose of this check is
to ensure that the version of the transaction used for deriving the fulfillment
(carried in `POST /transfer#echoData`) is equal to the `Transaction` object in
`POST /transfer#transaction` but allowing for differences such as key ordering
that may have resulted from JSON encoding and decoding through multiple
intermediary systems.

1. Let **tx** be the result of base64 decoding `POST /transfer#echoData`
2. Let **txCompare** be the UTF-8 encoded JSON object that is the value of the
   `POST /transfer#transaction`
3. Ensure that **tx** and **txCompare** are _semantically equal_, otherwise exit
   with error
4. Let **txDigest** be the result of deriving the SHA-256 hash digest of **tx**.
5. Let **txPrefix** be the first 16 bytes of **txDigest** (which is 32 bytes).
6. Let **txSecret** be the result of deriving the AES128 CMAC of **txDigest**
   using **secret** as the key.
7. Let **fulfillment** be the concatenation of **txPrefix** and **txSecret**.
8. Let **condition** be the result of deriving the SHA-256 hash digest of
   **fulfillment**.
9. Ensure that **condition** and `transfer.condition` are equal, otherwise exit
   with error

| Output          | `PUT /transfer` response callback |
| --------------- | --------------------------------- |
| **fulfillment** | `PUT /transfer#fulfillment`       |

### Cross-Currency and Cross-Border Support

The following updates to the API will facilitate cross-currency quotes and
transfers and the necessary lookups to facilitate these.

#### Update `Party`

The `Party` data model is updated to include a new `accounts` data element:

| Data Element | Cardinality | Type          | Description                                                                                                                   |
| ------------ | ----------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| accounts     | 0..1        | `AccountList` | A list of accounts that the Party has in different currencies together with an optional `AccountAddress` for routing purposes |

#### Add `AccountList` and `Account` data types

The `AccountList` data model is defined as:

| Data Element | Cardinality | Type      | Description                |
| ------------ | ----------- | --------- | -------------------------- |
| account      | 1..32       | `Account` | Number of Account elements |

The `Account` data model is defined as:

| Data Element | Cardinality | Type             | Description                 |
| ------------ | ----------- | ---------------- | --------------------------- |
| currency     | 1           | `Currency`       | The currency of the account |
| address      | 0..1        | `AccountAddress` | The address of this account |

The `AccountAddress` data type is a variable length string with a maximum size
of 1023 characters and consists of:

- Alphanumeric characters, upper or lower case. (Addresses are case-sensitive so
  that they can contain data encoded in formats such as base64url.)
- Underscore (\_)
- Tilde (~)
- Hyphen (-)
- Period (.) Addresses MUST NOT end in a period (.) character

An entity providing accounts to parties (i.e. a participant) can provide any
value for an `AccountAddress` that is **routable** to that entity. It does not
need to provide an address that makes the account identifiable outside the
entity's domain. i.e. This is an address not an identifier

For example, a participant (Blue DFSP) that has been allocated the address space
`moja.blue` might allocate a random UUID to the account and return the value:

```json
{
  "address": "moja.blue.8f027046-b82a-4fa9-838b-70210fcf8137",
  "currency": "ZAR"
}
```

_This address is *routable* to Blue DFSP because it uses the prefix `moja.blue`_

Blue DFSP may also simply use their own address if that is sufficient (in
combination with the remainder of the `PartyIdInfo`) to uniquely identify the
payee and the destination account.

```json
{
  "address": "moja.blue",
  "currency": "ZAR"
}
```

_This address is also *routable* to Blue DFSP because it uses the prefix
`moja.blue`_

**IMPORTANT**: The policy for defining addresses and the life-cycle of these is
at the discretion of the address space owner (the payee DFSP in this case)

#### Specify accountAddress in the Quote and Transfer to assist with routing

If a sending DFSP has an `AccountAddress` for the payee account this should be
included in the `POST /quotes` request.

Intermediaries that need to route a quote request via FX providers or
cross-network providers/gateways will determine the next hop of the quote
request by consulting their internal quoting engines which may use the address
to assist in deciding where to route the quote next.

### Regulatory Data Exchange

To enable the exchange of data between participants securely the API includes a
`Participants` list in the `POST /quotes` request, `PUT /quotes` response
callback and `POST /transfers` request response.

`POST /quotes#participants` is an ordered list of `Participant` objects each
representing a participant in the transaction. The order corresponds to the
order in which participants are expected to process `POST /transfer` requests in
order to complete the transaction.

The data element is optional for single hop transactions (that consist of only
one transfer) but required for transactions that consist of two or more
transfers.

#### Add `ParticipantList`, `Participant` and `Rate` data model

`ParticipantList`:

| Data Element | Cardinality | Type          | Description                    |
| ------------ | ----------- | ------------- | ------------------------------ |
| participant  | 1..16       | `Participant` | Number of Participant elements |

`Participant`:

| Name             | Cardinality | Type               | Description                                                                                                 |
| ---------------- | ----------- | ------------------ | ----------------------------------------------------------------------------------------------------------- |
| fspId            | 1           | `FspId`            | The identity of the participant                                                                             |
| transferCurrency | 1           | `Currency`         | The currency of the transfer that will be made by this participant.                                         |
| fee              | 1           | `Money`            | The fee that will be charged by the participant.                                                            |
| rate             | 0..1        | `Rate`             | The rate of exchange that will applied by this participant.                                                 |
| expiration       | 1           | `DateTime`         | Date and time until when the quotation is valid and can be honored when used in the subsequent transaction. |
| requiredData     | 0..1        | `RequiredDataList` | List of data required for compliance                                                                        |
| providedData     | 0..32       | `ProvidedDataList` | The data provided by other participants for use by this participant.                                        |

`Rate`:

| Data Element | Cardinality | Type        | Description                                      |
| ------------ | ----------- | ----------- | ------------------------------------------------ |
| rate         | 1           | `RateValue` | Rate of exchange                                 |
| fromCurrency | 1           | `Currency`  | Currency from which the conversion is being made |
| toCurrency   | 1           | `Currency`  | Currency to which the conversion is being madre  |

#### `RateValue` data type:

The API data type `RateValue` is a JSON String consisting of digits only and an
optional period. Negative numbers and leading zeroes are not allowed.

##### `RateValue` Regular Expression

The regular expression for restricting an Rate is
`^(([1-9][0-9]{0,5}))([.][0-9]{0,8}[1-9])?$`

#### Add `RequiredDataList`, `ProvidedDataList` and `ProvidedData`

The `RequiredDataList` data model is defined as:

| Data Element | Cardinality | Type             | Description                                                                    |
| ------------ | ----------- | ---------------- | ------------------------------------------------------------------------------ |
| requiredData | 1..256      | `String(1..128)` | Names of data elements required by the participant to complete the transaction |

The `ProvidedDataList` data model is defined as:

| Data Element | Cardinality | Type           | Description                                                                    |
| ------------ | ----------- | -------------- | ------------------------------------------------------------------------------ |
| providedData | 1..256      | `ProvidedData` | Names of data elements required by the participant to complete the transaction |

The `ProvidedData` data model is defined as:

| Data Element | Cardinality | Type              | Description                                                                   |
| ------------ | ----------- | ----------------- | ----------------------------------------------------------------------------- |
| dataKey      | 1           | `String(1..128)`  | Names of data element provided by the participant to complete the transaction |
| dataValue    | 1           | `String(1..2056)` | Value of data element required by the participant to complete the transaction |

#### Fees and Rates

With each successive `POST /quotes` request in a multi-hop transaction the
participants list will be added to by the participant processing the request.

The participant MUST specify:

1. the currency of the transfer it will make to the next participant
2. the fee it will charge
3. the rate of exchange it will apply

If the `fee` is denominated in the same currency as the `transferCurrency` then
the `fee` will be applied after applying the conversion at the specified `rate`.
If the currency of the `fee` is not the same as the `transferCurrency` then it
MUST be the same as the transfer that will be received by this participant (i.e.
the `transferCurrency` of the preceding participant in the list). In this case,
the fee is applied to the incoming transfer amount before the conversion.

#### Regulatory Data

When preparing a quote, each participant will indicate the data that it requires
by putting the names data fields into the `dataRequired` list. It MUST also
provide an encryption key that MUST be used by other participants to encrypt any
data that they provide.

On the return leg (`PUT /quotes` callback responses) each participant evaluates
the data requested by downstream recipients. If it must provide any of that data
it encrypts this data first under the key of the payer FSP (the first
participant) and then under the key of the participant requesting the data.

Encryption is done using JSON Web Encryption
([RFC 7516](https://tools.ietf.org/html/rfc7516)).

NOTE: The set of data fields that can be requested must be maintained in an
as-yet-undefined registry

When the payer FSP constructs the `POST /transfers` request it will decrypt any
data passed back in the quote response and encrypted under its key.

This data is added to the `dataProvided` of the relevant participant before
sending the `POST /transfers` request.

Participants can reject the quote if they are unable to provide the data
requested or they can reject the transfer if the data provided is insufficient.

### Connecting to non-Mojaloop systems

To accommodate the variety of clearing timelines in non-Mojaloop systems a
participant that initiates a transaction from a Mojaloop system that will be
routed to a non-Mojaloop system can express a maximum value date in the quote
request.

This is the latest date and time when the payment must clear in the payee's
account.

In the response the CNP can provide a value date that they commit to, based on
their knowledge of and SLAs with the external systems that will receive the
payment.


### Generalizing Transaction Outcome Notifications

`POST /quotes#subscribers` is a list of `Subscriber` objects each
representing an interested party in the transaction.

The `Subscriber` object takes the form of:

| Name               | Cardinality | Type               | Description                                                                             |
| ------------------ | ----------- | ------------------ | --------------------------------------------------------------------------------------- |
| id                 | 1           | `FspId`            | The id of a participant interested in the transaction                                   |
| role               | 1           | `SubscriptionRole` | The role of the subscription                                                            |

Where `SubscriptionRole` is a enum of the following values:

| Name               | Description                                | 
| ------------------ | ------------------------------------------ | 
| `PAYER`            | The sender of the funds                    | 
| `PAYEE`            | The recipient of the funds                 | 
| `PISP`        | The participant initiating the transaction | 


The `subscribers` list is included in the following request bodies:
1. Plaintext in the `POST /quotes` request
2. Inside the `Transaction` field of `PUT /quotes` (i.e. `transaction#subscribers`)
3. Inside the `Transaction` field of `POST /transfers` (i.e. `transaction#subscribers`)


#### Sending subscribers with a `POST /quotes`

Including the `subscribers` list with the `POST /quotes` request allows the 
PayerFSP to specify themselves and any other interested party who should be
notified by the switch upon the conclusion of a transaction.

For example, in a 'normal' peer-to-peer transaction, between two 
participants, `dfspA` and `dfspB`, dfspA can set the `quotes#subscribers`
object like so:
```json
[
  {
    "id": "dfspA",
    "role": "PAYER"
  }    
]
```

>See [below](#quote-request-with-a-single-subscriber) for a full example of this request

Or, in the case of a 3rd party initiated transaction, where a PISP `pispA`
has initiated a transaction:

```json
[
    {
      "id": "dfspA",
      "role": "PAYER"
    },
    {
      "id": "pispA",
      "role": "PISP"
    },   
  ]
```

> See [below](#quote-request-with-multiple-subscribers) for a full example of this request

#### Subscribers in the Transaction object

It is the responsibility of the PayeeFSP to form the Transaction object to be included in the `PUT /quotes/{id}` callback.

To build the `transaction#subscribers` field, the PayeeFSP takes the following steps:
1. Copy the value of `subscribers` from the `POST /quote` payload
2. Optionally append new `Subscriber` objects to the `subscribers` list
> The PayeeFSP can append a `Subscriber` object for themselves to request a callback 
> on the conclusion of the transaction - equivalent to the new behaviour introduced 
> in v1.1 of the API


##### Protecting against tampering with the `subscribers` list

Since the `Transaction` object is finalized by the PayeeFSP in the `PUT /quotes/{id}` callback, 
participants are unable to modify the `transaction#subscribers` after this point. Modifications
to `transaction#subscribers` would lead to an invalid condition and fulfilment, and void the
transaction.

Additionally, upon receiving the `PUT /quotes/{id}` callback, the PayerDFSP MUST validate the 
`transaction#subscribers`, and ensure that the PayeeFSP only appended to the `subscribers` list,
and did not remove any of the elements originally specified in the `POST /quotes` request.


##### Payee Notification Subscriptions - two methods

This leaves the PayeeFSP with 2 methods to request a callback from the switch upon the conclusion of a transaction:
1. In `PUT /transfers/{id}`, set the `transferState` to `RESERVED`
2. In `PUT /quotes/{id}` append a `Subscriber` object representing the PayeeFSP to `transaction#subscribers`

In the interests of preserving backwards compatibility, we propose to keep the `v1.1` notification behaviour,
but mark it as deprecated, to be removed in `v3.0` of the API


## Data Model Changes

`POST /quotes` request:

| Name                 | Cardinality | Type              | Description                                                                                             |
| -------------------- | ----------- | ----------------- | ------------------------------------------------------------------------------------------------------- |
| quoteId              | 1           | `CorrelationId`   | Common ID between the FSPs for the quote object, decided by the Payer FSP.                              |
| transactionId        | 1           | `CorrelationId`   | Common ID (decided by the Payer FSP) between the FSPs for the future transaction object.                |
| transactionRequestId | 0..1        | `CorrelationId`   | Identifies an optional previously-sent transaction request.                                             |
| payee                | 1           | `Party`           | Information about the Payee in the proposed financial transaction.                                      |
| payer                | 1           | `Party`           | Information about the Payer in the proposed financial transaction.                                      |
| amountType           | 1           | `AmountType`      | `SEND` for send amount, `RECEIVE` for receive amount.                                                   |
| amount               | 1           | `Money`           | If `SEND`: The amount the Payer would like to send. If `RECEIVE`: The amount the Payee should receive.  |
| fees                 | 0..1        | `Money`           | "Fees in the transaction.                                                                               |
| transactionType      | 1           | `TransactionType` | Type of transaction for which the quote is requested.                                                   |
| geoCode              | 0..1        | `GeoCode`         | Longitude and Latitude of the initiating Party. Can be used to detect fraud.                            |
| note                 | 0..1        | `Note`            | A memo that will be attached to the transaction.                                                        |
| expiration           | 0..1        | `DateTime`        | Expiration is optional.                                                                                 |
| accountAddress       | 0..1        | `AccountAddress`  | The address of the payee account, used for routing where the quote goes via one or more intermediaries. |
| participants         | 1           | `ParticipantList` | The participants in the transaction.                                                                    |
| subscribers          | 0..16       |
| maxValueDate         | 0..1        | `DateTime`        | The maximum Value Date for this transaction to clear in the payee’s account                             |
| extensionList        | 0..1        | `ExtensionList`   | Optional extension, specific to deployment.                                                             |

`PUT /quotes` response callback:

| Name               | Cardinality | Type            | Description                                                                                                 |
| ------------------ | ----------- | --------------- | ----------------------------------------------------------------------------------------------------------- |
| transferAmount     | 1           | `Money`         | The amount of Money that the Payer FSP should transfer to the Payee FSP.                                    |
| payeeReceiveAmount | 0..1        | `Money`         | The amount of Money that the Payee should receive in the end-to-end transaction.                            |
| payeeFspFee        | 0..1        | `Money`         | Payee FSP’s part of the transaction fee.                                                                    |
| payeeFspCommission | 0..1        | `Money`         | Transaction commission from the Payee FSP.                                                                  |
| expiration         | 1           | `DateTime`      | Date and time until when the quotation is valid and can be honored when used in the subsequent transaction. |
| geoCode            | 0..1        | `GeoCode`       | Longitude and Latitude of the Payee. Can be used to detect fraud.                                           |
| transaction        | 1           | `Transaction`   | The end-to-end transaction.                                                                                 |
| echoData           | 0..1        | `EchoData`      | Opaque data provided by the payee that must be echoed back unchanged in the transfer.                       |
| condition          | 1           | `IlpCondition`  | The condition that must be attached to the transfer by the Payer.                                           |
| participants       | 0..16       | `Participant`   | The participants in the transaction.                                                                        |
| valueDate          | 0..1        | `DateTime`      | The maximum Value Date for this transaction to clear in the payee’s account                                 |
| extensionList      | 0..1        | `ExtensionList` | Optional extension, specific to deployment.                                                                 |

`POST /transfers` request:

| Name          | Cardinality | Type            | Description                                                                                               |
| ------------- | ----------- | --------------- | --------------------------------------------------------------------------------------------------------- |
| transferId    | 1           | `CorrelationId` | The common ID between the FSPs and the optional Switch for the transfer object, decided by the Payer FSP. |
| payeeFsp      | 1           | `FspId`         | Payee FSP in the proposed financial transaction.                                                          |
| payerFsp      | 1           | `FspId`         | Payer FSP in the proposed financial transaction.                                                          |
| amount        | 1           | `Money`         | The transfer amount to be sent.                                                                           |
| transaction   | 1           | `Transaction`   | The end-to-end transaction.                                                                               |
| echoData      | 0..1        | `EchoData`      | Data provided by the Payee during quoting that is echoed back unchanged.                                  |
| condition     | 1           | `IlpCondition`  | The condition that must be fulfilled to commit the transfer.                                              |
| expiration    | 1           | `DateTime`      | The transfer should be rolled back if no fulfilment is delivered before this time.                        |
| participants  | 0..16       | `Participant`   | The participants in the transaction.                                                                      |
| extensionList | 0..1        | `ExtensionList` | Optional extension, specific to deployment.                                                               |

`PUT /transfers` response callback

| Name               | Cardinality | Type                | Description                                                 |
| ------------------ | ----------- | ------------------- | ----------------------------------------------------------- |
| fulfilment         | 0..1        | `IlpFulfilment`     | Fulfilment of the condition specified with the transaction. |
| transactionResult  | 0..1        | `TransactionResult` | The result of the end-to-end transaction.                   |
| completedTimestamp | 0..1        | `DateTime`          | Time and date when the transfer was completed.              |
| transferState      | 1           | `TransferState`     | State of the transfer.                                      |
| extensionList      | 0..1        | `ExtensionList`     | Optional extension, specific to deployment.                 |

`EchoData`:

| Data Element | Cardinality | Type              | Description                                                                     |
| ------------ | ----------- | ----------------- | ------------------------------------------------------------------------------- |
| echoData     | 1           | `String(1..2048)` | Opaque data provided by the Payee during quoting that is echoed back unchanged. |

`Account`:

| Data Element | Cardinality | Type             | Description                 |
| ------------ | ----------- | ---------------- | --------------------------- |
| currency     | 1           | `Currency`       | The currency of the account |
| address      | 0..1        | `AccountAddress` | The address of this account |

`AccountList`:

| Data Element | Cardinality | Type      | Description                |
| ------------ | ----------- | --------- | -------------------------- |
| account      | 1..32       | `Account` | Number of Account elements |

`Party`:

| Data Element               | Cardinality | Type                         | Description                                                                           |
| -------------------------- | ----------- | ---------------------------- | ------------------------------------------------------------------------------------- |
| partyIdInfo                | 1           | `PartyIdInfo`                | Party Id type, id, sub ID or type, and FSP Id.                                        |
| merchantClassificationCode | 0..1        | `MerchantClassificationCode` | Used in the context of Payee Information, where the Payee happens to be a merchant.   |
| name                       | 0..1        | `PartyName`                  | Display name of the Party, could be a real name or nickname.                          |
| personalInfo               | 0..1        | `PartyPersonalInfo`          | Personal information used to verify identity of Party such as name and date of birth. |
| accounts                   | 0..1        | `AccountList`                | A list of accounts that can accept transfers for the party.                           |

`Transaction`:

| Name               | Cardinality | Type              | Description                                                                                 |
| ------------------ | ----------- | ----------------- | ------------------------------------------------------------------------------------------- |
| transactionId      | 1           | `CorrelationId`   | ID of the transaction, the ID is decided by the Payer FSP during the creation of the quote. |
| quoteId            | 1           | `CorrelationId`   | ID of the quote, the ID is decided by the Payer FSP during the creation of the quote.       |
| payee              | 1           | `Party`           | Information about the Payee in the proposed financial transaction.                          |
| payer              | 1           | `Party`           | Information about the Payer in the proposed financial transaction.                          |
| amount             | 1           | `Money`           | Transaction amount to be sent.                                                              |
| transactionType    | 1           | `TransactionType` | Type of the transaction.                                                                    |
| subscribers        | 0..16       | `Subscriber`      | A list of subscribers who should be notified on the conclusion of the transaction           |
| note               | 0..1        | `Note`            | Memo associated to the transaction, intended to the Payee.                                  |
| extensionList      | 0..1        | `ExtensionList`   | Optional extension, specific to deployment.                                                 |


`TransactionResult`:

| Name               | Cardinality | Type             | Description                                                                             |
| ------------------ | ----------- | ---------------- | --------------------------------------------------------------------------------------- |
| completedTimestamp | 0..1        | DateTime         | Time and date when the transaction was completed.                                       |
| transactionState   | 1           | TransactionState | State of the transaction.                                                               |
| code               | 0..1        | Code             | Optional redemption information provided to Payer after transaction has been completed. |
| extensionList      | 0..1        | ExtensionList    | Optional extension, specific to deployment.                                             |


`Subscriber`:

| Name               | Cardinality | Type               | Description                                                                             |
| ------------------ | ----------- | ------------------ | --------------------------------------------------------------------------------------- |
| id                 | 1           | `FspId`            | The id of a participant interested in the transaction                                   |
| role               | 1           | `SubscriptionRole` | The of the subscription 

`SubscriptionRole` Enum:

| Name               | Description                                | 
| ------------------ | ------------------------------------------ | 
| `PAYER`            | The sender of the funds                    | 
| `PAYEE`            | The recipient of the funds                 | 
| `PISP`        | The participant initiating the transaction | 


A `subscribers` list is expressed as:

| Name               | Cardinality | Type               | Description                                                                             |
| ------------------ | ----------- | ------------------ | --------------------------------------------------------------------------------------- |
| `subscribers`      | 1...16      | `Subscriber`       | A list of Subscribers who are interested in the outcome of this Transaction             |


## Examples

### Quote Request with a Single Subscriber

```http
POST /quotes HTTP/1.1
Accept: application/vnd.interoperability.quotes+json;version=2 
Content-Type: application/vnd.interoperability.quotes+json;version=2.0 
Content-Length: 662
Date: Tue, 19 June 2021 08:00:00 GMT
FSPIOP-Source: dfspA
FSPIOP-Destination: dfspB
{
  "quoteId": "7c23e80c-d078-4077-8263-2c047876fcf6",
  "transactionId": "85feac2f-39b2-491b-817e-4a03203d4f14",
  "payee": {
    "partyIdInfo": {
      "partyIdType": "MSISDN",
      "partyIdentifier": "123456789",
      "fspId": "MobileMoney"
    }
  },
  "payer": {
    "personalInfo": {
      "complexName": {
        "firstName": "Mats",
        "lastName": "Hagman"
      }
    },
    "partyIdInfo": {
      "partyIdType": "IBAN",
      "partyIdentifier": "SE4550000000058398257466",
      "fspId": "BankNrOne"
    }
  },
  "amountType": "RECEIVE",
  "amount": {
    "amount": "100",
    "currency": "USD"
  },
  "transactionType": {
    "scenario": "TRANSFER",
    "initiator": "PAYER",
    "initiatorType": "CONSUMER"
  },
  "note": "Birthday Present",
  "expiration": "2020-06-19T09:00:00.000-01:00",
  "subscribers": [
    {
      "id": "dfspA",
      "role": "PAYER"
    }    
  ]
}
```

### Quote Request with Multiple Subscribers

```http
POST /quotes HTTP/1.1
Accept: application/vnd.interoperability.quotes+json;version=2 
Content-Type: application/vnd.interoperability.quotes+json;version=2.0 
Content-Length: 696
Date: Tue, 19 June 2021 08:00:00 GMT
FSPIOP-Source: dfspA
FSPIOP-Destination: dfspB
{
  "quoteId": "7c23e80c-d078-4077-8263-2c047876fcf6",
  "transactionId": "85feac2f-39b2-491b-817e-4a03203d4f14",
  "payee": {
    "partyIdInfo": {
      "partyIdType": "MSISDN",
      "partyIdentifier": "123456789",
      "fspId": "MobileMoney"
    }
  },
  "payer": {
    "personalInfo": {
      "complexName": {
        "firstName": "Mats",
        "lastName": "Hagman"
      }
    },
    "partyIdInfo": {
      "partyIdType": "IBAN",
      "partyIdentifier": "SE4550000000058398257466",
      "fspId": "BankNrOne"
    }
  },
  "amountType": "RECEIVE",
  "amount": {
    "amount": "100",
    "currency": "USD"
  },
  "transactionType": {
    "scenario": "TRANSFER",
    "initiator": "PAYER",
    "initiatorType": "CONSUMER"
  },
  "note": "Birthday Present",
  "expiration": "2020-06-19T09:00:00.000-01:00",
  "subscribers": [
    {
      "id": "dfspA",
      "role": "PAYER"
    },
    {
      "id": "pispA",
      "role": "PISP"
    },   
  ]
}
```