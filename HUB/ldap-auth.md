# LDAP 认证插件

使用用户名和密码保护将LDAP绑定身份验证添加到路由。
该插件将检查`Proxy-Authorization`和`Authorization` header 中的有效凭据（按此顺序）。


> 注意：此插件的功能与0.14.1之前的Kong版本和0.34之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
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

此插件与无DB模式部分兼容。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=ldap-auth"  \
    --data "config.hide_credentials=true" \
    --data "config.ldap_host=ldap.example.com" \
    --data "config.ldap_port=389" \
    --data "config.start_tls=false" \
    --data "config.base_dn=dc=example,dc=com" \
    --data "config.verify_ldap_host=false" \
    --data "config.attribute=cn" \
    --data "config.cache_ttl=60" \
    --data "config.header_type=ldap"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: ldap-auth
  route: {route}
  config: 
    hide_credentials: true
    ldap_host: ldap.example.com
    ldap_port: 389
    start_tls: false
    base_dn: dc=example,dc=com
    verify_ldap_host: false
    attribute: cn
    cache_ttl: 60
    header_type: ldap
```
在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 全局插件

- **使用数据库：** 可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：** 可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`response-ratelimiting`  |
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.hide_credentials` <br>  *optional* | `false` |  此插件将定位的 Route 的ID。 |
| `config.ldap_host` |   |   |
| `config.ldap_port` |   |   |
| `config.start_tls` | `false`  |   |
| `config.base_dn` |   |   |
| `config.verify_ldap_host` |   |   |
| `config.attribute` |   |   |
| `config.cache_ttl` |   |   |
| `config.timeout` <br>  *optional*  |   |   |
| `config.keepalive` <br>  *optional*  |  `60000` |   |
| `config.anonymous` <br>  *optional* |   |   |
| `config.header_type` <br>  *optional*  | `ldap`  |   |

## 用法

## 上游 headers

