# 使用Docker 安装 Kong

> 本文原文链接：https://docs.konghq.com/install/docker/

有关如何在Docker中使用Kong的详细信息可以在镜像图像的DockerHub存储库中找到：[kong](https://hub.docker.com/_/kong/)。
我们还有一个[Docker Compose template](https://github.com/Kong/docker-kong/tree/master/compose)，内置编排和可扩展性。

## 使用数据库

这是一个快速示例，显示如何将Kong容器连接到Cassandra或PostgreSQL容器。

1. 创建一个Docker network

	您需要创建一个自定义网络，以允许容器相互发现和通信。在此示例中，`kong-net`是网络名称，您可以使用任何名称。
    ```
    $ docker network create kong-net
    ```
2. 启动数据库

	如果您想使用Cassandra容器：
    ```
     $ docker run -d --name kong-database \
               --network=kong-net \
               -p 9042:9042 \
               cassandra:3
    ```
    如果您想使用PostgreSQL容器：
    ```
     $ docker run -d --name kong-database \
               --network=kong-net \
               -p 5432:5432 \
               -e "POSTGRES_USER=kong" \
               -e "POSTGRES_DB=kong" \
               -e "POSTGRES_PASSWORD=Passw0rd" \
               -e "POSTGRES_HOST_AUTH_METHOD=trust" \
               postgres:9.6
    ```
3. 准备数据库

	使用临时Kong容器运行迁移：
    ```
    $ docker run --rm \
        --network=kong-net \
        -e "KONG_LOG_LEVEL=debug" \
        -e "KONG_DATABASE=postgres" \
        -e "KONG_PG_HOST=kong-database" \
        -e "KONG_PG_PASSWORD=Passw0rd" \
        -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
        kong:latest kong migrations bootstrap
    ```
    在上面的示例中，配置了Cassandra和PostgreSQL，但您应该使用`cassandra`或`postgres`更新`KONG_DATABASE`环境变量。    
    对于Kong 小于0.15的注意事项：如果Kong版本低于0.15（最高0.14），请使用up子命令而不是bootstrap。另请注意，如果Kong  版本小于0.15，则不应同时进行迁移;只有一个Kong节点应该一次执行迁移。对于0.15,1.0及以上的Kong，此限制被取消。

4. 启动Kong

	迁移运行并且数据库准备就绪后，启动一个将连接到数据库容器的Kong容器，就像临时迁移容器一样：
    ```
     $ docker run -d --name kong \
     --network=kong-net \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=kong-database" \
     -e "KONG_PG_PASSWORD=Passw0rd" \
     -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
     -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
     -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
     -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
     -p 8000:8000 \
     -p 8443:8443 \
     -p 8001:8001 \
     -p 8444:8444 \
     kong:latest
    ```

5. 使用Kong

	Kong正在运行：
    ```
     $ curl -i http://localhost:8001/
    ```
    通过[5分钟的快速入门](https://docs.konghq.com/latest/getting-started/quickstart)快速学习如何使用Kong。

## 无数据库模式

在无DB模式下启动Kong所涉及的步骤如下：

1. 创建一个Docker network

	这与Pg / Cassandra指南中的相同。我们也使用`kong-net`作为网络名称，它也可以改为其他东西。
    ```
     $ docker network create kong-net
    ```
    在无DB模式下运行Kong并不严格需要此步骤，但如果您希望将来添加其他内容（如Redis群集备份的速率限制插件），这是一个很好的预防措施。

2. 创建Docker volume

	对于本指南的目的，Docker卷是主机内的一个文件夹，可以将其映射到容器中的文件夹中。卷有一个名称。在这种情况下，我们将命名我们的`kong-vol`
    ```
     $ docker volume create kong-vol
    ```
    您现在应该能够检查volume：
    ```
     $ docker volume inspect kong-vol
    ```
    结果应该类似于：
    ```
     [
         {
             "CreatedAt": "2019-05-28T12:40:09Z",
             "Driver": "local",
             "Labels": {},
             "Mountpoint": "/var/lib/docker/volumes/kong-vol/_data",
             "Name": "kong-vol",
             "Options": {},
             "Scope": "local"
         }
 	]
    ```
    注意`MountPoint`条目。我们将在下一步中使用该路径。

3. 准备声明性配置文件

	[声明性配置格式](https://docs.konghq.com/1.3.x/db-less-and-declarative-config/#the-declarative-configuration-format)指南中描述了语法和属性。
    
    添加您需要的任何核心实体（服务，路由，插件，消费者等）。
    
    在本指南中，我们假设您将其命名为kong.yml。
    
    将其保存在上一步中提到的`MountPoint`路径中。
    
    就本指南而言，这将是`/var/lib/docker/volumes/kong-vol/_data/kong.yml`

4. 在无DB模式中启动Kong
	
    虽然可以仅使用`KONG_DATABASE=off`来启动Kong容器，但通常还需要通过`KONG_DECLARATIVE_CONFIG`变量名称将声明性配置文件作为参数包含在内。为此，我们需要从容器中使文件“visible”。我们使用`-v`标志来实现这一点，它将`kong-vol`卷映射到容器中的`/usr/local/kong/declarative`文件夹。
    ```
     $ docker run -d --name kong \
     --network=kong-net \
     -v "kong-vol:/usr/local/kong/declarative" \
     -e "KONG_DATABASE=off" \
     -e "KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml" \
     -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
     -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
     -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
     -p 8000:8000 \
     -p 8443:8443 \
     -p 8001:8001 \
     -p 8444:8444 \
     kong:latest
    ```

5. 使用Kong
	
    Kong应该正在运行，它应该包含一些以Kong .yml添加的实体。
    ```
     $ curl -i http://localhost:8001/
    ```
    例如，获取服务列表：
    ```
     $ curl -i http://localhost:8001/services
    ```
    




