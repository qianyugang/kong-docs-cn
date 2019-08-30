# 使用源码安装 Kong

无论是否有数据库，Kong都可以运行。

使用数据库时，您将使用`kong.conf`配置文件在启动时设置Kong的配置属性，并将数据库用作所有已配置实体的存储，例如Kong代理所在的 Routes 和 Services 。

不使用数据库时，您将使用`kong.conf`的配置属性和`kong.yml`文件来将实体指定为声明性配置。

## 使用数据库

1. 安装依赖项

	[OpenResty 1.15.8.1](https://openresty.org/en/installation.html)。作为一个OpenResty应用程序，您必须遵循OpenResty[安装说明](https://openresty.org/en/installation.html)。您将需要OpenSSL和PCRE来编译OpenResty，并至少使用以下编译选项:
    ```
     $ ./configure \
       --with-pcre-jit \
       --with-http_ssl_module \
       --with-http_realip_module \
       --with-http_stub_status_module \
       --with-http_v2_module
    ```
    您可能必须指定`--with-openssl`，并且可以添加任何其他您想要的选项，例如其他Nginx模块或自定义`--prefix`目录。
    
    OpenResty可以方便地捆绑[LuaJIT](http://luajit.org/)和[resty-cli](https://github.com/openresty/resty-cli)，它们对于Kong来说是必不可少的。将`ngin`x和`resty`可执行文件添加到`$ PATH`：
    ```
     $ export PATH="$PATH:/usr/local/openresty/bin"
    ```
    [Luarocks 3.1.3](https://github.com/keplerproject/luarocks/wiki/Download)，使用与OpenResty捆绑的LuaJIT版本编译（请参阅`--with-lua`和`--with-lua-include`配置选项）。例：
    ```
     ./configure \
       --lua-suffix=jit \
       --with-lua=/usr/local/openresty/luajit \
       --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1
    ```
    
2. 安装 Kong

	现在已经安装了OpenResty，我们可以使用Luarocks来安装Kong的Lua源：
    ```
     $ luarocks install kong 1.3.0-0
    ```
    或者
    ```
     $ git clone git@github.com:Kong/kong.git
     $ cd kong
     $ [sudo] make install # this simply runs the `luarocks make kong-*.rockspec` command
    ```
    
3. 添加`kong.conf`

	> 注意：如果您使用的是Cassandra，则需要执行此步骤;它是Postgres用户的可选项。

    默认情况下，Kong配置为与本地Postgres实例通信。
    如果您使用的是Cassandra，或者需要修改任何设置，请下载[kong.conf.default](https://raw.githubusercontent.com/Kong/kong/master/kong.conf.default)文件并根据需要进行调整。
    然后，以root身份将其添加到`/etc`：
    ```
     $ sudo mkdir -p /etc/kong
 	 $ sudo cp kong.conf.default /etc/kong/kong.conf
    ```
    
4. 准备数据库

	[配置](https://docs.konghq.com/1.3.x/configuration#database)Kong以便它可以连接到您的数据库。Kong支持[PostgreSQL 9.5+](http://www.postgresql.org/)和[Cassandra 3.x.x](http://cassandra.apache.org/)作为其数据存储。
    
    如果您使用的是Postgres，请在启动Kong之前配置数据库和用户：
    ```
    CREATE USER kong; CREATE DATABASE kong OWNER kong;
    ```
    接下来，运行Kong迁移：
    ```
     $ kong migrations bootstrap [-c /path/to/kong.conf]
    ```
    
    > 对于Kong < 0.15的注意事项：如果Kong版本低于0.15（最高0.14），请使用`up`子命令而不是`bootstrap`。另请注意，如果Kong < 0.15，则不应同时进行迁移;只有一个Kong节点应该一次执行迁移。对于0.15,1.0及以上的Kong，此限制被取消。
    
5. 启动Kong
	
    ```
    $ kong start [-c /path/to/kong.conf]
    ```
    
6. 使用Kong
	
    Kong正在运行
    ```
     $ curl -i http://localhost:8001/
    ```
    
    
## 不使用数据库

1. 按照上面的列表中的步骤1和2（安装依赖项，安装Kong）。

2. 写声明性配置文件

	以下命令将在当前文件夹中生成`kong.yml`文件。它包含有关如何填写它的说明。执行此操作时，请遵循[声明配置格式]：/1.3.x/db-less-and-declarative-config/#the-declarative-configuration-format说明。
    ```
     $ kong config init
    ```
    我们假设该文件名为`kong.yml`。
    
3. 添加`kong.conf`

	下载[kong.conf.default](https://raw.githubusercontent.com/Kong/kong/master/kong.conf.default)文件并根据需要进行[调整](https://docs.konghq.com/1.3.x/configuration#database)。
    
    特别是，确保将`database`配置选项设置为`off`，并将`declarative_config`选项设置为`kong.yml`的绝对路径
    ```
     database = off
     ...
     declarative_config = /path/to/kong.yml
    ```
    
4. 启动Kong
	
    ```
    $ kong start [-c /path/to/kong.conf]
    ```
    
5. 使用Kong
	
    Kong正在运行
    ```
     $ curl -i http://localhost:8001/
    ```
    
    
    
    
    