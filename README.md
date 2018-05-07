# Open API for FSP Interoperability Specification
The Open API for FSP Interoperability Specification includes the following documents.

#### General Documents
* [Glossary](#glossary)
#### Logical Documents
* [Logical Data Model](#logical-data-model)
* [Generic Transaction Patterns](#generic-transaction-patterns)
* [Use Cases](#use-cases)
#### Asynchronous REST Binding Documents
* [API Definition](#api-definition)
* [JSON Binding Rules](#json-binding-rules)
* [Scheme Rules](#scheme-rules)
#### Data Integrity, Confidentiality, and Non-Repudiation
* [PKI Best Practices](#pki-best-practices)
* [Signature](#signature)
* [Encryption](#encryption)

## Logical Data Model
This document introduces the four generic transaction patterns that are supported in a logical version of the Interoperability API. Additionally, all logical services that are part of the API are presented on a high-level.

## Generic Transaction Patterns
This document specifies the logical data model used by Open API (Application Programming Interface) for FSP (Financial Service Provider) Interoperability (hereafter cited as "the API"). Section 2 in the document lists elements used by each service. Section 3 in the document describes the data model in terms of basic elements, simple data types and complex data types.

## API Definition
The **API Definition** document introduces and describes **the API**. The purpose of the API is to enable interoperable financial transactions between a Payer (a payer of electronic funds in a payment transaction) located in one FSP (an entity that provides a digital financial service to an end user) and a Payee (a recipient of electronic funds in a payment transaction) located in another FSP. The API does not specify any front-end services between a Payer or Payee and its own FSP; all services defined in the API are between FSPs. FSPs are connected either (a) directly to each other or (b) by a Switch placed between the FSPs to route financial transactions to the correct FSP. 
The transfer of funds from a Payer to a Payee should be performed in near real-time. As soon as a financial transaction has been agreed to by both parties, it is deemed irrevocable. This means that a completed transaction cannot be reversed in the API. To reverse a transaction, a new negated refund transaction should be created from the Payee of the original transaction.  

The API is designed to be sufficiently generic to support both a wide number of use cases and extensibility of those use cases, However, it should contain sufficient detail to enable implementation in an unambiguous fashion.  
Version 1.0 of the API is designed to be used within a country or region; international remittance that requires foreign exchange is not supported. This version also contains basic support for the Interledger Protocol, which will in future versions of the API be used for supporting foreign exchange and multi-hop financial transactions.

This document:
- Defines an asynchronous REST binding of the logical API introduced in Generic Transaction Patterns.
- Adds to and builds on the information provided in Open API for FSP Interoperability Specification. The contents of the Specification are listed in Section **Open API for FSP Interoperability Specification**.

## JSON Binding Rules
The purpose of this document is to express the data model used by **the API** in the form of JSON Schema binding rules, along with validation rules for the corresponding instances.

This document adds to and builds on the information provided in Open API for FSP Interoperability Specification. The contents of the Specification are listed in Section 1.1.
The types used in the PDP API fall primarily into three categories:
- Basic data types and Formats used
- Element types
- Complex types

The various types used in API Definition, Data Model and the Open API Specification, as well as the JSON transformation rules to which their instances must adhere, are identified in the following sections.

## PKI Best Practices
This document explains Public Key Infrastructure (PKI)  best practices to apply in **the API** deployment. See Chapter 2, PKI Background, for more information about PKI. 
The API should be implemented in an environment that consists of either:
- Financial Service Providers (FSPs) that communicate with other FSPs (in a bilateral setup) or 
- A Switch that acts as an intermediary platform between FSP platforms. There is also an Account Lookup System (ALS) available to identify in which FSP an account holder is located.

For more information about the environment, see Chapter 3, Network Topology. Chapters 4 and 5 identify management strategies for the CA and for the platform. Communication between platforms is performed using a REST (REpresentational State Transfer)-based HTTP protocol (for more information, see API Definition). Because this protocol does not provide a means for ensuring either integrity or confidentiality between platforms, extra security layers must be added to protect sensitive information from alteration or exposure to unauthorized parties.
