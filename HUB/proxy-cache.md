# Proxy Caching 代理缓存

此插件为Kong提供反向代理缓存实现。它基于可配置的响应代码和内容类型以及请求方法来缓存响应实体。它可以缓存每个Consumer或每个API。缓存实体存储一段可配置的时间，之后对同一资源的后续请求将重新获取并重新存储资源。缓存实体也可以在到期时间之前通过Admin API强制清除。



## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。
- `api`：用于表示上游服务的遗留实体。自CE 0.13.0和EE 0.32以来，已被废除。

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
    --data "name=proxy-cache"  \
    --data "config.strategy=memory"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: proxy-cache
  service: {service}
  config: 
    strategy: memory
```
在这两种情况下，`{service}`是此插件配置将定位的service的`ID`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=proxy-cache"  \
    --data "config.strategy=memory"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: proxy-cache
  route: {route}
  config: 
    strategy: memory
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。


## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=proxy-cache" \
     \
    --data "config.strategy=memory"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: proxy-cache
  consumer: {consumer}
  config: 
    strategy: memory
```
在这两种情况下，`{consumer`}都是此插件配置将定位的`Consumer`的`id`或`username`。  
您可以组合`consumer_id`和`service_id` 。 
在同一个请求中，进一步缩小插件的范围。

## 在 Api 上启用插件

如果您使用旧版本的Kong与旧版API实体（自CE 0.13.0和EE 0.32以来已被废除。），您可以通过发出以下请求在此类API之上配置此插件：
```
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=proxy-cache"  \
    --data "config.strategy=memory"
```
- `api`：此插件配置将定位的API的ID或名称。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`proxy-cache`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `api_id` | | 此插件将定位的API的ID。注意：自CE 0.13.0和EE 0.32以来，不推荐使用API实体来支持Services。 |
| `config.response_code` | `200`, `301`, `404` | 被视为可缓存上游响应状态代码 |
| `config.request_method` | GET, HEAD | 被认为是可缓存的下游请求方法 |
| `config.content_type` | `text/plain`, `application/json` | 上游被认为是可缓存的响应内容类型。该插件针对每个指定值执行完全匹配;例如，如果期望上游响应`application/json;charset=utf-8`content-type，插件配置必须包含所述值，否则将返回`Bypass`缓存状态 |
| `config.vary_headers` <br> `optional` |  |  考虑缓存密钥的相关header。如果未定义，则不考虑任何header。 |
| `config.vary_query_params` <br> `optional` |  | 考虑缓存密钥的相关查询参数。如果未定义，则考虑所有参数。 |
| `config.cache_ttl` | `300` | 缓存实体的TTL（以秒为单位）  |
| `config.cache_control` | `false` | 启用时，请遵守[RFC7234](https://tools.ietf.org/html/rfc7234#section-5.2)中定义的Cache-Control行为 |
| `config.storage_ttl`  <br> `optional` |  | 将资源保留在存储后端的秒数。此值独立于`Cache_ttl`或由Cache-Control行为定义的资源TTL。 |
| `config.strategy` | | 用于保存缓存实体的后备数据存储。可接受的值是`memory`和`redis`。 |
| `config.memory.dictionary_name` | `kong_cache` | 选择内存策略时，用于保存缓存实体的共享字典的名称。请注意，此字典当前必须在Kong Nginx模板中手动定义。 |
| `config.redis.host`  <br> `semi-optional` |  | 定义redis策略时用于Redis连接的主机 |
| `config.redis.port`  <br> `semi-optional` |  | 定义redis策略时用于Redis连接的端口 |
| `config.redis.timeout`   <br> `semi-optional`| `2000` | 定义redis策略时用于Redis连接的连接超时 |
| `config.redis.password` <br> `semi-optional`  |  | 定义redis策略时用于Redis连接的密码。如果未定义，则不会向Redis发送AUTH命令。 |
| `config.redis.database` <br> `semi-optional`  | `0` | 定义redis策略时用于Redis连接的数据库 |
| `config.redis.sentinel_master`  <br> `semi-optional` |  | 定义redis策略时，Sentinel master用于Redis连接。定义此值意味着使用Redis Sentinel。 |
| `config.redis.sentinel_role` <br> `semi-optional`  |  | 定义redis策略时用于Redis连接的Sentinel角色。定义此值意味着使用Redis Sentinel。 |
| `config.redis.sentinel_addresses` <br> `semi-optional`  |  | 定义redis策略时，Sentinel地址用于Redis连接。定义此值意味着使用Redis Sentinel。 |
| `config.redis.cluster_addresses`  <br> `semi-optional` |  | 定义redis策略时用于Redis连接的群集地址。定义此值意味着使用Redis群集。 |

## 策略
`kong-plugin-enterprise-proxy-cache` 旨在支持以不同的后端格式存储代理缓存数据。目前提供以下策略：
- `memory`：一个`lua_shared_dict`，请注意，默认字典`kong_cache`也被Kong的其他插件和元素用于存储不相关的数据库缓存实体。使用这个字典是一种引导代理缓存插件的简单方法，但不推荐用于大规模安装，因为大量使用会对Kong的数据库缓存操作的其他方面施加压力。建议此时通过自定义Nginx模板定义单独的`lua_shared_dict`。
- `redis`：支持Redis和Redis Sentinel部署。

## 缓存 key

Kong基于请求方法，完整客户端请求（例如，请求路径和查询参数）以及与请求相关联的API或Consumer的UUID来键入每个高速缓存元素。这也意味着API 和/或 Consumer之间的缓存是不同的。目前，缓存密钥格式是硬编码的，无法调整。在内部，缓存键表示为组成部分的串联的十六进制编码的MD5和。计算方法如下：
```
key = md5(UUID | method | request)
```
其中`method`是通过OpenResty `ngx.req.get_method()`调用定义的，而请求是通过Nginx `$request` 变量定义的。
Kong将返回与给定请求关联的缓存键作为`X-Cache-Key`响应头。如上所述，还可以为给定请求预先计算高速缓存密钥。

## 缓存控制

启用`cache_control`配置选项后，Kong将遵循[RFC7234](https://tools.ietf.org/html/rfc7234#section-5.2)定义的请求和响应Cache-Control标头，但有一些例外：

- 目前尚不支持缓存重新验证，因此忽略了`proxy-revalidate`等指令。
- 类似地，简化了`no-cache`的行为以排除实体完全缓存。
- 目前尚不支持通过`Vary`进行二级密钥计算。

## 缓存状态

Kong通过`X-Cache-Status` header 识别请求的代理缓存行为的状态。
此 header 有几个可能的值：

- `Miss`:可以在缓存中满足请求，但是在缓存中找不到资源的条目，并且请求在上游代理。
- `Hit`:请求已满足并从缓存中提供。
- `Refresh`:资源在缓存中找到，但由于Cache-Control行为或达到其硬编码的cache_ttl阈值，无法满足请求。
- `Bypass`:基于插件配置的缓存无法满足请求。

## 存储TTL

Kong可以在存储引擎中存储比规定的`cache_ttl`或`Cache-Control`值指示的更长的资源实体。这允许Kong在其到期时维护资源的缓存副本。这允许能够使用`max-age`和`max-stale` header 的客户端在必要时请求过时的数据副本。

## 上游中断

由于Kong的核心请求处理模型的实现，此时代理缓存插件不能用于在上游无法访问时提供过时的缓存数据。为了使Kong能够提供缓存数据而不是在上游无法访问时返回错误，我们建议定义一个非常大的storage_ttl（大约几小时或几天），以便将过时的数据保存在缓存中。在上游中断的情况下，通过增加`cache_ttl`插件配置值可以将陈旧数据视为“新鲜”。通过这样做，在Kong尝试连接到失败的上游服务之前，先前已经被认为过时的数据现在被提供给客户端。

## Admin API

此插件为托管缓存实体提供了多个端点。这些端点分配给`proxy-cache`RBAC资源。

Admin API上提供了以下端点，用于检查和清除缓存实体：

### 查询缓存实体

有两个独立的端点可用：一个用于查找已知的插件实例，另一个用于搜索给定缓存键的所有代理缓存插件数据存储。
两个端点都具有相同的返回值。

**请求路径**
```
GET /proxy-cache/:plugin_id/caches/:cache_id
```

| 属性 | 描述 | 
| --- | ---- |
| `plugin_id` | 代理缓存插件的UUID |
| `cache_id` | 由X-Cache-Key响应头报告的缓存实体密钥  |

**请求路径**
```
GET /proxy-cache/:cache_id
```
| 属性 | 描述 | 
| --- | ---- |
| `cache_id` | 由X-Cache-Key响应头报告的缓存实体密钥 |

**响应**
如果缓存实体存在
```
HTTP 200 OK
```
如果具有给定键的实体不存在
```
HTTP 400 Not Found
```

### 删除缓存实体

有两个独立的端点可用：一个用于查找已知的插件实例，另一个用于搜索给定缓存键的所有代理缓存插件数据存储。
两个端点都具有相同的返回值。

**请求路径**
```
DELETE /proxy-cache/:plugin_id/caches/:cache_id
```

| 属性 | 描述 | 
| --- | ---- |
| `plugin_id` | 代理缓存插件的UUID |
| `cache_id` | 由X-Cache-Key响应头报告的缓存实体密钥  |

**请求路径**
```
DELETE /proxy-cache/:cache_id
```
| 属性 | 描述 | 
| --- | ---- |
| `cache_id` | 由X-Cache-Key响应头报告的缓存实体密钥 |

**响应**
如果缓存实体存在
```
HTTP 204 No Content
```
如果具有给定键的实体不存在
```
HTTP 400 Not Found
```

### 清除所有缓存实体

**请求路径**
```
DELETE /proxy-cache/
```
**响应**
```
HTTP 204 No Content
```
请注意，此端点会清除所有`proxy-cache`插件中的所有缓存实体。

