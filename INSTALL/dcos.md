# 在 DC/OS 集群安装

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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    