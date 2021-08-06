# Mojaloop Third Party API Specification


TODOs:
- fix link to Ref 1
- add in section links to make reading document much easier

## 1 Revision History

| Version | Description | Modified By | Date |
| --- | --- | --- | --- |
| `0.0` | Initial Version                            | M. Richards | 4 November 2020  |
| `0.1` | Following review by Henrik Karlsson        | M. Richards | 9 November 2020  |
| `0.2` | Further changes consequent on HK review    | M. Richards | 13 November 2020 |
| `0.3` | Following HK and LD reviews                | M. Richards | 9 February 2021  |
| `0.4` | Following reviews                          | M. Richards | 30 March 2021    |
| `0.5` | Following discussion on transaction object | M. Richards | 8 June 2021      |
| `0.6` | Conversion to .md format                   | L. Daly     | 6 August 2021    |


## 2 References

The following references are used in this specification:

| Reference | Description | Version | URL |
| --- | --- | --- | --- |
| Ref. 1 | Open API for FSP Interoperability | `1.1` | [https://github.com/mojaloop/mojaloop-specification/blob/master/documents/v1.1-document-set/API%20Definition_v1.1.pdf](https://github.com/mojaloop/mojaloop-specification/blob/master/documents/v1.1-document-set/API%20Definition_v1.1.pdf)|

## 3 Third Party API

This section describes the content of the API which will be used by PISPs.
The content of the API falls into two sections. The first section manages the process for linking customer accounts and providing a general permission mechanism for PISPs to perform operations on those accounts. The second section manages the transfer of funds at the instigation of a PISP.
The content of the account linking section consists of the following operations:
- The PISP requests association with a customer account on behalf of the customer.
- The owner of the customer’s account satisfies itself that association really was requested by their customer, and the customer has a chance to confirm or modify directly with the account owning DFSP the types of access and the accounts for which the PISP will have permission. The DFSP then notifies the PISP that the customer has authorized access, and provides a token which the PISP can use to continue the process. This part of the process is performed via direct communication between the PISP application and the DFSP, and does not use the API.
- The DFSP requests confirmation from the PISP that the DFSP’s customer has confirmed with the PISP that they authorize the PISP to perform operations on their account. Confirmation requires the PISP to provide the bearer token that the DFSP sent the PISP as confirmation of the successful completion of the out-of-band customer authorization described in the previous step.
- The DFSP confirms to the PISP the accounts which it will allow the PISP to access and the access types available to the PISP on each account. It also confirms the following items of information:
  - For each account to which the DFSP grants access, the Mojaloop identifier which the PISP should use in subsequent access requests to identify the account on which the operation should be performed.
- For each association to be made, the PISP asks the user’s handset to register a keypair to be used to confirm transfer requests in the future. The public key belonging to this keypair is returned to the DFSP, together with the account identifier provided by the DFSP.
- If the DFSP is not using a local authentication service to verify the challenges it uses to authenticate transfer requests, it asks the scheme’s authentication service to register the public key and associate it with the account ID it provides.

- For each association to be made, the DFSP provides a challenge to the PISP. The PISP asks the customer to sign the challenge, and returns the signed challenge to the DFSP.

- The DFSP verifies that the signed challenge matches the value that it holds for the association, using either its own authentication service or the scheme authentication service.
The API is used by the following different types of participant, as follows:
  1. PISPs.
  2. DFSPs who offer services to their customer which allow the customer to access their account via one or more PISPs.
  3. FIDO authorization servers.
  4. The Mojaloop switch

Each resource in the API definition is accompanied by a definition of the type(s) of participant ¬¬¬allowed to access it.



### 3.1 Resources

The PISP API will contain the following resources:

#### 3.1.1 accounts

The /accounts resource is used to request information from a DFSP relating to the accounts 
it holds for a given identifier. The identifier is given to the PISP by the user, and the 
DFSP returns a set of information about the accounts it is prepared to divulge to the PISP.
The PISP can then display the names of the accounts to the user, and allow the user to select
the accounts with which they wish to link via the PISP.

The /accounts resource supports the endpoints described below.

##### 3.1.1.1 Requests

This section describes the services that a PISP can request on the /accounts resource.

###### 3.1.1.1.1  `GET /accounts/<Type>/<ID>`

Used by: PISP

The HTTP request `GET /accounts/<Type>/<ID>` is used to lookup information about the requested
Party’s accounts, defined by `<Type>` and `<ID>` (for example, `GET /accounts/MSISDN/123456789`).
See Section 5.1.6.11 of Ref. 1 above for more information regarding addressing of a Party.

Callback and data model information for `GET /accounts/<Type>/<ID>`:
• Callback - PUT /accounts/<Type>/<ID>
• Error Callback - PUT /accounts/<Type>/<ID>/error
• Data Model – Empty body

##### 3.1.1.2 Callbacks 

The responses for the `/accounts` resource are as follows

###### 3.1.1.2.1  `PUT /accounts/<Type>/<ID>`

Used by: DFSP

The `PUT /accounts/<Type>/<ID>` response is used to inform the requester of the result of a request
for accounts information.  The identifier type and the identifier ID given in the call are the 
values given in the original request (see Section 3.1.1.1.1 above.)

The data content of the message is given below.

| Name | Cardinality | Type | Description |
| --- | --- | --- | --- |
| accountList | 1 | [AccountList](todo) | Information about the accounts that the DFSP associates with the identifier sent by the PISP. |

###### 3.1.1.2.2  `PUT /accounts/<type>/<ID>/error`

Used by: DFSP

The `PUT /accounts/<Type>/<ID>/error` response is used to inform the requester that an account list
request has given rise to an error. The identifier type and the identifier ID given in the call are
the values given in the original request (see [Section 3.1.1.1.1](#3_1_1_1_1) above.)

The data content of the message is given below.


| Name | Cardinality | Type | Description |
| --- | --- | --- | --- |
| errorInformation | 1 | ErrorInformation | The result of the authentication check carried out by the authentication service. |




















































3.1.2 consentRequests
The /consentRequests resource is used by a PISP to initiate the process of linking with a DFSP’s account on behalf of a user. The PISP contacts the DFSP and sends a list of the permissions that it wants to obtain and the accounts for which it wants permission.
3.1.2.1 Requests
This section describes the services that can be requested by a client on the API resource /consentRequests.
3.1.2.1.1 GET /consentRequests/<ID>
Used by: PISP
The HTTP request GET /consentRequests/<ID> is used to get information about a previously requested consent. The <ID> in the URI should contain the requestId that was assigned to the request by the PISP when the PISP originated the request.
Callback and data model information for GET /consentRequests/<ID>:
• Callback – PUT /consentRequests /<ID>
• Error Callback – PUT /consentRequests /<ID>/error
• Data Model – Empty body
3.1.2.1.2 POST /consentRequests
Used by: PISP
The HTTP request POST /consentRequests is used to request a DFSP to grant access to one or more accounts owned by a customer of the DFSP for the PISP who sends the request.
Callback and data model for POST /consentRequests:
• Callback: PUT /consentRequests/<ID>
• Error callback: PUT /consentRequests/<ID>/error
• Data model – see below
Name Cardinality Type Description
consentRequestId 1 CorrelationId
Common ID between the PISP and the Payer DFSP for the consent request object. The ID should be reused for resends of the same consent request. A new ID should be generated for each new consent request.
partyIdInfo 1 PartyIdInfo
The identifier of the customer on behalf of whom the consent request is being made.
scopes 1..n Scope
One or more requests for access to a particular account. In each case, the address of the account and the types of access required are given.
authChannels 1..n ConsentRequestChannelType
A collection of the types of authentication that the DFSP may use to verify that its customer has in fact requested access for the PISP to the accounts requested..
callbackUri 0..1 Uri
The callback URI that the user will be redirected to after completing verification via the WEB authorization channel

3.1.2.2 Callbacks
This section describes the callbacks that are used by the server under the resource /consentRequests.
3.1.2.2.1 PATCH /consentRequests/<ID>
Used by: DFSP, PISP
When a party intends to change the content of a consent request, it can do this via the PATCH /consentRequests/<ID> resource. The syntax of this call complies with the JSON Merge Patch specification  rather than the JSON Patch specification : that is to say, . The PATCH /consentRequests/<ID> resource contains a set of proposed changes to the current state of the permissions relating to a particular authorization request. The data model for this call is as follows:

Name Cardinality Type Description
scopes 0..n Scope
One or more requests for access to a particular account. In each case, the address of the account and the types of access required are given.
authChannels 0..1 ConsentRequestChannelType
The authorization channel chosen by the DFSP from the list of supported authorization channels proposed by the PISP in the original request.
callbackUri 0..1 Uri
The callback URI that the user will be redirected to after completing verification via the WEB authorization channel
authUri 0..1 Uri
The URI that the PISP should call to complete the linking procedure if completion is required.
authToken 0..1 BinaryString
The bearer token given to the PISP by the DFSP as part of the out-of-loop authentication process

3.1.2.2.2 PUT /consentRequests/<ID>
Used by: DFSP
When a PISP requests a series of permissions from a DFSP on behalf of a DFSP’s customer, not all the permissions requested may be granted by the DFSP. Conversely, the out-of-loop authorization process may result in additional privileges being granted by the account holder to the PISP. The PUT /consentRequests/<ID> resource returns the current state of the permissions relating to a particular authorization request. The data model for this call is as follows:
Name Cardinality Type Description





Scopes 1..n Scope
One or more requests for access to a particular account. In each case, the address of the account and the types of access required are given.
authChannels 1
ConsentRequestChannelType
The authorization channel chosen by the DFSP from the list of supported authorization channels proposed by the PISP in the original request.
callbackUri 0..1 Uri
The callback URI that the user will be redirected to after completing verification via the WEB authorization channel
authUri 0..1 Uri
The URI that the PISP should call to complete the linking procedure if completion is required.
authToken 0..1 BinaryString
The bearer token given to the PISP by the DFSP as part of the out-of-loop authentication process

3.1.2.3 Error callbacks
This section describes the error callbacks that are used by the server under the resource /consentRequests.
3.1.2.3.1 PUT /consentRequests/<ID>/error
Used by: DFSP
If the server is unable to complete the consent request, or if an out-of-loop processing error or another processing error occurs, the error callback PUT /consentRequests/<ID>/error is used. The <ID> in the URI should contain the <ID> that was used in the GET /consentRequests/<ID> request or the POST /consentRequests request. The data model for this resource is as follows:
Name Cardinality Type Description
errorInformation 1 ErrorInformation
Error code, category description.

3.1.3 consents
The /consents resource is used to negotiate a series of permissions between the PISP and the DFSP which owns the account(s) on behalf of which the PISP wants to transact.
The /consents request is originally sent to the PISP by the DFSP following the original consent request process described in Section 3.1.3 above. At the close of this process, the DFSP which owns the customer’s account(s) will have satisfied itself that its customer really has requested that the PISP be allowed access to their accounts, and will have defined the accounts in question and the type of access which is to be granted.
3.1.3.1 Requests 
The /consents resource will support the following requests.
3.1.3.1.1 GET /consents/<ID>
Used by: DFSP
The GET consents/<ID> resource allows a party to enquire after the status of a consent. The <ID> used in the URI of the request should be the consent request ID which was used to identify the consent when it was created.
Callback and data model information for GET /consents/<ID>:
• Callback – PUT /consents/<ID>
• Error Callback – PUT /consents/<ID>/error
• Data Model – Empty body
3.1.3.1.2 POST /consents
Used by: DFSP
The POST /consents request is used to request the creation of a consent for interactions between a PISP and the DFSP who owns the account which a PISP’s customer wants to allow the PISP access to.
Callback and data model information for POST /consents/<ID>:
• Callback – PUT /consents/<ID>
• Error Callback – PUT /consents/<ID>/error
Data Model – defined below
Name Cardinality Type Description
consentId 1 CorrelationId
Common ID between the PISP and the Payer DFSP for the consent object. The ID should be reused for resends of the same consent. A new ID should be generated for each new consent.
consentRequestId 1 CorrelationId
The ID given to the original consent request on which this consent is based.
initiatorId 1
FspId
The ID of the PISP associated with the consent.
issuerId
1
FspId
The ID of the DFSP which created the consent.

scopes 1..n Scope
One or more accounts on which the DFSP is prepared to grant specified permissions to the PISP.
credential 0..1 Credential
The credential which is being used to support the consents.
extensionList 0..1 ExtensionList
Optional extension, specific to deployment
3.1.3.1.3 DELETE /consents/<ID>
The DELETE /consents/<ID> request is used to request the deletion of a previously agreed consent. The switch should be sure not to delete the consent physically; instead, information relating to the consent should be marked as deleted and requests relating to the consent should not be honoured.
Note: the ALS should verify that the participant who is requesting the deletion is either the initiator named in the consent or the account holding institution named in the consent. If any other party attempts to delete a consent, the request should be rejected, and an error raised.
Callback and data model information for DELETE /consents/<ID>:
• Callback – PUT /consents/<ID>
• Error Callback – PUT /consents/<ID>/error

3.1.3.2 Callbacks 
The /consents resource will support the following callbacks: 
3.1.3.2.1 PATCH/consents/<ID>
Used by: PISP
When a party intends to change the content of a consent, it can do this via the PATCH /consents/<ID> resource. The syntax of this call complies with the JSON Merge Patch specification  rather than the JSON Patch specification . The PATCH /consents/<ID> resource contains a set of proposed changes to the current state of the permissions relating to a particular authorization grant. The data model for this call is as follows:
Name Cardinality Type Description
scopes 0..n Scope
The scopes covered by the consent.
consentState 0 CredentialState
State of the consent
credential 0  
extensionList 0..1 ExtensionList
Optional extension, specific to deployment

3.1.3.2.2 PUT /consents/<ID>
Used by: PISP
The PUT /consents/<ID> resource is used to return information relating to the consent object whose consentId is given in the URI. The data returned by the call is as follows:
Name Cardinality Type Description
scopes 1..n Scope
The scopes covered by the consent.
consentState 1 ConsentState
State of the consent
credential 1 Credential
Information about the challenge which relates to the consent.
extensionList 0..1 ExtensionList
Optional extension, specific to deployment
3.1.3.3 Error callbacks
This section describes the error callbacks that are used by the server under the resource /consents.
3.1.3.3.1 PUT /consents/<ID>/error
Used by: PISP
If the server is unable to complete the consent, or if an out-of-loop processing error or another processing error occurs, the error callback PUT /consents/<ID>/error is used. The <ID> in the URI should contain the <ID> that was used in the GET /consents/<ID> request or the POST /consents request. The data model for this resource is as follows:
Name Cardinality Type Description
errorInformation 1 ErrorInformation
Error code, category description.

3.1.4 parties
The parties resource will be used by the PISP to identify a party to a transfer. This will be used by the PISP to identify the payee DFSP when it requests a transfer.
The PISP will be permitted to issue a PUT /parties response. Although it does not own any transaction accounts, there are circumstances in which another party may want to pay a customer via their PISP identification: for instance, where the customer is at a merchant’s premises and tells the merchant that they would like to pay via their PISP app. In these circumstances, the PISP will need to be able to confirm that it does act for the customer.
3.1.4.1 Requests 
The parties resource will support the following requests.
3.1.4.1.1 GET /parties
Used by: PISP
The GET /parties resource will use the same form as the resource described in Section 6.3.3.1 of Ref. 1 above.
3.1.4.2 Callbacks 
The parties resource will support the following callbacks.
3.1.4.2.1 PUT /parties
Used by: DFSP
The PUT /parties resource will use the same form as the resource described in Section 6.3.4.1 of Ref. 1 above.
It should be noted, however, that the Party object returned from this resource has a different format from the Party object described in Section 7.4.11 of Ref. 1 above. The structure of this object is described in Section 3.2.1.29 below.
3.1.5 services
The services resource is a new resource which enables a participant to query for other participants who offer a particular service. The requester will issue a GET request, specifying the type of service for which information is required as part of the query string. The switch will respond with a list of the current DFSPs in the scheme which are registered as providing that service.
3.1.5.1 Requests 
The services resource will support the following requests.
3.1.5.2 GET /services/<Type>
Used by: DFSP, PISP
The HTTP request GET /services/<Type> is used to find out the names of the participants in a scheme which provide the type of service defined in the <Type> parameter. The <Type> parameter should specify a value from the ServiceType enumeration. If it does not, the request will be rejected with an error.
Callback and data model information for GET /services/<Type>:
• Callback - PUT /services/<Type>
• Error Callback - PUT /services/<Type>/error
• Data Model – Empty body
3.1.5.3 Callbacks
This section describes the callbacks that are used by the server for services provided by the resource /services.
3.1.5.3.1 PUT /services/<Type>
Used by: Switch
The callback PUT /services/<Type> is used to inform the client of a successful result of the service information lookup. The information is returned in the following form:
Name Cardinality Type Description
serviceProviders 1…n FspId
A list of the Ids of the participants who provide the service requested.

3.1.5.3.2 PUT /services/<Type>/error
Used by: Switch
If the server encounters an error in fulfilling a request for a list of participants who provide a service, the error callback PUT /services/<Type>/error is used to inform the client that an error has occurred.
Name Cardinality Type Description
errorInformation 1 ErrorInformation
Error code, category description.

3.1.6 thirdpartyRequests/authorizations
The /thirdpartyRequests/authorizations resource is analogous to the /authorizations resource described in Section 6.6 of Ref. 1 above. The DFSP uses it to request the PISP to:
1. Display the information defining the terms of a proposed transfer to its customer;
2. Obtain the customer’s confirmation that they want the transfer to proceed;
3. Return a signed version of the terms which the DFSP can use to verify the consent
The /thirdpartyRequests/authorizations resource supports the endpoints described below.
3.1.6.1 Requests
This section describes the services that a client can request on the /thirdpartyRequests/authorizations resource.
3.1.6.1.1 GET /thirdpartyRequests/authorizations/<ID>
Used by: DFSP
The HTTP request GET /thirdpartyRequests/authorizations /<ID> is used to get information relating to a previously issued authorization request. The <ID> in the request should match the authorizationRequestId which was given when the authorization request was created.
Callback and data model information for GET /thirdpartyRequests/authorizations/<ID>:
• Callback - PUT /thirdpartyRequests/authorizations /<ID>
• Error Callback - PUT /thirdpartyRequests/authorizations /<ID>/error
• Data Model – Empty body
3.1.6.1.2 POST /thirdpartyRequests/authorizations
Used by: DFSP
The HTTP request POST /thirdpartyRequests/authorizations is used to request the validation by a customer for the transfer described in the request.
Callback and data model information for POST /thirdpartyRequests/authorizations:
• Callback - PUT /thirdpartyRequests/authorizations /<ID>
• Error Callback - PUT /thirdpartyRequests/authorizations /<ID>/error
• Data Model – See Table below
Name Cardinality Type Description
authorizationRequestId 1 CorrelationId
Common ID between the PISP and the Payer DFSP for the transaction request object. The ID should be reused for resends of the same transaction request. A new ID should be generated for each new transaction request.
transactionRequestId 1 CorrelationId
The unique identifier of the transaction request for which authorization is being requested.
challenge 1 BinaryString
The challenge that the PISP’s client is to sign.
transactionId 1 CorrelationId
The unique identifier for the proposed transaction. It is set by the payer DFSP and signed by the payee DFSP as part of the terms of the transfer
transferAmount 1 Money
The amount that will be debited from the sending customer’s account as a consequence of the transaction.
payeeReceiveAmount 1 Money
The amount that will be credited to the receiving customer’s account as a consequence of the transaction.





fees
1 Money
The amount of fees that the paying customer will be charged as part of the transaction.

payer
1 Party
Information about the Payer in the proposed transaction
payee
1 Party
Information about the Payee in the proposed transaction

transactionType
1
TransactionType
The type of the transaction.

condition
1
IlpCondition
The condition returned by the payee DFSP to the payer DFSP as a cryptographic guarantee of the transfer.





expiration 1
DateTime
The time by which the transfer must be completed, set by the payee DFSP.
extensionList 0..1 ExtensionList
Optional extension, specific to deployment.

3.1.6.2 Callbacks
The following callbacks are supported for the /thirdpartyRequests/authorizations resource
3.1.6.2.1 PUT /thirdpartyRequests/authorizations/<ID>
Used by: PISP
The PUT /thirdpartyRequests/authorizations/<ID> resource will have the same content as the PUT /authorizations/<ID> resource described in Section 6.6.4.1 of Ref. 1 above.
3.1.6.3 Error callbacks
This section describes the error callbacks that are used by the server under the resource /thirdpartyRequests/authorizations.
3.1.6.3.1 PUT /thirdpartyRequests/authorizations/<ID>/error
Used by: DFSP
The PUT /thirdpartyRequests/authorizations/<ID>/error resource will have the same content as the PUT /authorizations/<ID>/error resource described in Section 6.6.5.1 of Ref. 1 above.
3.1.7 thirdpartyRequests/transactions
The /thirdpartyRequests/transactions resource is analogous to the /transactionRequests resource described in Section 6.4 of Ref. 1 above. The PISP uses it to request the owner of the PISP’s customer’s account to transfer a specified amount from the customer’s account with the DFSP to a named Payee.
The /thirdpartyRequests/transactions resource supports the endpoints described below.
3.1.7.1 Requests
This section describes the services that a client can request on the /thirdpartyRequests/transactions resource.
3.1.7.1.1 GET /thirdpartyRequests/transactions/<ID>
Used by: PISP
The HTTP request GET /thirdpartyRequests/transactions/<ID> is used to get information relating to a previously issued transaction request. The <ID> in the request should match the transactionRequestId which was given when the transaction request was created.
Callback and data model information for GET /thirdpartyRequests/transactions/<ID>:
• Callback - PUT /thirdpartyRequests/transactions /<ID>
• Error Callback - PUT /thirdpartyRequests/transactions /<ID>/error
• Data Model – Empty body
3.1.7.1.2 POST /thirdpartyRequests/transactions
Used by: PISP
The HTTP request POST /thirdpartyRequests/transactions is used to request the creation of a transaction request on the server for the transfer described in the request.
Callback and data model information for POST /thirdpartyRequests/transactions:
• Callback - PUT /thirdpartyRequests/transactions /<ID>
• Error Callback - PUT /thirdpartyRequests/transactions /<ID>/error
• Data Model – See Table below
Name Cardinality Type Description
transactionRequestId 1 CorrelationId
Common ID between the PISP and the Payer DFSP for the transaction request object. The ID should be reused for resends of the same transaction request. A new ID should be generated for each new transaction request.
payee 1 Party
Information about the Payee in the proposed financial transaction.
payer 1 PartyIdInfo
Information about the Payer type, id, sub-type/id, FSP Id in the proposed financial transaction.
amount 1 Money
Requested amount to be transferred from the Payer to Payee.
transactionType 1 TransactionType
Type of transaction
note 0..1 Note
Reason for the transaction request, intended for the Payer.





authenticationType 0..1 AuthenticationType
OTP, FIDO or QR Code, otherwise empty.
expiration 0..1 DateTime
Can be set to get a quick failure in case the peer FSP takes too long to respond. Also, it may be beneficial for Consumer, Agent, Merchant to know that their request has a time limit.
extensionList 0..1 ExtensionList
Optional extension, specific to deployment.
3.1.7.2 Callbacks
The following callbacks are supported for the /thirdpartyRequests/transactions resource
3.1.7.2.1 PUT /thirdpartyRequests/transactions/<ID>
Used by: DFSP
The PUT /thirdpartyRequests/transactions/<ID> resource will have the same content as the PUT /transactionRequests/<ID> resource described in Section 6.4.4.1 of Ref. 1 above.
3.1.7.2.2 PATCH /thirdpartyRequests/transactions/<ID>
Used by: DFSP
The issuing PISP will expect a response to their request for a transfer which describes the finalised state of the requested transfer. This response will be given by a PATCH call on the /thirdpartyRequests/transactions/<ID> resource.  The <ID> given in the query string should be the transactionRequestId which was originally used by the PISP to identify the transaction request (see Section 3.1.8.1.2 above.)
The data model for this endpoint is as follows:
Name Cardinality Type Description
completedTimestamp 0..1 DateTime
Time and date when the transaction was completed
transferState 1 TransferState
State of the transfer
extensionList 0..1 ExtensionList
Optional extension, specific to deployment

3.1.7.3 Error callbacks
This section describes the error callbacks that are used by the server under the resource /thirdpartyRequests/transactions.
3.1.7.3.1 PUT /thirdpartyRequests/transactions/<ID>/error
Used by: DFSP
The PUT /thirdpartyRequests/transactions/<ID>/error resource will have the same content as the PUT /transactionRequests/<ID>/error resource described in Section 6.4.5.1 of Ref. 1 above.
3.1.7.3.2 PATCH /thirdpartyRequests/transactions/<ID>/error
Used by: DFSP
The issuing PISP will expect a response to their request for a transfer which describes the finalized state of the requested transfer. This response will be given by a PATCH call on the /thirdpartyRequests/transactions/<ID>/error resource.  The content of this resource will be the same as the data model described in Table 24 of Ref. 1 above, in the section describing the PUT command on the /transfers/<ID>/error resource shown in Section 6.7.5.1 of Ref. 1 above.

3.1.8 thirdPartyRequests/verifications
The /thirdPartyRequests/verifications resource is used by a Payer DFSP to verify that an authorization response received from a PISP was signed using the correct key, in cases where the authentication service to be used is implemented by the switch and not internally by the DFSP. The DFSP sends the original challenge and the signed response to the authentication service, together with the consent ID to be used for the verification. The authentication service compares the response with the result of signing the challenge with the private key associated with the consent ID, and, if the two match, it returns a positive result. Otherwise, it returns an error.
The /thirdPartyRequests/verifications resource supports the endpoints described below.
3.1.8.1 Requests
This section describes the services that a client can request on the /thirdPartyRequests/verifications resource.
3.1.8.1.1 GET /thirdPartyRequests/verifications/<ID>
Used by: DFSP
The HTTP request /thirdPartyRequests/verifications <ID> is used to get information regarding a previously created or requested authorization. The <ID> in the URI should contain the verification request ID (see Section 3.1.9.1.2 below) that was used for the creation of the transfer.Callback and data model information for GET /thirdPartyRequests/verifications/<ID>:
Callback – PUT /thirdPartyRequests/verifications/<ID>
Error Callback – PUT /thirdPartyRequests/verifications/<ID>/error
Data Model – Empty body
3.1.8.1.2 POST /thirdPartyRequests/verifications
Used by: DFSP
The POST /thirdPartyRequests/verifications resource is used to request confirmation from an authentication service that a challenge has been signed using the correct private key. 
Callback and data model information for POST /thirdpartyRequests/verifications:
• Callback - PUT /thirdpartyRequests/verifications /<ID>
• Error Callback - PUT /thirdpartyRequests/verifications /<ID>/error
• Data Model – See Table below
Name Cardinality Type Description
verificationRequestId 1 CorrelationId
Common ID between the DFSP and authentication service for the verification request object. The ID should be reused for resends of the same authorization request. A new ID should be generated for each new authorization request.
challenge 1 Challenge
The challenge originally sent to the PISP
value 1 authenticationValue
The signed challenge returned by the PISP.
consentId 1 CorrelationId
Common Id between the DFSP and the authentication service for the agreement against which the authentication service is to evaluate the signature

3.1.8.2 Callbacks 
This section describes the callbacks that are used by the server under the resource /thirdPartyRequests/verifications/
3.1.8.2.1 PUT /thirdPartyRequests/verifications/<ID>
Used by: FIDO
The callback PUT /thirdPartyRequests/verifications/<ID> is used to inform the client of the result of an authorization check. The <ID> in the URI should contain the authorizationRequestId (see Section 3.1.9.1.2 above) which was used to request the check, or the <ID> that was used in the GET /thirdPartyRequests/verifications/<ID>. The data model for this resource is as follows:
Name Cardinality Type Description
authorizationResponse 1 AuthenticationResponse
The result of the authorization check.
3.1.8.3 Error callbacks
This section describes the error callbacks that are used by the server under the resource /thirdPartyRequests/verifications.
3.1.8.3.1 PUT /thirdPartyRequests/verifications/<ID>/error
Used by: FIDO
If the server is unable to complete the authorization request, or another processing error occurs, the error callback PUT /thirdPartyRequests/verifications/<ID>/error is used. The <ID> in the URI should contain the <ID> that was used in the call which requested the authorization. The data model for this resource is as follows:
Name Cardinality Type Description
errorInformation 1 ErrorInformation
Error code, category description.

### 3.2 Data Models
