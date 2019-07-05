# Kubernetes Sidecar 注入

该插件将注入Kong数据平面节点并在Kubernetes之上形成服务网格

## 介绍

Kong `0.15.0` / `1.0.0`增加了代理和路由原始`tcp`和`tls`流的能力，并使用服务网格Sidecar模式和Kong节点之间的相互`tls`来部署Kong。本教程将引导您使用我们的 [Kubernetes Sidecar 注入插件](https://github.com/Kong/kubernetes-sidecar-injector)在Kubernetes上设置Kong服务网格。

## 准备条件

您需要在Kubernetes上运行Kong 1.0.0或更高版本，包括存储为可用于Kong控制平面的机密的SSL证书。来自[Kong Kubernetes Repository](https://github.com/Kong/kong-dist-kubernetes)的Make任务`run_cassandra`和`run_postgres`将完全配置必备数据存储，Kong控制平面，Kong数据平面和SSL机密。

或者，按照[Kong Kubernetes Install Instructions](https://docs.konghq.com/install/kubernetes/)页面中的任何设置说明进行操作，然后设置SSL证书/密码：
```
cd $(mktemp -d)

### Create a key+certificate for the control plane
cat <<EOF | kubectl create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: kong-control-plane.kong.svc
spec:
  request: $(openssl req -new -nodes -batch -keyout privkey.pem -subj /CN=kong-control-plane.kong.svc | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF
kubectl certificate approve kong-control-plane.kong.svc
kubectl -n kong create secret tls kong-control-plane.kong.svc --key=privkey.pem --cert=<(kubectl get csr kong-control-plane.kong.svc -o jsonpath='{.status.certificate}' | base64 --decode)
kubectl delete csr kong-control-plane.kong.svc
rm privkey.pem
```

或使用以下简便脚本：
```
curl -fsSL https://raw.githubusercontent.com/Kong/kong-dist-kubernetes/master/setup_certificate.sh | bash
```

## 安装步骤

导出一些变量以访问Kong Admin API和Proxy：
```
$ export HOST=$(kubectl get nodes --namespace default -o jsonpath='{.items[0].status.addresses[0].address}')
$ export ADMIN_PORT=$(kubectl get svc --namespace kong kong-control-plane  -o jsonpath='{.spec.ports[0].nodePort}')
```

通过Kong Admin API启用Sidecar Injector插件：
```
curl $HOST:$ADMIN_PORT/plugins -d name=kubernetes-sidecar-injector -d config.image=kong
```

打开Kubernets Sidecar Injection：
```
cat <<EOF | kubectl create -f -
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  name: kong-sidecar-injector
webhooks:
- name: kong.sidecar.injector
  rules:
  - apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
    operations: [ "CREATE" ]
  failurePolicy: Fail
  namespaceSelector:
    matchExpressions:
    - key: kong-sidecar-injection
      operator: NotIn
      values:
      - disabled
  clientConfig:
    service:
      namespace: kong
      name: kong-control-plane
      path: /kubernetes-sidecar-injector
    caBundle: $(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')
EOF
```

或使用以下简便脚本：
```
curl -fsSL https://raw.githubusercontent.com/Kong/kong-dist-kubernetes/master/setup_sidecar_injector.sh | bash
```

## 使用

接下来，任何开始使用Kong Sidecar的pods都会自动注入，而来自该pods容器的所有数据都将通过Kong Sidecar。
例如，如果我们使用Istio中的bookinfo.yaml示例：
```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.1/samples/bookinfo/platform/kube/bookinfo.yaml
```
我们看到所有pods都收到了Kong Sidecar：
```
kubectl get all
NAME                 READY   STATUS
pod/details-v1       2/2     Running
pod/productpage      2/2     Running
pod/ratings-v1       2/2     Running
pod/reviews-v1       2/2     Running
pod/reviews-v2       2/2     Running
pod/reviews-v3       2/2     Running
```
继续配置服务。






