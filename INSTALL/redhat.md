# 在 Red Hat 安装 Kong

## 安装包

首先下载适合您的配置的软件包

- RHEL 6：https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/6/kong-1.3.0.rhel6.amd64.rpm
- RHEL 7：https://bintray.com/kong/kong-rpm/download_file?file_path=rhel/7/kong-1.3.0.rhel7.amd64.rpm

企业试用版用户应从其欢迎电子邮件中下载其软件包，并在步骤1之后将其许可证保存到`/etc/kong/license.json`。

## YUM 资源

您也可以通过YUM安装Kong；

请按照以下页面上的“Set Me Up”部分中的说明进行操作。

- RPM repository：https://bintray.com/kong/kong-rpm

注意：确保所生成的`.repo`文件的`baseurl`字段包含您的RHEL版本；例如：
```
baseurl=https://kong.bintray.com/kong-rpm/rhel/6
```
后者
```
baseurl=https://kong.bintray.com/kong-rpm/rhel/7
```

## 安装

1. 启用EPEL资源库

	在安装Kong之前，您需要为正确的操作系统版本安装`epel-release`软件包，以便Kong可以获取所有必需的依赖项：
    ```
     $ EL_VERSION=`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'` && \
   		sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${EL_VERSION%.*}.noarch.rpm

    ```

2. 安装Kong
	
    如果要下载[软件包](https://docs.konghq.com/install/redhat/#packages)，请执行：
    ```
     $ sudo yum install kong-1.3.0.*.noarch.rpm --nogpgcheck
    ```
    如果使用的是资源，请执行：
    ```
     $ sudo yum install -y wget
     $ wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
     $ export major_version=`grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d "." -f1`
     $ sed -i -e 's/baseurl.*/&\/rhel\/'$major_version''/ bintray-kong-kong-rpm.repo
     $ sudo mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
     $ sudo yum update -y
     $ sudo yum install -y kong
    ```
    
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
    
      
    
    
    
    
    
    
    
    

