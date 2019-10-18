# 在 DC/OS 集群安装

> 本文原文链接：https://docs.konghq.com/install/dcos/

可以使用以下步骤在Mesosphere DC/OS群集上配置Kong：

以下步骤使用AWS来配置DC/OS集群，并假设您具有[DC/OS](https://dcos.io/docs/1.9/)，[Marathon](https://mesosphere.github.io/marathon/)，[VIP](https://dcos.io/docs/1.9/networking/load-balancing-vips/virtual-ip-addresses/)和[Marathon-LB](https://dcos.io/docs/1.9/networking/marathon-lb/)的基本知识。

1. 初始设定

	下载或克隆以下存储库：
    ```
    $ git clone git@github.com:Kong/kong-dist-dcos.git
 	$ cd kong-dist-dcos
    ```
    如果您已经配置了DC/OS群集，请跳到步骤3。
    
2. 部署一个DC/OS集群

	遵循DC/OS [AWS文档](https://dcos.io/docs/1.9/installing/oss/cloud/aws/)，部署将在其上配置Kong的DC / OS群集
    
    群集准备就绪后，可以使用[DC/OS CLI](https://dcos.io/docs/1.9/cli/)或[DC/OS GUI](https://dcos.io/docs/1.9/gui/)部署Kong。
    
3. 部署Marathon-LB
	
    我们将使用`marathon-lb`软件包来部署[Marathon-LB](https://dcos.io/docs/1.9/networking/marathon-lb/)来对群集的外部流量进行负载平衡，并使用VIP来对内部流量进行负载平衡：
    ```
     $ dcos package install marathon-lb
    ```

4. 部署kong支持的数据库

	在部署Kong之前，您需要预配一个Cassandra或PostgreSQL实例。
    
    对于Cassandra，请使用`cassandra`软件包在DC/OS集群中部署3个Cassandra节点：
    ```
     $ dcos package install cassandra
    ```
    对于PostgreSQL，请使用具有以下选项的postgresql软件包：
    ```
    {
       "service": {
         "name": "postgresql"
       },
       "postgresql": {
         "cpus": 0.3,
         "mem": 512
       },
       "database": {
         "username": "kong",
         "password": "kong",
         "dbname": "kong"
       },
       "storage": {
         "host_volume": "/tmp",
         "pgdata": "pgdata",
         "persistence": {
           "enable": true,
           "volume_size": 512,
           "external": {
             "enable": false,
             "volume_name": "postgresql",
             "provider": "dvdi",
             "driver": "rexray"
           }
         }
       },
       "networking": {
         "port": 5432,
         "host_mode": false,
         "external_access": {
           "enable": false,
           "external_access_port": 15432
         }
       }
     }
    ```
    它将PostgreSQL配置如下：

    - `username` :此参数配置Kong数据库的用户名 
    - `password` : 此参数配置Kong数据库的密码    
    - `dbname` : 此参数配置kong数据库的名称  
    - `persistence` : 此参数为PostgreSQL启用持久卷  

    使用仓库中的postgres.json文件安装PostgreSQL：
    ```
     $ dcos package install postgresql --options=postgres.json
    ```

5. 部署 Kong

	现在，我们有一个外部负载平衡器和Kong支持的数据库正在运行。使用Universe存储库中的[kong程序包](https://universe.dcos.io/#/package/kong/version/latest)，使用以下选项部署Kong：
    ```
     {
       "service": {
         "name": "kong",
         "instances": 1,
         "cpus": 1,
         "mem": 512,
         "role": "*"
       },
       "configurations": {
         "log-level": "notice",
         "database": {
           "migrations": true,
           "use-cassandra": false
         },
         "postgres": {
           "host": "postgresql.marathon.l4lb.thisdcos.directory",
           "port": 5432,
           "database": "kong",
           "user": "kong",
           "password": "kong"
         },
         "cassandra": {
           "contact-points": "node-0.cassandra.mesos, node-1.cassandra.mesos, node-2.cassandra.mesos",
           "port": 9042,
           "keyspace": "kong"
         }
       },
       "networking": {
         "proxy": {
           "external-access": true,
           "vip-port": 8000,
           "vip-port-ssl": 8443,
           "virtual-host": "<vhost>",
           "https-redirect": true,
           "service-port": 10201
         },
         "admin": {
           "external-access": true,
           "vip-port": 8001,
           "vip-port-ssl": 8444,
           "https-redirect": false,
           "service-port": 10202
         }
       }
     }
    ```
    它对Kong的配置如下：
    
    - `configurations.log_level`：设置Kong的log_level配置
    - `configurations.custom-envs`：以空格分隔的Kong配置列表
    - `configurations.database.use-cassandra`：如果为`true`，则将Cassandra用作Kong数据库
    - `configurations.database.migration`：如果为`true`，则Kong将在启动期间进行迁移
    - `configurations.postgres.host`：PostgreSQL host 
    - `configurations.postgres.port`：PostgreSQL 端口 
    - `configurations.postgres.database`：PostgreSQL 数据库 
    - `configurations.postgres.user`：PostgreSQL 用户名 
    - `configurations.postgres.password`：PostgreSQL 密码 
    - `configurations.cassandra.contact-points`：用逗号分隔的Cassandra联系人列表
    - `configurations.cassandra.port`：Cassandra监听查询的端口
    - `configurations.cassandra.keyspace`：在Cassandra中使用的keyspace。如果不存在，将被创建
    - `networking.proxy.external-access`：如果为`true`，则允许外部访问Kong的代理端口
    - `networking.proxy.virtual-host`：将Kong代理端口与Marathon-lb集成在一起的虚拟主机地址
    - `networking.proxy.https-redirect`：如果为`true`，则Marathon-lb将HTTP流量重定向到HTTPS。这需要设置“虚拟主机”
    - `networking.proxy.service-port`：用于从群集外部访问Kong的代理端口的端口号
    - `networking.proxy.vip-port`：用于内部与代理API通信的端口号。默认值为8000
    - `networking.proxy.vip-port-ssl`：用于内部与代理API进行安全通信的端口号。默认值为8443
    - `networking.admin.external-access`：如果为`true`，则允许外部访问Kong的管理端口
    - `networking.admin.virtual-host`：将Kong管理端口与Marathon-lb集成在一起的虚拟主机地址
    - `networking.admin.https-redirect`：如果为`true`，则Marathon-lb将HTTP流量重定向到HTTPS。这需要设置“虚拟主机”
    - `networking.admin.service-port`：用于从群集外部访问Kong的管理端口的端口号
    - `networking.admin.vip-port`：用于内部与Admin API通信的端口号。默认值为8001
    - `networking.admin.vip-port-ssl`：用于内部与Admin API进行安全通信的端口号。默认值为8444
    
    注意：根据您选择的数据存储区来调整上述配置。
	
    运行以下命令以安装Kong软件包：
    ```
    $ dcos package install kong --options=kong_postgres.json
    ```
    
6. 验证部署

	要验证我们的Kong实例是否已启动并正在运行，可以使用dcos task命令：
    ```
     $ dcos task
     NAME         HOST        USER  STATE  ID
     kong         10.0.1.8   root    R    kong.af46c916-3b55-11e7-844e-52921ef4378d
     marathon-lb  10.0.4.42  root    R    marathon-lb.d65c3cc3-3b54-11e7-844e-52921ef4378d
     postgres     10.0.1.8   root    R    postgres.5b0a2635-3b55-11e7-844e-52921ef4378d
    ```
    
7. 使用Kong

	现在已经安装了Kong，以测试配置，将SSH SSH到群集中的一个实例（例如主实例）中，然后尝试curl端点：
    
    **Admin**
    
    ```
     $ curl -i -X GET http://marathon-lb.marathon.mesos:10202
     HTTP/1.1 200 OK
     ..

     {..}
    ```

	**Proxy**
    
    ```
     $ curl -i -X GET http://marathon-lb.marathon.mesos:10201
     HTTP/1.1 404 Not Found
     ..

     {"message":"no API found with those values"}
    ```
    
    **VHOST**
    
    在此示例中，用于公开Kong的代理端口的公共DNS名称是`mesos-tes-PublicSl-1TJB5U5K35XXT-591175086.us-east-1.elb.amazonaws.com`。
    
	注意：Kong在代理端口上返回404是有效的响应，因为尚未注册任何API。
    
8. 卸载 Kong

	要卸载Kong，请运行以下命令：
    ```
    $ dcos package uninstall kong
    ```
    
9. 例子
	
    在本示例中，我们创建了一个应用程序，该应用程序在端口`8080`上返回`Hello world`。使用kong-dist-dcos存储库中的`my_app.json`文件，将该应用程序部署在群集中，该群集将充当后端服务器来处理从Kong接收的请求：
    ```
    $ dcos marathon app add my_app.json
    ```
    在Kong上创建一个API：
    ```
     $ curl -i -X POST marathon-lb.marathon.mesos:10002/apis \
       --data "name=myapp" \
       --data "hosts=myapp.com" \
       --data "upstream_url=http://myapp.marathon.l4lb.thisdcos.directory:8080"
     HTTP/1.1 201 Created
	 ...

    ```
    向API发出请求：
    ```
     $ curl -i -X GET marathon-lb.marathon.mesos:10001 \
       --header "Host:myapp.com"
     HTTP/1.1 200 OK
     ...

     Hello world
    ```
	
    
    
    
    
    
    
    
    
    
    
