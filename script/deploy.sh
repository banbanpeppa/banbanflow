#!/bin/bash
# This script creates a kubeflow deployment on minikube
# It checks for kubectl, ks
# Creates the ksonnet app, installs packages, components and then applies them

set -xe

KUBE_UUID=`uuidgen`
KUBE_UUID=${KUBE_UUID:0:8}

KUBEFLOW_NAMESPACE=${KUBEFLOW_NAMESPACE:-"kubeflow-${KUBE_UUID}"}
KUBEFLOW_REPO=${KUBEFLOW_REPO:-"`pwd`/kubeflow_repo"}
KUBEFLOW_VERSION=${KUBEFLOW_VERSION:-"0.2.2"}
KUBEFLOW_DEPLOY=${KUBEFLOW_DEPLOY:-true}

if [[ ! -d "${KUBEFLOW_REPO}" ]]; then
  if [ "${KUBEFLOW_VERSION}" == "master" ]; then
        TAG=${KUBEFLOW_VERSION}
  else
        TAG=v${KUBEFLOW_VERSION}
  fi  
  TMPDIR=$(mktemp -d /tmp/tmp.kubeflow-repo-XXXX)
  curl -L -o ${TMPDIR}/kubeflow.tar.gz https://github.com/kubeflow/kubeflow/archive/${TAG}.tar.gz
  tar -xzvf ${TMPDIR}/kubeflow.tar.gz  -C ${TMPDIR}
  # GitHub seems to strip out the v in the file name.
  SOURCE_DIR=$(find ${TMPDIR} -maxdepth 1 -type d -name "kubeflow*")
  mv ${SOURCE_DIR} "${KUBEFLOW_REPO}"
fi

source "${KUBEFLOW_REPO}/scripts/util.sh"

# verify ks version is higher than 0.11.0
check_install ks
check_install kubectl

# Name of the deployment
DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-"kubeflow-${KUBE_UUID}"}

KUBEFLOW_KS_DIR=${KUBEFLOW_KS_DIR:-"`pwd`/${DEPLOYMENT_NAME}_ks_app"}

if [[ -d "$KUBEFLOW_KS_DIR" ]]; then
  rm -rf ${KUBEFLOW_KS_DIR}
fi

kubectl create namespace ${KUBEFLOW_NAMESPACE}
kubectl config set-context $(kubectl config current-context) --namespace=${KUBEFLOW_NAMESPACE}

cd $(dirname "${KUBEFLOW_KS_DIR}")
ks init $(basename "${KUBEFLOW_KS_DIR}")
cd "${KUBEFLOW_KS_DIR}"
ks env set default --namespace ${KUBEFLOW_NAMESPACE}

# Add the local registry
ks registry add kubeflow "${KUBEFLOW_REPO}/kubeflow"

# Install packages
ks pkg install kubeflow/argo
ks pkg install kubeflow/core
ks pkg install kubeflow/examples
ks pkg install kubeflow/katib
ks pkg install kubeflow/mpi-job
ks pkg install kubeflow/pytorch-job
ks pkg install kubeflow/seldon
ks pkg install kubeflow/tf-serving

# Generate all required components
ks generate kubeflow-core kubeflow-core

# Enable collection of anonymous usage metrics
# Skip this step if you don't want to enable collection.
# ks param set kubeflow-core reportUsage true
# ks param set kubeflow-core usageId $(uuidgen)
ks param set kubeflow-core reportUsage false
ks param set kubeflow-core tfJobUiServiceType NodePort
ks param set kubeflow-core jupyterHubServiceType NodePort
ks param set kubeflow-core AmbassadorServiceType NodePort

# Apply the components generated
if ${KUBEFLOW_DEPLOY}; then
  ks apply default
fi

curl -sSL https://raw.githubusercontent.com/banbanandroid/static/master/tf-hub-tensorboard.sh > ${KUBEFLOW_KS_DIR}/tf-hub-tensorboard.sh
chmod +x ${KUBEFLOW_KS_DIR}/tf-hub-tensorboard.sh

set +xe

echo "Deployment successful!"
echo "Your namespace is ${KUBEFLOW_NAMESPACE}"
echo "Your work dir is ${KUBEFLOW_KS_DIR}"