# Apache OpenWhisk

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/openwhisk/

该插件调用[OpenWhisk操作](https://github.com/openwhisk/openwhisk/blob/master/docs/actions.md)。
它可以与其他请求插件结合使用以保护，管理或扩展功能。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。


## 安装

您可以使用LuaRocks软件包管理器来安装插件
```
$ luarocks install kong-plugin-openwhisk
```

或从[源码](https://github.com/Kong/kong-plugin-openwhisk)安装它。
有关插件安装的更多信息，请参阅[文档插件开发-安装/卸载插件](https://docs.konghq.com/latest/plugin-development/distribution/)


## 配置

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=openwhisk"  \
    --data "config.host=OPENWHISK_HOST" \
    --data "config.path=PATH_TO_ACTION" \
    --data "config.action=ACTION_NAME" \
    --data "config.service_token=AUTHENTICATION_TOKEN"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: openwhisk
  service: {service}
  config: 
    host: OPENWHISK_HOST
    path: PATH_TO_ACTION
    action: ACTION_NAME
    service_token: AUTHENTICATION_TOKEN
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

通过发出以下请求在 Route 上配置此插件：
```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=openwhisk"  \
    --data "config.host=OPENWHISK_HOST" \
    --data "config.path=PATH_TO_ACTION" \
    --data "config.action=ACTION_NAME" \
    --data "config.service_token=AUTHENTICATION_TOKEN"
```

**不使用数据库：**

通过添加此部分在 Route 上配置此插件执行声明性配置文件：

```
plugins:
- name: openwhisk
  route: {route}
  config: 
    host: OPENWHISK_HOST
    path: PATH_TO_ACTION
    action: ACTION_NAME
    service_token: AUTHENTICATION_TOKEN
```
在这两种情况下，`{route}`是此插件配置将定位的 route 的`id`或`name`。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=openwhisk" \
     \
    --data "config.host=OPENWHISK_HOST" \
    --data "config.path=PATH_TO_ACTION" \
    --data "config.action=ACTION_NAME" \
    --data "config.service_token=AUTHENTICATION_TOKEN"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: openwhisk
  consumer: {consumer}
  config: 
    host: OPENWHISK_HOST
    path: PATH_TO_ACTION
    action: ACTION_NAME
    service_token: AUTHENTICATION_TOKEN
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
| `name` |  |  要使用的插件的名称，在本例中为`openwhisk`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.host` |  | OpenWhisk服务的Host  |
| `config.port`<br> *optional* | `443` | OpenWhisk服务的Port  |
| `config.path` |  | `Action`资源的路径。  |
| `config.action` |  | 插件要调用的`Action`的名称。  |
| `config.service_token` |  | 用于访问Openwhisk资源的服务令牌。  |
| `config.https_verify` <br> *optional* | `false` | 将其设置为true可对`Openwhisk`服务进行身份验证。 |
| `config.https`<br> *optional*  | `true` | 使用HTTPS与OpenWhisk服务器连接。  |
| `config.result` <br> *optional* | `true` |  仅返回调用的`Action`的结果。 |
| `config.timeout` <br> *optional* | `60000` | 在终止与OpenWhisk服务器的连接之前的超时（以毫秒为单位）。 |
| `config.keepalive`<br> *optional*  | `60000` |  在关闭之前，与OpenWhisk服务器的空闲连接将存活的时间（以毫秒为单位）。 |

注意：如果`config.https_verify`设置为`true`，则将根据Kong配置中`lua_ssl_trusted_certificate`指令指定的CA证书来验证服务器证书。

## 示例

在这个演示中，我们在MacOS上的一个随机机器上运行Kong和[Openwhisk平台](https://github.com/openwhisk/openwhisk)。

1. 使用[wsk cli](https://github.com/openwhisk/openwhisk-cli)在Openwhisk平台上使用以下代码片段创建javascript Action `hello`。
	
    ```
     function main(params) {
     	var name = params.name || 'World';
     	return {payload:  'Hello, ' + name + '!'};
 	}
    ```
    ```
     $ wsk action create hello hello.js

 	ok: created action hello
    ```

2. 创建一个Service 或者 Route
	
    **使用数据库**
    
    创建一个Service 
    ```
     $ curl -i -X  POST http://localhost:8001/services/ \
   --data "name=openwhisk-test" \
   --data "url=http://example.com"

 	HTTP/1.1 201 Created
 	...
    ```
    创建一个使用该Service 的Route。
    ```
     $ curl -i -f -X  POST http://localhost:8001/services/openwhisk-test/routes/ \
   --data "paths[]=/"

 	HTTP/1.1 201 Created
 	...
    ```
    **不使用数据库**
	在声明性配置文件上添加Service和关联的Route：
    ```
     services:
     - name: openwhisk-test
       url: http://example.com

     routes:
     - service: openwhisk-test
       paths: ["/"]
    ```

3. 在Route上启用openwhisk插件

    **使用数据库**
    
    可以在Service或Route上启用插件。本示例使用Service。
    ```
     $ curl -i -X POST http://localhost:8001/services/openwhisk-test/plugins \
     --data "name=openwhisk" \
     --data "config.host=192.168.33.13" \
     --data "config.service_token=username:key" \
     --data "config.action=hello" \
     --data "config.path=/api/v1/namespaces/guest"

     HTTP/1.1 201 Created
     ...
    ```
    
    **不使用数据库**
    
    向`plugins: `添加一个条目:声明性配置yaml条目。它可以与Service或Route相关联。这个例子使用了一个Service:
    ```
     plugins:
     - name: openwhisk
       config:
         host: 192.168.33.13
         service_token: username:key
         action: hello
         path: /api/v1/namespaces/guest
    ```
    
4. 发出调用动作的请求

	**没有参数**
    ```
       $ curl -i -X POST http://localhost:8000/ -H "Host:example.com"
       HTTP/1.1 200 OK
       ...

       {
         "payload": "Hello, World!"
       }
    ```
	**参数为form-urlencoded**
    ```
       $ curl -i -X POST http://localhost:8000/ -H "Host:example.com" --data "name=bar"
       HTTP/1.1 200 OK
       ...

       {
         "payload": "Hello, bar!"
       }
    ```
	**参数为JSON**
    ```
       $ curl -i -X POST http://localhost:8000/ -H "Host:example.com" \
         -H "Content-Type:application/json" --data '{"name":"bar"}'
       HTTP/1.1 200 OK
       ...

       {
         "payload": "Hello, bar!"
       }
    ```
	**参数为multipart form**
    ```
       $ curl -i -X POST http://localhost:8000/ -H "Host:example.com"  -F name=bar
       HTTP/1.1 100 Continue

       HTTP/1.1 200 OK
       ...

       {
         "payload": "Hello, bar!"
       }
    ```
    **参数作为查询字符串**
    ```
       $ curl -i -X POST http://localhost:8000/?name=foo -H "Host:example.com"
       HTTP/1.1 200 OK
       ...

       {
         "payload": "Hello, foo!"
       }
    ```
    
    OpenWhisk元数据响应
    
    当Kong的`config.result`设置为`false`时，将返回OpenWhisk的元数据作为响应：
    ```
       $ curl -i -X POST http://localhost:8000/?name=foo -H "Host:example.com"
       HTTP/1.1 200 OK
       ...

       {
         "duration": 4,
         "name": "hello",
         "subject": "guest",
         "activationId": "50218ff03f494f62abbde5dfd2fcc68a",
         "publish": false,
         "annotations": [{
           "key": "limits",
           "value": {
             "timeout": 60000,
             "memory": 256,
             "logs": 10
           }
         }, {
           "key": "path",
           "value": "guest/hello"
         }],
         "version": "0.0.4",
         "response": {
           "result": {
             "payload": "Hello, foo!"
           },
           "success": true,
           "status": "success"
         },
         "end": 1491855076125,
         "logs": [],
         "start": 1491855076121,
         "namespace": "guest"
       }
    ```


## 限制

**使用伪造的上游服务**

当使用OpenWhisk插件时，响应将由插件本身返回，而无需将请求代理到任何上游服务。这意味着服务的`host`、`port`和`path`属性将被忽略，但是仍然必须指定要由Kong验证的实体。特别是`host`属性必须是IP地址，或者由您的名称服务器解析的主机名。

**响应插件**

系统中有一个已知的限制，阻止一些响应插件被执行。我们计划在未来取消这一限制。



