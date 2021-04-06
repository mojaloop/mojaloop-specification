## **\[85\] -- \[Distributed Tracing Support\]**
___

### *Open API for FSP Interoperability -- Solution Proposal*

### **Table of Contents**

- [1. Preface](#1-preface)
  - [1.1 Solution Proposal Information](#11-solution-proposal-information)
  * [1.2 Document Version Information](#12-document-version-information)
* [2. Change Request](#2-change-request)
  * [2.1 Background](#21-background)
* [3. Proposed Solution](#3-proposed-solution)
* [4. Other Considered Solutions](#4-other-considered-solutions)
  * [4.1 Zipkin's B3 Propogation Design](#41-zipkins-b3-propogation-design)
  

## **1. Preface**
___

This section contains basic information regarding the solution proposal.

#### 1.1 Solution Proposal Information

| | |
|---|---|
| Proposal ID | 85 |
| Pull Request Link | https://github.com/mojaloop/mojaloop-specification/pull/85 |
| Change Request ID | 71 |
| Change Request Link | https://github.com/mojaloop/mojaloop-specification/issues/71 |
| Change Request Name | Distributed Tracing Support |
| Prepared By | Miguel de Barros, ModusBox |
| Solution Proposal Status | In review [X] / Approved [ ] / Rejected [ ] |
| Approved/Rejected Date |  |

#### 1.2 Document Version Information

| Version | Date | Author | Change Description |
|---|---|---|---|
| 1.0 | 2021-04-01 | Miguel de Barros | Initial version. Sent out for review. |

## **2. Change Request**
___

Refer to the following: [#71 - Change Request: Distributed Tracing Support for FSPIOP API](https://github.com/mojaloop/mojaloop-specification/issues/71).

## **3. Proposed Solution**
___

The proposed solution is for the Distributed Tracing specification for Mojaloop's Interoperability OpenAPIs and how they should be handled by both FSP and Hub implementers.

[Distributed Tracing Support for OpenAPI Interoperability v1.0](../fspiop-api/documents/Tracing_v1.0.md)


## **4. Other Considered Solutions**
___
The following subsections describes the considered alternative
solutions.

#### 4.1 Zipkin's B3 Propogation Design

Refer to the following alternative tracing standard: [Zipkin's B3 Propagation Design](https://github.com/apache/incubator-zipkin-b3-propagation).
