# 在 Vagrant 上安装

> 本文原文链接https://docs.konghq.com/install/vagrant/

Vagrant可用于为Kong及其依赖项创建隔离环境。

您可以将Vagrant框用作一体化的Kong安装用于测试目的，或者您可以将其与源代码链接并开始在Kong或定制插件上进行开发。

这是一个快速示例，显示如何构建（一次性）测试设置：

1. 获取Vagrantfile并启动VM
	```
    $ git clone https://github.com/Kong/kong-vagrant
 	$ cd kong-vagrant/
 	$ vagrant up
    ```

2. 启动 Kong
	默认的Vagrantfile将安装PostgreSQL和Cassandra。PostgreSQL是默认值：
    ```
    # 指定迁移标志以初始化数据存储
 	$ vagrant ssh -c "kong start --run-migrations"
    ```
    Cassandra可通过以下设置获得：
    ```
    $ vagrant ssh -c "KONG_DATABASE=cassandra kong start --run-migrations"
    ```
    要在无DB模式下启动Kong，请使用：
    ```
     $ vagrant ssh -c "KONG_DATABASE=off kong start"
    ```
    如果要包含[声明性配置文件](https://docs.konghq.com/1.3.x/db-less-and-declarative-config/)，请将其放在`./kong/kong.yml`文件夹中，并且可以通过Vagrant中的`/kong/kong.yml`路径获取：
    ```
     $ vagrant ssh -c "KONG_DECLARATIVE_CONFIG=/kong/kong.yml KONG_DATABASE=off kong start"
    ```
    主机端口`8000`,`8001`,`1843`和`8444`将被转发到Vagrant box。
    
    > 注意：查看[kong-vagrant](https://github.com/Kong/kong-vagrant)存储库以获取有关自定义和开发的更多详细信息。 

3. 开始使用Kong
	Kong已经启动：
    ```
     $ curl http://127.0.0.1:8001
    ```
