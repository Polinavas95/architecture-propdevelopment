1. Запустить minikube в терминале, если ранее еще не делали этого
```shell
minikube start --cpus=4 --memory=7168 --network-plugin=cni --cni=calico
```

## Развернуть 4 пода с метками
Переключиться на администратора
```shell
kubectl config use-context minikube
```

Front-end (UI для обычных пользователей)

```shell
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
```

Back-end API (API для обычных пользователей)

```shell
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
```

Admin Front-end (UI для администраторов)

```shell
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
```

Admin Back-end API (API для администраторов)

```shell
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```

Проверить, что поды создались

```shell
kubectl get pods
kubectl get services
```
Дождитесь статуса RUNNING у всех подов


Удалить под и сервис при необходимости
```shell
kubectl delete pod admin-back-end-api-app
kubectl delete service admin-back-end-api
```

Удалить все поды и сервисы
```shell
kubectl delete pod --all
kubectl delete service front-end back-end-api admin-front-end admin-back-end-api
```

Применить политики для сервисов

```shell
kubectl apply -f non-admin-api-allow.yaml
```

Проверить, что политики создались

```shell
kubectl get networkpolicies
```

Проверить, что трафик есть между сервисами, для которых он разрешён, но его нет между сервисами, для которых он запрещён 
Проверяем на front-end
```shell
kubectl run tests-frontend --rm -i -t --image=busybox --labels role=front-end -- sh
```
В запущенной оболочке для проверки используйте IP адрес (команда kubectl get services)
```shell
wget -qO- --timeout=2 http://<IP-адрес>
```

Например, IP адрес back-end-api-app, который должен сработать
```shell
wget -qO- --timeout=2 http://10.107.111.248
```

А IP адрес admin-back-end-api-app должен упасть по таймауту
```shell
wget -qO- --timeout=2 10.100.103.4
```

Чтобы выйти из оболчки
```shell
exit
```