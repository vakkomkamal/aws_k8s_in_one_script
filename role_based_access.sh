#!/usr/bin/env bash

kubectl describe clusterrole admin

echo "Enter the Name of the Namespace you want to create: "
read namespace
kubectl create namespace $namespace
echo "created namespace $namespace"
echo "Enter the Name of the Role you would like to bind to0 the cluster: "
read k8srole



cat <<EOF> role.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $k8srole
  namespace: $namespace
rules:
  - apiGroups:
      - ""
      - "apps"
      - "batch"
      - "extensions"
    resources:
      - "configmaps"
      - "cronjobs"
      - "deployments"
      - "events"
      - "ingresses"
      - "jobs"
      - "pods"
      - "pods/attach"
      - "pods/exec"
      - "pods/log"
      - "pods/portforward"
      - "secrets"
      - "services"
    verbs:
      - "create"
      - "delete"
      - "describe"
      - "get"
      - "list"
      - "patch"
      - "update"
EOF

kubectl apply -f role.yaml

echo "Enter the username you want to grant the role or namespace permission: "
read username



cat <<EOF> rolebinding.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $k8srole
  namespace: $namespace
subjects:
- kind: User
  name: $username
roleRef:
  kind: Role
  name: $k8srole
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply rolebinding.yaml

aws sts get-caller-identity

echo "your clustername: "
read yourClusterName
echo "Yours or cluster admins AccountID: "
read yourAccountID
echo "yours or cluster admin AccountID: "
read yourIAMRoleName

eksctl create iamidentitymapping --cluster $yourClusterName --arn arn:aws:iam::$yourAccountID:role/$yourIAMRoleName --username $username

