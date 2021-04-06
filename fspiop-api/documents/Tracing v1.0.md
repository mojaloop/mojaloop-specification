---
showToc: true
---
# Distributed Tracing Support for OpenAPI Interoperability

## _Tracing for the OpenAPI Interoperability Specification_


**Table of Content**

1. [Preface](#1-preface)

    1.1 [Conventions Used in This Document](#11-conventions-used-in-this-document)

    1.2 [Document Version Information](#12-document-version-information)

2. [Introduction](2-introduction)

    2.1 [Open API for FSP Interoperability Specification](#21-open-api-for-fsp-interoperability-specification)

3. [Tracing Specification](#3-tracing-specification)

    3.1 [Tracing Data Model](#31-tracing-data-model)

    3.2 [Generating a Trace](#32-generating-a-trace)

    3.3 [Continuing a Trace](#33-continuing-a-trace)

    3.4 [Forwarding a Trace](#34-forwarding-a-trace)

4. [Examples](#4-examples)

5. [References](#5-references)

**Table of Tables**

[Table 1 – Data model of HTTP header fields for Tracing](#table-1)

## 1. Preface

This section contains information about how to use this document.

### 1.1 Conventions Used in This Document

This document uses the notational conventions for BASE64URL(OCTETS), UTF8(STRING), ASCII(STRING), and || defined in RFC 7515<sup>[1](https://tools.ietf.org/html/rfc7515#section-1.1)</sup>.

The following conventions are used in this document to identify the specified types of information.

|Type of Information|Convention|Example|
|---|---|---|
|**Elements of the API, such as resources**|Boldface|**/authorization**|
|**Variables**|Italics within curly brackets|_{ID}_|
|**Glossary terms**|Italics on first occurrence; defined in _Glossary_|The purpose of the API is to enable interoperable financial transactions between a _Payer_ (a payer of electronic funds in a payment transaction) located in one _FSP_ (an entity that provides a digital financial service to an end user) and a _Payee_ (a recipient of electronic funds in a payment transaction) located in another FSP.|
|**Library documents**|Italics|User information should, in general, not be used by API deployments; the security measures detailed in _API Signature_ and _API Encryption_ should be used instead.|

### 1.2 Document Version Information

|Version|Date|Change Description|
|---|---|---|
|**1.0**|2021-04-01|Initial version|
| | | |

## 2. Introduction

This document details the distributed tracing standards to be supported for Open APIs for Interoperability (hereafter cited as the API) to ensure _tracing_ and _observability_ within the API system, and to/from the API clients.


**Note:** ...


## 3. Tracing Specification

This section introduces the technology used by the API signature, including the data exchange format for the signature of an API message and the mechanism used to generate and verify a signature.

### 3.1 Tracing Data Model

The [Table 1](#table-1).

**Note:** ...

###### Table 1

| Name | Cardinality | Type | Description |
| --- | --- | --- | --- |
| ... | 1 | String(1..32768) |  |
**Table 1 – Data model of HTTP header fields for Tracing**

### 3.2 Generating a Trace

To create the a trace, the following steps are performed. The order of the steps is not significant in cases where there are no dependencies between the inputs and outputs of the steps.

1. ....
  
2. ....
  


**Note:** ...

### 3.3 Continuing a Trace

When validating the signature of an API request, the following steps are performed. The order of the steps is not significant in cases where there are no dependencies between the inputs and outputs of the steps. If any of the listed steps fails, then the signature cannot be validated.

1. ...

2. ...<sup>[4](https://tools.ietf.org/html/rfc7159)</sup>.



### 3.4 Forwarding a Trace

.....

### 4. Examples

.....



## 5. References

<sup>1</sup> [https://www.w3.org/TR/trace-context-1](https://www.w3.org/TR/trace-context-1) – Trace Context - Level 1 - W3C Recommendation 06 February 2020

<sup>2</sup> [https://w3c.github.io/trace-context](https://w3c.github.io/trace-context) – Trace Context - W3C Editor's Draft
