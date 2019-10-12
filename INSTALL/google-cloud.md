# 在 google-cloud 安装 Kong

当前有两种选择可从Google Cloud Platform（GCP）市场安装Kong-您可以在CasCompandra上将Kong虚拟机部署在Google Compute Engine（GCE）上，也可以在Google Kubernetes Engine（GKE）上部署带有Postgres的Kong。

请注意，GCP的[免费套餐和积分](https://cloud.google.com/free/)，使您有可能免费在GCP上试用Kong！

## GKE上的Kong容器

要在GKE上与Postgres一起启动Kong，请访问[Kubernetes页面上的Kong](https://docs.konghq.com/install/kubernetes/#kong-via-google-cloud-platform-marketplace)并按照说明进行操作。

## GCE上的Kong虚拟机

要在GCE上与Cassandra一起启动Kong，请在[GCP市场上访问Kong](https://console.cloud.google.com/launcher/details/bitnami-launchpad/kong)并按照说明进行操作。