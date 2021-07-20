#!/usr/bin/env bash

##
# Synchronises the definition docs from their disparate locations into one place.
#
# This is a temporary measure to aid in writing and updating the proposed 3rd Party API
# documentation.
#
# In the near future, this repository will be home to the PISP documentation, so we won't need
# to have this script to sync everything
##

PISP_PROJECT_BASE="https://raw.githubusercontent.com/mojaloop/pisp-project/master"


# API definition, grab from mojaloop/pisp-project
wget ${PISP_PROJECT_BASE}/src/interface/thirdparty-dfsp-api.yaml -O ./thirdparty-dfsp-v1.0.yaml
wget ${PISP_PROJECT_BASE}/src/interface/thirdparty-pisp-api.yaml -O ./thirdparty-pisp-v1.0.yaml

# Tx pattern documents
wget ${PISP_PROJECT_BASE}/docs/linking/README.md -O ./transaction-patterns-linking.md
wget ${PISP_PROJECT_BASE}/docs/transfer/README.md -O ./transaction-patterns-transfer.md
