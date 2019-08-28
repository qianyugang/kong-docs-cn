# Docker Kong 中文文档
** 原文链接：** [https://docs.docker-cn.com/samples/kong/](https://docs.docker-cn.com/samples/kong/)  
（如有翻译的不准确或错误之处，欢迎留言指出）
## Kong
一个运行在Nginx上的开源微服务&API管理工具。  
github项目地址：[https://github.com/Mashape/kong](https://github.com/Mashape/kong)
> 参考提示：  
> 此内容从[Docker官方文档](https://github.com/docker-library/docs/tree/master/kong/)导入,它是由原始上传者提供。你可以点击此页面查看Kong的Docker Store页面 [ https://store.docker.com/images/kong.]( https://store.docker.com/images/kong.)

## 支持的标签和相应的Dockerfile链接
- 0.10, 0.10.1, latest ([Dockerfile](https://github.com/Mashape/docker-kong/blob/1edce50d74f0f3de63185a85a2741d2d2bf47112/Dockerfile))
- 0.9, 0.9.9 ([Dockerfile](https://github.com/Mashape/docker-kong/blob/b512fa58a9c5a085b21bc5ffb90299cbc4e48eba/Dockerfile))

有关上述每个受支持标记的已发布工件的详细信息（image metadata, transfer size, etc等），请点击[the docker-library/repo-info GitHub repo](the docker-library/repo-info GitHub repo.) 中的 [the repos/kong directory](https://github.com/docker-library/repo-info/blob/master/repos/kong)  。  

有关这个镜像和它的历史等更多信息，请点击[the relevant manifest file (library/kong)](https://github.com/docker-library/official-images/blob/master/library/kong) 查看。镜像更新地址为[pull requests to the docker-library/official-images GitHub repo](https://github.com/docker-library/official-images/pulls?q=label%3Alibrary%2Fkong)。

## Kong 是什么

Kong旨在保护，管理和扩展微服务和API。如果您正在开发构建一个web服务，手机服务，或者物联网服务，你可能需要在软件上实现通用功能，Kong可以充当一个网关的角色通过提供日志，认证或者其他功能的插件来给给HTTP提供任何资源。

由NGINX和Cassandra提供支持，专注于高性能和可靠性，Kong为数以万计的api服务提供支持。  

Kong的文档点击[getkong.org/docs](http://getkong.org/docs)查看。

## Kong 镜像
### 如何使用这个镜像

首先，首先，Kong需要在启动之前运行Cassandra 2.2.x或PostgreSQL 9.4 / 9.5集群。
您可以使用官方的Cassandra / PostgreSQL容器，也可以使用自己的容器

#### 1、将Kong链接到Cassandra或PostgreSQL容器

您可以自由决定使用Cassandra或PostgreSQL，Kong对于这两者都支持。

##### Cassandra

通过执行以下命令启动Cassandra容器：
```
$ docker run -d --name kong-database \
                -p 9042:9042 \
                cassandra:2.2
```


#### Postgres

通过执行以下命令启动PostgreSQL容器：
```
docker run -d --name kong-database \
                -p 5432:5432 \
                -e "POSTGRES_USER=kong" \
                -e "POSTGRES_DB=kong" \
                postgres:9.4
```

#### 启动Kong

当数据库已经正常启动，我们可以启动一个Kong容器并将其链接到数据库容器，并使用cassandra或postgres配置KONG_DATABASE环境变量，具体取决于您决定使用的数据库。
```
$ docker run -d --name kong \
    --link kong-database:kong-database \
    -e "KONG_DATABASE=cassandra" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PG_HOST=kong-database" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    kong
```

如果一切顺利的话，如果您使用默认端口创建容器，Kong已经已经监听了 8000端口([proxy](http://getkong.org/docs/latest/configuration/#proxy_port)) ,8443端口([proxy SSL](http://getkong.org/docs/latest/configuration/#proxy_listen_ssl)),8001端口([admin api](http://getkong.org/docs/latest/configuration/#admin_api_port))。端口7946（[cluster](http://getkong.org/docs/latest/configuration/#cluster_listen)）由Kong的其他节点使用。  
您可以阅读更多文档来学习Kong [getkong.org/docs](getkong.org/docs)。

### 2、使用Kong自定义配置（以及自定义Cassandra / PostgreSQL集群）
您可以使用环境变量覆盖[Kong配置文件](http://getkong.org/docs/latest/configuration/)的任何属性,只需要在任何Kong的配置文件属性前加上`KONG_`属性。举个例子：
```
$ docker run -d --name kong \
    -e "KONG_LOG_LEVEL=info" \
    -e "KONG_CUSTOM_PLUGINS=helloworld" \
    -e "KONG_PG_HOST=1.1.1.1" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    kong
```

### 在一个正在运行的容器中重启Kong
如果你更改了您的自定义配置，你可以重启kong（没有重启时间）用下列命令：
```
docker exec -it kong kong reload
```
它将会在这个容器中运行命令 `kong reload`

### License
查看此映像中包含的软件的[许可证信息](https://getkong.org/license/)。

### 支持的 Docker 版本
Docker版本17.04.0-ce正式支持此镜像。  
尽量支持到低版本（1.6）。  
查看[docker安装文档](https://docs.docker-cn.com/installation/)获取如何升级你的docker守护进程。  

### 用户反馈

#### 问题
如果您对此镜像有任何问题，请通过[Githun issue](https://github.com/Mashape/kong/issues)联系我们，如果问题与CVE有关，请先在官方图像存储库中检查[cve-tracker](https://github.com/docker-library/official-images/issues?q=label%3Acve-tracker)问题。

#### 贡献
您可以为此镜像加入任何更新，修复，新功能，不论复杂或者简单的功能，我们一直乐于收到大家的任何请求，并会尽快处理它们。  
在开始编码之前，我们建议您通过[GitHub](https://github.com/Mashape/kong/issues)问题讨论您的计划，特别是有一些宏达的想法的时候，这样其他贡献者有机会可以为你指出正确的方向，给你设计上的反馈，并帮助您了解到是否有其他的开发者在和您做一样的事情。
#### 文档
此镜像的文档存储在[docker-library/docs GitHub repo](https://github.com/docker-library/docs)的 [kong/ directory](https://github.com/docker-library/docs/tree/master/kong) 上，在尝试拉取请求之前，请务必熟悉存储库的[README.md](https://github.com/docker-library/docs/blob/master/README.md)文件。






