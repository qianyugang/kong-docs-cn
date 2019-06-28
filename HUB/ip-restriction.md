# IP限制

通过将IP地址列入白名单或列入黑名单来限制对Service 或Route的访问。可以使用 [CIDR表示法](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)中的单个IP，多个IP或范围，如`10.10.10.0/24`。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
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
    --data "name=ip-restriction"  \
    --data "config.whitelist=54.13.21.1" \
    --data "config.whitelist=143.1.0.0/24"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: ip-restriction
  service: {service}
  config: 
    whitelist: 54.13.21.1143.1.0.0/24
```
在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=ip-restriction"  \
    --data "config.whitelist=54.13.21.1" \
    --data "config.whitelist=143.1.0.0/24"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: ip-restriction
  route: {route}
  config: 
    whitelist: 54.13.21.1143.1.0.0/24
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=ip-restriction" \
     \
    --data "config.whitelist=54.13.21.1" \
    --data "config.whitelist=143.1.0.0/24"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: ip-restriction
  consumer: {consumer}
  config: 
    whitelist: 54.13.21.1143.1.0.0/24
```
在这两种情况下，`{consumer`}都是此插件配置将定位的`Consumer`的`id`或`username`。  
您可以组合`consumer_id`和`service_id` 。 
在同一个请求中，进一步缩小插件的范围。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`ip-restriction`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.whitelist` |  |  必须指定`config.whitelist`或`config.blacklist`其中之一。 |
| `config.blacklist` |  |  必须指定`config.whitelist`或`config.blacklist`其中之一。 |

请注意，`whitelist`和`blacklist`模型在其使用中是互斥的，因为它们提供了互补的方法。也就是说，您无法使用`whitelist`和`blacklist`同时来配置插件。白名单提供了一种积极的安全模型，其中允许配置的CIDR范围访问资源，而其他所有范围都被拒绝。白名单提供了一种积极的安全模型，其中允许配置的CIDR范围访问资源，而其他所有范围都被拒绝。
相比之下，黑名单配置提供了负面的安全模型，其中明确拒绝某些CIDRS访问资源（并且其他所有其他内容都是允许的）。










