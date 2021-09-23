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

set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PISP_PROJECT_GIT_URL="https://github.com/mojaloop/pisp-project.git"
PISP_PROJECT_BRANCH='master'
CLONE_DIR='/tmp/pisp-project'

rm -rf ${CLONE_DIR}

git clone -b ${PISP_PROJECT_BRANCH} ${PISP_PROJECT_GIT_URL} ${CLONE_DIR}


# API definition, grab from mojaloop/pisp-project
cp ${CLONE_DIR}/src/interface/thirdparty-dfsp-api.yaml ${DIR}/thirdparty-dfsp-v1.0.yaml
cp ${CLONE_DIR}/src/interface/thirdparty-pisp-api.yaml ${DIR}/thirdparty-pisp-v1.0.yaml

# Tx pattern documents
cp ${CLONE_DIR}/docs/linking/README.md  ${DIR}/transaction-patterns-linking.md
cp ${CLONE_DIR}/docs/transfer/README.md ${DIR}/transaction-patterns-transfer.md

# copy tx pattern svgs.
cp -R ${CLONE_DIR}/docs/out/* ${DIR}/assets/

# sed to update the svg paths
sed -i 's/..\/out/.\/assets/g' transaction-patterns-linking.md
sed -i 's/..\/out/.\/assets/g' transaction-patterns-transfer.md