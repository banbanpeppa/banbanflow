#!/bin/bash
set -xe

uuid=`uuidgen`
uuid=${uuid:0:8}

if [ ! -d "/tmp/model-train-serve" ]; then
	mkdir -p /tmp/model-train
fi

MODEL_SERVE_YAML_TMP=/tmp/model-train-serve/serve-${uuid}.yaml
MODEL_TRANING_YAML_TMP=/tmp/model-train-serve/training-${uuid}.yaml

curl -sSL "https://raw.githubusercontent.com/banbanandroid/banbanflow/master/script/kubeflow-introduction/mode-serve.yaml" > ${MODEL_SERVE_YAML_TMP}
curl -sSL "https://raw.githubusercontent.com/banbanandroid/banbanflow/master/script/kubeflow-introduction/tensorflow-model.yaml" > ${MODEL_TRANING_YAML_TMP}

sed -i "s/uuidgen/${uuid}/g" ${MODEL_SERVE_YAML_TMP}
sed -i "s/uuidgen/${uuid}/g" ${MODEL_TRANING_YAML_TMP}

kubectl create -f ${MODEL_SERVE_YAML_TMP}
sleep 1

kubectl create -f ${MODEL_TRANING_YAML_TMP}
sleep 1