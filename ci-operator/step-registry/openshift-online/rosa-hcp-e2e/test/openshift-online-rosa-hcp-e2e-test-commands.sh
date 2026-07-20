#!/bin/bash

set -euo pipefail

export AWS_SHARED_CREDENTIALS_FILE="${CLUSTER_PROFILE_DIR}/.awscred"
export AWS_REGION="${REGION}"
export KUBECONFIG="${SHARED_DIR}/kubeconfig"
export DEPLOYMENT_MODE="${DEPLOYMENT_MODE:-standalone}"

# Clone rosa-hcp-e2e-test repository
WORK_DIR=$(mktemp -d)
echo "Cloning ${ROSA_HCP_E2E_REPO} (branch: ${ROSA_HCP_E2E_BRANCH})..."
git clone --depth=1 --branch "${ROSA_HCP_E2E_BRANCH}" "${ROSA_HCP_E2E_REPO}" "${WORK_DIR}/rosa-hcp-e2e-test"
cd "${WORK_DIR}/rosa-hcp-e2e-test"

# Install Python dependencies
if [[ -f "requirements.txt" ]]; then
  echo "Installing Python requirements..."
  pip3 install -r requirements.txt
fi

# Install Ansible collection/role dependencies
if [[ -f "requirements.yml" ]]; then
  echo "Installing Ansible requirements..."
  ansible-galaxy install -r requirements.yml
fi

echo "Running rosa-hcp-e2e tests (DEPLOYMENT_MODE=${DEPLOYMENT_MODE})..."
./run-test-suite.py 10-install-capi-standalone -vvv \
  2>&1 | tee "${ARTIFACT_DIR}/rosa-hcp-e2e-test.log"

echo "Tests complete. Results at ${ARTIFACT_DIR}/rosa-hcp-e2e-test.log"
