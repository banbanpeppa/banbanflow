#!/bin/bash
set -xe

uuid=`uuidgen`
uuid=${uuid:0:8}

MODEL_TRANING_YAML_TMP=/tmp/model-traincephfs-pv-${uuid}.yaml
TF_TENSORBOARD_YAML_TMP=/tmp/tf-tensorboard-${uuid}.yaml

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/cephfs-pv.yaml" > ${CEPHFS_PV_YAML_TMP}

curl -sSL "https://raw.githubusercontent.com/banbanandroid/static/master/tf_tensorboard.yaml" > ${TF_TENSORBOARD_YAML_TMP}

curl -sSL  ${CEPHFS_PV_YAML_TMP}
sed -i "s/uuidgen/${uuid}/g" ${TF_TENSORBOARD_YAML_TMP}

# cat ${CEPHFS_PV_YAML_TMP}
# cat ${TF_TENSORBOARD_YAML_TMP}

kubectl create -f ${TF_TENSORBOARD_YAML_TMP}
sleep 1

curl -sSL  https://raw.githubusercontent.com/banbanandroid/banbanflow/master/script/kubeflow-introduction/tensorflow-model.yaml | 