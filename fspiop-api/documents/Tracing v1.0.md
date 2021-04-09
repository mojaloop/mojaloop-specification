@@ -0,0 +1,215 @@
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

[Table 1 – Data model of HTTP header fields for Tracing](#table-1-–-data-model-of-http-header-fields-for-Tracing)<br/>
[Table 2 – Data model for Tracing values](#table-2-–-data-model-for-tracing-values)<br/>
[Table 3 – Supported version-formats](#table-3-–-supported-version-formats)<br/>
[Table 4 – Data model for _tracestate_ list member values](#table-4-–-data-model-for-tracestate-list-member-values)<br/>

## 1. Preface

This section contains information about how to use this document.

### 1.1 Conventions Used in This Document

This document uses the notational conventions for **2HEXDIGLC**, **16HEXDIGLC** and **32HEXDIGLC** defined in W3C Trace Context Recommendation <sup>[1](https://www.w3.org/TR/trace-context-1/#traceparent-header-field-values)</sup>.

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

This document details the Distributed Tracing standards to be supported for the Mojaloop API Suite to ensure _tracing_ and _observability_ within the API system, and to/from API consumers.

Distributed Tracing is a method to monitor a request end-to-end from the source to the destination, including any participating actors/components that process or forward the request. This helps to pinpoint where failures and poor performance of a specific request have occurred. As such this method is well suited to a modern microservice architecture which includes distributed application components. In addition it also supports the inclusion of both API consumers which can be both internal and external (referred to as _vendors_). Vendors may participate either by continuing the trace, or forwarding the received tracing information without modification.


## 3. Tracing Specification

This section introduces Distributed Tracing from a Mojaloop context, including the header format, and the mechanisms used to generate, continue and forward traces.

### 3.1 Tracing Data Model

The [Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing) describes the trace headers fields that are optionally included in each Interoperability API request. Tables [2](#table-2-–-data-model-for-tracing-values), [3](#table-3-–-supported-version-formats), and [4](#table-4-–-data-model-for-tracestate-list-member-values) describes the associated values and properties that is contained by each of the respective trace header fields shown in [Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing).

#### **Table 1 – Data model of HTTP header fields for Tracing**

| Name | Cardinality | Type | Description | Reference |
| --- | --- | --- | --- | --- |
| traceparent | 1 | String(55) | Incoming request containing the trace information, including the _version_ and populated _version-format_ values.<br/>Format: _{version}_-_{version-format}_.<br/>Example: `00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01` | Sections _[3.2.2 traceparent Header Field Values](https://www.w3.org/TR/trace-context-1/#traceparent-header-field-values)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#traceparent-header-field-values)</sup> |
| tracestate | 0...1 | String(512), <br/>list-member-keyvalue(0...32) | Provides optional vendor-specific trace information, and support for multiple distributed traces. It should only be propagated if and only if the value contains non-empty list (max of 32) of _list-member-keyvalue_'s (Refer to [Table 4](#table-4-–-data-model-for-tracestate-list-member-values)) that are comma (`,`) separated.<br/>Format: _{list-member-keyvalue}_,_{list-member-keyvalue}_,_{list-member-keyvalue}_. If the value of the traceparent field wasn't changed before propagation, tracestate MUST NOT be modified as well. <br/>Example: `vendorname1=opaqueValue1,vendorname2=opaqueValue2` | Section _[3.3 Tracestate Header](https://www.w3.org/TR/trace-context-1/#tracestate-header)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#tracestate-header)</sup> |

Table 1 – Data model of HTTP header fields for Tracing

#### **Table 2 – Data model for Tracing values**

| Name | Cardinality | Type | Description | Reference |
| --- | --- | --- | --- | --- |
| version | 1 | 2HEXDIGLC | Version indicator for trace-format. Refer to [Table 3](#table-3-–-supported-version-formats) for supported versions. | Section _[3.2.2.1 version](https://www.w3.org/TR/trace-context-1/#version)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#version)</sup> |
| version-format | 1 | String(52) | A _dash_ (`-`) delimitated string included tracing information such as: trace-id, parent-id, trace-flags, etc. | Refer to [Table 3](#table-3-–-supported-version-formats) |
| trace-id | 1 | 32HEXDIGLC | ID representing the entire trace, i.e. the end-to-end trace identifier. | Section _[3.2.2.3 trace-id](https://www.w3.org/TR/trace-context-1/#trace-id)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#trace-id)</sup> |
| parent-id | 1 | 16HEXDIGLC | ID representing the span-id.  | Section _[3.2.2.4 parent-id](https://www.w3.org/TR/trace-context-1/#parent-id)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#parent-id)</sup> |
| trace-flags | 1 | 2HEXDIGLC | Control flags related to the trace. | Section _[3.2.2.5 trace-flags](https://www.w3.org/TR/trace-context-1/#trace-flags)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#trace-flags)</sup> |

#### **Table 3 – Supported version-formats**

| Version | Format | Regex | Reference |
| --- | --- | --- | --- |
| 00 | {trace-id}_-_{parent-id}_-_{trace-flags} | `[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{2}` | Section _[3.2.2.2 version-format](https://www.w3.org/TR/trace-context-1/#version-format)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#version-format)</sup> |

#### **Table 4 – Data model for _tracestate_ list member values**

| Name | Cardinality | Type | Description | Reference |
| --- | --- | --- | --- | --- |
| list-member-keyvalue | 1 | String(3...512) | Key-value pair joined by `=`, describing _vendor_ specific tracing information.<br/>Format: _{vendor-name}_=_{vendor-value}_<br/>Example: `vendorname1=opaqueValue1`  | Section _[3.3.1.3 list-members](https://www.w3.org/TR/trace-context-1/#list)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#list) |
| vendor-name | 1 | String(1..256) | Vendor (list-member) identifier which is printable lowercase ASCII which only includes `a-z`, `0-9`, underscores (`_`), dashes (`-`), asterisks (`*`), and forward slashes (`/`). The _FSP_ or _Hub_ identifier should be used here. | Section _[3.3.1.3.1 Key](https://www.w3.org/TR/trace-context-1/#key)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#key) |
| vendor-value | 1 | String(1..256) |  Opaque printable lowercase ASCII string excluding comma (`,`), equals (`=`), tabs, newlines, and carriage returns. | Section _[3.3.1.3.2 Value](https://www.w3.org/TR/trace-context-1/#value)_ <sup>[1](https://www.w3.org/TR/trace-context-1/#value) |

### 3.2 Creating a Trace

To create the a trace, the following steps are performed:

3.2.1. Generate the _traceparent_ ([Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing)) header with the following values:
   > 3.2.1.1. Set the _version_ ([Table 2](#table-2-–-data-model-for-tracing-values)) to `00`.<br/>
   > 3.2.1.2. Generate the _trace-id_ ([Table 2](#table-2-–-data-model-for-tracing-values)) to represent the entire end-to-end trace.<br/>
   > 3.2.1.3. Generate a _parent-id_ ([Table 2](#table-2-–-data-model-for-tracing-values)) to represent a distribute portion of the trace.<br/>
   > 3.2.2.4 Set _trace-flags_ ([Table 2](#table-2-–-data-model-for-tracing-values)) to `01` to indicate if the trace was sampled by the source, otherwise to `00`.<br/>

3.2.2. Generate the _tracestate_ header, value below is for example purposes only as it is vendor specific: 
   > 3.2.2.1. Add a _list-member-keyvalue_ ([Table 4](#table-4-–-data-model-for-tracestate-list-member-values)) with value `{vendor-name}=BASE64Encoded({parent-id})`, where _vendor-name_ ([Table 4](#table-4-–-data-model-for-tracestate-list-member-values)) is the FSP or Hub identifier and _vendor-value_ ([Table 4](#table-4-–-data-model-for-tracestate-list-member-values)) being `BASE64Encoded({parent-id})` with the operation to base64 encode the _parent-id_ ([Table 2](#table-2-–-data-model-for-tracing-values)). Base64 encoding the list member value is optional but required if its contents is not printable ASCII<sup>[1](https://www.w3.org/TR/trace-context-1/#value)</sup>.

### 3.3 Continuing a Trace

To create a trace, the following steps are performed:

3.3.1. Mutate the _traceparent_ ([Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing)) header with the following values:
   > 3.3.1.1. _version_ ([Table 2](#table-2-–-data-model-for-tracing-values)) is unchanged.<br/>
   > 3.3.1.2. _trace-id_ ([Table 2](#table-2-–-data-model-for-tracing-values)) is unchanged.<br/>
   > 3.3.1.3. Generate a _parent-id_ ([Table 2](#table-2-–-data-model-for-tracing-values)) representing a specific span (i.e. portion) of the end-to-end trace.<br/>
   > 3.3.2.4 Set _trace-flags_ ([Table 2](#table-2-–-data-model-for-tracing-values)) to `01` to indicate if the trace was sampled by the source, otherwise to `00`.<br/>

3.3.2. Mutate the _tracestate_ ([Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing)) header with the following:
   > 3.3.2.1. Add or update (if it already exists) list member `{VENDOR}=BASE64Encoded({parent-id})`, where `BASE64Encoded({string-value})` is the operation to base 64 encode the input `string-value` to the _tracestate_ header field. Ensure that the added or updated list member is inserted/moved to the front<sup>[1](https://www.w3.org/TR/trace-context-1/#value)</sup> of the list.
   > 3.3.2.1. Ensure _tracestate_ is less than 512 characters. If necessary remove the last list members until the 512 character limit has been reached <sup>[1](https://www.w3.org/TR/trace-context-1/#tracestate-limits)</sup>.

### 3.4. Forwarding a Trace

Vendors receiving trace request headers ([Table 1](#table-1-–-data-model-of-http-header-fields-for-Tracing)) do not need to participate as they are optional, but it is preferable <sup>[1](https://www.w3.org/TR/trace-context-1/#design-overview)</sup> that the trace request headers are forwarded in the outgoing request unmodified to guarantee traces are not broken.

Unmodified header propagation is typically implemented in pass-through services like proxies. As such, this behavior <sup>[1](https://www.w3.org/TR/trace-context-1/#mutating-the-traceparent-field)</sup> may also be implemented in a service which currently does not collect distributed tracing information.

### 4. Examples

#### 4.1. POST /transfers request being sent by FSP1 to FSP2 through a Mojaloop Switch

This example will result in a single end-to-end trace graph being created from `FSP1` to `FSP2` being routed through a `Mojaloop Switch` for a  **POST /transfers** linking the resulting **PUT /transfers** callback from `FSP2` to `FSP1` via the `Mojaloop Switch`.

<br/>
4.1.1. `FSP1` sends a **POST /transfers** to a `Mojaloop Switch` which includes the following generated trace information:<br/><br/>

> traceparent: `00`-`0af7651916cd43dd8448eb211c80319c`-`b7ad6b7169203331`-`01`<br/>
> tracestate: `fsp1`=`t61rcWkgMzE`<br/>

<br/>
4.1.2. The `Mojaloop Switch` receives the **POST /transfers** and responds with a `HTTP 202` accepted. The `Mojaloop Switch` continuous the trace by mutating the trace information as follows, before forwarding the the **POST /transfers** to `FSP2`:<br/><br/>

> traceparent: 00-0af7651916cd43dd8448eb211c80319c-`00f067aa0ba902b7`-01<br/>
> tracestate: `moja`=`00f067aa0ba902b7`,fsp1=t61rcWkgMzE<br/>

<br/>
4.1.3. `FSP2` receives the request  and responds with a `HTTP 202` accepted. The funds are committed and `FSP2` sends a **PUT /transfers** callback including the following mutated trace information to the `Mojaloop Switch`:<br/><br/>

> traceparent: 00-0af7651916cd43dd8448eb211c80319c-`b9c7c989f97918e1`-01<br/>
> tracestate: `fsp2`=`ucfJifl5GOE`,moja=00f067aa0ba902b7,fsp1=t61rcWkgMzE<br/>

<br/>
4.1.4. The `Mojaloop Switch` receives the **PUT /transfers** and responds with a `HTTP 200`. The `Mojaloop Switch` will reconstuct the trace from a combination of the _traceparent_ and _tracestate_ headers, generating a new _parent-id_ from the span-id contained in the list-member `moja`=`00f067aa0ba902b7`. The trace information will be mutated as follows, before forwarding the the **PUT /transfers** back to `FSP1`:<br/><br/>

> traceparent: 00-0af7651916cd43dd8448eb211c80319c-`53ce929d0e0e4736`-01<br/>
> tracestate: `moja`=`53ce929d0e0e4736`,fsp2=ucfJifl5GOE,fsp1=t61rcWkgMzE<br/>

<br/>
4.1.5. `FSP1` receives the fulfil response responding with an `HTTP 200`, and completes the transfer.

#### 4.2. POST /transfers request being sent by non-trace-participating FSP1 to non-trace-participating FSP2 through a Mojaloop Switch

This will example will result in two disparate end-to-end trace graphs being created which are NOT linked as follows:
> 4.2.a. `FSP1` to `FSP2` being routed through a `Mojaloop Switch` for a  **POST /transfers**<br/>
> 4.2.b. `FSP2` to `FSP1` being routed through a `Mojaloop Switch` for a  **PUT /transfers** callback<br/>

**Note:** As per section [3.4. Forwarding a Trace](#34-forwarding-a-trace), this scenario should not occur as `FSP2` should have forwarded the trace headers as part of the **PUT /transfers** callback to the `Mojaloop Switch`.

<br/>
4.2.1. `FSP1` sends a POST /transfers to a `Mojaloop Switch` which includes no trace information.

4.2.2. The `Mojaloop Switch` receives the POST /transfers and responds with a HTTP 202 accepted. The `Mojaloop Switch` generates a new trace as none was found in the request headers before forwarding the the POST /transfers to `FSP2`:<br/><br/>

> traceparent: `00`-`0af7651916cd43dd8448eb211c80319c`-`00f067aa0ba902b7`-`01`<br/>
> tracestate: `moja`=`00f067aa0ba902b7`<br/>

<br/>
4.2.3. `FSP2` receives the request, commits the funds and responds with a PUT /transfers callback forwarding the unmutated trace information:<br/><br/>

> traceparent: 00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01 <br/>
> tracestate: moja=00f067aa0ba902b7

<br/>
4.2.4. The `Mojaloop Switch` receives the PUT /transfers and responds with a HTTP 200. The `Mojaloop Switch` will reconstruct the trace context with the switch from a combination of the _traceparent_ and _tracestate_ headers, generating a new _parent-id_ from the span-id contained in the list-member `moja`=`00f067aa0ba902b7`. The trace information will be mutated as follows, before forwarding the the PUT /transfers back to `FSP1`:<br/><br/>

> traceparent: 00-0af7651916cd43dd8448eb211c80319c-`53ce929d0e0e4736`-01 <br/>
> tracestate: `moja`=`53ce929d0e0e4736`<br/>

<br/>
4.2.5. `FSP1` receives the **PUT /transfers** callback and responds with an `HTTP 200`.  `FSP1` then completes the transfer. The trace information is ignored as `FSP1` is not participating in the distributed trace.

## 5. References

<sup>1</sup> [https://www.w3.org/TR/trace-context-1](https://www.w3.org/TR/trace-context-1) – Trace Context - Level 1 - W3C Recommendation 06 February 2020

<sup>2</sup> [https://w3c.github.io/trace-context](https://w3c.github.io/trace-context) – Trace Context - W3C Editor's Draft
