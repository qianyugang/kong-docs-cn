# 在 Amazon Linux 上安装 Kong

## 安装包

首先下载专门为Amazon Linux AMI构建的以下软件包：
- https://bintray.com/kong/kong-rpm/download_file?file_path=amazonlinux/amazonlinux/kong-1.4.0.aws.amd64.rpm

企业试用版用户应从其电子邮件中下载其软件包，并在步骤1之后将其许可证保存到`/etc/kong/license.json`。

## YUM存储库

您也可以通过YUM安装Kong；
请按照以下页面上的“设置我”部分中的说明进行操作。

- RPM repository：https://bintray.com/kong/kong-rpm

> 注意：确保所生成的`.repo`文件的`baseurl`字段包含amazonlinux / amazonlinux；

```
baseurl=https://kong.bintray.com/kong-rpm/amazonlinux/amazonlinux
```

## 安装

1. 安装Kong
	如果要下载[软件包](https://docs.konghq.com/install/aws-linux/#packages)，请执行：
    ```
    $ sudo yum install epel-release
 	$ sudo yum install kong-1.4.0.aws.rpm --nogpgcheck
    ```
    如果使用的是存储库，请执行：
    ```
     $ sudo yum update -y
     $ sudo yum install -y wget
     $ sudo amazon-linux-extras install -y epel
     $ wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
     $ sed -i -e 's/baseurl.*/&\/amazonlinux\/amazonlinux'/ bintray-kong-kong-rpm.repo
     $ mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
     $ sudo yum update -y
     $ sudo yum install -y kong
    ```
    
2. 准备数据库或声明性配置文件
    Kong在有没有数据库的情况下都可以运行。
    
    当使用数据库时，将使用`kong.conf`配置文件在启动时设置Kong的配置属性，并使用数据库存储为所有已配置实体（例如Kong代理的路由和服务）。
    
    不使用数据库时，将使用`kong.conf`的配置属性和`kong.yml`文件将实体指定为声明性配置。
    
    **使用数据库**
    
    [配置](https://docs.konghq.com/1.4.x/configuration#database)Kong，以便它可以连接到您的数据库。Kong支持[PostgreSQL 9.5+](http://www.postgresql.org/)和[Cassandra 3.x.x](http://cassandra.apache.org/)作为数据存储。
    
    如果您使用的是Postgres，请在启动Kong之前配置数据库和用户，即：
    ```
     CREATE USER kong; CREATE DATABASE kong OWNER kong;
    ```
    现在，运行Kong迁移：
    ```
     $ kong migrations bootstrap [-c /path/to/kong.conf]
    ```
    > 请注意Kong版本 小于 0.15：Kong版本低于0.15（最高0.14）时，请使用up子命令而不是`bootstrap`。还要注意，Kong 版本小于0.15时，永远不要同时运行迁移；一次只能有一个Kong节点执行迁移。对于0.15、1.0及更高版本，此限制被取消。
    
	**不使用数据库** 
    
    如果要在无数据库模式下运行Kong，则应首先生成声明性配置文件。以下命令将在当前文件夹中生成`kong.yml`文件。它包含有关如何填充它的说明。
    ```
     $ kong config init
    ```
    
    填充`kong.yml`文件后，编辑`kong.conf`文件。将数据库选项设置为`off`，并将`declarative_config`选项设置为`kong.yml`文件的路径：
    ```
     database = off
 	declarative_config = /path/to/kong.yml
    ```
    
3. 启动 Kong

	```
     $ kong start [-c /path/to/kong.conf]
    ```
    
4. 使用Kong

	查看 Kong 是否运行：
    ```
     $ curl -i http://localhost:8001/
    ```
    
    
    
    
