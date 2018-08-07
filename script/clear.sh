#!/bin/bash

set -xe

if [ "$#" -ne "1" ]; then  
    echo "usage: $0 <uuid> <namespace>"  
    exit 2
fi

UUID=${1}
KUBEFLOW_NAMESPACE=${2}
CLEAR_UP_TMP_DIR=/tmp/clear-${UUID}

if [ -z "${2}" ]; then
	echo "KUBEFLOW_NAMESPACE NIL, use current-context"
else
	kubectl config set-context $(kubectl config current-context) --namespace=${KUBEFLOW_NAMESPACE}
fi

mkdir -p ${CLEAR_UP_TMP_DIR}

CEPHFS_PV_YAML_TMP=${CLEAR_UP_TMP_DIR}/cephfs-pv-${UUID}.yaml
TF_TENSORBOARD_YAML_TMP=${CLEAR_UP_TMP_DIR}/tf-tensorboard-${UUID}.yaml

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/cephfs-pv.yaml" > ${CEPHFS_PV_YAML_TMP}

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/tf_tensorboard.yaml" > ${TF_TENSORBOARD_YAML_TMP}

sed -i "s/uuidgen/${UUID}/g" ${CEPHFS_PV_YAML_TMP}
sed -i "s/uuidgen/${UUID}/g" ${TF_TENSORBOARD_YAML_TMP}

# find the jupyter first and delete the jupyter-hub
JUPYTER_HUB_POD_NAME=`kubectl get pv | grep jupyterhub-pv-${UUID} | awk '{print $6}'`
JUPYTER_HUB_POD_NAME=${JUPYTER_HUB_POD_NAME##*/}
JUPYTER_HUB_POD_NAME=${JUPYTER_HUB_POD_NAME##*-}

if [ -z "${JUPYTER_HUB_POD_NAME}" ]; then
	TESORBOARD_TMP=`kubectl get po | grep tensorboard-manual-${UUID} | awk '{print $1}'`
	if [ -z "${TESORBOARD_TMP}" ]; then
		echo "No resources should be removed"
		kubectl get pv
		kubectl get pvc
		kubectl get po
	else
		echo "Error, No pod founded to mount to the pv with name jupyterhub-pv-${UUID}."
		echo "Remove the tensorboard resources."
		kubectl delete -f ${TF_TENSORBOARD_YAML_TMP}
	fi
	exit 2
fi

kubectl delete po jupyter-${JUPYTER_HUB_POD_NAME}
kubectl delete pvc claim-${JUPYTER_HUB_POD_NAME}

## clear the pvc and pv

kubectl delete -f ${CEPHFS_PV_YAML_TMP}

## clear tensorboard and pv
kubectl delete -f ${TF_TENSORBOARD_YAML_TMP}

## delete mount dir in cephfs (TODO)