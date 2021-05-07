## 配置加载

> 本文原文地址：https://docs.konghq.com/1.1.x/configuration/

如果您通过官方软件包安装Kong，则可以在`/etc/kong/kong.conf.default`找到默认配置文件。
要开始配置Kong，您可以复制此配置文件文件：

```
$ cp /etc/kong/kong.conf.default /etc/kong/kong.conf
```

如果您的配置文件中的所有值都被注释掉，Kong将使用默认设置运行。
启动时，Kong会自动查找可能包含配置文件的多个默认位置：

```
/etc/kong/kong.conf
/etc/kong.conf
```

您可以通过使用CLI中的`-c / --conf`参数，为配置文件指定自定义路径：

```
$ kong start --conf /path/to/kong.conf
```

配置文件格式修改很简单：只需取消注释任何属性（注释由`#`字符定义）并根据需要进行修改。为方便起见，可以将布尔值指定为`on / off`或`true / false`。


## 校验配置

您可以使用`check`命令验证设置的完整性：

```
$ kong check <path/to/kong.conf>
configuration at <path/to/kong.conf> is valid
```

此命令将考虑您当前设置的环境变量，并在设置无效时报错。此外，您还可以在调试模式下使用CLI，以便更深入地了解Kong的启动属性

```
$ kong start -c <kong.conf> --vv
2016/08/11 14:53:36 [verbose] no config file found at /etc/kong.conf
2016/08/11 14:53:36 [verbose] no config file found at /etc/kong/kong.conf
2016/08/11 14:53:36 [debug] admin_listen = "0.0.0.0:8001"
2016/08/11 14:53:36 [debug] database = "postgres"
2016/08/11 14:53:36 [debug] log_level = "notice"
[...]
```

## 环境变量

从配置文件中加载属性时，Kong还将查找具有相同名称的环境变量。
您可以通过环境变量完全配置Kong，这对于基于容器的基础结构非常方便。要使用环境变量覆盖设置，请使用设置名称声明环境变量，前缀为`KONG_`并大写。例：

```
log_level = debug # in kong.conf
```
可以被如下系统环境变量覆盖：
```
$ export KONG_LOG_LEVEL=error
```

## 注入 Nginx 指令

通过调整Kong实例的Nginx配置，您可以优化其基础架构的性能。当Kong启动时，它会构建一个Nginx配置文件。您可以通过Kong配置直接将自定义Nginx指令注入此文件。

### 注入单个 Nginx 指令

添加到`kong.conf`文件中的任何以`nginx_http_`，`nginx_proxy_`或`nginx_admin_`为前缀的条目将通过删除前缀并添加到Nginx配置的相应部分而转换为等效的Nginx指令。

- 带有`nginx_http_`前缀的条目将被注入整个`http`块指令。
- 带有`nginx_proxy_`前缀的条目将被注入到处理Kong的代理端口的`Service`块指令中。
- 带有`nginx_admin_`前缀的条目将被注入到处理Kong的Admin API端口的服务器块指令中。

例如，如果将以下行添加到`kong.conf`文件中：

```
nginx_proxy_large_client_header_buffers=16 128k
```

它会将以下指令添加到Kong的Nginx配置的代理`Service`块中：

```
large_client_header_buffers 16 128k;
```

与kong.conf中的任何其他条目一样，也可以使用环境变量指定这些指令，如上所示。
例如，如果您声明一个这样的环境变量：

```
export KONG_NGINX_HTTP_OUTPUT_BUFFERS="4 64k"
```

这样将以下Nginx指令添加到http模块

```
output_buffers 4 64k;
```

与往常一样，请注意shell的引用规则，指定包含空格的值。有关Nginx配置文件结构和块指令的更多详细信息，请参阅https://nginx.org/en/docs/beginners_guide.html#conf_structure。
但请注意，某些指令依赖于特定的Nginx模块，其中一些模块可能不包含在Kong的官方版本中。

### 通过注入的Nginx指令包含文件

对于更复杂的配置方案，例如添加整个新`Servic`块，您可以使用上述方法将include指令注入Nginx配置，指向包含其他Nginx设置的文件。

或者，如果使用以下内容创建名为`my-server.kong.conf`的文件：

```
# custom server
server {
  listen 2112;
  location / {
    # ...more settings...
    return 200;
  }
}
```

您可以通过在kong.conf文件中添加以下条目来使Kong节点服务于此端口：

```
nginx_http_include = /path/to/your/my-server.kong.conf
```

或者，通过环境变量配置它：

```
$ export KONG_NGINX_HTTP_INCLUDE="/path/to/your/my-server.kong.conf"
```

现在，当你启动Kong时，该文件中的服务器部分将被添加到该文件中，这意味着其中定义的自定义服务器将与常规Kong端口一起响应：
```
$ curl -I http://127.0.0.1:2112
HTTP/1.1 200 OK
...
```

请注意，如果在`nginx_http_include`属性中使用相对路径，则该路径将相对于`kong.conf`文件的`prefix`属性的值进行解释（如果使用它来覆盖`kong start`的`-p`标志的值）
开始Kong时的前缀）。

## 自定义Nginx模板和嵌入Kong

对于绝大多数用例，使用上面解释的Nginx指令注入系统应该足以定制Kong的Nginx实例的行为。这样，您可以从单个`kong.conf`文件（以及可选的自己包含的文件）管理Kong节点的配置和调优，而无需处理自定义Nginx配置模板。

有两种情况您可能希望直接使用自定义Nginx配置模板：

- 在极少数情况下，您可能需要修改一些不能通过其标准`kong.conf`属性调整的Kong的默认Nginx配置，您仍然可以修改Kong使用的模板来生成其Nginx配置并使用您的自定义模板启动Kong。
- 如果您需要在已经运行的OpenResty实例中嵌入Kong，则Nginx section
Permalink可以重用Kong生成的配置并将其包含在现有配置中。

### 自定义Nginx模板

可以使用`--nginx-conf`参数启动，重新加载和重新启动Kong，该参数必须指定Nginx配置模板。这样的模板使用[Penlight](http://stevedonovan.github.io/Penlight/api/index.html)[模板引擎](http://stevedonovan.github.io/Penlight/api/libraries/pl.template.html)，该引擎使用给定的Kong配置进行编译，然后在启动Nginx之前将其转储到您的Kong前缀目录中。

可以在以下网址找到默认模板：https://github.com/kong/kong/tree/master/kong/templates 。
它分为两个Nginx配置文件：`nginx.lua`和`nginx_kong.lua`。前者是简约的，包括后者，其中包含了运行所需要的一切。
当kong start运行时，就在启动Nginx之前，它会将这两个文件复制到前缀目录中，如下所示：

```
/usr/local/kong
├── nginx-kong.conf
└── nginx.conf
```

如果你必须调整由Kong定义但不能通过kong.conf中的Kong配置调整的全局设置，你可以将nginx_kong.lua配置模板的内容内联到一个自定义模板文件（在这个例子中称为custom_nginx.template），例如：

```
# ---------------------
# custom_nginx.template
# ---------------------

worker_processes ${{NGINX_WORKER_PROCESSES}}; # can be set by kong.conf
daemon ${{NGINX_DAEMON}};                     # can be set by kong.conf

pid pids/nginx.pid;                      # this setting is mandatory
error_log logs/error.log ${{LOG_LEVEL}}; # can be set by kong.conf

events {
    use epoll;          # a custom setting
    multi_accept on;
}

http {

  # contents of the nginx_kong.lua template follow:

  resolver ${{DNS_RESOLVER}} ipv6=off;
  charset UTF-8;
  error_log logs/error.log ${{LOG_LEVEL}};
  access_log logs/access.log;

  ... # etc
}
```

然后你可以这样启动你的Nginx实例：

```
$ nginx -p /usr/local/openresty -c my_nginx.conf
```

并且Kong将在该实例中运行（在`nginx-kong.conf`中配置）。


## 使用Kong来给一个网站和APIs提供服务

API提供方的一个常见用例是使Kong通过代理端口（80或443）在生产中同时为网站和API提供服务。例如，https：//example.net（Website）和https://example.net/api/v1（API）。

为实现这一目标，我们不能简单地声明一个新的虚拟服务器块，就像我们在上一节中所做的那样。

一个好的解决方案是使用自定义的Nginx配置模板，该模板内联nginx_kong.lua并添加一个新的位置块，为Kong Proxy `location` 提供服务：

```
# ---------------------
# custom_nginx.template
# ---------------------

worker_processes ${{NGINX_WORKER_PROCESSES}}; # can be set by kong.conf
daemon ${{NGINX_DAEMON}};                     # can be set by kong.conf

pid pids/nginx.pid;                      # this setting is mandatory
error_log logs/error.log ${{LOG_LEVEL}}; # can be set by kong.conf
events {}

http {
  # here, we inline the contents of nginx_kong.lua
  charset UTF-8;

  # any contents until Kong's Proxy server block
  ...

  # Kong's Proxy server block
  server {
    server_name kong;

    # any contents until the location / block
    ...

    # here, we declare our custom location serving our website
    # (or API portal) which we can optimize for serving static assets
    location / {
      root /var/www/example.net;
      index index.htm index.html;
      ...
    }

    # Kong's Proxy location / has been changed to /api/v1
    location /api/v1 {
      set $upstream_host nil;
      set $upstream_scheme nil;
      set $upstream_uri nil;

      # Any remaining configuration for the Proxy location
      ...
    }
  }

  # Kong's Admin server block goes below
  # ...
}

```

## 属性参考

### 通用部分

#### Prefix

工作目录。
相当于Nginx的前缀路径，包含临时文件和日志。每个Kong流程必须有一个单独的工作目录。

默认：`/usr/local/kong`

#### log_level

Nginx服务器的日志级别。可以在 `<prefix>/logs/error.log`中找到日志有关可接受值的列表，请参见http://nginx.org/en/docs/ngx_core_module.html#error_log。

#### proxy_access_log

代理端口请求访问日志的路径。
将此值设置为off可禁用日志记录代理请求。
如果此值是相对路径，则它将位于`prefix`位置下

默认：`logs/access.log`

#### proxy_error_log

代理端口请求错误日志的路径。
这些日志的粒度由`log_level`指令调整。  
默认：`logs/error.log`

#### admin_access_log

Admin API请求访问日志的路径。
将此值设置为off可禁用日志记录Admin API请求。
如果此值是相对路径，则它将位于`prefix`位置下。

默认：`logs/admin_access.log`

#### admin_error_log

Admin API请求错误日志的路径。
这些日志的粒度由log_level指令调整。

默认：`logs/error.log`

#### plugins

此节点应加载的插件名称的逗号分隔列表。
列表中的每个项目可以是：

- 插件名称。这里接受默认捆绑插件（例如key-auth）和自定义插件（例如自定义速率限制）。
- 关键字`bundled`。这与包含与Kong捆绑的所有插件（来自`kong.plugins。{name}.*`命名空间）具有相同的含义。
- 关键字off。如果指定，Kong将不会加载任何插件，并且任何插件都不能通过Admin API进行配置。

请注意，如果以前配置了一些插件（即在数据库中有行）并且未在此列表中指定，则Kong将无法启动。
在禁用插件之前，请确保在重新启动Kong之前删除它的所有实例。

默认：`bundled`

例子：
- `plugins=bundled,custom-auth,custom-log` 将会包含已经捆绑的默认插件，和两个自定义插件
- `plugins=custom-auth,custom-log` 将会包含只 `custom-auth` 和 `custom-log`两个插件
- `plugins=off` 不会包含任何插件

提示：限制可用插件的数量可以在数据库缓存中遇到LRU搅动时（即配置的mem_cache_size已满时）提高P99延迟。

#### anonymous_reports

发送匿名使用数据，例如错误堆栈跟踪，以帮助改善Kong。
默认：`on`

### Nginx部分

#### proxy_listen

代理服务器应侦听的以逗号分隔的地址和端口列表。代理服务器是Kong的公共入口点，它将来自您的消费者的流量代理到您的后端服务。proxy_listen值接受IPv4，IPv6和主机名。

可以为每对指定一些后缀：
发送匿名使用数据，例如错误堆栈跟踪，以帮助改善Kong。 默认：on

Nginx部分

proxy_listen


发送匿名使用数据，例如错误堆栈跟踪，以帮助改善Kong。 默认：on

Nginx部分

proxy_listen



- `ssl` 将要求通过特定地址/端口建立的所有连接都是在启用TLS的情况下进行的。
- `http2` 将允许客户端打开到Kong的代理服务器的HTTP / 2连接。
- `proxy_protocol` 将为给定的地址/端口启用PROXY协议的使用。

此节点的代理端口，启用“控制平面”模式（无流量代理功能），可以配置连接到同一数据库的节点集群。有关此参数的值和其他`* _listen`值的可接受格式的说明，请参见http://nginx.org/en/docs/http/ngx_http_core_module.html#listen。

默认：`0.0.0.0:8000, 0.0.0.0:8443 ssl`  
例子：`0.0.0.0:80, 0.0.0.0:81 http2, 0.0.0.0:443 ssl, 0.0.0.0:444 http2 ssl`

#### stream_listen

流模式应侦听的以逗号分隔的地址和端口列表。此值接受IPv4，IPv6和主机名。

可以为每对指定一些后缀：

- `proxy_protocol` 将为给定的地址/端口启用PROXY协议的使用。
- `transparent` 将会使kong监听您在iptables中配置的任何和所有IP地址和端口并进行响应。

请注意，不支持`ssl`后缀，并且每个地址/端口都将接受启用或未启用TLS的TCP。

例子：
```
stream_listen = 127.0.0.1:7000
stream_listen = 0.0.0.0:989, 0.0.0.0:20
stream_listen = [::1]:1234
```

默认情况下，此值设置为`off`，从而禁用此节点的mesh proxy 端口

#### admin_listen

管理员界面应监听的以逗号分隔的地址和端口列表。Admin界面是允许您配置和管理Kong的API。访问此界面应仅限于Kong管理员。此值接受IPv4，IPv6和主机名。
可以为每对指定一些后缀：

- `ssl` 将要求通过特定地址/端口建立的所有连接都是在启用TLS的情况下完成的。
- `http2` 将允许客户端打开到Kong的代理服务器的HTTP / 2连接。
- `proxy_protocol` 将为给定的地址/端口启用PROXY协议的使用。

此值可以设置为off，从而禁用此节点的Admin接口，启用“数据平面”模式（无配置功能）从数据库中提取其配置更改。

默认：`127.0.0.1:8001, 127.0.0.1:8444 ssl`

例子：`127.0.0.1:8444 http2 ssl`


#### nginx_user

定义工作进程使用的用户和组凭据。如果省略group，则使用名称等于user的组。

默认：`nobody nobody`

例子：`nginx www`

#### nginx_worker_processes

确定Nginx生成的工作进程数。有关此指令的详细用法和可接受值的说明，请参见http://nginx.org/en/docs/ngx_core_module.html#worker_processes。

默认：`auto`

#### nginx_daemon

确定Nginx是作为守护程序还是作为前台进程运行。主要用于开发或在Docker环境中运行Kong时。参见：http://nginx.org/en/docs/ngx_core_module.html#daemon。

默认：`on`

#### mem_cache_size

数据库实体的内存高速缓存大小。接受的单位是k和m，最小推荐值为几MB。

默认：`128m`

#### ssl

确定Nginx是否应该在`proxy_listen_ssl`地址上监听HTTPS流量。
如果禁用，Nginx将仅在`proxy_listen`上绑定自己，并且将忽略所有SSL设置。

默认：`on`

#### ssl_cipher_suite

定义Nginx提供的TLS密码。可接受的值包括`modern`, `intermediate`, `old`, 或者 `custom`。有关每个密码套件的详细说明，请参阅https://wiki.mozilla.org/Security/Server_Side_TLS。

#### ssl_ciphers

定义由Nginx提供的自定义TLS密码列表。此列表必须符合`openssl ciphers`定义的模式。如果ssl_cipher_suite不是自定义的，则忽略此值。

默认：无

#### ssl_cert

如果启用了`ssl`，则为`proxy_listen_ssl`地址的SSL证书的绝对路径。
如果未指定且启用了`ssl`，则Kong将生成默认证书和密钥。

默认：无

#### ssl_cert_key

如果启用了`ssl`，则为`proxy_listen_ssl`地址的SSL密钥的绝对路径。

默认：无

#### http2

在`proxy_listen_ssl`地址上启用对HTTPS流量的HTTP2支持。

默认：`off`

#### client_ssl

确定代理请求时Nginx是否应发送客户端SSL证书。

默认：`off`

#### client_ssl_cert

如果启用了`client_ssl`，则`proxy_ssl_certificate`指令的客户端SSL证书的绝对路径。
请注意，此值是在节点上静态定义的，目前无法基于每个API进行配置。

默认：无

#### client_ssl_cert_key

如果启用了client_ssl，则为proxy_ssl_certificate_key地址的客户端SSL密钥的绝对路径。
请注意，此值是在节点上静态定义的，并且当前无法基于每个API进行配置。

默认：无

#### admin_ssl

确定Nginx是否应该在admin_listen_ssl地址上侦听HTTPS流量。
如果禁用，Nginx将仅在admin_listen上绑定自身，并且将忽略所有SSL设置。

默认：`on`

#### admin_ssl_cert

如果启用了`admin_ssl`，则为`admin_listen_ssl`地址的SSL证书的绝对路径。
如果未指定且启用了`admin_ssl`，则Kong将生成默认证书和密钥。

默认：无

#### admin_ssl_cert_key

如果启用了`admin_ssl`，则为`admin_listen_ssl`地址的SSL密钥的绝对路径。

默认：无

#### admin_http2

在`admin_listen_ssl`地址上启用对HTTPS流量的HTTP2支持。

#### upstream_keepalive

设置在每个工作进程的缓存中保留的上游服务器的最大空闲keepalive连接数。  
超过此数量时，将关闭最近最少使用的连接。  
值为`0`将完全禁用此行为，强制每个上游请求打开新连接。  

默认：60

#### headers

Kong应该在客户端响应中注入的，以逗号分隔的headers列表。  
可接受的值是：

- `Server`：Kong产生的响应上注入`Server:kong / x.y.z` （例如Admin API，来自auth插件的拒绝请求等）。
- `Via`：`Via:kong / x.y.z`注入成功代理的请求。
- `X-Kong-Proxy-Latency`：Kong在代理上游请求之前处理请求并运行所有插件所花费的时间（以毫秒为单位）
- `X-Kong-Upstream-Latency`：上游服务发送响应头所花费的时间（以毫秒为单位）
- `X-Kong-Upstream-Status`：上游服务返回的HTTP状态码。如果插件有重写响应的话，这对于客户端区分上游状态特别有用。
- `server_tokens`：与指定`Server`和`Via`相同。
- `latency_tokens`：与指定`X-Kong-Proxy-Latency`和`X-Kong-Upstream-Latency`相同。

除此之外，这个值可以设置为`off`，这可以防止Kong注入任何上述headers。
请注意，这不会阻止插件注入自己的headers。

例子：`headers = via, latency_tokens`  
默认：`server_tokens, latency_tokens`

#### trusted_ips

定义已知可以发送正确的`X-Forwarded-*`headers的可信IP地址块。来自可靠IP的请求，Kong会向上游转发了他们的原本`X-Forwarded- *`headers。不可信的请求使Kong插入自己的`X-Forwarded-*`headers。

#### real_ip_header

定义请求header字段，其值将用于替换客户端地址。
此值设置Nginx配置中同名的`ngx_http_realip_module`指令。

如果这个值收到`proxy_protocol`

- 至少有一个`proxy_listen`条目必须启用`proxy_protocol`标志。 
- `proxy_protocol`参数将附加到Nginx模板的`listen`指令。

有关此指令的说明，请查看http://nginx.org/en/docs/http/ngx_http_realip_module.html#real_ip_header

#### real_ip_recursive

此值设置Nginx配置中同名的`ngx_http_realip_module`指令。

有关此指令的说明，请查看http://nginx.org/en/docs/http/ngx_http_realip_module.html#real_ip_recursive

默认：off

#### client_max_body_size

定义由Kong代理的请求所允许的最大请求主体大小，在Content-Length请求标头中指定。如果请求超过此限制，Kong将回复413（请求实体太大）。将此值设置为0将禁用检查请求正文大小。

默认：0

#### client_body_buffer_size

定义用于读取请求正文的缓冲区大小。
如果客户端请求正文大于此值，则正文将缓冲到磁盘。
请注意，当主体缓冲到磁盘时，访问或操作请求主体的插件可能无法正常工作，因此建议将此值设置得尽可能高（例如，将其设置为与`client_max_body_size`一样高，以强制保留请求主体
在缓存中）。请注意，高并发环境将需要大量内存分配来处理许多并发的大型请求主体。

#### error_default_type

缺少请求`Accept`header且Nginx返回请求错误时要使用的默认MIME类型。可接受的值是`text/plain`，`text/html`，`application/json`和`application/xml`。

默认：`text/plain`

### Datastore section

Kong将把所有数据（例如路由，服务，消费者和插件）存储在Cassandra或PostgreSQL中，并且属于同一群集的所有Kong节点必须将它们自己连接到同一个数据库。

Kong支持以下数据库版本：

- PostgreSQL：9.5及以上。
- Cassandra：2.2及以上。

#### database

确定此节点将使用哪个PostgreSQL或Cassandra作为其数据存储区。
可接受的值是`postgres`和`cassandra`。

默认值：`postgres`

#### Postgres settings

| NAME | DESCRIPTION | DEFAULT |
| ---- | ----------- | ------- |
| pg_port | Postgres服务器的主机。 | `127.0.0.1` |
| pg_host | Postgres服务器的端口。 | `5432` |
| pg_user | Postgres用户。 | `kong` |
| pg_password | Postgres用户的密码。 |  |
| pg_database | 要连接的数据库。 | `kong` |
| pg_ssl | 启用与服务器的SSL连接。	 | `off` |
| pg_ssl_verify | 如果启用了`pg_ssl`，则切换服务器证书验证。请参阅`lua_ssl_trusted_certificate`设置。 | `off` |

#### Cassandra settings

| NAME | DESCRIPTION | DEFAULT |
| ---- | ----------- | ------- |
| cassandra_contact_points | 以逗号分隔的联系人列表指向的Cassandra群集。  | `127.0.0.1` |
| cassandra_port | 节点正在侦听的端口。的所有节点和联系点必须在同一端口上监听 | `9042` |
| cassandra_keyspace | Keyspace可以在您的群集中使用。如果它不存在，将被创建。 | `kong` |
| cassandra_consistency | 读取/写入Cassandra集群时使用的一致性设置 | `ONE` |
| cassandra_timeout | 定义读取和写入的超时（以毫秒为单位） | `5000` |
| cassandra_ssl | 切换Kong和Cassandra之间的客户端到节点TLS连接。 | `off` |
| cassandra_ssl_verify | 如果启用了`cassandra_ssl`，则切换服务器证书验证。<br>请参阅`lua_ssl_trusted_certificate`以指定证书颁发机构。 | `off` |
| cassandra_username | 使用PasswordAuthenticator方案时的用户名。  | `kong` |
| cassandra_password | 使用PasswordAuthenticator方案时的密码。 |  |
| cassandra_lb_policy | 在Cassandra集群中分发查询时使用的负载平衡策略。<br>可接受的值是`RoundRobin`，`RequestRoundRobin`，<br>`DCAwareRoundRobin`和`RequestDCAwareRoundRobin`。<br>以“Request”为前缀的策略可以在整个同一请求中有效地使用已建立的连接。<br>当且仅当您使用多数据中心群集时，首选“DCAware”策略。 |  |
| cassandra_local_datacenter | 使用`DCAwareRoundRobin`或`RequestDCAwareRoundRobin`平衡策略时，<br>必须指定与此Kong节点本地（最近）的集群的名称。 |  |
| cassandra_repl_strategy | 在第一次迁移时，Kong将使用此设置来创建密钥空间。<br>可接受的值是`SimpleStrategy`和`NetworkTopologyStrategy` | `SimpleStrategy` |
| cassandra_repl_factor | 在第一次迁移时，Kong将在使用`SimpleStrategy`时使用此复制因子创建keyspace。 | `1` |
| cassandra_data_centers | 在第一次迁移时，Kong将在使用`NetworkTopologyStrategy`时使用此设置。格式是以逗号分隔的列表，由`<dc_name>:<repl_factor>`组成。 | `dc1:2,dc2:3` |
| cassandra_schema_consensus_timeout | 定义Cassandra节点之间每个模式共识的等待时间的超时（以毫秒为单位）。此值仅在迁移期间使用。 |  `10000`|


### Datastore cache section

为了避免与数据存储区进行不必要的通信，Kong将实体（例如API，消费者，凭证等）缓存一段可配置的时间。
如果更新了这样的实体，它还会处理失效。
本节允许配置Kong关于此类配置实体的缓存的行为。

#### db_update_frequency

使用数据存储区检查更新实体的频率（以秒为单位）。
当节点通过Admin API创建，更新或删除实体时，其他节点需要等待下一轮询（由此值配置）以最终清除旧的缓存实体并开始使用新的实体。

默认：`5`

#### db_update_propagation

数据存储中的实体传输到另一个数据中心的副本节点所用的时间（以秒为单位）。
在分布式环境（如多数据中心Cassandra集群）中，此值应为Cassandra将行传播到其他数据中心所花费的最大秒数。
设置后，此属性将增加Kong传输实体更改所用的时间。
单数据中心设置或PostgreSQL服务器应该没有这样的延迟，并且该值可以安全地设置为0。

默认：`0`


#### db_cache_ttl

此节点缓存时实体从数据存储区的生存时间（以秒为单位）。
数据库未命中（无实体）也根据此设置进行缓存。
如果设置为0（默认值），则此类缓存实体或未命中永不过期。

默认：`0`(不过期)

#### db_resurrect_ttl

数据存储区中的陈旧实体在无法刷新时（例如，数据存储区无法访问）的时间（以秒为单位）。
当此TTL到期时，将进行刷新陈旧实体的新尝试。

### DNS 解析器部分

默认情况下，DNS解析器将使用标准配置文件`/etc/hosts`和`etc/resolv.conf`。
如果已设置环境变量`LOCALDOMAIN`和`RES_OPTIONS`，则后一个文件中的设置将被覆盖。  

Kong会将主机名解析为`SRV`或`A`记录（按此顺序，`CNAME`记录将在此过程中取消引用）。
如果名称被解析为`SRV`记录，它还将通过从DNS服务器接收的端口字段内容覆盖任何给定的端口号。    

DNS选项`SEARCH`和`NDOTS`（来自`/etc/resolv.conf`文件）将用于将短名称扩展为完全限定名称。
因此，它将首先尝试`SRV`类型的整个`SEARCH`列表，如果失败则会尝试搜索`A`的`SEARCH`列表等。

在`ttl`的持续时间内，内部DNS解析器将对通过DNS记录中的条目获得的每个请求进行负载均衡。
对于`SRV`记录，`weight`权重字段将被接受，但它将仅使用记录中的最低优先级`priority`字段条目。

#### dns_resolver

以逗号分隔的名称服务器列表，每个条目都采用`ip [:port]`格式供Kong使用。
如果未指定，将使用本地`resolv.conf`文件中的名称服务器。
如果省略，端口默认为`53`。
接受IPv4和IPv6地址。

默认：无

#### dns_hostsfile

要使用的hosts文件。
此文件只读一次，其内容在内存中是静态的。
要在修改文件后再次读取文件，必须重新加载Kong。

默认：`/etc/hosts`

#### dns_order

解析不同记录类型的顺序。
`LAST`类型表示上次成功查找的类型（对于指定的名称）。
格式是（不区分大小写）逗号分隔列表。

默认值：`LAST`，`SRV`，`A`，`CNAME`

#### dns_valid_ttl

默认情况下，使用响应的TTL值缓存DNS记录。
如果此属性收到一个值（以秒为单位），它将覆盖所有记录的TTL。

默认：无

#### dns_stale_ttl

以秒为单位定义记录在缓存中保留的时间长度超过其TTL。
在后台获取新DNS记录时将使用此值。
过期数据将从记录到期时使用，直到刷新查询完成或`dns_stale_ttl`秒数已过。

#### dns_not_found_ttl

空DNS响应和“（(3) name error”响应的TTL，以秒为单位。

默认：无

#### dns_error_ttl

错误响应的TTL，以秒为单位。

默认：`1`

#### dns_no_sync

如果启用，则在缓存未命中时，每个请求都将触发自己的dns查询。
禁用时，同一名称/类型的多个请求将同步到单个查询。

默认：`off`

### 发展和杂项部分

从lua-nginx-module继承的其他设置允许更多的灵活性和高级用法。
有关更多信息，请参阅lua-nginx-module文档：https：//github.com/openresty/lua-nginx-module

#### lua_ssl_trusted_certificate

PEM格式的Lua cosockets的证书颁发机构文件的绝对路径。当启用`pg_ssl_verify`或`cassandra_ssl_verify`时，此证书将用于验证Kong的数据库连接。

默认：无

#### lua_ssl_verify_depth

设置Lua cosockets使用的服务器证书链中的验证深度，由`lua_ssl_trusted_certificate`设置。
这包括为Kong的数据库连接配置的证书。

默认：`1`

#### lua_package_path

设置Lua模块搜索路径（LUA_PATH）。　　
在开发或使用未存储在默认搜索路径中的自定义插件时很有用。　　

查看：https://github.com/openresty/lua-nginx-module#lua_ssl_verify_depth

默认：无

#### lua_package_cpath

设置Lua C模块搜索路径（LUA_CPATH）。

查看：https://github.com/openresty/lua-nginx-module#lua_package_cpath

#### lua_socket_pool_size

指定与每个远程服务器关联的每个cosocket连接池的大小限制。

请参阅https://github.com/openresty/lua-nginx-module#lua_socket_pool_size

默认值：`30`

### 附加配置

#### origins

原始配置在复杂的网络配置中非常有用，并且在Kong用于服务网格(service mesh)时通常是必需的。

`origin`是一个以逗号分隔的成对对象列表，该对的每一半用`=`符号分隔。每对左侧的原点被右侧的原点覆盖。此覆盖发生在访问阶段之后和上游解析之前。它具有导致Kong将流向左侧原点的流量发送到右侧原点的效果。

术语origin（单数）是指特定 scheme/host 或 IP address/port 三元组，如RFC 6454（https://tools.ietf.org/html/rfc6454#section-3.2 ）中所述。在kong的`origin`配置项中，必须是`http`, `https`, `tcp`, or `tls`其中之一。在每对源中，该方案必须是类似的类型 - 因此http可以与https配对，并且tcp可以与tls配对，但http和https不能与tcp和tls配对。

当左侧原点的加密方案（如tls或https）与右侧来源中的tcp或http等未加密方案配对时，Kong将在与左侧原点匹配的传入连接上终止TLS，然后将未加密的流量路由到指定的右侧源。当通过TLS与Kong节点建立连接时，这很有用，但本地服务（Kong代理流量）不会或不能终止TLS。类似地，如果左侧原点是`tcp`或`http`且右侧原点是`tls`或`https`，则Kong将接受未加密的传入流量，然后在将其路由到出站时将该流量包装在TLS中。这种能力是Kong Mesh的重要推动。

与所有Kong配置设置一样，可以在Kong.conf文件中声明origin设置 - **但是建议Kong管理员不要这样做。** 相反，应使用环境变量在每个节点上设置`origin`。因此，kong.conf.default中不存在`origins`。在Kubernetes部署中，建议不要“手动”配置和维护起源 - 相反，每个Kong节点的起源应由Kubernetes身份模块（KIM）管理。

默认值：无

#### Examples

如果给定的Kong节点具有以下源的配置:

```
http://upstream-foo-bar:1234=http://localhost:5678
```

Kong节点不会尝试解析`upstream-foo-bar`，而是将该节点路由到`localhost：5678`。
在Kong的服务网格部署中，这种覆盖是必要的，以使临近`upstream-foo-bar`应用程序实例的Kong边车将流量路由到该本地实例，而不是试图将流量通过网络路由回到`upstream-foo-bar`的非本地实例。

在另一个典型的边车部署中，其中Kong节点部署在同一主机，虚拟机或Kubernetes Pod上，作为Kong作为代理的服务的一个实例，起源将配置为：

```
https://service-b:9876=http://localhost:5432
```

这种设置将导致该Kong节点仅接受端口9876上的HTTPS连接，终止TLS，然后将现在未加密的流量转发到localhost端口5432。

以下是一个由两对组成的示例，演示正确使用没有空格的分隔符：

```
https://foo.bar.com:443=http://localhost:80,tls://dog.cat.org:9999=tcp://localhost:8888
```

此配置将导致Kong仅接受端口443上的HTTPS流量，并且仅接受端口9999上的TLS流量，在两种情况下都终止TLS，然后分别将流量转发到localhost端口80和8888。
假设localhost端口80和8888每个都与一个单独的服务相关联，当Kong充当节点代理时，可能会发生这种配置，这是一个代表多个服务的本地代理（与sidecar代理不同，
其中本地代理仅代表单个本地服务）。






