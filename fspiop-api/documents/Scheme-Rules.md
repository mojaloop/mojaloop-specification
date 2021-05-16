---
showToc: true
---
# Scheme Rules

## _Open API for FSP Interoperability Specification_

**Table of Contents**

1. [Preface](#1-preface)

    1.1 [Conventions Used in This Document](#11-conventions-used-in-this-document)

    1.2 [Document Version Information](#12-document-version-information)

2. [Introduction](#2-introduction)

    2.1 [Open API for FSP Interoperability Specification](#2.1-open-api-for-fsp-interoperability-specification)

    2.1.1 [General Documents](#211-general-documents)

    2.1.2 [Logical Documents](#212-logical-documents)

    2.1.3 [Asynchronous REST Binding Documents](#213-asynchronous-rest-binding-documents)

    2.1.4 [Data Integrity, Confidentiality, and Non-Repudiation](#214-data-integrity,-confidentiality,-and-non-repudiation)

3. [Business Scheme Rules](#3-business-scheme-rules)

    3.1 [Authentication Type](#31-authentication-type)

    3.2 [Consumer KYC Identification Required](#32-consumer-kyc-identification-required)

    3.3 [Currency](#33-currency)

    3.4 [FSP ID Format](#34-fsp-id-format)

    3.5 [Interoperability Transaction Type](#35-interoperability-transaction-type)

    3.6 [Geo-Location Required](#36-geo-location-required)

    3.7 [Extension Parameters](#37-extension-parameters)

    3.8 [Merchant Code Format](#38-merchant-code-format)

    3.9 [Max Size Bulk Payments](#39-max-size-bulk-payments)

    3.10 [OTP Length](#310-otp-length)

    3.11 [OTP Expiration Time](#311-otp-expiration-time)

    3.12 [Party ID Types](#312-party-id-ypes)

    3.13 [Personal Identifier Types](#313-personal-identifier-types)

    3.14 [QR Code Format](#314-qr-code-format)

4. [API Implementation Scheme Rules](#4-api-implementation-scheme-rules)

    4.1 [API Version](#41-api-version)

    4.2 [HTTP or HTTPS](#42-http-or-https)

    4.3 [HTTP Timeout](#43-http-timeout)

    4.4 [Callback Timeouts](#44-callback-timeouts)

5. [Security and Non-Functional Requirements Scheme Rules](#5-security-and-non---functional-requirements-scheme-rules)

    5.1 [Clock Synchronization](#51-clock-synchronization)

    5.2 [Data Field Encryption](#52-data-field-encryption)

    5.3 [Digital Signing of Message](#53-digital-signing-of-message)

    5.4 [Digital Certificates](#54-digital-certificates)

    5.5 [Cryptographic Requirement](#55-cryptographic-requirement)

    5.6 [Communication Security](#56-communication-security)

**Table of Figures**

[Figure 1 – HTTP Timeout](#figure-1)

[Figure 2 – Callback](#figure-2)

##1 Preface

This section contains information about how to use this document.

### 1.1 Conventions Used in This Document

The following conventions are used in this document to identify the specified types of information

|Type of Information|Convention|Example|
|---|---|---|
|**Elements of the API, such as resources**|Boldface|**/authorization**|
|**Variables**|Italics within curly brackets|_{ID}_|
|**Glossary terms**|Italics on first occurrence; defined in _Glossary_|The purpose of the API is to enable interoperable financial transactions between a _Payer_ (a payer of electronic funds in a payment transaction) located in one _FSP_ (an entity that provides a digital financial service to an end user) and a _Payee_ (a recipient of electronic funds in a payment transaction) located in another FSP.|
|**Library documents**|Italics|User information should, in general, not be used by API deployments; the security measures detailed in _API Signature_ and _API Encryption_ should be used instead.|

### 1.2 Document Version Information

|Version|Date|Change Description|
|---|---|---|
|**1.0**|2018-03-13|Initial version|

##2. Introduction

This document defines scheme rules for Open API for FSP Interoperability (hereafter cited as the API) in three categories.

1. Business Scheme Rules:

    a. These business rules should be governed by FSPs and an optional regulatory authority implementing the API within a scheme.
    
    b. The regulatory authority or implementing authority should identify valid values for these business scheme rules in their API policy document.

2. API implementation Scheme Rules:

    a. These API parameters should be agreed on by FSPs and the optional Switch. These parameters should be part of the implementation policy of a scheme.

    b. All participants should configure these API parameters as indicated by the API-level scheme rules for the implementation with which they are working.

3. Security and Non-Functional Scheme Rules.

    a. Security and non-functional scheme rules should be determined and identified in the implementation policy of a scheme. 

### 2.1 Open API for FSP Interoperability Specification

The Open API for FSP Interoperability Specification includes the following documents.

#### 2.1.1 General Documents

- _Glossary_

#### 2.1.2 Logical Documents

- _Logical Data Model_

- _Generic Transaction Patterns_

- _Use Cases_

#### 2.1.3 Asynchronous REST Binding Documents

- _API Definition_

- _JSON Binding Rules_

- _Scheme Rules_

#### 2.1.4 Data Integrity, Confidentiality, and Non-Repudiation

- _PKI Best Practices_

- _Signature_

- _Encryption_

## 3. Business Scheme Rules

This section describes the business scheme rules. The data model for the parameters in this section can be found in _API Definition._

#### 3.1 Authentication Type

The authentication type scheme rule controls the authentication types OTP and QR code. It lists the various authentication types available for _Payer_ authentication. A scheme can choose to support all the authentication types mentioned in “AuthenticationTypes” in _API Definition_ or a subset thereof.

#### 3.2 Consumer KYC Identification Required

A scheme can mandate verification of consumer KYC (Know Your Customer) identification by Agent or Merchant at the time of transaction (for example, cash-out, cash-in, merchant payment). The API cannot control this scheme rule; therefore, it should be documented in scheme policy so that it is followed by all participants in a scheme. The scheme can also decide on the valid KYC proof of identification that should be accepted by all FSPs.

#### 3.3 Currency

A scheme may recommend allowing transactions in more than one currency. This scheme may define the list of valid currencies in which transactions can be performed by participants; however, this is not required. A Switch may work as transaction router and doesn’t validate the transaction currency. If a scheme does not define the list of valid currencies, then the Switch works as transaction router and the participating FSP can accept or reject the transaction based on its supported currencies. Foreign exchange is not supported; that is, the transaction currency for the Payer and the _Payee_ should be the same.

#### 3.4 FSP ID Format

A scheme may determine the format of the FSP ID. The FSP ID should be of string type. Each participant will be issued a unique FSP ID by the scheme. Each FSP should prepend the FSP ID to a merchant code (a unique identifier for a merchant) so that the merchant code is unique across all the participants (that is, across the scheme). The scheme can also determine an alternate strategy to ensure that FSP IDs and merchant codes are unique across participating FSPs.

#### 3.5 Interoperability Transaction Type 

The API supports the use cases documented in _Use Cases_. A scheme may recommend implementation of all the supported usecases or a subset thereof. A scheme may also recommend to rollout the use cases in phases. Two or more FSPs in the scheme might decide to implement additional use-cases supported by the API. A Switch may work as a transaction router and does not validate transaction type; the FSP can accept or reject the transaction based on its supported transaction types. If a participant FSP initiates a supported API transaction type due to incorrect configuration on the Payer end, then the transaction must be rejected by the peer FSP if the peer FSP doesn’t support the specific transaction type.

#### 3.6 Geo-Location Required

The API supports geolocation of the Payer and the Payee; however, this is optional. A scheme can mandate the geolocation of transactions. In this case, all participants must send the geolocation of their respective party.

#### 3.7 Extension Parameters

The API supports one or more extension parameters. A scheme can recommend that the list of extension parameters be supported. All participants must agree with the scheme rule and support the scheme-mandatory extension parameters.

#### 3.8 Merchant Code Format

The API supports merchant payment transaction. Typically, a consumer either enters or scans a merchant code to initiate merchant payment. In case of merchant payment, the merchant code should be unique across all the schemes. Currently, the merchant code is not unique in the way that mobile numbers or email addresses are unique. Therefore, it is recommended to prepend a prefix or suffix (FSP ID) to the merchant code so that the merchant code is unique across the FSPs.

#### 3.9 Max Size Bulk Payments

The API supports the Bulk Payment use-case. The scheme can define the maximum number of transactions in a bulk payment.

#### 3.10 OTP Length

The API supports One-time Password (OTP) as authentication type. A scheme can define the minimum and maximum length of OTP to be used by all FSPs.

#### 3.11 OTP Expiration Time

An OTP’s expiration time is configured by each FSP. A scheme can recommend it to be uniform for all schemes so that users from different FSPs have a uniform user experience.

#### 3.12 Party ID Types

The API supports account lookup system. An account lookup can be performed based on valid party ID types of a party. A scheme can choose which party ID types to support from **PartyIDType** in API Definition.

#### 3.13 Personal Identifier Types

A scheme can choose the valid or supported personal identifier types mentioned in **PersonalIdentifierType** in API Definition.

#### 3.14 QR Code Format

A scheme should standardize the QR code format in the following two scenarios as indicated.

##### 3.14.1 Payer-Initiated transaction

Payer scans the QR code of Payee (Merchant) to initiate a Payer-Initiated Transaction. In this case, the QR code should be standardized to include the Payee information, transaction amount, transaction type and transaction note, if any. The scheme should standardize the format of QR code for Payee.

##### 3.14.2 Payee-Initiated Transaction

Payee scans the QR code of Payer to initiate Payee-Initiated transaction. For example: Merchant scans the QR code of Payer to initiate a Merchant Payment. In this case, the QR code should be standardized to locate the Payer without using the account lookup system. The scheme should standardize the format of QR code; that is, FSP ID, Party ID Type and Payer ID, or only Party ID Type and Party ID.

## 4. API Implementation Scheme Rules

This section describes API implementation scheme rules.

#### 4.1 API Version

API version information must be included in all API calls as defined in _API Definition_. A scheme should recommend that all FSPs implement the same version of the API.

#### 4.2 HTTP or HTTPS

The API supports both HTTP and HTTPS. A scheme should recommend that the communication is secured using TLS (see [Section 5.6](#56communication-security)).

#### 4.3 HTTP Timeout

FSPs and Switch should configure HTTP timeout. If FSP doesn’t get HTTP response (either **HTTP 202** or **HTTP 200**) for the **POST** or **PUT** request then FSP should timeout. Refer to the diagram in Figure 1 for the **HTTP 202** and **HTTP 200** timeouts shown in dashed lines.

###### Figure-1

{% uml src="assets/diagrams/sequence/figure1_http-timeout.plantuml" %}
{% enduml %}

**Figure 1 – HTTP Timeout**

#### 4.4 Callback Timeouts

The FSPs and the Switch should configure callback timeouts. The callback timeouts of the initiating FSP should be greater than the callback timeout of the Switch. A scheme should determine callback timeout for the initiating FSP and the Switch. Refer to the diagram in Figure 2 for the callback timeouts highlighted in <font color="red">red</font>.

###### Figure-2

{% uml src="assets/diagrams/sequence/figure2_callback_timeout.plantuml" %}
{% enduml %}

**Figure 2 – Callback Timeout**

## 5. Security and Non-Functional Requirements Scheme Rules

This section describes the scheme rules for security, environment and other network requirements.

#### 5.1 Clock Synchronization

It is important to synchronize clocks between FSPs and Switches. It is recommended that an NTP server or servers be used for clock synchronization.

#### 5.2 Data Field Encryption

Data fields that need to be encrypted will be determined by national and local laws, and any standard that must be complied with. Encryption should follow _Encryption_.

#### 5.3 Digital Signing of Message

A scheme can decide that all messages must be signed as described in _Signature_. Response messages need not to be signed.

#### 5.4 Digital Certificates

To use the signing and encryption features detailed in _Signature_ and _Encryption_ in a scheme, FSPs and Switches must obtain digital certificates as specified by the scheme-designated _CA_ (Certificate Authority).

#### 5.5 Cryptographic Requirement

All parties must support the encoding and encryption ciphers as specified in _Encryption_, if encryption features are to be used in the scheme.

#### 5.6 Communication Security

A scheme should require that all HTTP communication between parties is secured using TLS<sup>[1](https://tools.ietf.org/html/rfc5246)</sup> version 1.2 or later.

<sup>1</sup> [https://tools.ietf.org/html/rfc5246](https://tools.ietf.org/html/rfc5246) - The Transport Layer Security (TLS) Protocol - Version 1.2
