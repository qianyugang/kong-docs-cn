# 在 Kubernetes 上安装 Kong 和 Kong Enterprise 

## Kubernetes Ingress Controller for Kong

使用官方[Kubernetes Ingress控制器](https://github.com/Kong/kubernetes-ingress-controller)安装Kong或Kong Enterprise。

通过[README文件](https://github.com/Kong/kubernetes-ingress-controller/blob/master/README.md)了解更多信息。要运行本地概念证明，请按照[Minikube和Minishift教程](https://github.com/Kong/kubernetes-ingress-controller/tree/master/deploy)进行操作。

[Kubernetes Ingress Controller for Kong](https://konghq.com/blog/kubernetes-ingress-controller-for-kong/)发布公告在[Kong Blog](https://konghq.com/blog/)上。

如有问题和讨论，请访问[Kong Nation](https://discuss.konghq.com/c/kubernetes)。
有关错误报告，请在[GitHub上打开一个新问题](https://github.com/Kong/kubernetes-ingress-controller/issues)。

## 通过 Google Cloud Platform Marketplace 安装 Kong

也许在Kubernetes上尝试Kong的最快方法是通过Google Cloud Platform Marketplace和[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) - 以及Google Cloud Platform的[Free Tier 和 credit,](https://cloud.google.com/free/)，您可以免费使用。

1. 访问 https://console.cloud.google.com/marketplace/details/kong/kong
2. 单击“Configure”，然后按照屏幕上的提示进行操作
3. 有关公开Admin API的重要详细信息，请参阅https://github.com/Kong/google-marketplace-kong-app/blob/master/README.md，以便您可以配置Kong。

如果您只是在尝试使用，请考虑在完成实验后删除Google云资源，以避免持续使用Google Cloud使用费。

## 通过 Helm 安装 Kong

使用官方[Helm chart](https://hub.kubeapps.com/charts/stable/kong) 安装Kong或Kong Enterprise。

如有问题和讨论，请访问 [Kong Nation](https://discuss.konghq.com/c/kubernetes)。

## 通过 Manifest 文件安装 Kong

可以通过[Kong Kubernetes存储库](https://github.com/Kong/kong-dist-kubernetes/)中提供的清单文件在Kubernetes集群上配置Kong或Kong Enterprise的试用版。

### 准备

1. 下载或克隆[Kong Kubernetes存储库](https://github.com/Kong/kong-dist-kubernetes/)
2. 一个Kubernetes集群

## 安装步骤

[Kong Kubernetes存储库](https://github.com/Kong/kong-dist-kubernetes/)包括 Make tasks `run_cassandra`，`run_postgres`和`run_dbless` 以便于使用，但我们将详细说明任务在此处使用的特定YAML文件。

对于所有变体，创建Kong命名空间:
```
$ kubectl apply -f kong-namespace.yaml
```
下一步取决于您是否要使用Kong与Cassandra，Postgres或没有数据存储区：

### Cassandra Backed Kong

使用此存储库中的`cassandra-service.yaml`和`cassandra-statefulset.yaml`文件在集群中部署`Cassandra`服务和`StatefulSet`。
```
$ kubectl apply -f cassandra-service.yaml
$ kubectl apply -f cassandra-statefulset.yaml
```

使用此存储库中的`kong-control-plane-cassandra.yaml`文件运行所需的迁移并部署Kong控制平面节点，包括Kong admin api
```
$ kubectl -n kong apply -f kong-control-plane-cassandra.yaml
```

使用此存储库中的`kong-ingress-data-plane-cassandra.yaml`文件运行Kong数据平面节点
```
$ kubectl -n kong apply -f kong-ingress-data-plane-cassandra.yaml
```

### PostgreSQL Backed Kong

使用存储库中的`postgres.yam`l文件在集群中部署postgreSQL服务和`ReplicationController`：
```
$ kubectl create -f postgres.yaml
```
使用此存储库中的`kong-control-plane-postgres.yaml`文件运行所需的迁移并部署Kong控制平面节点，包括Kong Admin API：
```
$ kubectl -n kong apply -f kong-control-plane-postgres.yaml
```
使用此存储库中的`kong-ingress-data-plane-postgres.yaml`文件运行Kong数据平面节点
```
$ kubectl -n kong apply -f kong-ingress-data-plane-postgres.yaml
```

### Using Datastore Backed Kong

首先，让我们确保Kong控制平面和数据平面成功运行
```
kubectl get all -n kong
NAME                           READY   STATUS
pod/kong-control-plane         1/1     Running
pod/kong-ingress-data-plane    1/1     Running
```
访问Kong Admin API端口（如果运行minikube，则以下内容应该有效）：
```
$ export HOST=$(kubectl get nodes --namespace default -o jsonpath='{.items[0].status.addresses[0].address}')
$ export ADMIN_PORT=$(kubectl get svc --namespace kong kong-control-plane  -o jsonpath='{.spec.ports[0].nodePort}')
```

### Using Kong without a Database

对于declarative / db-less，使用此存储库中的`declarative.yaml`示例文件创建配置映射
```
$ kubectl create configmap kongdeclarative -n kong --from-file=declarative.yaml
```
现在使用此存储库中的`kong-dbless.yaml`文件部署Kong数据平面
```
$ kubectl apply -f kong-dbless.yaml
```

### Using Declarative / DB Less Backed Kong

要更新declarative / db-less Kong，请编辑声明性文件，然后替换配置映射
```
$ kubectl create configmap kongdeclarative -n kong --from-file=declarative.yaml -o yaml --dry-run | kubectl replace -n kong -f -
```
现在使用声明性Kong yaml文件的`md5sum`进行滚动部署
```
$ kubectl patch deployment kong-dbless -n kong -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"declarative\":\"`md5sum declarative.yaml | awk '{ print $$1 }'`\"}}}}}}"
```
访问Kong Admin API端口（如果运行minikube，则以下内容应该有效）：
```
$ export HOST=$(kubectl get nodes --namespace default -o jsonpath='{.items[0].status.addresses[0].address}')=
$ export ADMIN_PORT=$(kubectl get svc --namespace kong kong-control-plane  -o jsonpath='{.spec.ports[0].nodePort}')
```

## Kong Enterprise 试用用户的附加步骤

1. 将Kong Enterprise Docker映像发布到容器注册表

    由于Kong Enterprise映像在公共Docker容器注册表中不可用，因此必须将其发布到私有存储库以与Kubernetes一起使用。虽然任何私有存储库都可以使用，但此示例使用[Google Cloud Platform容器注册表](https://cloud.google.com/container-registry/)，该注册表在其他步骤中自动与Google Cloud Platform示例集成。	
    
    在下面的步骤中，将 `<image ID>` 替换为与docker images输出中已加载图像关联的ID。将 `<project ID>` 替换为您的Google Cloud Platform项目ID。
    ```
     $ docker load -i /tmp/kong-docker-enterprise-edition.tar.gz
     $ docker images
     $ docker tag <image ID> gcr.io/<project ID>/kong-ee
     $ gcloud docker -- push gcr.io/demo-cs-lab/kong-ee:latest
    ```
    
2. 添加您的Kong Enterprise许可文件

    编辑`kong_trial_postgres.yaml`和`kong_trial_migration_postgres.yaml`，将`YOUR_LICENSE_HERE`替换为您的Kong Enterprise License File字符串 - 它应如下所示：
    ```
     - name: KONG_LICENSE_DATA
     value: '{"license":{"signature":"alongstringofcharacters","payload":{"customer":"Test Company","license_creation_date":"2018-03-06","product_subscription":"Kong Only","admin_seats":"5","support_plan":"Premier","license_expiration_date":"2018-06-04","license_key":"anotherstringofcharacters"},"version":1}}'
    ```
3. 使用Kong Enterprise图像

	编辑`kong_trial_postgres.yaml`和`kong_trial_migration_postgres.yaml`并将`image：kong`替换为`image：gcr.io/<project ID> / kong-ee`，使用与上面相同的项目ID。
    
    
4. 部署Kong Enterprise

	使用[Kong Enterprise Trial目录](https://github.com/Kong/kong-dist-kubernetes/tree/master/ee-trial)中的`kong_trial_*` YAML文件，从上面的Manifest Files指令继续执行Kong或Kong Enterprise中的步骤4。
    一旦Kong Enterprise运行，您应该能够通过`<kong-admin-ip-address>：8002`或`https：// <kong-ssl-admin-ip-address>：8445`访问Kong Admin GUI。

