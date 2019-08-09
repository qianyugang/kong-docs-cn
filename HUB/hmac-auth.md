# HMAC Authentication 认证插件

将HMAC签名身份验证添加到服务或路由以确定传入请求的完整性。该插件将验证在`Proxy-Authorization`或`Authorization` header 中发送的数字签名（按此顺序）。此插件实现基于[draft-cavage-http-signature](https://tools.ietf.org/html/draft-cavage-http-signatures)特征草案，其签名方案略有不同。

> 注意：此插件的功能与0.14.0之前的Kong版本和0.34之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=hmac-auth" 
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: hmac-auth
  service: {service}
  config: 
```
在这两种情况下，`{service}`是此插件配置将定位的`Route`的`ID`或名称。
查询：get | 新增：add | 修改：
## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=hmac-auth" 
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: hmac-auth
  route: {route}
  config: 
```

在这两种情况下，`{route}`是此插件配置将定位的Route的`id`或`name`。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`hmac-auth`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.hide_credentials` <br> *optional* |  `false` | 一个可选的布尔值，告诉插件显示或隐藏来自上游服务的凭据。如果为`true`，则插件将在代理之前从请求（即`Authorization` header）中剥离凭证。  |
| `config.clock_skew` <br> *optional* |  `300` | [时钟偏移](https://tools.ietf.org/html/draft-cavage-http-signatures-00#section-3.4)在几秒钟内以防止重放攻击。 | 
| `config.anonymous` <br> *optional* | | 如果身份验证失败，则用作“匿名”使用者的可选字符串（使用者uuid）值。如果为空（默认），则请求将失败，并且身份验证失败`4xx`。请注意，此值必须引用Kong内部的Consumer id属性，而不是其`custom_id`。  |
| `config.validate_request_body` <br> *optional* | `false` | 一个布尔值，告诉插件启用正文验证 |
| `config.enforce_headers` <br> *optional* | `false` |  客户端至少应用于HTTP签名创建的header列表 |
| `config.algorithms` <br> *optional* | `hmac-sha1`,<br> `hmac-sha256`,<br> `hmac-sha384`,<br> `hmac-sha512` | 用户想要支持的HMAC摘要算法列表。允许的值为`hmac-sha1`，`hmac-sha256`，`hmac-sha384`和`hmac-sha512`|

应用后，具有有效凭据的任何用户都可以访问Service/Route。
要仅限某些经过身份验证的用户使用，还要添加[ACL](https://docs.konghq.com/plugins/acl/)插件（此处未介绍）并创建白名单或黑名单用户组。

## 用法

要使用该插件，首先需要创建一个Consumer来将一个或多个凭据关联起来。

注意：由于HMAC签名是由客户端生成的，因此您应确保Kong在此插件运行之前不更新或删除HMAC签名中使用的任何请求参数。

### 创建一个 Consumer

您需要将凭证与现有的Consumer对象相关联。一个 Consumer 可以拥有许多凭据。

**使用数据库**

要创建 Consumer，您可以执行以下请求：
```
curl -d "username=user123&custom_id=SOME_CUSTOM_ID" http://kong:8001/consumers/
```

**不使用数据库**

您的声明性配置文件需要有一个或多个使用者。
您可以在`consumers:`创建它们yaml部分：
```
consumers:
- username: user123
  custom_id: SOME_CUSTOM_ID
```

在这两种情况下，参数如下所述：

| 参数 | 描述 |
| --- | ---- |
| `username` <br> *semi-optional* |  consumer的用户名。必须指定此字段或`custom_id`。 |
| `custom_id` <br> *semi-optional* | 用于将使用者映射到另一个数据库的自定义标识符。必须指定此字段或`username`。|

### 创建一个 Credential

**使用数据库**

您可以通过发出以下HTTP请求来配置新的用户名/密码凭据：
```
$ curl -X POST http://kong:8001/consumers/{consumer}/hmac-auth \
    --data "username=bob" \
    --data "secret=secret456"
```

**不使用数据库**

您可以在`hmacauth_credentials` yaml条目上的声明性配置文件中添加凭据：
您可以在`consumers:`创建它们yaml部分：
```
hmacauth_credentials:
- consumer: {consumer}
  username: bob
  secret: secret456
```

在这两种情况下，字段/参数的工作方式如下：

|  字段/参数 | 描述 |
| --------- | --- |
| `{consumer}` | 要将凭据关联到的Consumer实体的id或username属性。 | 
| `{username}` | 用于HMAC签名验证的用户名。 | 
| `{secret}` <br> `optional` | 在HMAC签名验证中使用的秘密。请注意，如果未提供此参数，Kong将为您生成一个值并将其作为响应正文的一部分发送。|
 
### 签名认证方案

期望客户端使用以下参数化发送`Authorization`或`Proxy-Authorization` header：
```
credentials := "hmac" params
params := keyId "," algorithm ", " headers ", " signature
keyId := "username" "=" plain-string
algorithm := "algorithm" "=" DQUOTE (hmac-sha1|hmac-sha256|hmac-sha384|hmac-sha512) DQUOTE
headers := "headers" "=" plain-string
signature := "signature" "=" plain-string
plain-string   = DQUOTE *( %x20-21 / %x23-5B / %x5D-7E ) DQUOTE
```

### 签名参数

| 参数 | 描述 |
| --- | ---- |
| username | 凭证的`username` |
| algorithm | 用于创建签名的数字签名算法 |
| headers | 用于对请求进行签名的HTTP标头名称列表，由单个空格字符分隔 |
| signature | 客户端生成的`Base64`编码数字签名 |

### 签名字符串构造
为了生成使用密钥签名的字符串，客户端必须按照它们出现的顺序获取`headers`指定的每个HTTP标头的值。

1. 如果标题名称不是`request-line`，则附加小写标题名称，后跟ASCII冒号`：`和ASCII空格` `。
2. 如果标题名称是`request-line`，则附加HTTP请求行（ASCII格式），否则追加标题值。
3. 如果value不是最后一个值，则附加ASCII换行符`\n`。字符串绝不能包含尾随的ASCII换行符。

### 时钟偏移 Clock Skew

HMAC身份验证插件还实现了[规范](https://tools.ietf.org/html/draft-cavage-http-signatures-00#section-3.4)中描述的时钟偏差检查，以防止重放攻击。默认情况下，允许在任一方向（过去/未来）上最小延迟300秒。任何具有更高或更低日期值的请求都将被拒绝。通过设置`clock_skew`属性（`config.clock_skew `POST参数），可以通过插件的配置编辑时钟偏差的长度。

服务器和请求客户端应与NTP同步，并且应使用`X-Date`或`Date` header 发送有效日期（使用GMT格式）。

### 正文验证 Body Validation

用户可以将`config.validate_request_body`设置为`true`以验证请求正文。如果启用，插件将计算请求正文的`SHA-256` HMAC摘要，并将其与`Digest` header 的值进行匹配。
摘要header需要采用以下格式：
```
Digest: SHA-256=base64(sha256(<body>))
```

如果没有请求主体，则应将`Digest`设置为0长度的主体的摘要。

注意：为了创建请求主体的摘要，插件需要将其保留在内存中，这可能会在处理大型主体（几个MB）或高请求并发期间对工作者的Lua VM造成压力。

### 执行 Headers

`config.enforce_headers`可用于强制任何 header 成为签名创建的一部分。默认情况下，插件不强制需要使用哪个标头来创建签名。要签名的最小建议数据是`request-line`，`host`和`date`。强烈的签名将包括所有headers和请求体的`digest`。

### HMAC 示例

可以在Service或Route上启用HMAC插件。

**创建一个 Service**
```
  $ curl -i -X POST http://localhost:8001/services \
      -d "name=example-service" \
      -d "url=http://example.com"
  HTTP/1.1 201 Created
  ...
```

**创建一个 Route**
```
  $ curl -i -f -X POST http://localhost:8001/services/example-service/routes \
      -d "paths[]=/"
  HTTP/1.1 201 Created
  ...
```
**在 Service 上启用插件**
可以在 Service 或 Route 上启用插件。
此示例使用 Service。
```
  $ curl -i -X POST http://localhost:8001/services/example-service/plugins \
      -d "name=hmac-auth" \
      -d "config.enforce_headers=date, request-line" \
      -d "config.algorithms=hmac-sha1, hmac-sha256"
  HTTP/1.1 201 Created
  ...
```
**添加一个 Consumer**
```
  $ curl -i -X POST http://localhost:8001/consumers/ \
      -d "username=alice"
  HTTP/1.1 201 Created
  ...

```
**给Alice添加一个凭证**
```
  $ curl -i -X POST http://localhost:8001/consumers/alice/hmac-auth \
      -d "username=alice123" \
      -d "secret=secret"
  HTTP/1.1 201 Created
  ...
```
**提出授权请求**
```
  $ curl -i -X GET http://localhost:8000/requests \
      -H "Host: hmac.com" \
      -H "Date: Thu, 22 Jun 2017 17:15:21 GMT" \
      -H 'Authorization: hmac username="alice123", algorithm="hmac-sha256", headers="date request-line", signature="ujWCGHeec9Xd6UD2zlyxiNMCiXnDOWeVFMu5VeRUxtw="'
  HTTP/1.1 200 OK
  ...

```
在上面的请求中，我们使用`date`和` request-line` header组成签名字符串，并使用`hmac-sha256`创建摘要来散列摘要：
```
  signing_string="date: Thu, 22 Jun 2017 17:15:21 GMT\nGET /requests HTTP/1.1"
  digest=HMAC-SHA256(<signing_string>, "secret")
  base64_digest=base64(<digest>)
```
因此`Authorization`标头的最终值如下所示：
```
  Authorization: hmac username="alice123", algorithm="hmac-sha256", headers="date request-line", signature=<base64_digest>"
```

**验证请求体**

要启用正文验证，我们需要将`config.validate_request_body`设置为`true`：

以下示例的工作方式相同，无论插件是添加到 Service 还是 Route。
```
  $ curl -i -X PATCH http://localhost:8001/plugins/{plugin-id} \
      -d "config.validate_request_body=true"
  HTTP/1.1 200 OK
  ...

```
现在，如果客户端在请求中包含正文摘要作为`Digest`header 的值，则插件将通过计算正文的`SHA-256`并将其与`Digest`header的值进行匹配来验证请求正文。
```
  $ curl -i -X GET http://localhost:8000/requests \
      -H "Host: hmac.com" \
      -H "Date: Thu, 22 Jun 2017 21:12:36 GMT" \
      -H "Digest: SHA-256=SBH7QEtqnYUpEcIhDbmStNd1MxtHg2+feBfWc1105MA=" \
      -H 'Authorization: hmac username="alice123", algorithm="hmac-sha256", headers="date request-line digest", signature="gaweQbATuaGmLrUr3HE0DzU1keWGCt3H96M28sSHTG8="' \
      -d "A small body"
  HTTP/1.1 200 OK
  ...
```
在上面的请求中，我们计算了正文的`SHA-256`摘要，并使用以下格式设置`Digest`header：
```
  body="A small body"
  digest=SHA-256(body)
  base64_digest=base64(digest)
  Digest: SHA-256=<base64_digest>
```

### 上游 Headers

当客户端经过身份验证后，插件会在将请求代理到上游服务之前将一些标头添加到请求中，以便您可以在代码中标识 Consumer：
- `X-Consumer-ID`，Kong 里 Consumer 的ID
- `X-Consumer-Custom-ID`，Consumer 的 `custom_id`（如果设置）
- `X-Consumer-Username`，Consumer 的 `username`（如果设置）
- `X-Credential-Username`，Credential 的 `username`（仅当消费者不是'匿名'消费者时）
- `X-Anonymous-Consumer`，身份验证失败时将设置为`true`，并设置“匿名” Consumer。

您可以使用此信息来实现其他逻辑。
您可以使用`X-Consumer-ID`值来查询Kong Admin API并检索有关Consumer的更多信息。

### 通过HMAC Credentials 进行分页

> 注意：此终点在Kong 0.11.2中引入。

您可以使用以下请求为所有使用者分配 hmac-auth Credentials：
```
$ curl -X GET http://kong:8001/hmac-auths

{
    "total": 3,
    "data": [
        {
            "created_at": 1509681246000,
            "id": "75695322-e8a0-4109-aed4-5416b0308d85",
            "secret": "wQazJ304DW5huJklHgUfjfiSyCyTAEDZ",
            "username": "foo",
            "consumer": { "id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880" }
        },
        {
            "created_at": 1509419793000,
            "id": "11d5cbfb-31b9-4a6d-8496-2f4a76500643",
            "secret": "zi6YHyvLaUCe21XMXKesTYiHSWy6m6CW",
            "username": "bar",
            "consumer": { "id": "3c2c8fc1-7245-4fbb-b48b-e5947e1ce941" }
        },
        {
            "created_at": 1509681215000,
            "id": "eb0365bc-88ae-4568-be7c-db1eb7c16e5e",
            "secret": "NvHDTg5mp0ySFVJsITurtgyhEq1Cxbnv",
            "username": "baz",
            "consumer": { "id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880" }
        }
    ]
}
```

您可以使用此其他路径按使用者筛选列表：
```
$ curl -X GET http://kong:8001/consumers/{username or id}/hmac-auths

{
    "total": 1,
    "data": [
        {
            "created_at": 1509419793000,
            "id": "11d5cbfb-31b9-4a6d-8496-2f4a76500643",
            "secret": "zi6YHyvLaUCe21XMXKesTYiHSWy6m6CW",
            "username": "bar",
            "consumer": { "id": "3c2c8fc1-7245-4fbb-b48b-e5947e1ce941" }
        }
    ]
}
```
`username or id` 需要列出凭据的consumer的用户名或ID


### 检索与 Credential 关联的 Consumer

> 注意：此终点在Kong 0.11.2中引入。

可以使用以下请求检索与HMAC凭据关联的使用者：
```
curl -X GET http://kong:8001/hmac-auths/{hmac username or id}/consumer

{
   "created_at":1507936639000,
   "username":"foo",
   "id":"c0d92ba9-8306-482a-b60d-0cfdd2f0e880"
}
```

`hmac username or id`：HMAC Credential的`id`或`username`属性，用于获取关联的Consumer。
请注意，此处接受的`username`不是Consumer的`username`属性。




 
