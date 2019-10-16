---
id: APIDefinition
title: API Definition
---
___
**Title:**  API Definition

**Draft:**  Version 1.0

**Last Modified:**  2018-11-01
___

# API Definition

## Open API for FSP Interoperability Specification

## Table of Contents

- [Table of Figures](#table-of-figures)
- [Table of Tables](#table-of-tables)
- [Table of Listings](#table-of-listings)

1. [Preface](#1-preface)
   - [Conventions Used in This Document](#conventions-used-in-this-document)
   - [Document Version Information](#document-version-information)

2. [Introduction](#2-introduction)
   - [Open API for FSP Interoperability Specification](#21-open-api-for-fsp-interoperability-specification)

3. [API Definition](#3-api-definition)
   - [General Characteristics](#31-general-characteristics)
   - [HTTP Details](#32-http-details)
   - [API Versioning](#33-api-versioning)

4. [Interledger Protocol](#4-interledger-protocol)
   - [More Information](#41-more-information)
   - [Introduction to Interledger](#42-introduction-to-interledger)
   - [ILP Addressing](#43-ilp-addressing)
   - [Conditional Transfers](#44-conditional-transfers)
   - [ILP Packet](#45-ilp-packet)

### Table of Figures

   - [Figure 1 -- HTTP POST call flow](#figure-1)
   - [Figure 2 -- HTTP GET call flow](#figure-2)
   - [Figure 3 -- HTTP DELETE call flow](#figure-3)
   - [Figure 4 -- Using the customized HTTP header fields FSPIOP-Destination and FSPIOP-Source](#figure-4)
   - [Figure 5 -- Example scenario where FSPIOP-Destination is unknown by FSP](#figure-5)

### Table of Tables

   - [Table 1 -- HTTP request header fields](#table-1)
   - [Table 2 -- HTTP response header fields](#table-2)
   - [Table 3 -- HTTP response status codes supported in the API](#table-3)
   - [Table 4 -- ILP address examples](#table-4)

### Table of Listings

   - [Listing 1 -- Generic URI format](#listing-1)
   - [Listing 2 -- Example URI containing several key-value pairs in the query string](#listing-2)
   - [Listing 3 -- HTTP Accept header example, requesting version 1 or the latest supported version](#listing-3)
   - [Listing 4 -- Content-Type HTTP header field example](#listing-4)
   - [Listing 5 -- Example error message when server does not support the requested version](#listing-5)
   - [Listing 6 -- The ILP Packet format in ASN.1 format](#listing-6)

## 1. Preface

This section contains information about how to use this document.

### Conventions Used in This Document

The following conventions are used in this document to identify the
specified types of information.

|Type of Information|Convention|Example|
|---|---|---|
|**Elements of the API, such as resources**|Boldface|**/authorization**|
|**Variables**|Italics with in angle brackets|<i>\<ID\></i>|
|**Glossary terms**|Italics on first occurrence; defined in _Glossary_|The purpose of the API is to enable interoperable financial transactions between a _Payer_ (a payer of electronic funds in a payment transaction) located in one _FSP_ (an entity that provides a digital financial service to an end user) and a _Payee_ (a recipient of electronic funds in a payment transaction) located in another FSP.|
|**Library documents**|Italics|User information should, in general, not be used by API deployments; the security measures detailed in _API Signature and API Encryption_ should be used instead.|

### Document Version Information

|Version|Date|Change Description|
|---|---|---|
|**1.0**|2018-03-13|Initial version|


## 2. Introduction

This document introduces and describes the *Open API* (Application Programming Interface) *for FSP* (Financial Service Provider) *Interoperability* (hereafter cited as "the API"). The purpose of the API is to enable interoperable financial transactions between a *Payer* (a payer of electronic funds in a payment transaction) located in one *FSP* (an entity that provides a digital financial service to an end user) and a *Payee* (a recipient of electronic funds in a payment transaction) located in another FSP. The API does not specify any front-end services between a Payer or Payee and its own FSP; all services defined in the API are between FSPs. FSPs are connected either (a) directly to each other or (b) by a *Switch* placed between the FSPs to route financial transactions to the correct FSP.

The transfer of funds from a Payer to a Payee should be performed in near real-time. As soon as a financial transaction has been agreed to by both parties, it is deemed irrevocable. This means that a completed transaction cannot be reversed in the API. To reverse a transaction, a new negated refund transaction should be created from the Payee of the original transaction.

The API is designed to be sufficiently generic to support both a wide number of use cases and extensibility of those use cases, However, it should contain sufficient detail to enable implementation in an unambiguous fashion.

Version 1.0 of the API is designed to be used within a country or region, international remittance that requires foreign exchange is not supported. This version also contains basic support for the [Interledger Protocol,]() which will in future versions of the API be used for supporting foreign exchange and multi-hop financial transactions.

This document:

- Defines an asynchronous REST binding of the logical API introduced in *Generic Transaction Patterns*.

- Adds to and builds on the information provided in *Open API for FSP Interoperability Specification.* The contents of the Specification are listed in Section [2.1.](#21-open-api-for-fsp-interoperability-specification)

### 2.1 Open API for FSP Interoperability Specification

The Open API for FSP Interoperability Specification includes the following documents.

#### 2.1.1 General Documents

- *Glossary*

#### 2.1.2 Logical Documents

- *Logical Data Model*
- *Generic Transaction Patterns*
- *Use Cases*

#### 2.1.3 Asynchronous REST Binding Documents

- *API Definition*
- *JSON Binding Rules*
- *Scheme Rules*

#### 2.1.4 Data Integrity, Confidentiality, and Non-Repudiation

- *PKI Best Practices*
- *Signature*
- *Encryption*


## 3. API Definition

This section introduces the technology used by the API, including:

- [General Characteristics](#31-general-characteristics)
- [HTTP Details](#32-http-details)
- [API Versioning](#33-api-versioning)

### 3.1 General Characteristics

This section describes the general characteristics of the API.

#### 3.1.1 Architectural Style

The API is based on the REST (REpresentational State Transfer<sup>1</sup>) architectural style. There are, however, some differences between a typical REST implementation and this one. These differences include:

- **Fully asynchronous API** -- To be able to handle numerous concurrent long-running processes and to have a single mechanism for handling requests, all API services are asynchronous. Examples of long-running processes are:
  - Financial transactions done in bulk
  - A financial transaction in which user interaction is needed
-   **Decentralized** -- Services are decentralized, there is no central authority which drives a transaction.
-   **Service-oriented** -- The resources provided by the API are relatively service-oriented compared to a typical implementation of a REST-based API.

-   **Not fully stateless** -- Some state information must be kept in both client and server during the process of performing a financial transaction.

-   **Client decides common ID** -- In a typical REST implementation, in which there is a clear distinction between client and server, it is the server that generates the ID of an object when the object is created on the server. In this API, a quote or a financial transaction resides both in the Payer and Payee FSP as the services are decentralized. Therefore, there is a need for a common ID of the object. The reason for having the client decide the common ID is two-fold:
  - The common ID is used in the URI of the asynchronous callback to the client. The client therefore knows which URI to listen to for a callback regarding the request.
  - The client can use the common ID in an HTTP **GET** request directly if it does not receive a callback from the server (see Section [3.2.2](#322-http-methods) for more information).

  To keep the common IDs unique, each common ID is defined as a UUID (Universally Unique IDentifier<sup>2</sup> (UUID). To further guarantee uniqueness, it is recommended that a server should separate each client FSP's IDs by mapping the FSP ID and the object ID together. If a server still receives a non-unique common ID during an HTTP **POST** request (see Section [3.2.2](#322-http-methods) for more details). The request should be handled as detailed in Section [3.2.5.](#325-idempotent-services-in-server)

#### 3.1.2 Application-Level Protocol

HTTP, as defined in RFC 7230<sup>3</sup>, is used as the application-level protocol in the API. All communication in production environments should be secured using HTTPS (HTTP over TLS<sup>4</sup>). For more details about the use of HTTP in the API, see Section [3.2.](#32-http-details)

#### 3.1.3 URI Syntax

The syntax of URIs follows RFC 3986<sup>5</sup> to identify resources and services provided by the API. This section introduces and notes implementation subjects specific to each syntax part.

A generic URI has the form shown in [Listing 1,](#listing-1) where the part \[*user:password@*\]*host*\[*:port*\] is the Authority part described in Section [3.1.3.2.](#3132-authority)
\<*resource*\>
##### Listing 1
```text
scheme:[//[user:password@]host[:port]][/]path[?query][#fragment]
```
**Generic URI format**

##### 3.1.3.1 Scheme

In accordance with Section [3.1.2,](#312-application-level-protocol) the *scheme* (that is, the set of rules, practices and standards necessary for the functioning of payment services) will always be either **http** or **https**.

##### 3.1.3.2 Authority

The authority part consists of an optional authentication (User Information) part, a mandatory host part, followed by an optional port number.

###### 3.1.3.2.1 User Information

User information should in general not be used by API deployments; the security measures detailed in *API Signature* and *API* *Encryption* should be used instead.

###### 3.1.3.2.2 Host

The host is the server's address. It can be either an IP address or a hostname. The host will (usually) differ for each deployment.

###### 3.1.3.2.3 Port

The port number is optional; by default, the HTTP port is **80** and HTTPS is **443**, but other ports could also be used. Which port to use might differ from deployment to deployment.

##### 3.1.3.3 Path

The path points to an actual API resource or service. The resources in the API are:

- **participants**
- **parties**
- **quotes**
- **transactionRequests**
- **authorizations**
- **transfers**
- **transactions**
- **bulkQuotes**
- **bulkTransfers**

All resources found above are also organized further in a hierarchical form, separated by one or more forward slashes (**'/'**). Resources support different services depending on the HTTP method used. All supported API resources and services, tabulated with URI and HTTP method, appear in [Table 5.](#table-5)

##### 3.1.3.4 Query

The query is an optional part of a URI; it is currently only used and supported by a few services in the API. See the API resources in Section [6, API Services,]() for more details about which services support query strings. All other services should ignore the query string part of the URI, as query strings may be added in future minor versions of the API (see Section [3.3.2)](#322-http-methods).

If more than one key-value pair is used in the query string, the pairs should be separated by an ampersand symbol (**'&'**).

[Listing 2](#listing-2) shows a URI example from the API resource **/authorization**, in which four different key-value pairs are present in the query string, separated by an ampersand symbol.
##### Listing 2
```text
/authorization/3d492671-b7af-4f3f-88de-76169b1bdf88?authenticationType=OTP&retriesLeft=2&amount=102&currency=USD
```
**Example URI containing several key-value pairs in the query string**

##### 3.1.3.5 Fragment

The fragment is an optional part of a URI. It is not supported for use by any service in the API and therefore should be ignored if received.

#### 3.1.4 URI Normalization and Comparison

As specified in RFC 7230<sup>6</sup>, the scheme (Section [3.1.3.1)](#3131-scheme) and host (Section [3.1.3.2.2)](#31322-host) part of the URI should be considered case-insensitive. All other parts of the URI should be processed in a case-sensitive manner.

#### 3.1.5 Character Set

The character set should always be assumed to be UTF-8, defined in 3629<sup>7</sup>; therefore, it does not need to be sent in any of the HTTP header fields (see Section [3.2.1)](#321-http-header-fields). No character set other than UTF-8 is supported by the API.

#### 3.1.6 Data Exchange Format

The API uses JSON (JavaScript Object Notation), defined in RFC 7159<sup>8</sup>, as its data exchange format. JSON is an open, lightweight, human-readable and platform-independent format, well-suited for interchanging data between systems.

### 3.2 HTTP Details

This section contains detailed information regarding the use of the application-level protocol HTTP in the API.

#### 3.2.1 HTTP Header Fields

HTTP Headers are generally described in RFC 7230<sup>9</sup>. The following two sections describes the HTTP header fields that should be expected and implemented in the API.

The API supports a maximum size of 65536 bytes (64 Kilobytes) in the HTTP header.

##### 3.2.1.1 HTTP Request Header Fields

[Table 1](#table-1) contains the HTTP request header fields that must be supported by implementers of the API. An implementation should also expect other standard and non-standard HTTP request header fields not listed here.

##### Table 1

|Field|Example Values|Cardinality|Description|
|---|---|---|---|
|**Accept**|**application/vnd.interoperability.resource+json**|<p>0..1</p><p>Mandatory in a request from a client. Not used in a callback from the server.</p>|The **Accept**<sup>10</sup> header field indicates the version of the API the client would like the server to use. See HTTP Accept Header (Section 3.3.4.1) for more information on requesting a specific version of the API.|
|**Content-Length**|**3495**|0..1|<p>The <strong>Content-Type</strong><sup>11</sup> header field indicates the anticipated size of the payload body. Only sent if there is a body.</p><p><strong>Note</strong>: The API supports a maximum size of 5242880 bytes (5 Megabytes).</p>|
|**Content-Type**|**application/vnd.interoperability.resource+json;version=1.0**|1|The **Content-Type**<sup>12</sup>] header indicates the specific version of the API used to send the payload body. See Section 3.3.4.2 for more information.|
|**Date**|**Tue, 15 Nov 1994 08:12:31 GMT**|1|The **Date**<sup>13</sup> header field indicates the date when the request was sent.|
|**X- Forwarded- For**|**X-Forwarded-For: 192.168.0.4, 136.225.27.13**|1..0|<p>The <strong>X-Forwarded-For</strong><sup>14</sup> header field is an unofficially accepted standard used to indicate the originating client IP address for informational purposes, as a request might pass multiple proxies, firewalls, and so on. Multiple <strong>X-Forwarded-For</strong> values as in the example shown here should be expected and supported by implementers of the API.</p><p>**Note**: An alternative to **X-Forwarded-For** is defined in RFC 7239<sup>15</sup>. However, as of 2018, RFC 7239 is less-used and supported than **X-Forwarded-For**.|
|**FSPIOP- Source**|**FSP321**|1|The **FSPIOP-Source** header field is a non- HTTP standard field used by the API for identifying the sender of the HTTP request. The field should be set by the original sender of the request. Required for routing (see Section 3.2.3.5) and signature verification (see header field **FSPIOP-Signature**).|
|**FSPIOP- Destination**|**FSP123**|0..1|The **FSPIOP-Destination** header field is a non-HTTP standard field used by the API for HTTP header-based routing of requests and responses to the destination. The field should be set by the original sender of the request (if known), so that any entities between the client and the server do not need to parse the payload for routing purposes (see Section 3.2.3.5).|
|**FSPIOP- Encryption**||0..1|<p>The <strong>FSPIOP-Encryption</strong.> header field is a non-HTTP standard field used by the API for applying end-to-end encryption of the request.</p><p>For more information, see API Encryption.</p>|
|**FSPIOP- Signature**||0..1|<p>The <strong>FSPIOP-Signature</strong> header field is a non-HTTP standard field used by the API for applying an end-to-end request signature.</p><p>For more information, see API Signature.</p>|
|**FSPIOP-URI**|**/parties/msisdn/123456789**|0..1|The **FSPIOP-URI** header field is a non- HTTP standard field used by the API for signature verification, should contain the service URI. Required if signature verification is used, for more information see _API Signature_.|
|**FSPIOP- HTTP- Method**|**GET**|0..1|The **FSPIOP-HTTP-Method** header field is a non-HTTP standard field used by the API for signature verification, should contain the service HTTP method. Required if signature verification is used, for more information see API Signature.|

**HTTP request header fields**

##### 3.2.1.2 HTTP Response Header Fields

[Table 2](#table-2) contains the HTTP response header fields that must be supported by implementers of the API. An implementation should also expect other standard and non-standard HTTP response header fields that are not listed here.

##### Table 2

|Field|Example Values|Cardinality|Description|
|---|---|---|---|
|**Content-Lenght**|**3495**|0..1|The **Content-Length**<sup>16</sup> header field indicates the anticipated size of the payload body. Only sent if there is a body.|
|**Content-Type**|**application/vnd.interoperability.resource+json;version=1.0**|1|The **Content-Type**<sup>17</sup> header field indicates the specific version of the API used to send the payload body. See Section 3.3.4.2 for more information.|

**HTTP response header fields**

#### 3.2.2 HTTP Methods

The following HTTP methods, as defined in RFC 7231<sup>18</sup>, are supported by the API:

- **GET** -- The HTTP **GET** method is used from a client to request information about a previously-created object on a server. As all services in the API are asynchronous, the response to the **GET** method will not contain the requested object. The requested object will instead come as part of a callback using the HTTP **PUT** method.

- **PUT** -- The HTTP **PUT** method is used as a callback to a previously sent HTTP **GET**, HTTP **POST** or HTTP **DELETE** method, sent from a server to its client. The callback will contain either:

  - Object information concerning a previously created object (HTTP **POST**) or sent information request (HTTP **GET**).
  - Acknowledgement that whether an object was deleted (HTTP **DELETE**).
  - Error information in case the HTTP **POST** or HTTP **GET** request failed to be processed on the server.

- **POST** -- The HTTP **POST** method is used from a client to request an object to be created on the server. As all services in the API are asynchronous, the response to the **POST** method will not contain the created object. The created object will instead come as part of a callback using the HTTP **PUT** method.

- **DELETE** -- The HTTP **DELETE** method is used from a client to request an object to be deleted on the server. The HTTP **DELETE** method should only be supported in a common Account Lookup System (ALS) for deleting information regarding a previously added Party (an account holder in a FSP), no other object types can be deleted. As all services in the API are asynchronous, the response to the HTTP **DELETE** method will not contain the final acknowledgement that the object was deleted or not; the final acknowledgement will come as a callback using the HTTP PUT method.

#### 3.2.3 HTTP Sequence Flow

All the sequences and related services use an asynchronous call flow. No service supports a synchronous call flow.

##### 3.2.3.1 HTTP POST Call Flow

[Figure 1](#figure-1) shows the normal API call flow for a request to create an object in a Peer FSP using HTTP **POST**. The service ***/service*** in the flow should be renamed to any of the services in [Table 5]() that support the HTTP **POST** method.

##### Figure 1

{% uml src="assets/diagrams/sequence/figure1.plantuml" %}
{% enduml %}

**HTTP POST call flow**

##### 3.2.3.2 HTTP GET Call Flow

[Figure 2](#figure-2) shows the normal API call flow for a request to get information about an object in a Peer FSP using HTTP **GET**. The service **/service/**<i>\<ID\></i> in the flow should be renamed to any of the services in [Table 5]() that supports the HTTP **GET** method.

##### Figure 2

{% uml src="assets/diagrams/sequence/figure2.plantuml" %}
{% enduml %}

**HTTP GET call flow**

##### 3.2.3.3 HTTP DELETE Call Flow

[Figure 3](#figure-3) contains the normal API call flow to delete FSP information about a Party in an ALS using HTTP **DELETE**. The service **/service/**<i>\<ID\></i> in the flow should be renamed to any of the services in [Table 5]() that supports the HTTP DELETE method. HTTP DELETE is only supported in a common ALS, which is why the figure shows the ALS entity as a server only.

##### Figure 3

{% uml src="assets/diagrams/sequence/figure3.plantuml" %}
{% enduml %}

**HTTP DELETE call flow**

**Note:** It is also possible that requests to the ALS be routed through a Switch, or that the ALS and the Switch are the same server.

**3.2.3.4 HTTP PUT Call Flow**

The HTTP **PUT** is always used as a callback to either a **POST** service request, a **GET** service request, or a **DELETE** service request.

The call flow of a **PUT** request and response can be seen in [Figure 1,](#figure-1) [Figure 2,](#figure-2) and [Figure 3.](#figure-3)

##### 3.2.3.5 Call Flow Routing using FSPIOP-Destination and FSPIOP-Source

The non-standard HTTP header fields **FSPIOP-Destination** and **FSPIOP-Source** are used for routing and message signature verification purposes (see *API Signature* for more information regarding signature verification). [Figure 4](#figure-4) shows how the header fields are used for routing in an abstract **POST /service** call flow, where the destination (Peer) FSP is known.

##### Figure 4

{% uml src="assets/diagrams/sequence/figure4.plantuml" %}
{% enduml %}

**Using the customized HTTP header fields FSPIOP-Destination and FSPIOP-Source**

For some services when a Switch is used, the destination FSP might be unknown. An example of this scenario is when an FSP sends a **GET /parties** to the Switch without knowing which Peer FSP that owns the Party (see Section [6.3.1]() describing the scenario). **FSPIOP-Destination** will in that case be empty (or set to the Switch's ID) from the FSP, but will subsequently be set by the Switch to the correct Peer FSP. See [Figure 5](#figure-5) for an example describing the usage of **FSPIOP-Destination** and **FSPIOP-Source**.

##### Figure 5

{% uml src="assets/diagrams/sequence/figure5.plantuml" %}
{% enduml %}

**Example scenario where FSPIOP-Destination is unknown by FSP**

#### 3.2.4 HTTP Response Status Codes

The API supports the HTTP response status codes<sup>19</sup> in [Table 3.](#table-3)

##### Table 3

|Status Code|Reason|Description|
|---|---|---|
|**200**|OK|Standard response for a successful request. Used in the API by the client as a response on a callback to mark the completion of an asynchronous service.|
|**202**|Accepted|The request has been accepted for future processing at the server, but the server cannot guarantee that the outcome of the request will be successful. Used in the API to acknowledge that the server has received an asynchronous request.|
|**400**| Bad Request|The application cannot process the request; for example, due to malformed syntax or the payload exceeded size restrictions.|
|**401**|Unauthorized|The request requires authentication in order to be processed.|
|**403**|Forbidden|The request was denied and will be denied in the future.|
|**404**|Not Found|The resource specified in the URI was not found.|
|**405**|Method Not Allowed|An unsupported HTTP method for the request was used; see Table 5 for information on which HTTP methods are allowed in which services.|
|**406**|Not acceptable|The server is not capable of generating content according to the Accept headers sent in the request. Used in the API to indicate that the server does not support the version that the client is requesting.|
|**501**|Not Implemented|The server does not support the requested service. The client should not retry.|
|**503**|Service Unavailable|The server is currently unavailable to accept any new service requests. This should be a temporary state, and the client should retry within a reasonable time frame.|

 **HTTP response status codes supported in the API**

Any HTTP status codes 3*xx*<sup>20</sup> returned by the server should not be retried and require manual investigation.

An implementation of the API should also be capable of handling other errors not defined above as the request could potentially be routed through proxy servers.

As all requests in the API are asynchronous, additional HTTP error codes for server errors (error codes starting with 5*xx*<sup>21</sup> that are *not* defined in [Table 3)](#table-3) are not used by the API itself. Any error on the server during actual processing of a request will be sent as part of an error callback to the client (see Section [9.2)]().

##### 3.2.4.1 Error Information in HTTP Response

In addition to the HTTP response code, all HTTP error responses (4*xx* and 5*xx* status codes) can optionally contain an [**ErrorInformation**]() element, defined in Section [7.4.2.]() This element should be used to give more detailed information to the client if possible.

#### 3.2.5 Idempotent Services in Server

All services that support HTTP **GET** must be _idempotent_; that is, the same request can be sent from a client any number of times without changing the object on the server. The server is allowed to change the state of the object; for example, a transaction state can be changed, but the FSP sending the **GET** request cannot change the state.

All services that support HTTP **POST** must be idempotent in case the client is sending the same service ID again; that is, the server must not create a new service object if a client sends the same **POST** request again. The reason behind this is to simplify the handling of resends during error-handling in a client; however, this creates some extra requirements of the server that receives the request. An example in which the same **POST** request is sent several times can be seen in Section [9.4.]()

##### 3.2.5.1 Duplicate Analysis in Server on Receiving a HTTP POST Request

When a server receives a request from a client, the server should check to determine if there is an already-existing service object with the same ID; for example, if a client has previously sent the request **POST /transfers** with the identical **transferId**. If the object already exists, the server must check to determine if the parameters of the already-created object match the parameters from the new request.

- If the previously-created object matches the parameter from the new request, the request should be assumed to be a resend from the client.

  - If the server has not finished processing the old request and therefore has not yet sent the callback to the client, this new request can be ignored, because a callback is about to be sent to the client.
  - If the server has finished processing the old request and a callback has already been sent, a new callback should be sent to the client, similar to if a HTTP **GET** request had been sent.

- If the previously-created object does not match the parameters from the new request, an error callback should be sent to the client explaining that an object with the provided ID already exists with conflicting parameters.

To simplify duplicate analysis, it is recommended to create and store a hash value of all incoming **POST** requests on the server, so that it is easy to compare the hash value against later incoming **POST** requests.

### 3.3 API Versioning

The strategy of the development of the API is to maintain backwards compatibility between the API and its resources and services to the maximum extent possible; however, changes to the API should be expected by implementing parties. Versioning of the API is specific to the API resource (for example, **/participants**, **/quotes**, **/transfers**).

There are two types of API resource versions: *Minor* versions, which are backwards-compatible, and *major* versions, which are backwards-incompatible.

- Whenever a change in this document defining the characteristics of the API is updated that in some way affects an API service, the affected resource will be updated to a new major or minor version (depending on whether the changes are backwards-compatible or not).

- Whenever a change is made to a specific service in the API, a new version of the corresponding resource will be released.

The format of the resource version is _x_._y_ where _x_ is the major version and _y_ is the minor version. Both major and minor versions are sequentially numbered. When a new major version of a service is released, the minor version is reset to **0**. The initial version of each resource in the API is **1.0**.

#### 3.3.1 Changes not Affecting the API Resource Version

Some changes will not affect the API resource version; for example, if the order of parameters within a request or callback were to be changed.

#### 3.3.2 Minor API Resource Version

The following list describes the changes that are considered backwards compatible if the change affects any API service connected to a resource. API implementers should implement their client/server in such a way that the API services automatically support these changes without breaking any functionality.

- Optional input parameters such as query strings added in a request
- Optional parameters added in a request or a callback
- Error codes added

These types of changes affect the minor API service version.

#### 3.3.3 Major API Resource Versions

The following list describes the changes that are considered backwards-incompatible if the change affects any API service connected to a resource. API implementers do *not* need to implement their client/server in such a way that it automatically supports these changes.

- Mandatory parameters removed or added to a request or callback
- Optional parameters changed to mandatory in a request or callback
- Parameters renamed
- Data types changed
- Business logic of API resource or connected services changed
- API resource/service URIs changed

These types of changes affect the major API service version. Please note that the list is not comprehensive; there might be other changes as well that could affect the major API service version.

#### 3.3.4 Version Negotiation between Client and Server

The API supports basic version negotiation by using HTTP content negotiation between the server and the client. A client should send the API resource version that it would like to use in the **Accept** header to the server (see Section [3.3.4.1)](#3341-http-accept-header). If the server supports that version, it should use that version in the callback (see Section [3.3.4.2)](#3342-acceptable-version-requested-by-client). If the server does not support the requested version, the server should reply with HTTP status 406<sup>22</sup> including a list of supported versions (see Section [3.3.4.3)](#3343-non-acceptable-version-requested-by-client).

#### 3.3.4.1 HTTP Accept Header

See below for an example of a simplified HTTP request which only includes an **Accept** header<sup>23</sup>. The **Accept** header should be used from a client requesting a service from a server specifying a major version of the API service. The example in [Listing 3](#listing-3) should be interpreted as "I would like to use major version 1 of the API resource, but if that version is not supported by the server then give me the latest supported version".

##### Listing 3
```
POST /service HTTP/1.1
Accept: application/vnd.interoperability.\<*resource*\>+json;version=1,
application/vnd.interoperability.\<*resource*\>+json

{
    ...
}
```
**HTTP Accept header example, requesting version 1 or the latest supported version**

Regarding the example in [Listing 3:](#listing-3)

- The ***POST /service*** should be changed to any HTTP method and related service or resource that is supported by the API (see [Table 5)](#table-5).
- The **Accept** header field is used to indicate the API resource version the client would like to use. If several versions are supported by the client, more than one version can be requested separated by a comma (**,**) as in the example above.
  - The application type is always **application/vnd.interoperability.**\<*resource*\>, where \<*resource\>* is the actual resource (for example, **participants** or **quotes**).
  - The only data exchange format currently supported is **json**.
  - If a client can use any minor version of a major version, only the major version should be sent; for example, **version=1** or **version=2**.
  - If a client would like to use a specific minor version, this should be indicated by using the specific *major.minor* version; for example, **version=1.2** or **version=2.8**. The use of a specific *major.minor* version in the request should generally be avoided, as minor versions should be backwards-compatible.

#### 3.3.4.2 Acceptable Version Requested by Client

If the server supports the API resource version requested by the client in the Accept Headers, it should use that version in the subsequent callback. The used *major.minor* version should always be indicated in the **Content-Type** header by the server, even if the client only requested a major version of the API. See the example in [Listing 4,](#listing-4) which indicates that version 1.0 is used by the server:

##### Listing 4
```
Content-Type: application/vnd.interoperability.resource+json;version=1.0
```
**Content-Type HTTP header field example**

##### 3.3.4.3 Non-Acceptable Version Requested by Client

If the server does not support the version requested by the client in the **Accept** header, the server should reply with HTTP status 406, which indicates that the requested version is not supported.

**Note:** There is also a possibility that the information might be sent as part of an error callback to a client instead of directly in the response; for example, when the request is routed through a Switch which does support the requested version, but the destination FSP does not support the requested version.

Along with HTTP status 406, the supported versions should be listed as part of the error message in the extensions list, using the major version number as *key* and minor version number as *value*. Please see error information in the example in [Listing 5,](#listing-5) describing the server's supported versions. The example should be interpreted as "I do not support the resource version that you requested, but I do support versions 1.0, 2.1, and 4.2".

##### Listing 5
```json
{
    "errorInformation": {
        "errorCode": "3001",
        "errorDescription": "The Client requested an unsupported version, see exten-
sion list for supported version(s).",
        "extensionList": [
            { "key": "1", "value": "0"},
            { "key": "2", "value": "1"},
            { "key": "4", "value": "2"},
        ]
    }
}
```
**Example error message when server does not support the requested version**

<sup>1</sup>  [http://www.ics.uci.edu/\~fielding/pubs/dissertation/rest\_arch\_style.htm](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm) -- Representational State Transfer (REST)

<sup>2</sup>  [https://tools.ietf.org/html/rfc4122](https://tools.ietf.org/html/rfc4122) -- A Universally Unique IDentifier (UUID) URN Namespace

<sup>3</sup>  [https://tools.ietf.org/html/rfc7230](https://tools.ietf.org/html/rfc7230) -- Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing

<sup>4</sup>  [https://tools.ietf.org/html/rfc5246](https://tools.ietf.org/html/rfc5246) -- The Transport Layer Security (TLS) Protocol - Version 1.2

<sup>5</sup>  [https://tools.ietf.org/html/rfc3986](https://tools.ietf.org/html/rfc3986) -- Uniform Resource Identifier (URI): Generic Syntax

<sup>6</sup>  [https://tools.ietf.org/html/rfc7230\#section-2.7.3](https://tools.ietf.org/html/rfc7230#section-2.7.3) -- Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing - http and https URI Normalization and Comparison

<sup>7</sup>  [https://tools.ietf.org/html/rfc3629](https://tools.ietf.org/html/rfc3629) -- UTF-8, a transformation format of ISO 10646

<sup>8</sup>  [https://tools.ietf.org/html/rfc7159](https://tools.ietf.org/html/rfc7159) -- The JavaScript Object Notation (JSON) Data Interchange Format

<sup>9</sup>  [https://tools.ietf.org/html/rfc7230\#section-3.2](https://tools.ietf.org/html/rfc7230#section-3.2) -- Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing - Header Fields

<sup>10</sup>  [https://tools.ietf.org/html/rfc7231\#section-5.3.2](https://tools.ietf.org/html/rfc7231#section-5.3.2) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content - Accept

<sup>11</sup>  [https://tools.ietf.org/html/rfc7230\#section-3.3.2](https://tools.ietf.org/html/rfc7230#section-3.3.2) -- Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing -- Content-Length

<sup>12</sup>  [https://tools.ietf.org/html/rfc7231\#section-3.1.1.5](https://tools.ietf.org/html/rfc7231#section-3.1.1.5) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content -- Content-Type

<sup>13</sup>  [https://tools.ietf.org/html/rfc7231\#section-7.1.1.2](https://tools.ietf.org/html/rfc7231#section-7.1.1.2) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content -- Date

<sup>14</sup>  [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For) -- X-Forwarded-For

<sup>15</sup>  [https://tools.ietf.org/html/rfc7239](https://tools.ietf.org/html/rfc7239) -- Forwarded HTTP Extension

<sup>16</sup>  [https://tools.ietf.org/html/rfc7230\#section-3.3.2](https://tools.ietf.org/html/rfc7230#section-3.3.2) -- Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing -- Content-Length

<sup>17</sup>  [https://tools.ietf.org/html/rfc7231\#section-3.1.1.5](https://tools.ietf.org/html/rfc7231#section-3.1.1.5) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content -- Content-Type

<sup>18</sup>  [https://tools.ietf.org/html/rfc7231\#section-4](https://tools.ietf.org/html/rfc7231#section-4) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content - Request Methods

<sup>19</sup>  [https://tools.ietf.org/html/rfc7231\#section-6](https://tools.ietf.org/html/rfc7231#section-6) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content - Response Status Codes

<sup>20</sup>  [https://tools.ietf.org/html/rfc7231\#section-6.4](https://tools.ietf.org/html/rfc7231#section-6.4) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content - Redirection 3xx

<sup>21</sup>  [https://tools.ietf.org/html/rfc7231\#section-6.6](https://tools.ietf.org/html/rfc7231#section-6.6) -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content - Server Error 5xx

<sup>22</sup>  [https://tools.ietf.org/html/rfc7231\#section-6.5.6](https://tools.ietf.org/html/rfc7231#section-6.5.6)
    -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content -
    406 Not Acceptable

<sup>23</sup>  [https://tools.ietf.org/html/rfc7231\#section-5.3.2](https://tools.ietf.org/html/rfc7231#section-5.3.2)
    -- Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content -
    Accept


## 4. Interledger Protocol

The current version of the API includes basic support for the Interledger Protocol (ILP), by defining a concrete implementation of the Interledger Payment Request protocol<sup>24</sup> in [API Resource **/quotes**,]() Section [6.5,]() and [API Resource **/transfers**,]() Section [6.7.]()

### 4.1 More Information

This document contains ILP information that is relevant to the API. For more information about the ILP protocol, see the Interledger project websit<sup>25</sup>, the Interledger Whitepaper<sup>26</sup>, and the Interledger architecture specification<sup>27</sup>.

### 4.2 Introduction to Interledger

ILP is a standard for internetworking payment networks. In the same way that the Internet Protocol (IP) establishes a set of basic standards for the transmission and addressing of data packets between different data networks, ILP establishes a set of basic standards for the addressing of financial transactions and transfer of value between accounts on different payment networks.

ILP is not a scheme. It is a set of standards that, if implemented by multiple payment schemes, will allow those schemes to be interoperable. Therefore, implementing ILP involves adapting an existing scheme to conform to those standards. Conformance means ensuring that transfers between accounts within the scheme are done in two phases (_reserve_ and _commit_) and defining a mapping between the accounts in the scheme and the global ILP Addressing scheme. This can be done by modifying the scheme itself, or by the entities that provide ILP-conformant access to the scheme using scheme adaptors.

The basic prerequisites for an ILP payment are the Payee ILP address
(see Section [4.3)](#43-ilp-addressing) and the condition (see Section
[4.4)](#44-conditional-transfers). In the current version of the API, both these
prerequisites should be returned by the Payee FSP during quoting [(API
Resource]() [**/quotes**,]() **see** Section
[6.5)]() of the financial transaction.

### 4.3 ILP Addressing

A key component of the ILP standard is the ILP addressing<sup>28</sup> scheme. It is a hierarchical scheme that defines one or more addresses for every account on a ledger.

[Table 4](#table-4) shows some examples of ILP addresses that could be used in different scenarios, for different accounts. Note that while the structure of addresses is standardized, the content is not, except for the first segment (up to the first period (**.**)).

##### Table 4
|ILP Address|Description|
|---|---|
|<strong>g.tz.fsp1.msisdn.1234567890</strong>|A mobile money account at **FSP1** for the user with **MSISDN 1234567890**.|
|**g.pk.fsp2.ac03396c-4dba-4743**|A mobile money account at **FSP2** identified by an opaque account id.|
|**g.us.bank1.bob**|A bank account at **Bank1** for the user **bob**.|
**ILP address examples**

The primary purpose of an ILP addresses is to identify an account in order to route a financial transaction to that account.

**Note:** An ILP address should not be used for identifying a counterparty in the Interoperability API. See Section [5.1.6.11]() regarding how to address a Party in the API.

It is useful to think of ILP addresses as analogous to IP addresses. They are seldom, if ever, be seen by end users but are used by the systems involved in a financial transaction to identify an account and route the ILP payment. The design of the addressing scheme means that a single account will often have many ILP addresses. The system on which the account is maintained may track these or, if they are all derived from a common prefix, may track a subset only.

### 4.4 Conditional Transfers

ILP depends on the concept of *conditional transfers*, in which all
ledgers involved in a financial transaction from the Payer to the Payee
can first reserve funds out of a Payer account and then later commit
them to the Payee account. The transfer from the Payer to the Payee
account is conditional on the presentation of a fulfilment that
satisfies the condition attached to the original transfer request.

To support conditional transfers for ILP, a ledger must support a
transfer API that attaches a condition and an expiry to the transfer.
The ledger must prepare the transfer by reserving the funds from the
Payer account, and then wait for one of the following events to occur:

- The fulfilment of the condition is submitted to the ledger and the funds are committed to the Payee account.

- The expiry timeout is reached, or the financial transaction is rejected by the Payee or Payee FSP. The transfer is then aborted and the funds that were reserved from the Payer account are returned.

When the fulfilment of a transfer is submitted to a ledger, the ledger
must ensure that the fulfilment is valid for the condition that was
attached to the original transfer request. If it is valid, the transfer
is committed, otherwise it is rejected, and the transfer remains in a
pending state until a valid fulfilment is submitted or the transfer
expires.

ILP supports a variety of conditions for performing a conditional
payment, but implementers of the API should use the SHA-256 hash of a
32-byte pre-image. The condition attached to the transfer is the SHA-256
hash and the fulfilment of that condition is the pre-image. Therefore,
if the condition attached to a transfer is a SHA -256 hash, then when a
fulfilment is submitted for that transaction, the ledger will validate
it by calculating the SHA-256 hash of the fulfilment and ensuring that
the hash is equal to the condition.

See Section [6.5.1.2 (Interledger Payment Request)]() for
concrete information on how to generate the fulfilment and the
condition.

### 4.5 ILP Packet

The ILP Packet is the mechanism used to package end-to-end data that can be passed in a hop-by-hop service. It is included as a field in hop-by-hop service calls and should not be modified by any intermediaries. The integrity of the ILP Packet is tightly bound to the integrity of the funds transfer, as the commit trigger (the fulfilment) is generated using a hash of the ILP Packet.

The packet has a strictly defined binary format, because it may be passed through systems that are designed for high performance and volume. These intermediary systems must read the ILP Address and the amount from the packet headers, but do not need to interpret the **data** field in the ILP Packet (see [Listing 6)](#listing-6). Since the intermediary systems should not need to interpret the **data** field, the format of the field is not strictly defined in the ILP Packet definition. It is simply defined as a variable length octet string. Section [6.5.1.2 (Interledger Payment Request)]() contains concrete information on how the ILP Packet is populated in the API.

The ILP Packet is the common thread that connects all the individual ledger transfers that make up an end-to-end ILP payment. The packet is parsed by the Payee of the first transfer and used to determine where to make the next transfer, and for how much. It is attached to that transfer and parsed by the Payee of the next transfer, who again determines where to make the next transfer, and for how much. This process is repeated until the Payee of the transfer is the Payee in the end-to-end financial transaction, who fulfils the condition, and the transfers are committed in sequence starting with the last and ending with the first.

The ILP Packet format is defined in ASN.<sup>29</sup> (Abstract Syntax Notation One), shown in [Listing 6.](#listing-6) The packet is encoded using the canonical Octet Encoding Rules.

##### Listing 6
```
InterledgerProtocolPaymentMessage ::= SEQUENCE {
    -- Amount which must be received at the destination amount UInt64,
    -- Destination ILP Address account Address,
    -- Information for recipient (transport layer information) data OCTET STRING (SIZE (0..32767)),
    -- Enable ASN.1 Extensibility
    extensions SEQUENCE {
        ...
    }
}
```
**The ILP Packet format in ASN.1 format**

**Note:** The only mandatory data elements in the ILP Packet are the amount to be transferred to the account of the Payee and the ILP Address of the Payee.

<sup>24</sup>  [https://interledger.org/rfcs/0011-interledger-payment-request/](https://interledger.org/rfcs/0011-interledger-payment-request/) -- Interledger Payment Request (IPR)

<sup>25</sup>  [https://interledger.org/](https://interledger.org/) -- Interledger

<sup>26</sup> [https://interledger.org/interledger.pdf](https://interledger.org/interledger.pdf) -- A Protocol for Interledger Payments

<sup>27</sup>  [https://interledger.org/rfcs/0001-interledger-architecture/](https://interledger.org/rfcs/0001-interledger-architecture/) -- Interledger Architecture

<sup>28</sup>  [https://interledger.org/rfcs/0015-ilp-addresses/](https://interledger.org/rfcs/0015-ilp-addresses/) -- ILP Addresses


<sup>29</sup>  [https://www.itu.int/rec/dologin\_pub.asp?lang=e&id=T-REC-X.696-201508-I!!PDF-E&type=items](https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-X.696-201508-I!!PDF-E&type=items) -- Information technology -- ASN.1 encoding rules: Specification of Octet Encoding Rules (OER)

+++++  ***END OF POC***  +++++  ***END OF POC***  +++++  ***END OF POC***  +++++
