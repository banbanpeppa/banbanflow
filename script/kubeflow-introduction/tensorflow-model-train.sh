#!/bin/bash
set -xe

uuid=`uuidgen`
uuid=${uuid:0:8}

mkdir -p /tmp/model-train

MODEL_TRANING_YAML_TMP=/tmp/model-train/training-${uuid}.yaml

curl -sSL https://raw.githubusercontent.com/banbanandroid/banbanflow/master/script/kubeflow-introduction/tensorflow-model.yaml > ${MODEL_TRANING_YAML_TMP}

sed -i "s/uuidgen/${uuid}/g" ${MODEL_TRANING_YAML_TMP}

kubectl create -f ${MODEL_TRANING_YAML_TMP}

sleep 1