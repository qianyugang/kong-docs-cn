# 在 CentOS 安装 Kong

## 安装包

首先下载配置的相应软件包：
- Centos6：https://bintray.com/kong/kong-rpm/download_file?file_path=centos/6/kong-1.3.0.el6.amd64.rpm
- Centos7：https://bintray.com/kong/kong-rpm/download_file?file_path=centos/7/kong-1.3.0.el7.amd64.rpm

企业试用用户应从其欢迎电子邮件中下载其包，并在步骤1之后将其许可保存到`/etc/kong/license.json`。

## YUM Repositories

你也可以通过YUM安装Kong;按照下面“Set Me Up”部分中的说明进行操作。
- RPM Repositoriy：https://bintray.com/kong/kong-rpm

注意：确保生成的`.repo`文件的`baseur`l字段包含您的CentOS版本;例如：
```
baseurl=https://kong.bintray.com/kong-rpm/centos/6
```
或者
```
baseurl=https://kong.bintray.com/kong-rpm/centos/7
```

## 安装

1. 安装Kong
	如果要下载[程序包](https://docs.konghq.com/install/centos/#packages)，请执行：
    ```
    $ sudo yum install epel-release
    $ sudo yum install kong-1.3.0.*.noarch.rpm --nogpgcheck
    ```
    如果您正在使用存储库，请执行：
    ```
     $ sudo yum update -y
     $ sudo yum install -y wget
     $ wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
     $ export major_version=`grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d "." -f1`
     $ sed -i -e 's/baseurl.*/&\/centos\/'$major_version''/ bintray-kong-kong-rpm.repo
     $ sudo mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
     $ sudo yum update -y
     $ sudo yum install -y kong
    ```
2. 准备数据库或声明性配置文件
    无论是否有数据库，Kong都可以运行。
    
    使用数据库时，您将使用	kong.conf	配置文件在启动时设置Kong的配置属性，并将数据库用作所有已配置实体的存储，例如Kong代理所在的 Routes 和 Services 。
    
    不使用数据库时，您将使用`kong.conf`的配置属性和`kong.yml`文件来将实体指定为声明性配置。
    
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
    填写`kong.yml`文件后，编辑您的`kong.conf`文件。将数据库选项设置为`off`，将`declarative_config`选项设置为`kong.yml`文件的路径：
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
    
      
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    