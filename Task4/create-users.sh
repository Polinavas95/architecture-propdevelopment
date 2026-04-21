#!/bin/bash

set -e

create_user() {
    local USERNAME=$1
    local NAMESPACE=$2

    echo "Создание пользователя: $USERNAME в namespace: $NAMESPACE"
    kubectl create serviceaccount "$USERNAME" -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${USERNAME}-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $USERNAME
type: kubernetes.io/service-account-token
EOF
    sleep 2
    TOKEN=$(kubectl get secret "${USERNAME}-token" -n "$NAMESPACE" -o jsonpath='{.data.token}' | base64 --decode)

    mkdir -p ./k8s-users
    echo "$TOKEN" > "./k8s-users/${USERNAME}.token"

    kubectl config set-credentials "$USERNAME" --token="$TOKEN"
    kubectl config set-context "${USERNAME}-context" \
        --cluster=minikube \
        --namespace="$NAMESPACE" \
        --user="$USERNAME"

    echo "Пользователь $USERNAME создан. Токен сохранён в ./k8s-users/${USERNAME}.token"
    echo "Контекст: ${USERNAME}-context"
    echo ""
}

kubectl create namespace propdev-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace propdev-prod --dry-run=client -o yaml | kubectl apply -f -

create_user "alice-dev" "propdev-dev"
create_user "bob-security" "propdev-prod"
create_user "charlie-ops" "propdev-prod"

echo "=== Все пользователи созданы ==="
echo ""
echo "Проверить доступ:"
echo "kubectl --context=alice-dev-context get pods -n propdev-dev"
echo "kubectl --context=bob-security-context get secrets -n propdev-prod"