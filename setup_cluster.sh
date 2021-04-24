#/bin/bash

if ! kind --version COMMAND &> /dev/null
then
    echo -e "\e[91mKind is not installed\033[0m"
    exit
fi

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

current_dir=$(pwd)

echo -e "\e[32mInstall linkerd\033[0m"
kubectl apply -f $current_dir/tools/linkerd/linkerd.yaml

echo -e "\e[32mWait for linkerd\033[0m"
linkerd check

echo -e "\e[32mSetup ambassador crds\033[0m"
kubectl apply -f $current_dir/tools/ambassador/crds.yaml

echo -e "\e[32mSetup ambassador operator\033[0m"
kubectl apply -n ambassador -f $current_dir/tools/ambassador/operator.yaml

echo -e "\e[32mWait for ingress\033[0m"
kubectl wait --timeout=180s -n ambassador --for=condition=deployed ambassadorinstallations/ambassador
kubectl apply -f $current_dir/tools/linkerd/ambassador_mapping.yaml

echo -e "\e[32mRun keycloak\033[0m"
kubectl apply -f $current_dir/keycloak/keycloak.yaml

echo -e "\e[32mRun author micoservice\033[0m"

if [[ "$(docker images -q zawiszaty/k8s_playground_author:latest 2> /dev/null)" == "" ]]; then
  docker build -t zawiszaty/k8s_playground_author:latest $current_dir/author  
fi
kind load docker-image zawiszaty/k8s_playground_author:latest
kubectl apply -f $current_dir/author/k8s/author.yaml
