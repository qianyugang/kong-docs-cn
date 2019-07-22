# OAuth 2.0 Authentication 认证插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/oauth2/

使用[授权码模式(Authorization Code Grant)](https://tools.ietf.org/html/rfc6749#section-4.1)，[客户端凭证模式( Client Credentials)](https://tools.ietf.org/html/rfc6749#section-4.4)，[简化授权模式(Implicit Grant)](https://tools.ietf.org/html/rfc6749#section-4.2)或[密码模式(Resource Owner Password Credentials Grant)](https://tools.ietf.org/html/rfc6749#section-4.3)授予流添加OAuth 2.0身份验证层。

> 注意：根据OAuth2规范，此插件要求通过HTTPS提供底层服务。为避免混淆，我们建议您将用于服务底层服务的Route配置为仅接受HTTPS流量（通过其`protocols`属性）。

> 注意：此插件的功能与0.12.0之前的Kong版本捆绑在一起，与此处记录的不同。有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。


## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式**不兼容**。

为了让它正常工作，插件需要生成和删除令牌，并将这些更改提交到数据库，这与无DB的数据库不兼容。除此之外，其Admin API端点还为令牌和凭据提供了多种POST，PATCH，PUT和DELETE方法。他们都不会在无DB的情况下工作。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=oauth2"  \
    --data "config.scopes=email" \
    --data "config.scopes=phone" \
    --data "config.scopes=address" \
    --data "config.mandatory_scope=true" \
    --data "config.enable_authorization_code=true"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: oauth2
  service: {service}
  config: 
    scopes:
    - email
    - phone
    - address
    mandatory_scope: true
    enable_authorization_code: true
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

### 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`oauth2`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.scopes` |  | 描述最终用户可用的范围名称数组 |
| `config.mandatory_scope` <br> *optional* | `false` | 一个可选的布尔值，告诉插件要求最终用户授权至少一个范围 |
| `config.token_expiration` <br> *optional* | `7200` | 一个可选的整数值，告诉插件一个令牌应该持续多少秒，之后客户端需要刷新令牌。设置为`0`以禁用过期。|
| `config.enable_authorization_code` <br> *optional* | `false` | 一个可选的布尔值，用于启用3-legged授权码（[RFC 6742第4.1节](https://tools.ietf.org/html/rfc6749#section-4.1)）
| `config.enable_client_credentials` <br> *optional* | `false` | 一个可选的布尔值，用于启用客户端凭证授权流程（[RFC 6742第4.4节](https://tools.ietf.org/html/rfc6749#section-4.4)） |
| `config.enable_implicit_grant` <br> *optional* | `false` | 一个可选的布尔值，用于启用简单授权流，允许在授权过程中配置令牌（[RFC 6742第4.2节](https://tools.ietf.org/html/rfc6749#section-4.2)） |
| `config.enable_password_grant` <br> *optional* | `false` | 一个可选的布尔值，用于启用资源所有者密码授权流程（[RFC 6742第4.3节](https://tools.ietf.org/html/rfc6749#section-4.3)） |
| `config.auth_header_name` <br> *optional* | `authorization` | 应该携带访问令牌的标头名称。默认值：`authorization`。 |
| `config.hide_credentials` <br> *optional* | `false` | 一个可选的布尔值，告诉插件显示或隐藏来自上游服务的凭据。如果值为`true`，则插件将在代理之前从请求中剥离凭证（即包含客户端凭证的头）。 |
| `config.accept_http_if_already_terminated` <br> *optional* | `false` | 接受已由代理或负载均衡器终止的HTTPs请求，并且`x-forwarded-proto:https` header 已添加到请求中。如果无法公开访问Kong服务器且唯一的入口点是此类代理或负载均衡器，则仅启用此选项。 |
| `config.anonymous` <br> *optional* | `false` | 如果身份验证失败，则用作“匿名”使用者的可选字符串（使用者uuid）值。如果为空（默认），则请求将失败，并且身份验证失败报错`4xx` 。请注意，此值必须引用Kong内部的Consumer `id`属性，而不是其`custom_id`。|
| `config.global_credentials` <br> *optional* | `false` | 一个可选的布尔值，允许使用插件生成的相同OAuth凭证与其OAuth 2.0插件配置也具有`config.global_credentials=true` 的任何其他服务。 |
| `config.refresh_token_ttl` <br> *optional* | `1209600` | 一个可选的整数值，告诉插件令牌/刷新令牌对有效的秒数，并可用于生成新的访问令牌。默认值为2周。设置为`0`以使 token/refresh token 对无限期有效。 |

> `config.refresh_token_ttl`选项仅适用于0.12.0及更高版本

## 使用方法

要使用该插件，首先需要创建一个将一个或多个 credentials 关联到的 consumer 。Consumer代表使用上游服务的开发人员。

> 注意：此插件需要数据库才能有效工作。它 不适用 于DB-Less模式。

### 端点 Endpoints

默认情况下，当客户端通过[代理端口](https://docs.konghq.com/latest/configuration/#proxy_listen)使用底层服务时，OAuth 2.0插件会监听以下端点：

| 端点 | 描述 |
| ---- | ---- |
| `/oauth2/authorize` |  授权服务器的端点，用于为[授权码](https://tools.ietf.org/html/rfc6749#section-4.1)流提供授权码，或在启用[简单授权](https://tools.ietf.org/html/rfc6749#section-4.2)流时提供访问令牌。仅支持POST。|
| `/oauth2/token` | 提供访问令牌的授权服务器的端点。这也是用于客户端凭据和资源所有者密码凭据授权流程的唯一端点。仅支持POST。 |

尝试授权和请求访问令牌的客户端必须使用这些端点。请记住，上面的端点必须与您通常用于匹配已配置的Route到Kong的正确URI路径或标头组合。

### 创建一个 Consumer

您需要将凭证与现有的Consumer对象相关联。要创建使用者，您可以执行以下请求：
```
$ curl -X POST http://kong:8001/consumers/ \
    --data "username=user123" \
    --data "custom_id=SOME_CUSTOM_ID"
```

| 参数 | 默认 | 描述 |
| ---- | ---- | ---- |
| `username` <br> *semi-optional* ||  消费者的用户名。必须指定此字段或`custom_id`。|
| `custom_id` <br> *semi-optional* || 用于将使用者映射到另一个数据库的自定义标识符。必须指定此字段或`username`。|

一个 Consumer 可以有多个 credentials。

### 创建一个 Application

然后，您可以通过发出以下HTTP请求来配置新的OAuth 2.0凭据（也称为“OAuth应用程序”）：
```
$ curl -X POST http://kong:8001/consumers/{consumer_id}/oauth2 \
    --data "name=Test%20Application" \
    --data "client_id=SOME-CLIENT-ID" \
    --data "client_secret=SOME-CLIENT-SECRET" \
    --data "redirect_uris=http://some-domain/endpoint/"
```

`consumer_id`：将凭据关联到的Consumer实体

| 表单参数 | 默认值 | 描述 |
| -------- | ------ | ---- |
| `name` |  | 与凭证关联的名称。在OAuth 2.0中，这将是应用程序名称。 | 
| `client_id` <br> *optional* | | 您可以选择设置自己唯一的`client_id`。如果不设置，插件将生成一个。 |
| `client_secret` <br> *optional* |  | 您可以选择设置自己唯一的`client_secret`。如果不设置，插件将生成一个。 |
| `redirect_uris` | | 应用程序中包含一个或多个URL的数组，用户将在授权后发送（[RFC 6742第3.1.2节](https://tools.ietf.org/html/rfc6749#section-3.1.2)） |

## 迁移 Access Tokens

如果您要迁移现有的OAuth 2.0应用程序并将 access tokens 转移到Kong，那么您可以：

-  如上所述，通过创建OAuth 2.0应用程序来迁移使用者和应用程序。
-  使用Kong的Admin API中的/ oauth2_tokens端点迁移访问令牌。例如：
	```
    $ curl -X POST http://kong:8001/oauth2_tokens \
        --data 'credential.id=KONG-APPLICATION-ID' \
        --data "token_type=bearer" \
        --data "access_token=SOME-TOKEN" \
        --data "refresh_token=SOME-TOKEN" \
        --data "expires_in=3600"
	```

| 表单参数 | 默认值 | 描述 |
| ----------- | ------- | ------ |
| `credential` |  | 包含在Kong上创建的OAuth 2.0应用程序的ID。 | 
|`token_type` <br> *optional* | `bearer` |  [token 类型](https://tools.ietf.org/html/rfc6749#section-7.1) |
|`access_token` <br> *optional* |  |  您可以选择设置自己的访问token值，否则将生成随机字符串 |
|`refresh_token` <br> *optional* |   | 您可以选择设置自己唯一的refresh token值，否则将生成随机字符串。  |
|`expires_in` |   | 访问token的到期时间（以秒为单位）。  |
|`scope` <br> *optional* |   | 与token关联的授权范围。  |
|`authenticated_userid` <br> *optional* |   | 授权应用程序的用户的自定义ID。  |

## 上游请求头

当客户端经过身份验证和授权后，插件会在将请求代理到上游服务之前将一些headers附加到请求中，以便您可以在代码中识别使用者和最终用户：

- `X-Consumer-ID`，Kong的Consumer的ID
-  `X-Consumer-Custom-ID`，Consumer 的`custom_id`（如果设置）
-  `X-Consumer-Username`，Consumer的`username`（如果设置）
-  `X-Authenticated-Scope`，最终用户已经过身份验证的以逗号分隔的范围列表（如果可用）（仅当消费者不是“匿名”消费者时）
-  `X-Authenticated-Userid`，已授予客户端权限的已登录用户标识（仅当消费者不是“匿名”消费者时）
-  `X-Anonymous-Consumer`，身份验证失败时将设置为`true`，并设置“匿名”使用者。

您可以使用此信息来实现其他逻辑。您可以使用`X-Consumer-ID`值来查询Kong Admin API并检索有关Consumer的更多信息。

___

## OAuth 2.0 Flows

### 客户端凭据

[客户端凭据](https://tools.ietf.org/html/rfc6749#section-4.4)流将开箱即用，无需构建任何授权页面。客户端需要使用`/oauth2/token`端点来请求访问令牌。

### 认证码

配置使用者并将OAuth 2.0凭据与其关联后，了解OAuth 2.0授权流程的工作原理非常重要。与大多数Kong插件相反，OAuth 2.0插件需要一些额外的工作才能使一切运行良好：
- 您必须在Web应用程序上实现授权页面，该页面将与插件服务器端通信。
- 您可以选择在您的网站/文档中解释如何使用受OAuth 2.0保护的服务，以便访问您服务的开发人员知道如何构建其客户端实现。

**流程解释**

构建授权页面将是插件本身无法开箱即用的主要任务，因为它需要检查用户是否已正确登录，并且此操作与您的身份验证实现密切相关。

授权页面由两部分组成：

- 用户将看到的前端页面，这将允许他授权客户端应用程序访问他的数据
- 后端将处理前端中显示的HTML表单，该表单将与Kong上的OAuth 2.0插件进行通信，并最终将用户重定向到第三方URL。

> [您可以在GitHub上的node.js + express.js中看到示例实现](https://github.com/Kong/kong-oauth2-hello-world)

一个此流程的图表：
![](https://docs.konghq.com/assets/images/docs/oauth2/oauth2-flow.png)

1. 客户端应用程序将最终用户重定向到Web应用程序上的授权页面，将`client_id`，`response_type`和`scope`（如果需要）作为查询字符串参数传递。这是一个示例授权页面：
	![](https://docs.konghq.com/assets/images/docs/oauth2/oauth2-prompt.png)
    
2. 在显示实际授权页面之前，Web应用程序将确保用户已登录。
3. 客户端应用程序将在查询字符串中发送`client_id`，Web应用程序可以通过向Kong发出以下请求来检索OAuth 2.0应用程序名称和开发人员名称：
	```
    $ curl kong:8001/oauth2?client_id=XXX
    ```
    
4. 如果最终用户授权应用程序，表单将使用`POST`请求将数据提交到后端，发送放置在`<input type =“hidden”../>`字段中的`client_id`，`response_type`和`scope`参数。
5. 后端必须将`provision_key`和`authenticated_userid`参数添加到`client_id`，`response_type`和`scope`参数中，它将在`/oauth2/authorize`端点上的服务地址向Kong发出`POST`请求。如果客户端已发送`Authorization`请求头，则必须添加该标请求头。
	```
     $ curl https://your.service.com/oauth2/authorize \
     --header "Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW" \
     --data "client_id=XXX" \
     --data "response_type=XXX" \
     --data "scope=XXX" \
     --data "provision_key=XXX" \
     --data "authenticated_userid=XXX"
    ```
`provision_ke`y是插件在添加到Service 时生成的密钥，而`authenticated_userid`是已授予权限的登录最终用户的ID。

6. Kong将会以一个JSON回复：
	```
     {
   		"redirect_uri": "http://some/url"
	 }
    ```
    根据请求是否成功，使用`200 OK`或`400 Bad Request`响应代码。
7. 在这两种情况下，忽略响应状态代码，只需将用户重定向到`redirect_uri`属性中返回的任何URI。
8. 客户端应用程序将从此处获取它，并将继续使用Kong，而不与您的Web应用程序进行其他交互。如果它是授权代码授权流程，则交换访问令牌的授权代码。
9. 检索到 Access Token后，客户端应用程序将代表用户向您的上游服务发出请求。
10.  Access Token 可能会过期，当发生这种情况时，客户端应用程序需要使用Kong续订 Access Token并检索新的令牌。
____


## 资源所有者密码凭据

[资源所有者密码凭据授权](https://tools.ietf.org/html/rfc6749#section-4.3)是授权代码流的一个更简单的版本，但它仍然需要构建授权后端（没有前端）才能使其正常工作。
![](https://docs.konghq.com/assets/images/docs/oauth2/oauth2-flow2.png)

1. 在第一个请求中，客户端应用程序向您的Web应用程序发出包含一些OAuth2参数（包括`username`和`password`参数）的请求。
2. 您的Web应用程序的后端将验证客户端发送的`username`和`password`，如果成功，将`provision_key`，`authenticated_userid`和`grant_type`参数添加到客户端最初发送的参数中，它将向Kong发出POST请求，在已配置插件的`/oauth2/token`端点上。如果客户端已发送Authorization标头，则必须添加该header。相当于：
	```
     $ curl https://your.service.com/oauth2/token \
     --header "Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW" \
     --data "client_id=XXX" \
     --data "client_secret=XXX" \
     --data "grant_type=password" \
     --data "scope=XXX" \
     --data "provision_key=XXX" \
     --data "authenticated_userid=XXX" \
     --data "username=XXX" \
     --data "password=XXX"
    ```
`provision_key`是插件在添加到服务时生成的密钥，而`authenticated_userid`是其`username`和`password`所属的最终用户的ID。
    
3. Kong将会以一个JSON回复
4. Kong发送的JSON响应必须按原样发送回原始客户端。如果操作成功，则此响应将包含Access Token，否则将包含错误。

在此流程中，您需要实现的步骤是：

- 后端端点将处理原始请求并将验证客户端发送的`username`和`password`，如果验证成功，则向Kong发出请求并返回客户端，无论Kong发送回的任何响应。

## Refresh Token

当您的访问令牌过期时，您可以使用与过期访问令牌一起收到的刷新令牌生成新的访问令牌。
```
$ curl -X POST https://your.service.com/oauth2/token \
    --data "grant_type=refresh_token" \
    --data "client_id=XXX" \
    --data "client_secret=XXX" \
    --data "refresh_token=XXX"
```












