# ACL

通过使用任意ACL组名称将消费者列入白名单或将其列入黑名单来限制对 Service 或者 Route 的访问。
此插件需要在服务或路由上启用[身份验证插件](https://docs.konghq.com/about/faq/#how-can-i-add-authentication-to-a-microservice-api)。

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

可以使用声明性配置创建使用者和ACL。
在ACL上执行POST，PUT，PATCH或DELETE的Admin API端点在无DB模式下不起作用。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=acl"  \
    --data "config.whitelist=group1" \
    --data "config.whitelist=group2" \
    --data "config.hide_groups_header=true"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: acl
  service: {service}
  config: 
    whitelist:
    - group1
    - group2
    hide_groups_header: true
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=acl"  \
    --data "config.whitelist=group1" \
    --data "config.whitelist=group2" \
    --data "config.hide_groups_header=true"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: acl
  route: {route}
  config: 
    whitelist:
    - group1
    - group2
    hide_groups_header: true
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
| `name` |  |  要使用的插件的名称，在本例中为`ip-restriction`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.whitelist` <br> *semi-optional* |  |  允许使用Service 或 Route的任意组名。必须指定`config.whitelist`或`config.blacklist`其中之一。 |
| `config.blacklist` <br> *semi-optional* |  |  允许使用Service 或 Route的任意组名。必须指定`config.whitelist`或`config.blacklist`其中之一。 |
| `config.hide_groups_header` <br> *optional* | `false` | 如果启用（`true`），则标志阻止`X-Consumer-Groups`header在请求中发送到上游服务。|

请注意，`whitelist`和`blacklist`模型在其使用中是互斥的，因为它们提供了互补的方法。也就是说，您无法使用`whitelist`和`blacklist`同时来配置插件。白名单提供了一种积极的安全模型，其中允许配置的CIDR范围访问资源，而其他所有范围都被拒绝。白名单提供了一种积极的安全模型，其中允许配置的CIDR范围访问资源，而其他所有范围都被拒绝。
相比之下，黑名单配置提供了负面的安全模型，其中明确拒绝某些CIDRS访问资源（并且其他所有其他内容都是允许的）。

## 用法

为了使用此插件，您需要使用[身份验证插件](https://docs.konghq.com/about/faq/#how-can-i-add-authentication-to-a-microservice-api)正确配置服务或路由，以便插件可以识别谁是发出请求的客户端[Consumer](https://docs.konghq.com/latest/admin-api/#consumer-object)。

### 通过Consumers

**使用数据库：**

将身份验证插件添加到服务或路由并创建了 Consumer 后，您现在可以使用以下请求将组关联到 Consumer ：
```
$ curl -X POST http://kong:8001/consumers/{consumer}/acls \
    --data "group=group1"
```

`consumer`：要将凭据关联到的Consumer实体的`id`或`username`属性。

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `group` | | 要与使用者关联的任意组名称。|

**不使用数据库：**

您可以通过声明性配置文件中的`acls`：条目创建ACL对象:
```
acls:
  consumer: { consumer }
  group: group1
```

- `consumer`：要将凭据关联到的Consumer实体的`id`或`username`属性。
- `group`：要与使用者关联的任意组名称。

您可以将多个组关联到 consumer。

### Upstream Headers

验证consumer后，插件会将`X-Consumer-Groups` header 附加到请求，然后再将其代理到上游服务，这样您就可以识别与消费者相关联的组。header的值是以逗号分隔的属于使用者的组列表，例如`admin，pro_user`。

如果`hide_groups_header`配置标志设置为`true`，则此header不会在请求中注入上游服务。

### 通过ACL分页

> 注意：此功能在Kong 0.11.2中引入。

您可以使用以下请求检索所有Consumers的所有ACL：

```
$ curl -X GET http://kong:8001/acls

{
    "total": 3,
    "data": [
        {
            "group": "foo-group",
            "created_at": 1511391159000,
            "id": "724d1be7-c39e-443d-bf36-41db17452c75",
            "consumer": { "id": "89a41fef-3b40-4bb0-b5af-33da57a7ffcf" }
        },
        {
            "group": "bar-group",
            "created_at": 1511391162000,
            "id": "0905f68e-fee3-4ecb-965c-fcf6912bf29e",
            "consumer": { "id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880" }
        },
        {
            "group": "baz-group",
            "created_at": 1509814006000,
            "id": "ff883d4b-aee7-45a8-a17b-8c074ba173bd",
            "consumer": { "id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880" }
        }
    ]
}
```

您可以使用此其他路径按consumer筛选列表：

```
$ curl -X GET http://kong:8001/consumers/{username or id}/acls

{
    "total": 1,
    "data": [
        {
            "group": "bar-group",
            "created_at": 1511391162000,
            "id": "0905f68e-fee3-4ecb-965c-fcf6912bf29e",
            "consumer": { "id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880" }
        }
    ]
}
```

`username or id`：需要列出ACL的使用者的用户名或ID

### 检索与ACL关联的Consumer

> 注意：此功能在Kong 0.11.2中引入。

可以使用以下请求检索与ACL关联的 Consumer ：
```
curl -X GET http://kong:8001/acls/{id}/consumer

{
   "created_at":1507936639000,
   "username":"foo",
   "id":"c0d92ba9-8306-482a-b60d-0cfdd2f0e880"
}
```

`id`：要获取关联Consumer的ACL的`id`属性。



