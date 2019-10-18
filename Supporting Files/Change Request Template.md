# _[Change ID] – [Change Request Name]_

## Open API for FSP Interoperability - Change Request

### **Table of Contents**

* [1. Preface](#1-preface)
  * [1.1 Change Request Information](#11-change-request-information)
  * [1.2 Document Version Information](#12-document-version-information)
* [2. Problem Description](#2-problem-description)
  * [2.1 Background](#21-background)
  * [2.2 Current Behaviour](#22-current-behaviour)
  * [2.3 Requested Behaviour](#23-requested-behaviour)
* [3 Proposed Solution Options](#3-proposed-solution-options)

## **1. Preface**
___

This section contains basic information regarding the change request.

#### 1.1 Change Request Information

| Change Request ID | TEMPLATE\_1 |
| --- | --- |
| Change Request Name | Template for Change Request |
| Requested By | Henrik Karlsson, Ericsson |
| Change Request Status | In review ☒  / Approved ☐ / Rejected ☐ |
| Approved/Rejected Date |   |

#### 1.2 Document Version Information

| Version | Date | Author | Change Description |
| --- | --- | --- | --- |
| 1.0 | 2019-02-04 | Henrik Karlsson | Initial version of template. Sent out for review. |

## **2. Problem Description**
___

#### 2.1 Background

Explain the background of the change request so that others can understand the reason for the change request.

**Example** :

In order to process a **POST** message on the **/transfers** resource (hereafter referred to as the _transfer request_) correctly, the Payee FSP must be able to ascertain which **PUT** message on the **/quotes** resource (hereafter referred to as the _quote response_) was used as the authorization for the transfer request. There are two reasons for this:

1. The open fields of the transfer request do not contain all of the information which the Payee FSP needs to know in order to complete the transfer. For example, the identification of the Payee is contained in the request for quotation, but not in the open fields of the transfer request.
2. The Payee FSP needs to be able to identify which private key was used to sign the data for the quote response and produce the condition and fulfilment. Unless we insist that a FSP only ever use one private key for this task, it will be necessary to make the connection between the quote response and the transfer request. As the specification itself says in Section 6.5.1.2: &quot;The choice and cardinality of the local secret is an implementation decision that may be driven by scheme rules. The only requirement is that the Payee FSP can determine which secret that was used when the ILP Packet is received back later as part of an incoming transfer.&quot;

At present, the quote response contains an ILP packet, which contains a data field and a condition. The data field contains an encoded version of the original request for quotation, and the condition is the result of signing that data with a private key. Assuming that the Payee FSP has saved some information relating to the original request for quotation, and assuming further that this will be searchable on a unique component of the request for quotation, it would be possible for the Payee FSP to reconstitute the original request for payment and abstract the unique code from it.

However, this is not an efficient way of proceeding. This connection must be established for every transfer request, since there is no other way of knowing which private key to apply. It therefore makes good sense to provide a quick and simple way of connecting the transfer request with the quote response that was used to authorize it.

#### 2.2 Current Behaviour

Explain how the API currently behaves.

**Example** :

It is not possible to easily to link a quote from a transfer, as a decode of the ILP Packet is necessary for each incoming **POST /transfers**.

#### 2.3 Requested Behaviour

Explain how you would like the API to behave.

**Example:**

A simple way of linking a quote from transfer.

## **3. Proposed Solution Options**
___

This section does not need to be filled in. But if you already have one or more simple solution alternatives, then please describe them here. It should not be a complete solution at this stage, unless it is a very limited change request. Feel free to add any pros and cons of each solution propsosal if you have any.

**Example:**

There are several alternative ways to simplify the link to a quote from a transfer, here are some proposals:

- Add the quote ID in the **POST /transfers** request.
  - Preferable solution as you are executing on a previously accepted quote.
  - Not aligned with current version of Interledger.
- Add the transaction ID in the **POST /transfers** request, as the transaction ID is also sent in the **POST /quotes** request.
  - Not aligned with current version of Interledger.
- Force the Payer FSP to use the transaction ID as transfer ID.
  - Not aligned with how the API currently works, would introduce unwanted logic on how IDs are generated and used as a transaction is not the same as a transfer.
  - No change in the **POST /transfers** request.