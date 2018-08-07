#!/bin/bash
# This script creates a kubernetes persistent volume with no storageclass
# It serves for the kubeflow component —— tf-hub
# since the tf-hub create a new notebook with mount to a pv with no storageclass

set -xe

uuid=`uuidgen`
uuid=${uuid:0:8}

NODE_HOST_IP=10.82.45.43

CEPHFS_PV_YAML_TMP=/tmp/cephfs-pv-${uuid}.yaml
TF_TENSORBOARD_YAML_TMP=/tmp/tf-tensorboard-${uuid}.yaml

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/cephfs-pv.yaml" > ${CEPHFS_PV_YAML_TMP}

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/tf_tensorboard.yaml" > ${TF_TENSORBOARD_YAML_TMP}

sed -i "s/uuidgen/${uuid}/g" ${CEPHFS_PV_YAML_TMP}
sed -i "s/uuidgen/${uuid}/g" ${TF_TENSORBOARD_YAML_TMP}

# cat ${CEPHFS_PV_YAML_TMP}
# cat ${TF_TENSORBOARD_YAML_TMP}

kubectl create -f ${TF_TENSORBOARD_YAML_TMP}
sleep 1
kubectl create -f ${CEPHFS_PV_YAML_TMP}

# see if the pv and pvc were created properly
kubectl get pv
kubectl get pvc

while [ ! -d "/cephfs/jupyterhubpv/${uuid}" ]; do
	sleep 1
done

mkdir -p /cephfs/jupyterhubpv/${uuid}/work
chmod -R 777 /cephfs/jupyterhubpv/${uuid}

set +xe

TENSORBOARD_PORT=`kubectl get svc | grep tensorboard-manual-${uuid} | awk '{print $5}'`
TENSORBOARD_PORT=${TENSORBOARD_PORT##*:}
TENSORBOARD_PORT=${TENSORBOARD_PORT%/*}

JUPYTER_HUB_PORT=`kubectl get svc | grep tf-hub-lb | awk '{print $5}'`
JUPYTER_HUB_PORT=${JUPYTER_HUB_PORT##*:}
JUPYTER_HUB_PORT=${JUPYTER_HUB_PORT%/*}

echo "Your jupyter_hub address: http://${NODE_HOST_IP}:"$JUPYTER_HUB_PORT
echo "Your tensorboard address: http://${NODE_HOST_IP}:"$TENSORBOARD_PORT