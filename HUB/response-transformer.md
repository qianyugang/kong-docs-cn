# Response Transformer 响应变更插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/response-transformer/

在将响应返回给客户端之前，转换上游服务器在Kong上发送的响应。

> 关于转换体的注意事项：注意响应体上转换的性能。为了解析和修改JSON主体，插件需要将其保留在内存中，这可能会在处理大型body（几个MB）时对工作者的Lua VM造成压力。由于Nginx的内部结构，在转换响应主体时不会设置`Content-Length` header。

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
    --data "name=response-transformer"  \
    --data "config.remove.headers=x-toremove, x-another-one" \
    --data "config.remove.json=json-key-toremove, another-json-key" \
    --data "config.add.headers=x-new-header:value,x-another-header:something" \
    --data "config.add.json=new-json-key:some_value, another-json-key:some_value" \
    --data "config.append.headers=x-existing-header:some_value, x-another-header:some_value"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: response-transformer
  service: {service}
  config: 
    remove.headers: x-toremove, x-another-one
    remove.json: json-key-toremove, another-json-key
    add.headers: x-new-header:value,x-another-header:something
    add.json: new-json-key:some_value, another-json-key:some_value
    append.headers: x-existing-header:some_value, x-another-header:some_value
```
在这两种情况下，`{service}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=response-transformer"  \
    --data "config.remove.headers=x-toremove, x-another-one" \
    --data "config.remove.json=json-key-toremove, another-json-key" \
    --data "config.add.headers=x-new-header:value,x-another-header:something" \
    --data "config.add.json=new-json-key:some_value, another-json-key:some_value" \
    --data "config.append.headers=x-existing-header:some_value, x-another-header:some_value"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: response-transformer
  route: {route}
  config: 
    remove.headers: x-toremove, x-another-one
    remove.json: json-key-toremove, another-json-key
    add.headers: x-new-header:value,x-another-header:something
    add.json: new-json-key:some_value, another-json-key:some_value
    append.headers: x-existing-header:some_value, x-another-header:some_value
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。


## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=response-transformer" \
     \
    --data "config.remove.headers=x-toremove, x-another-one" \
    --data "config.remove.json=json-key-toremove, another-json-key" \
    --data "config.add.headers=x-new-header:value,x-another-header:something" \
    --data "config.add.json=new-json-key:some_value, another-json-key:some_value" \
    --data "config.append.headers=x-existing-header:some_value, x-another-header:some_value"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: response-transformer
  consumer: {consumer}
  config: 
    remove.headers: x-toremove, x-another-one
    remove.json: json-key-toremove, another-json-key
    add.headers: x-new-header:value,x-another-header:something
    add.json: new-json-key:some_value, another-json-key:some_value
    append.headers: x-existing-header:some_value, x-another-header:some_value
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
| `name` |  |  要使用的插件的名称，在本例中为`response-transformer`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.remove.headers` <br> *optional* |  | header 名称列表。使用给定名称删除设置header。  |
| `config.remove.json` <br> *optional*  |  |  属性名称列表。如果存在，则从JSON正文中删除该属性。 |
| `config.replace.headers` <br> *optional*  |  | headername列表：键值对。当且仅当header已设置时，将其旧值替换为新值。如果尚未设置header，则忽略。  |
| `config.replace.json` <br> *optional*  |  | 属性列表：键值对。当且仅当参数已存在时，将其旧值替换为新值。如果参数尚不存在，则忽略。  |
| `config.add.headers` <br> *optional*  |  | header 名称列表：键值对。当且仅当header尚未设置时，设置具有给定值的新header。如果已设置标头，则忽略。  |
| `config.add.json` <br> *optional*  |  | 属性列表：键值对。  当且仅当属性不存在时，将具有给定值的新属性添加到JSON主体。如果该属性已存在则忽略。 |
| `config.append.headers` <br> *optional*  |  |  headername列表：键值对。如果未设置header，请使用给定值进行设置。如果已设置，则将设置具有相同名称和新值的新header。 |
| `config.append.json` <br> *optional*  |  | 财产清单：价值对。如果JSON正文中不存在该属性，请使用给定值添加该属性。如果它已经存在，则两个值（旧的和新的）将聚合在一个数组中。  |

注意：如果值包含a，则不能使用列表的逗号分隔格式。必须使用数组表示法。

## 执行顺序

插件按以下顺序执行响应变更：  
删除 -> 重命名 -> 替换 -> 添加 ->追加  
remove –> rename –> replace –> add –> append

## 例子

在这些示例中，我们在Route上启用了插件。这对于Service来说同样适用。

- 通过分别传递每个header：键值对来添加多个header：

**使用数据库：**
```
$ curl -X POST http://localhost:8001/routes/{route}/plugins \
  --data "name=response-transformer" \
  --data "config.add.headers[1]=h1:v1" \
  --data "config.add.headers[2]=h2:v1"
```

**不使用数据库：**
```
plugins:
- name: response-transformer
  route: {route}
  config:
    add:
      headers: ["h1:v1", "h2:v2"]
```

| 上游响应 header | 代理响应 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 通过传递逗号分隔的标头：值对来添加多个标头（仅适用于数据库）：

```
$ curl -X POST http://localhost:8001/routes/{route}/plugins \
  --data "name=response-transformer" \
  --data "config.add.headers=h1:v1,h2:v2"
```

| 上游响应 header | 代理响应 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 添加多个标头，将config作为JSON主体传递（仅适用于数据库）：
```
$ curl -X POST http://localhost:8001/routes/{route}/plugins \
  --header 'content-type: application/json' \
  --data '{"name": "response-transformer", "config": {"add": {"headers": ["h1:v2", "h2:v1"]}}}'
```

| 上游响应 header | 代理响应 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 |

- 添加body属性和header：

**使用数据库：**

```
$ curl -X POST http://localhost:8001/routes/{route}/plugins \
  --data "name=response-transformer" \
  --data "config.add.json=p1:v1,p2=v2" \
  --data "config.add.headers=h1:v1"
```

**不使用数据库：**

```
plugins:
- name: response-transformer
  route: {route}
  config:
    add:
      json: ["p1:v1", "p2=v2"]
      headers: ["h1:v1"]
```

| 上游响应 header | 代理响应 header |
| ------------- | --------------- |
| h1: v2 |  h1: v2 <br> h2: v1 |
| h3: v1 |  h1: v1 <br> h2: v1 <br> h3: v1|

| 上游响应JSON正文 | 代理响应正文 |
| ------------- | --------------- |
| {} | 	{“p1” : “v1”, “p2”: “v2”} | 
| {“p1” : “v2”} | {“p1” : “v2”, “p2”: “v2”} | 

- 附加多个标头并删除body参数：

**使用数据库：**

```
$ curl -X POST http://localhost:8001/routes/{route}/plugins \
  --header 'content-type: application/json' \
  --data '{"name": "response-transformer", "config": {"append": {"headers": ["h1:v2", "h2:v1"]}, "remove": {"json": ["p1"]}}}'
```

**不使用数据库：**

```
plugins:
- name: response-transformer
  route: {route}
  config:
    append:
      headers: ["h1:v2", "h2:v1"]
    remove:
      json: ["p1"]
```

| 上游响应 header | 代理响应 header |
| ------------- | --------------- |
| h1: v1 |  h1: v1 <br> h2: v1 <br> h2: v1 |

| 上游响应JSON正文 | 代理响应正文 |
| ------------- | --------------- |
| {“p2”: “v2”} | {“p2”: “v2”} 
| {“p1” : “v1”, “p2” : “v1”} | {“p2”: “v2”}| 
