# 在 macOS 上安装 Kong

## 安装包

- Homebrew Formula：https://github.com/Kong/homebrew-kong

## 安装

1. 安装 Kong

	使用[Homebrew](https://brew.sh/)包管理器添加Kong作为点击并安装它：
    ```
    $ brew tap kong/kong
 	$ brew install kong
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
    
    默认情况下，Kong配置为与本地Postgres实例通信。如果您使用的是Cassandra，或者需要修改任何设置，请下载`kong.conf.default`文件并根据需要进行调整。然后，以root身份将`kong.conf.default`添加到`/etc`：
    ```
    $ sudo mkdir -p /etc/kong
 	$ sudo cp kong.conf.default /etc/kong/kong.conf
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
    
    