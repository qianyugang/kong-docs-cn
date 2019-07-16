# Key Authentication 密钥认证插件


将密钥身份验证（有时也称为API密钥）添加到 Service 或 Route 。该插件将检查`Proxy-Authorization`和`Authorization` header 中的有效凭据（按此顺序）。

> 注意：此插件的功能与0.11.2之前的Kong版本捆绑在一起，与此处记录的不同。有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式**部分兼容**。

可以使用声明性配置创建使用者和凭据。
在凭据上执行POST，PUT，PATCH或DELETE的Admin API端点在无DB模式下不可用。


## 在 Service 上启用插件


通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=key-auth" 
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: key-auth
  service: {service}
  config: 
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=key-auth" 
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: key-auth
  route: {route}
  config: 
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
| `name` |  |  要使用的插件的名称，在本例中为`key-auth`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.key_names` <br> *optional* | `apikey` | 插件将要查找键的参数名称数组。客户端必须以其中一个密钥名称发送身份验证密钥，插件将尝试从header或具有相同名称的查询参数读取凭据。 <br> *注意：* 键名只能包含`[a-z]，[A-Z]，[0-9]，[_]和[-]`。 由于[NGINX默认值中的附加限制](http://nginx.org/en/docs/http/ngx_http_core_module.html#ignore_invalid_headers)，不允许在标题中使用下划线。| 
| `config.key_in_body` <br> *optional* | `false` | 如果启用，插件将读取请求正文（如果所述请求有一个并且支持其MIME类型）并尝试在其中找到密钥。支持的MIME类型是`application/www-form-urlencoded`, `application/json`, 和 `multipart/form-data`。 | 
| `config.hide_credentials` <br> *optional* | `false` | 一个可选的布尔值，告诉插件显示或隐藏来自上游服务的凭据。如果为`true`，则插件将在代理之前从请求中剥离凭证（即包含密钥的header或查询字符串）。 | 
| `config.anonymous` <br> *optional* |  | 如果身份验证失败，则用作“匿名”使用者的可选字符串（使用者uuid）值。如果为空（默认），则请求将失败，并且身份验证失败`4xx`。 请注意，此值必须引用Kong内部的Consumer id属性，而不是其`custom_id`。| 
| `config.run_on_preflight` <br> *optional* | `true` |  一个布尔值，指示插件是否应在`OPTION`S预检请求上运行（并尝试进行身份验证），如果设置为`false`，则始终允许`OPTIONS`请求。 | 

请注意，根据其各自的规范，HTTP header 名称被视为**不区分大小写**，而HTTP查询字符串参数名称**区分大小写**。Kong按照设计遵循这些规范，这意味着在搜索请求 header 字段时，与搜索查询字符串相比，将对`key_names`配置值进行不同的处理。建议管理员在期望在请求 header 中发送授权密钥时不要定义区分大小写的`key_names`值。

> 选项`config.run_on_preflight`仅在版本`0.11.1`及更高版本中可用

应用后，具有有效凭据的任何用户都可以访问该服务。要仅限某些经过身份验证的用户使用，还要添加[ACL插件](https://docs.konghq.com/plugins/acl/)（此处未介绍）并创建白名单或黑名单用户组。

# 使用方法

## 创建一个 Consumer

## 创建一个 Key

## 使用 Key

## 删除 Key

## 上游 Headers

## 通过 Keys 分页

## 检索与密钥关联的 Consumer












