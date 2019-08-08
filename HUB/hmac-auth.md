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
### 签名参数
### 签名字符串构造


### 时钟偏移 Clock Skew
### 正文验证 Body Validation
### 执行 Headers
### HMAC 示例
### 上游 Headers
### 通过HMAC Credentials 进行分页
### 检索与 Credential 关联的 Consumer









 
