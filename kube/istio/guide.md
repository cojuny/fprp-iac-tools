
#### 1. Install CLI

```
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
```

#### Insatll Istio

for testing:

```
istioctl install --set profile=demo -y
```

check:

```
kubectl get pods -n istio-system
kubectl get svc -n istio-system
```
