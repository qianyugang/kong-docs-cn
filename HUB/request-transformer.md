# Request Transformer 请求变更插件

> https://docs.konghq.com/hub/kong-inc/request-transformer/

在上游服务器接收之前，变更客户端在Kong上发送的请求。

> 注意：此插件的功能与0.10.0之前的Kong版本捆绑在一起，与此处记录的不同。有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

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
    --data "name=request-transformer"  \
    --data "config.remove.headers=x-toremove" \
    --data "config.remove.headers=x-another-one" \
    --data "config.remove.querystring=qs-old-name:qs-new-name" \
    --data "config.remove.querystring=qs2-old-name:qs2-new-name" \
    --data "config.remove.body=formparam-toremove" \
    --data "config.remove.body=formparam-another-one" \
    --data "config.rename.headers=header-old-name:header-new-name" \
    --data "config.rename.headers=another-old-name:another-new-name" \
    --data "config.rename.querystring=qs-old-name:qs-new-name" \
    --data "config.rename.querystring=qs2-old-name:qs2-new-name" \
    --data "config.rename.body=param-old:param-new" \
    --data "config.rename.body=param2-old:param2-new" \
    --data "config.append.headers=x-existing-header:some_value" \
    --data "config.append.headers=x-another-header:some_value" \
    --data "config.add.headers=x-new-header:value" \
    --data "config.add.headers=x-another-header:something" \
    --data "config.add.querystring=new-param:some_value" \
    --data "config.add.querystring=another-param:some_value" \
    --data "config.add.body=new-form-param:some_value" \
    --data "config.add.body=another-form-param:some_value"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: request-transformer
  service: {service}
  config: 
    remove.headers:
    - x-toremove
    - x-another-one
    remove.querystring:
    - qs-old-name:qs-new-name
    - qs2-old-name:qs2-new-name
    remove.body:
    - formparam-toremove
    - formparam-another-one
    rename.headers:
    - header-old-name:header-new-name
    - another-old-name:another-new-name
    rename.querystring:
    - qs-old-name:qs-new-name
    - qs2-old-name:qs2-new-name
    rename.body:
    - param-old:param-new
    - param2-old:param2-new
    append.headers:
    - x-existing-header:some_value
    - x-another-header:some_value
    add.headers:
    - x-new-header:value
    - x-another-header:something
    add.querystring:
    - new-param:some_value
    - another-param:some_value
    add.body:
    - new-form-param:some_value
    - another-form-param:some_value
```
在这两种情况下，`{service}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=request-transformer" \
     \
    --data "config.remove.headers=x-toremove" \
    --data "config.remove.headers=x-another-one" \
    --data "config.remove.querystring=qs-old-name:qs-new-name" \
    --data "config.remove.querystring=qs2-old-name:qs2-new-name" \
    --data "config.remove.body=formparam-toremove" \
    --data "config.remove.body=formparam-another-one" \
    --data "config.rename.headers=header-old-name:header-new-name" \
    --data "config.rename.headers=another-old-name:another-new-name" \
    --data "config.rename.querystring=qs-old-name:qs-new-name" \
    --data "config.rename.querystring=qs2-old-name:qs2-new-name" \
    --data "config.rename.body=param-old:param-new" \
    --data "config.rename.body=param2-old:param2-new" \
    --data "config.append.headers=x-existing-header:some_value" \
    --data "config.append.headers=x-another-header:some_value" \
    --data "config.add.headers=x-new-header:value" \
    --data "config.add.headers=x-another-header:something" \
    --data "config.add.querystring=new-param:some_value" \
    --data "config.add.querystring=another-param:some_value" \
    --data "config.add.body=new-form-param:some_value" \
    --data "config.add.body=another-form-param:some_value"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: request-transformer
  consumer: {consumer}
  config: 
    remove.headers:
    - x-toremove
    - x-another-one
    remove.querystring:
    - qs-old-name:qs-new-name
    - qs2-old-name:qs2-new-name
    remove.body:
    - formparam-toremove
    - formparam-another-one
    rename.headers:
    - header-old-name:header-new-name
    - another-old-name:another-new-name
    rename.querystring:
    - qs-old-name:qs-new-name
    - qs2-old-name:qs2-new-name
    rename.body:
    - param-old:param-new
    - param2-old:param2-new
    append.headers:
    - x-existing-header:some_value
    - x-another-header:some_value
    add.headers:
    - x-new-header:value
    - x-another-header:something
    add.querystring:
    - new-param:some_value
    - another-param:some_value
    add.body:
    - new-form-param:some_value
    - another-form-param:some_value
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
| `config.http_method` <br> *optional* |  | 更改上游请求的HTTP方法。  |
| `config.remove.headers` <br> *optional* |  | headers 名列表。使用给定名称取消设置 header。  |
| `config.remove.querystring` <br> *optional* |  | 查询字符串名称列表。删除查询字符串（如果存在）。  |
| `config.remove.body` <br> *optional* |  | 参数名称列表。当且仅当content-type是以下[`application/json`，`multipart/form-data`，`application/x-www-form-urlencoded`]并且参数存在时，删除参数。|
| `config.replace.headers` <br> *optional* |  | headername列表：键值对。当且仅当header已设置时，将其旧值替换为新值。如果尚未设置header，则忽略。  |
| `config.replace.querystring` <br> *optional* |  | 查询名称列表：键值对。当且仅当字段名称已设置时，将其旧值替换为新值。如果尚未设置字段名称，则忽略。  |
| `config.rename.headers` <br> *optional* |  |  headername列表：键值对。当且仅当标头已设置时，重命名header。该值保持不变。如果尚未设置标头，则忽略。 |
| `config.rename.querystring` <br> *optional* |  |  查询名称列表：键值对。当且仅当已设置字段名称时，重命名字段名称。该值保持不变。如果尚未设置字段名称，则忽略。 |
| `config.rename.body` <br> *optional* |  |  参数名称列表：键值对。当且仅当content-type为以下[`application/json`，`multipart/form-data`，`application/x-www-form-urlencoded`]且参数存在时，重命名参数名称。 |
| `config.append.headers` <br> *optional* |  | headername列表：键值对。如果未设置header，请使用给定值进行设置。如果已设置，则将设置具有相同名称和新值的新header。  |
| `config.replace.body` <br> *optional* |  | 参数名称列表：键值对。当且仅当content-type是以下[`application/json`，`multipart/form-data`，`application/x-www-form-urlencoded`]并且参数已经存在时，将其旧值替换为新值。如果参数尚不存在，则忽略。  |
| `config.add.headers` <br> *optional* |  |  headername列表：键值对。当且仅当header尚未设置时，设置具有给定值的新标头。如果已设置header，则忽略。 |
| `config.add.querystring` <br> *optional* |  |  查询名称列表：键值对。当且仅当尚未设置查询字符串时，设置具有给定值的新查询字符串。如果已设置查询字符串，则忽略。 |
| `config.add.body` <br> *optional* |  | pramname列表：键值对。当且仅当内容类型是以下[`application/json`，`multipart/form-data`，`application/x-www-form-urlencoded`]并且参数不存在时，添加具有给定值的新参数以形成 form-encoded 请求体。如果参数已存在，则忽略。  |
| `config.append.headers` <br> *optional* |  | headername列表：键值对。如果未设置header，请使用给定值进行设置。如果已设置，则将附加具有相同名称和新值的其他新header。  |
| `config.append.querystring` <br> *optional* |  | 查询名称列表：键值对。如果未设置查询字符串，请使用给定值进行设置。如果已设置，将设置具有相同名称和新值的新查询字符串。  |
| `config.append.body` <br> *optional* |  | 参数名称列表：键值对。如果content-type是以下[`application/json`，`multipart/form-data`，`application/x-www-form-urlencoded`]中的一个，则在参数不存在的情况下添加具有给定值的新参数，否则如果它已经存在，则添加两个值（旧的和新的）将聚合在一个数组中。  |

注意：如果值包含一个`,`则不能使用以逗号分隔的列表格式。必须使用数组表示法。

## 基于请求内容的动态变更

与Kong Enterprise捆绑在一起的Request Transformer插件允许根据客户端请求中找到的变量数据添加或替换上游请求中的内容，例如请求header，查询字符串参数或URI捕获组定义的URI参数。

如果您已经是Kong Enterprise客户，则可以使用Enterprise支持渠道打开支持服务单，请求访问此插件功能。

如果您不是Kong Enterprise客户，可以通过联系我们来咨询我们的企业产品。

## 执行顺序

插件按以下顺序执行响应变更：  
删除 -> 重命名 -> 替换 -> 添加 ->追加  
remove –> rename –> replace –> add –> append

## 例子

在这些示例中，我们在服务上启用了插件。这对于Routes来说同样适用。

- 通过分别传递每个header：键值对来添加多个header：

**使用数据库：**
```
$ curl -X POST http://localhost:8001/services/example-service/plugins \
  --data "name=request-transformer" \
  --data "config.add.headers[1]=h1:v1" \
  --data "config.add.headers[2]=h2:v1"
```

**不使用数据库：**
```
plugins:
- name: request-transformer
  config:
    add:
      headers: ["h1:v1", "h2:v1"]
```

| 传入请求header | 上游代理的 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 通过传递逗号分隔的标头：值对来添加多个标头（仅适用于数据库）：

```
$ curl -X POST http://localhost:8001/services/example-service/plugins \
  --data "name=request-transformer" \
  --data "config.add.headers=h1:v1,h2:v2"
```

| 传入请求header | 上游代理的 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 添加多个标头，将config作为JSON主体传递（仅适用于数据库）：
```
$ curl -X POST http://localhost:8001/services/example-service/plugins \
  --header 'content-type: application/json' \
  --data '{"name": "request-transformer", "config": {"add": {"headers": ["h1:v2", "h2:v1"]}}}'
```

| 传入请求header | 上游代理的 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 添加查询字符串和header：

**使用数据库：**

```
$ curl -X POST http://localhost:8001/services/example-service/plugins \
  --data "name=request-transformer" \
  --data "config.add.querystring=q1:v2,q2:v1" \
  --data "config.add.headers=h1:v1"
```

**不使用数据库：**

```
plugins:
- name: request-transformer
  config:
    add:
      headers: ["h1:v1"],
      querystring: ["q1:v1", "q2:v2"]

```

| 传入请求header | 上游代理的 header |
| ------------- | --------------- |
| h1: v2 |  h1: v2 <br> h2: v1 |
| h3: v1 |  h1: v1 <br> h2: v1 <br> h3: v1|

| 传入请求查询字符串 | 上游代理的查询字符串 |
| ------------- | --------------- |
| ?q1=v1 | ?q1=v1&q2=v1 | 
| | ?q1=v2&q2=v1 | 

- 附加多个标头并删除body参数：

**使用数据库：**

```
$ curl -X POST http://localhost:8001/services/example-service/plugins \
  --header 'content-type: application/json' \
  --data '{"name": "request-transformer", "config": {"append": {"headers": ["h1:v2", "h2:v1"]}, "remove": {"body": ["p1"]}}}'
```

**不使用数据库：**

```
plugins:
- name: request-transformer
  config:
    add:
      headers: ["h1:v1", "h2:v1"]
    remove:
      body: [ "p1" ]
```

| 传入请求header | 上游代理的 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

| 传入请求查询字符串 | 上游代理的查询字符串 |
| ------------- | --------------- |
| p1=v1&p2=v1 | 	p2=v1 | 
| p2=v1 | p2=v1 | 
