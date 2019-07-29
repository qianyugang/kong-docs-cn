# Session 插件

本文原文链接：https://docs.konghq.com/hub/kong-inc/session

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

2. 配置Service的key-auth插件
	
    发出以下cURL请求以将key-auth插件添加到Service：
    ```
     $ curl -i -X POST \
       --url http://localhost:8001/services/example-service/plugins/ \
       --data 'name=key-auth'
    ```
    请务必记下创建的插件`id` - 稍后将需要它。

3. 验证是否正确配置了key-auth插件

	发出以下cURL请求以验证在服务上正确配置了[key-auth] [key-auth]插件：
    ```
     $ curl -i -X GET \
	   --url http://localhost:8000/sessions-test
    ```
    由于未指定所需的头或参数`apikey`，并且尚未启用匿名访问，因此响应应为`401 Unauthorized`：
    
4. 创建Consumer和匿名Consumer
	
    由Kong代理和验证的每个请求都必须与Consumer相关联。现在，您将通过发出以下请求来创建名为`anonymous_users`的Consumer：
    ```
     $ curl -i -X POST \
       --url http://localhost:8001/consumers/ \
       --data "username=anonymous_users"
    ```
    请务必记下消费者`id` - 您将在以后的步骤中使用它。
    
    现在创建一个将通过会话进行身份验证的使用者
    ```
     $ curl -i -X POST \
       --url http://localhost:8001/consumers/ \
       --data "username=fiona"
    ```

5. 为您的消费者提供密钥身份验证凭据

	```
     $ curl -i -X POST \
       --url http://localhost:8001/consumers/fiona/key-auth/ \
       --data 'key=open_sesame'
    ```

6. 启用匿名访问

	您现在将通过发出以下请求重新配置key-auth插件以允许匿名访问（使用前面步骤中的`id`值替换下面的uuids）：
    ```
     $ curl -i -X PATCH \
       --url http://localhost:8001/plugins/<your-key-auth-plugin-id> \
       --data "config.anonymous=<anonymous_consumer_id>"
    ```

7. 将Kong Session插件添加到service中

	```
     $ curl -X POST http://localhost:8001/services/example-service/plugins \
     --data "name=session"  \
     --data "config.storage=kong" \
     --data "config.cookie_secure=false"
    ```
    > 注意：默认情况下，cookie_secure为true，并且应始终为true，但为了避免使用HTTPS，为了演示而将其设置为false。

8. 添加请求终止插件

	要禁用匿名访问，仅允许用户通过会话或身份验证凭据进行访问，请启用“请求终止插件”。
    ```
     $ curl -X POST http://localhost:8001/services/example-service/plugins \
         --data "name=request-termination"  \
         --data "config.status_code=403" \
         --data "config.message=So long and thanks for all the fish!" \
         --data "consumer.id=<anonymous_consumer_id>"
    ```

##  无数据库安装

将所有这些添加到声明性配置文件中：

```
services:
- name: example-service
  url: http://mockbin.org/request

routes:
- service: example-service
  paths: [ "/sessions-test" ]

consumers:
- username: anonymous_users
  # 手动设置为固定的uuid，以便在key-auth插件中使用它
  id: 81823632-10c0-4098-a4f7-31062520c1e6
- username: fiona

keyauth_credentials:
- consumer: fiona
  key: open_sesame

plugins:
- name: key-auth
  service: example-service
  config:
    # 使用匿名consumer修复uuid（不能使用用户名）
    anonymous: 81823632-10c0-4098-a4f7-31062520c1e6
    # cookie_secure默认为true，并且应始终为true，
    # 但为了避免使用HTTPS，为了这个演示而设置为false
    cookie_secure: false
- name: session
  config:
    storage: kong
    cookie_secure: false
- name: request-termination
  service: example-service
  consumer: anonymous_users
  config:
    status_code: 403
    message: "So long and thanks for all the fish!"
```

### 验证

1. 检查是否禁用了匿名请求
	```
      $ curl -i -X GET \
    	--url http://localhost:8000/sessions-test
    ```
    应该返回`403`
    
2. 验证用户是否可以通过会话进行身份验证
	```
     $ curl -i -X GET \
   		--url http://localhost:8000/sessions-test?apikey=open_sesame
    ```
    响应现在应该具有Set-Cookie标头。确保此cookie有效。
    
    如果cookie看起来像这样：
    ```
    Set-Cookie: session=emjbJ3MdyDsoDUkqmemFqw..|1544654411|4QMKAE3I-jFSgmvjWApDRmZHMB8.; Path=/; SameSite=Strict; HttpOnly
    ```
    像这样使用它：
    ```
       $ curl -i -X GET \
         --url http://localhost:8000/sessions-test \
         -H "cookie:session=emjbJ3MdyDsoDUkqmemFqw..|1544654411|4QMKAE3I-jFSgmvjWApDRmZHMB8."
    ```
    此请求应该成功，并且在续订期之前不会出现`Set-Cookie`响应标头。
    
3. 您现在还可以验证cookie是否附加到浏览器会话：导航到 http://localhost:8000/sessions-test ，它应该返回403并看到消息“So long and thanks for all the fish!”
4. 在同一浏览器会话中，导航到http://localhost:8000/sessions-test？apikey=open_sesame ，它应返回200，通过密钥验证密钥查询参数进行身份验证。
5. 在同一个浏览器会话中，导航到http://localhost:8000/sessions-test ，它现在将使用Kong Session Plugin授予的会话cookie。

### 默认情况

默认情况下，Kong Session Plugin使用`Secure`，`HTTPOnly`，`Samesite = Strict` cookie来支持安全性。
cookie_domain是使用Nginx变量主机自动设置的，但可以被覆盖。
    
### 会话数据存储

会话数据可以存储在cookie本身（加密）`storage = cookie`或https://docs.konghq.com/hub/kong-inc/session/#-kong-storage-adapter[Kong](https://docs.konghq.com/hub/kong-inc/session/#-kong-storage-adapter)内。
会话数据存储两个上下文变量：
```
ngx.ctx.authenticated_consumer.id
ngx.ctx.authenticated_credential.id
```

## Kong存储适配器

当`storage=kong`时，Kong Session Plugin使用自己的会话数据存储适配器扩展了[lua-resty-session](https://github.com/bungle/lua-resty-session)的功能。这会将加密的会话数据存储到当前的数据库策略中（例如postgres，cassandra等），并且cookie将不包含任何会话数据。存储在数据库中的数据是加密的，cookie将仅包含会话ID，到期时间和HMAC签名。会话将使用内置的Kong DAO `ttl`机制，该机制在指定的cookie_lifetime之后销毁会话，除非在正常浏览器活动期间发生更新。建议应用程序通过XHR请求（或类似的东西）注销以手动处理重定向。

## 注销

通常为用户提供注销（即手动销毁）其当前会话的能力。可以使用请求URL中的查询参数或`POST`参数进行注销。config的`logout_methods`允许插件根据HTTP谓词限制注销。设置`logout_query_arg`时，它将检查是否存在指定的URL查询参数，同样当设置`logout_post_arg`时，它将检查请求体中是否存在指定的变量。允许的HTTP方法是`GET`，`DELETE`和`POST`。当存在会话且传入请求是注销请求时，Kong Session Plugin将在继续插件运行循环之前返回200，并且请求将不会继续到上游。

## 已知限制

由于OpenResty的限制，`header_filter`阶段无法连接到数据库，这对初始检索cookie（新鲜会话）造成问题。有一个小窗口的时间，其中cookie被发送到客户端，但数据库插入尚未提交，因为数据库调用在`ngx.timer`线程中。当前的解决方法是在发出后续请求之前将`Set-Cookie`header头发送到客户端之后等待一段时间（~100-500ms）。这在会话续订期间不是问题，因为在`access`阶段进行更新。



