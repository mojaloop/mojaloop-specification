# Third Party API

The Third Party API is an API for non-fund-holding participants to interact over a centralized Mojaloop hub.

## Terms

The following terms are commonly used across the Third Party API Documentation

| Term | Definition | More |
| ---- | ---------- | -------- |
| PISP | Payment Initiation Service Provider | |
| DFSP | Digital Financial Service Provider | Used interchangably with Financial Service Provider (FSP) |
| 3PPI | Third Party Payment Initiation | |
| User | An end user that is shared between a PISP and DFSP | We mostly use this in the context of a real human being, but this could also be a machine user, or a business for example |
| Consent | A representation of an agreement between the DFSP, PISP and User | |
| Auth-Service | A service run by the Mojaloop Hub that is responsible for verifying and storing Consents, and verifying transaction request signatures | |


## API Definitions

The Third Party API is defined across the following OpenAPI 3.0 files:

- [Thirdparty API - PISP](./thirdparty-pisp-v1.0.yaml)
- [Thirdparty API - DFSP](./thirdparty-dfsp-v1.0.yaml)

## Transaction Patterns

The interactions and examples of how a DFSP and PISP will interact with the Third Party API can be found in the following Transaction Patterns Documents:

1. [Linking](./transaction-patterns-linking.md) describes how an account link and credential can be established between a DFSP and a PISP
2. [Transfer](./transaction-patterns-transfer.md) describes how a PISP can initate a payment from a DFSP's account using the account link

## Data Models

The [Data Models Document](./data-models.md) describes in detail the Data Models used in the Thirdparty API
