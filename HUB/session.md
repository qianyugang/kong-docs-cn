# Session 插件

Kong Session Plugin可用于管理通过Kong API Gateway代理的API的浏览器会话。它为会话数据存储，加密，续订，到期和发送浏览器cookie提供配置和管理。它是使用[lua-resty-session](https://github.com/bungle/lua-resty-session)构建的。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

## 在 Service 上启用插件


通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=session"  \
    --data "config.secret=opensesame"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: session
  service: {service}
  config: 
    secret: opensesame
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=session"  \
    --data "config.secret=opensesame"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: session
  route: {route}
  config: 
    secret: opensesame
```

在这两种情况下，`{route}`是此插件配置将定位的Route的`id`或`name`。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。


### 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`session`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.secret` <br> *optional* | 从`kong.utils.random_string`<br>生成的随机数 | 密钥HMAC生成中使用的秘密。|
| `config.cookie_name` <br> *optional* |  `session` | Cookie的名称。  |
| `config.cookie_lifetime` <br> *optional* |  3600 | 会话保持打开的持续时间（以秒为单位） 。  |
| `config.cookie_renew` <br> *optional* |  600 | 插件更新会话时剩余会话的持续时间（以秒为单位）。  |
| `config.cookie_path` <br> *optional* |  / | cookie可用的主机中的资源。  |
| `config.cookie_domain` <br> *optional* | 使用Nginx变量主机设置，但可能会被覆盖 | cookie可用的主机中的资源。|
| `config.cookie_samesite` <br> Strict |   | 确定是否以及如何使用跨站点请求发送cookie。<br>“Strict”：仅当请求来自设置cookie的网站时，浏览器才会发送cookie。<br> “Lax”：在跨域子请求中保留相同站点的cookie，但是当用户从外部站点导航到URL时将发送，例如，通过一个链接。<br> “off”：禁用相同站点属性，以便可以使用跨站点请求发送cookie。<br> https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#SameSite_cookies |
| `config.cookie_httponly` <br> *optional* |  true | 应用`HttpOnly`标记，以便仅将cookie发送到服务器。<br> https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#Secure_and_HttpOnly_cookies |
| `config.cookie_secure` <br> *optional* |  true | 应用Secure指令，以便只能通过HTTPS协议使用加密请求将cookie发送到服务器。https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#Secure_and_HttpOnly_cookies  |
| `config.cookie_discard` <br> *optional* |  10 | 旧会话的TTL更新之后的持续时间（以秒为单位），丢弃旧cookie。|
| `config.storage` <br> *optional* |  cookie | 确定会话数据的存储位置。<br>`kong`:将加密的会话数据存储到Kong目前的数据库策略中（例如Postgres，Cassandra）;<br>不包含任何会话数据。`cookie`:将加密的会话数据存储在cookie本身中。|
| `config.logout_methods` <br> *optional* |  [`"POST"`, `"DELETE"`] | 可用于结束会话的方法：POST，DELETE，GET。 |
| `config.logout_query_arg` <br> *optional* |  session_logout | 查询参数传递给注销请求。  |
| `config.logout_post_arg` <br> *optional* |  session_logout | post参数传递给注销请求。请勿更改此属性。|


## 用法

Kong Session Plugin可以全局配置或按实体配置（例如，Service，Route），并且总是与另一个Kong Authentication [Plugin](https://docs.konghq.com/hub/)一起使用。此插件的工作方式与[多重身份验证](https://docs.konghq.com/0.14.x/auth/#multiple-authentication)设置类似。

一旦Kong Session Plugin与Authentication Plugin一起启用，它将在凭证验证之前运行。如果未找到任何会话，则将运行身份验证插件，并将正常检查凭据。如果凭证验证成功，则会话插件将创建新会话以供后续请求使用。

当一个新请求进入，并且会话存在时，那么Kong Session Plugin将附加`ngx.ctx`变量，以使身份验证插件知道已通过会话验证进行了身份验证。由于此配置是逻辑OR方案，因此希望禁止匿名访问，然后应在匿名使用者上配置[请求终止](https://docs.konghq.com/hub/kong-inc/request-termination/)插件。如果不这样做，将允许未经授权的请求。有关详细信息，请参阅[多重身份验证](https://docs.konghq.com/0.14.x/auth/#multiple-authentication)部分。

### 使用数据库进行设置

用于[Key Auth](https://docs.konghq.com/hub/kong-inc/key-auth/)插件

1. 创建示例Service和Route
	
    发出以下cURL请求以创建指向mockbin.org的`example-service`，它将显示如下请求：
    ```
     $ curl -i -X POST \
       --url http://localhost:8001/services/ \
       --data 'name=example-service' \
       --data 'url=http://mockbin.org/request'
    ```
	给Service添加一个Route
    ```
     $ curl -i -X POST \
       --url http://localhost:8001/services/example-service/routes \
       --data 'paths[]=/sessions-test'
    ```
    url `http//localhost:8000/sessions-test`现在将显示所请求的内容。










