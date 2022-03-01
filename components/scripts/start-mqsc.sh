#!/bin/bash
#
# A simple MVP script that will run MQSC against a queue manager.
ckksum=""

# Outer loop that keeps the MQ service running
while true; do

   tmpCksum=`cksum /dyn-mq-config-mqsc/dynamic.mqsc | cut -d" " -f1`

   if (( tmpCksum != cksum ))
   then
      cksum=$tmpCksum
      echo "Applying MQSC"
      runmqsc $1 < /dyn-mq-config-mqsc/dynamic.mqsc
   else
      sleep 3
   fi

done

cd ..
ingress_secret_name=$(oc get ingresscontroller.operator default \
--namespace openshift-ingress-operator \
-o jsonpath='{.spec.defaultCertificate.name}')
oc extract secret/$ingress_secret_name -n openshift-ingress
oc create secret tls -n openshift-gitops argocd-tls --cert=tls.crt --key=tls.key --dry-run=client -o yaml | oc apply -f -
cd -