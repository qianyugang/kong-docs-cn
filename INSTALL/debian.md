# 在 Debian 安装 Kong

## 安装包

首先下载适合您的配置的软件包：

- 7 Wheezy：https://bintray.com/kong/kong-deb/download_file?file_path=kong-1.3.0.wheezy.amd64.deb
- 8 Jessie：https://bintray.com/kong/kong-deb/download_file?file_path=kong-1.3.0.jessie.amd64.deb
- 9 Stretch：https://bintray.com/kong/kong-deb/download_file?file_path=kong-1.3.0.stretch.amd64.deb

## APT 资源

您也可以通过APT安装Kong；
请按照以下页面上的“Set Me Up”部分中的说明进行操作，将分发设置为适当的值（例如，`wheezy`），并将组件设置为`main`。

https://bintray.com/kong/kong-deb

## 安装

1. 安装 Kong

	如果要下载[软件包](https://docs.konghq.com/install/debian/#packages)，请执行：
    ```
    $ sudo apt-get update
 	$ sudo apt-get install openssl libpcre3 procps perl
 	$ sudo dpkg -i kong-1.3.0.*.deb
    ```
    如果使用的是apt信息库，请执行：
    ```
    $ sudo apt-get update
     $ sudo apt-get install -y apt-transport-https curl lsb-core
     $ echo "deb https://kong.bintray.com/kong-deb `lsb_release -sc` main" | sudo tee -a /etc/apt/sources.list
     $ curl -o bintray.key https://bintray.com/user/downloadSubjectPublicKey?username=bintray
     $ sudo apt-key add bintray.key
     $ sudo apt-get update
     $ sudo apt-get install -y kong
    ```

2. 准备数据库或声明性配置文件

	Kong可以在有或没有数据库的情况下运行。
    
    使用数据库时，将使用`kong.conf`配置文件在启动时设置Kong的配置属性，并将数据库存储为所有已配置实体（例如Kong代理的路由和服务）的存储。
    
    当不使用数据库时，将使用`kong.conf`的配置属性和`kong.yml`文件将实体指定为声明性配置。
    
    **使用数据库**
    
    [配置](https://docs.konghq.com/1.3.x/configuration#database)Kong以便它可以连接到您的数据库。Kong支持[PostgreSQL 9.5+](http://www.postgresql.org/)和[Cassandra 3.x.x](http://cassandra.apache.org/)作为其数据存储。
    
    如果您使用Postgres，请在开始Kong之前配置数据库和用户，即：
    ```
    CREATE USER kong; CREATE DATABASE kong OWNER kong;
    ```
    
   	然后执行Kong的数据迁移：
    
    ```
     $ kong migrations bootstrap [-c /path/to/kong.conf]
    ```
    
    对于Kong 小于0.15的注意事项：如果Kong版本低于0.15（最高0.14），请使用up子命令而不是bootstrap。另请注意，如果Kong 小于0.15，则不应同时进行迁移;只有一个Kong节点应该一次执行迁移。对于0.15,1.0及以上的Kong，此限制被取消。
    
    **不使用数据库**
    
    如果要在[无DB模式](https://docs.konghq.com/1.3.x/db-less-and-declarative-config/)下运行Kong，则应首先生成声明性配置文件。以下命令将在当前文件夹中生成`kong.yml`文件。它包含有关如何填写它的说明。
    ```
    $ kong config init
    ```
    填写`kong.yml`文件后，编辑您的`kong.conf`文件。将`database`选项设置为`off`，将`declarative_config`选项设置为`kong.yml`文件的路径：
    ```
    database = off
 	declarative_config = /path/to/kong.yml
    ```

3. 启动Kong
    ```
    $ kong start [-c /path/to/kong.conf]
    ```
    
4. 使用Kong
    Kong正在运行
    ```
     $ curl -i http://localhost:8001/
    ```
    
      
    
    
    
    














