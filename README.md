[![Git Commit](https://img.shields.io/github/last-commit/mojaloop/mojaloop-specification.svg?style=flat)](https://github.com/mojaloop/mojaloop-specification/commits/master)
[![Git Releases](https://img.shields.io/github/release/mojaloop/mojaloop-specification.svg?style=flat)](https://github.com/mojaloop/mojaloop-specification/releases)
[![CircleCI](https://circleci.com/gh/mojaloop/mojaloop-specification.svg?style=svg)](https://circleci.com/gh/mojaloop/mojaloop-specification)

# Brief overview of the Mojaloop Family of APIs

The **Mojaloop Family of APIs** is a set of several different APIs that cater for several business or transactional functions. So far, the well defined and adopted APIs are
- FSP Interoperability (FSPIOP) API
- Administration API
- Settlement API
- Third-party Payment Initiaion (3PPI/PISP) API

There are other APIs that are either in active development and design or on the roadmap
- Cross-network API (FX)
- Reporting API

## 1. FSP Interoperability API Specification
The Open API for FSP Interoperability Specification includes the following documents.

#### Logical Documents
* [Logical Data Model](#logical-data-model)
* [Generic Transaction Patterns](#generic-transaction-patterns)
* [Use Cases](#use-cases)
  
#### Asynchronous REST Binding Documents
* [API Definition](#api-definition)
* [Central Ledger API](#central-ledger-api) 
* [JSON Binding Rules](#json-binding-rules) 
* [Scheme Rules](#scheme-rules)  
  
#### Data Integrity, Confidentiality, and Non-Repudiation
* [PKI Best Practices](#pki-best-practices)  
* [Signature](#signature)  
* [Encryption](#encryption)  

### 1.1 Glossary
The [Glossary](./fspiop-api/documents/Glossary.md) provides the glossary for the Open API (Application Programming Interface) for FSP (Financial Service Provider) Interoperability (hereafter cited as **"the API"**). Terms have been compiled from three sources:
- ITU-T Digital Financial Services Focus Group Glossary (ITU-T),
- Feedback from Technology Service Providers (TSPs) in the PDP work groups (PDP) and
- Feedback from the L1P IST Reference Implementation team (RI).

Information is shared in accordance with **Creative Commons Licensing**.

### 1.2 Logical Data Model
The [Logical Data Model](./fspiop-api/documents/Logical-Data-Model.md) document specifies the logical data model used by the API. Section 2 in the document lists elements used by each service. Section 3 in the document describes the data model in terms of basic elements, simple data types and complex data types.

### 1.3 Generic Transaction Patterns
The [Generic Transaction Patterns](./fspiop-api/documents/Generic-Transaction-Patterns.md) document introduces the four generic transaction patterns that are supported in a logical version of the API. Additionally, all logical services that are part of the API are presented at a high-level.

### 1.4 Use Cases
The purpose of the [Use Cases](./fspiop-api/documents/Use-Cases.md) document is to define a set of use cases that can be implemented using the API. The use cases referenced within this document provide an overview of transaction processing flows and business rules of each transaction step as well as relevant error conditions. The primary purpose of the API is to support the movement of financial transactions between one Financial Services Provider (FSP) and another.

It should be noted that the API is only responsible for message exchange between FSPs and a Switch when a cross-FSP transaction is initiated by an End User in one of the FSPs. This can occur in either of two scenarios: 
- A bilateral scenario in which FSPs communicate with each other
- A Switch based scenario in which all communication goes through a Switch 

Reconciliation, clearing and settlement after real-time transactions is out of scope for the API. Additionally, account lookup is supported by the API, but it relies on the implementation in a local market in which a third party or Switch would provide such services. Therefore, the need for effective on-boarding processes and appropriate scheme rules must be considered when implementing use cases.

### 1.5 API Definition
The [API Definition](./fspiop-api/documents/API-Definition_v1.1.md) document introduces and describes **the FSP Interoperability API**. The purpose of the API is to enable interoperable financial transactions between a Payer (a payer of electronic funds in a payment transaction) located in one FSP (an entity that provides a digital financial service to an end user) and a Payee (a recipient of electronic funds in a payment transaction) located in another FSP. The API does not specify any front-end services between a Payer or Payee and its own FSP; all services defined in the API are between FSPs. FSPs are connected either (a) directly to each other or (b) by a Switch placed between the FSPs to route financial transactions to the correct FSP. 
The transfer of funds from a Payer to a Payee should be performed in near real-time. As soon as a financial transaction has been agreed to by both parties, it is deemed irrevocable. This means that a completed transaction cannot be reversed in the API. To reverse a transaction, a new negated refund transaction should be created from the Payee of the original transaction.  

The API is designed to be sufficiently generic to support both a wide number of use cases and extensibility of those use cases, However, it should contain sufficient detail to enable implementation in an unambiguous fashion.  
Version 1.0 of the API is designed to be used within a country or region; international remittance that requires foreign exchange is not supported. This version also contains basic support for the Interledger Protocol, which will in future versions of the API be used for supporting foreign exchange and multi-hop financial transactions.

This document:
- Defines an asynchronous REST binding of the logical API introduced in Generic Transaction Patterns.
- Adds to and builds on the information provided in Open API for FSP Interoperability Specification. The contents of the Specification are listed in Section **Open API for FSP Interoperability Specification**.

### 1.6 Scheme Rules
The [Scheme Rules](./fspiop-api/documents/Scheme-Rules.md) document defines scheme rules for Open API for FSP Interoperability (hereafter cited as the API) in three categories.
1.	Business Scheme Rules:   
a.	These business rules should be governed by FSPs and an optional regulatory authority implementing the API within a scheme.   
b.	The regulatory authority or implementing authority should identify valid values for these business scheme rules in their API policy document.   
2.	API implementation Scheme Rules:   
a.	These API parameters should be agreed on by FSPs and the optional Switch. These parameters should be part of the implementation policy of a scheme.   
b.	All participants should configure these API parameters as indicated by the API-level scheme rules for the implementation with which they are working.   
3.	Security and Non-Functional Scheme Rules.   
a.	Security and non-functional scheme rules should be determined and identified in the implementation policy of a scheme.   

### 1.7 JSON Binding Rules
The purpose of [JSON Binding Rules](./fspiop-api/documents/JSON-Binding-Rules.md) is to express the data model used by **the API** in the form of JSON Schema binding rules, along with validation rules for the corresponding instances.

This document adds to and builds on the information provided in Open API for FSP Interoperability Specification. The contents of the Specification are listed in Section 1.1.
The types used in the PDP API fall primarily into three categories:
- Basic data types and Formats used
- Element types
- Complex types

The various types used in API Definition, Data Model and the Open API Specification, as well as the JSON transformation rules to which their instances must adhere, are identified in the following sections.

### 1.8 PKI Best Practices
The [PKI Best Practices](./fspiop-api/documents/PKI-Best-Practices.md) document explains Public Key Infrastructure (PKI) best practices to apply in **the API** deployment. See Chapter 2, PKI Background, for more information about PKI. 
The API should be implemented in an environment that consists of either:
- Financial Service Providers (FSPs) that communicate with other FSPs (in a bilateral setup) or 
- A Switch that acts as an intermediary platform between FSP platforms. There is also an Account Lookup System (ALS) available to identify in which FSP an account holder is located.

For more information about the environment, see Chapter 3, Network Topology. Chapters 4 and 5 identify management strategies for the CA and for the platform. Communication between platforms is performed using a REST (REpresentational State Transfer)-based HTTP protocol (for more information, see API Definition). Because this protocol does not provide a means for ensuring either integrity or confidentiality between platforms, extra security layers must be added to protect sensitive information from alteration or exposure to unauthorized parties.

### 1.9 Signature
The [Signature](./fspiop-api/documents/Signature_v1.1.md) document details security methods to be implemented for **the API** to ensure confidentiality of API messages between an API client and the API server.

In information security, confidentiality means that information is not made available or disclosed to unauthorized individuals, entities, or processes (Excerpt [ISO27000](http://www.27000.org/)). For the API, confidentiality means that some sensitive fields in the payload of an API message cannot be accessed or identified in an unauthorized or undetected manner by the intermediaries involved in the API communication. That is, if some fields of an API message are encrypted by the API client, then only the expected API recipient can decrypt those fields.

JSON Web Encryption (JWE [RFC7516](https://tools.ietf.org/html/rfc7516)) must be applied to the API to provide message confidentiality. When an API client sends an HTTP request (such as an API request or callback message) to a counterparty, the API client can determine whether there are sensitive fields in the API message to be protected according to the regulation or local schema. If there is a field to be protected, then the API client uses JWE to encrypt the value of that field. Subsequently, the cipher text of that field will be transmitted to the counterparty.

To support encryption for multiple fields of an API message, JWE is extended in this document to adapt to the requirements of the API.

### 1.10 Encryption
The [Encryption](./fspiop-api/documents/Encryption_v1.1.md) document details the security methods to be implemented for **the API** to ensure integrity and non-repudiation between the API client and the API server.

In information security, data integrity means maintaining and assuring the accuracy and completeness of data over its entire life-cycle. For the API, data integrity means that an API message cannot be modified in an unauthorized or undetected manner by parties involved in the API communication.

In legal terms, non-repudiation means that a person intends to fulfill their obligations to a contract. It also means that one party in a transaction cannot deny having received the transaction, nor can the other party deny having sent the transaction. For the API, non-repudiation means that an API client cannot deny having sent an API message to a counterparty. JSON Web Signature (JWS), as defined in [RFC 7515](https://tools.ietf.org/html/rfc7515), must be applied to the API to provide message integrity and non-repudiation for either component fields of an API payload or the full API payload. Whenever an API client sends an API message to a counterparty, the API client should sign the message using its private key. After the counterparty receives the API message, the counterparty must validate the signature with the API client’s public key. Only the HTTP request message of an API message need to be signed, any HTTP response message of the APIs SHALL NOT be signed.   

**Note**:
- The corresponding public key should either be shared in advance with the counterparty or retrieved by the counterparty (for example, the local scheme Certificate Authority).

Because intermediary fees are not supported in the current version of the API, intermediaries involved in API message-transit may not modify the API message payload. Thus, the signature at full payload level is used to protect the integrity of the full payload of an API message from end-to-end. Regardless of how many intermediaries there are in transit, the original payload cannot be modified by the intermediaries. The final recipient of the API message must validate the signature generated by the original API client based on the message payload received.

**Notes**:
- Whether the signature needs to be validated by the intermediaries in transit is determined by the internal implementation of each intermediary or the local schema.
- In a future version of the API, intermediary fees may be supported; at that time, signature-at-field-level may also be supported. However, both features are out-of-scope for the current version (1.0) of the API.

## 2. Administration API
The Administration API includes the following documents.

### 2.1 Administration Central Ledger API

[The specification of the Central Ledger API](./admin-api/admin-api-specification-v1.0.md) introduces and describes the **Central Ledger API**. The purpose of the API is to enable Hub Operators to manage admin processes around:

- creating/activating/deactivating participants in the Hub
- adding and updating participant endpoint information
- managing participant accounts, limits, and positions
- creating Hub accounts
- performing Funds In and Funds Out operations
- creating/updating/viewing settlement models
- retrieving transfer details

## 3. Third-party Payment Initiation API
Refer to the Third-party API documentation [here](https://github.com/mojaloop/pisp/tree/master/docs) and [here](https://github.com/mojaloop/api-snippets/tree/master/thirdparty/openapi3).

## 4. Settlement API
Refer to the Third-party API documentation [here](https://docs.mojaloop.io/documentation/mojaloop-technical-overview/central-settlements/oss-settlement-fsd.html) and [here](https://github.com/mojaloop/mojaloop-specification/tree/master/settlement-api).
