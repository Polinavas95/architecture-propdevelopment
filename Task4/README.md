## Порядок работы

1. Запустить minikube в терминале
```shell
minikube start --cpus=4 --memory=7168 --network-plugin=cni --cni=calico
```

2. Проверка работы kuberlect

```shell
kubectl cluster-info
```

3. Включение RBAC (на всякий случай для старых версий)

```shell
kubectl api-resources | grep rbac
```

4. Создание namespace
```shell
kubectl create namespace propdev-production
```
# Проверить, что namespace создался

```shell
kubectl get namespaces | grep propdev
```

Далее выполняй скрипты ниже по очереди

## Создание пользователей

1) Запустить скрипт создания 3х пользователей

```shell
chmod +x ./create-users.sh
./create-users.sh
```

```shell
# Переключиться на контекст пользователя
kubectl config use-context alice-dev-context

# Проверить, кто ты
kubectl auth whoami

# Проверить права
kubectl auth can-i get pods -n propdev-dev
kubectl auth can-i get secrets -n propdev-prod

# Вернуться обратно на admin
kubectl config use-context minikube
```

 ## Создание ролей

Выполнить скрипт

```shell
kubectl apply -f create-roles.yaml
```

Для связывания пользователей с ролями выполни скрипт

```shell
kubectl apply -f bind-users.yaml
```

Проверить все привязки
```shell
kubectl get clusterrolebindings | grep -E "admin|viewer|secret|integration"
kubectl get rolebindings -n propdev-production
```

##  Пример привязки пользователя

Так как привязки ролей идут по группам, то для привязки пользователя можно использовать эту команду

Права на просмотр всего кластера
```shell
kubectl create clusterrolebinding alice-viewer-binding \
  --clusterrole=cluster-viewer \
  --user=alice-dev
```

Проверить права
```shell
kubectl config use-context alice-dev-context
```

Проверить имя
```shell
kubectl --context=alice-dev-context auth whoami
```

Скопировать Username (system:serviceaccount:propdev-dev:alice-dev)

Переключиться на администратора
```shell
kubectl config use-context minikube
```

Создать привязку 
```shell
kubectl create clusterrolebinding alice-viewer-binding \
  --clusterrole=cluster-viewer \
  --serviceaccount=propdev-dev:alice-dev
```

Переключиться обратно на alice

```shell
kubectl config use-context alice-dev-context
```

Проверить доступность к чтению namespaces

```shell
kubectl --context=alice-dev-context auth can-i get pods --all-namespaces
```
Должно быть "yes"


