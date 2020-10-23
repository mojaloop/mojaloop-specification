---
Change Request ID: 19
Change Request Name: PISP Authorizations
Prepared By: Lewis Daly (Crosslake)
Solution Proposal Status: In review
Approved/Rejected Date: N/A
Target SIG: Thirdparty SIG
Target APIs: Thirdparty API
---

> A note on scope.
>
> This draft change request covers only the new `POST /authorizations` call
> in the Thirdparty API, and not components such as the other calls in
> the transfer flow or account linking flows. 
>
> We may wish to merge this change request into a larger change request
> for the thirdparty apis and PISP functions in the future.

# Proposal - Allow a DFSP to request transaction authorization

- [Proposal - Allow a DFSP to request transaction authorization](#proposal---Allow-a-DFSP-to-request-transaction-authorization)
  - [Document History](#document-history)
  - [Supporting Documents](#supporting-documents)
  - [Definitions](#Definitions)
  - [Change Request Background](#change-request-background)
  - [Proposed Solution](#proposed-solution)
    - [`POST /authorizations resource`](#POST-/authorizations-resource)
    - [Request Flow](#request-flow)
    - [Error Handling + Retries](#Error-Handling--Retries)
  - [HTTP Request Descriptions](#HTTP-Request-Descriptions)
  - [Data Models](#data-models)

## Document History

| Version | Date       | Author             | Change Description         |
| ------- | ---------- | ------------------ | -------------------------- |
| 1.0     | 2020-10-23 | Lewis Daly        | Initial draft              |

## Supporting Documents

[todo: ld - add links to sequences etc.]

- [PISP Transfer Overview](https://github.com/mojaloop/pisp/blob/master/docs/transfer/README.md)
- [PISP Transfer Sequence - Detailed](https://raw.githubusercontent.com/mojaloop/pisp/master/docs/out/transfer/api_calls_detailed/PISPTransferDetailedAPI-page2.png)
- [Proposed Thirdparty-PISP Swagger Explorer](http://docs.mojaloop.io/pisp/?urls.primaryName=thirdparty-pisp-api)
- [Proposed Thirdparty-DFSP Swagger Explorer](http://docs.mojaloop.io/pisp/?urls.primaryName=thirdparty-dfsp-api)

## Definitions

- `PISP` - Payment initiaion service provider. In mojaloop, PISP is a _role_ adopted by a participant participating in a scheme. A PISP has 
- Thirdparty API - A _new_ Mojaloop API. PISPs use the Thirdparty API to talk to the Mojaloop Switch, as opposed to the FSPIOP-API. 
  - The Thirdparty API can be divided into 2 separate parts: Thirdparty-PISP and Thirdparty-DFSP
  - Thirdparty-PISP is the section of the Thirdparty API a PISP uses to communicate with the Mojaloop Switch
  - Thirdparty-DFSP is the section of the Thirdparty API a DFSP uses to communicate with the Mojaloop Switch with respect to Thirdparty functions

- Thirdparty Transaction Request - A transaction request initiated by a PISP


## Change Request Background

As a part of a 3rd Party Transaction Request, we require a PISP to obtain the
explicit consent from their user for each transaction initiated on their behalf.

[todo: more background?]

## Proposed Solution

We propose to include the API resource `/authorizations` into the Thirdparty API for
Payer FPSs to request Authorization on a Thirdparty Transaction Request, and for 
PISPs to return authorization confirmation from their end-user.

### `POST /authorizations` resource

The FSPIOP-API includes 2 calls for asking for and obtaining consent for a
transactionRequest: `GET /authorizations` and `PUT /authorizations/{id}` 
[see 6.6 API Resource `/authorizations`](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#66-api-resource-authorizations).

The FSPIOP uses the `/authorizations` resource to request authorization for a
transactionRequest from a PayeeFSP to a PayerFSP.

In the thirdparty initiation use case, we propose to adopt the same `/authorizations`
resource into the Thirdparty API, with one modification: there will be no provision for 
a HTTP `GET` verb when requesting the authorization on a Thirdparty Transaction Request, 
only a `POST`.

Such a modification allows for:
1. Additional data to be specified in the request body of the `POST /authorizations` request, such as a Quote response object
2. More consistency with other resources in the FSPIOP-API (while a separate discussion, `GET /authorizations` is an anomaly in the FSPIOP-API)

### Request Flow

1. PISP requests a Thirdparty Transaction Request from the Payer FSP
1. The Payer FSP responds saying it acknowledges the Thirdparty Transaction Request
1. The Payer FSP requests a Quote from the Payee DFSP
1. The Payee DFSP responds with a Quote response
1. The Payer FSP issues a `POST /authorizations` to the PISP
    - This API call contains the Quote Response object
1. The PISP presents the Quote to their user, and asks them to authorize the Transaction
    - This authorization will take the form of a cryptographic signature on some aspect of the Quote Response object
1. The PISP returns the authorized transaction containing the signature with a `PUT /authorizations/{id}` response
1. The DFSP validates the `PUT /authorizations/{id}` response, and if valid, proceeds with the transaction

### Error Handling + Retries

We propose to handle errors in the same manner as the FSPIOP-API ([see section 6.6.1.2](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#6612-retry-authorization-value)), with the exception that `POST /authorizations` is used instead of `GET /authorizations`

The algorithm for handling errors and retries has the following input:

1. The number of retries, `n`, where is a positive integer and `n >= 1`

The steps for handling errors and retries are as follows:

1. The DFSP issues a `POST /authorizations` request with the number of retries of `n`
2. The PISP responds with the signed authorization in `PUT /authorizations/{id}`
3. _If_ the signed authorization is valid, exit
4. _If_ the signed authoriation is invalid, _and_ `n == 1`, the DFSP sends a `PUT /authorizations/{id}/error` to the PISP and the Thirdparty Transaction request is considered failed
5. _Otherwise_, decrement `n` by 1, and _goto_ step 1.


## HTTP Request Descriptions

### `POST /authorizations`

The call `POST /authorizations` is used by a Payer FSP to request authorization 
from a thirdparty as the result of a previously created Thirdparty Transaction 
request.

| Name                 | Cardinality | Type                 | Description                                                                                               |
| -------------------- | ----------- | -------------------- | --------------------------------------------------------------------------------------------------------- |
| transactionId        | 1           | `CorrelationId`      | Common ID (decided by the Payer FSP) between the participants for the future transaction object.          |
| transactionRequestId | 1           | `CorrelationId`      | Common ID (decided by the PISP ) - Identifies an the previously requested Thirdparty Transaction Request. |
| authenticationType   | 1           | `AuthenticationType` | The authentication method to be used by the PISP.                                                         |
| retriesLeft          | 1           | `String(1..32)`      | A string formatted unsigned integer greater than 1. The number of retries left before the Thirdparty Transaction Request  is rejected.                        |
| amount               | 1           | `Money`              | The transaction amount that will be withdrawn from the Payer's account.                                   |
| quote                | 1           | `QuoteResponse`      | The Quote Response from the Payer FSP.                                                                    |
| extensionList        | 0..1        | `ExtensionList`      | Optional extension, specific to deployment.                                                               |


### `PUT /authorizations/{id}`

The call `PUT /authorizations/{id}` is used by the PISP to return the authorization
result with the challenge signed by the user.

The path parameter `id` in the `PUT /authorizations/{id}` URI should be the `transactionRequestId`.

| Name                 | Cardinality | Type                    | Description                                                                                               |
| -------------------- | ----------- | ----------------------- | --------------------------------------------------------------------------------------------------------- |
| authenticationInfo   | 1           | `AuthenticationInfo`    | The complex object containing the authentication result from the PISP                                     |
| responseType         | 1           | `AuthorizationResponse` | todo |
| extensionList        | 0..1        | `ExtensionList`         | Optional extension, specific to deployment.                                                               |

### `PUT /authorizations/{id}/error`

The call `PUT /authorizations/{id}/error` is used by the Payer FSP to inform a PISP
of a failed authorization request, or any other processing error after receiving a `PUT /authorizations/{id}`.


| Name                 | Cardinality | Type                    | Description                         |
| -------------------- | ----------- | ----------------------- | ----------------------------------- |
| errorInformation     | 1           | `ErrorInformation`      | Error code, category description    |


## Data Models

### `AuthenticationType` Enumeration

| Name               | Description                                   | 
| ------------------ | --------------------------------------------- | 
| `OTP`              | One-time password generated by the Payer FSP. | 
| `QRCODE`           | QR code used as One Time Password.            | 
| `U2F`              | Universal 2nd Factor Authentication.          | 


### `AuthenticationInfo`

| Name                 | Cardinality | Type                                        | Description                                                           |
| -------------------- | ----------- | ------------------------------------------- | --------------------------------------------------------------------- |
| authentication       | 1           | `AuthenticationType`                        | The method of authentication used                                     |
| authenticationValue  | 1           | `AuthenticationValueU2F` or `String(1..32)` | The authentication value. Format depends on `AuthenticationType`.     |
| extensionList        | 0..1        | `ExtensionList`                             | Optional extension, specific to deployment.                           |

### `AuthenticationValueU2F`

AuthenticationValue takes the following formats, depending on the value of `authentication#authentication`.

| Name                 | Cardinality | Type                    | Description                                                                                               |
| -------------------- | ----------- | ----------------------- | --------------------------------------------------------------------------------------------------------- |
| pinValue             | 1           | `String(1..2048)`       | Base64 encoded binary string. The challenge object signed by the user's FIDO private key                  |
| counter              | 1           | `String(1..32)`         | A counter [ todo: why? ]



### Existing Data Models:

The following data models are from the FSPIOP-API and remain unmodified

- [AuthorizationResponse](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#753-authorizationresponse)
- [ErrorInformation](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#742-errorinformation)
- [ExtensionList](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#744-extensionlist)
- [Money](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#7410-money)
- [QuoteResponse](https://docs.mojaloop.io/mojaloop-specification/documents/API%20Definition%20v1.0.html#6531-put-quotesid)
