# 微服务 API 网关 Kong File Log 插件中文文档

** 原文链接：** [https://docs.konghq.com/hub/kong-inc/file-log/#parameters](https://docs.konghq.com/hub/kong-inc/file-log/#parameters)  
（如有翻译的不准确或错误之处，欢迎留言指出）

将请求和响应数据写入磁盘上的日志文件中。不建议在生产中使用此插件，在生产环境下，最好使用另一个日志插件，例如`syslog`。由于系统限制，此插件使用阻塞文件i/o，将会损害性能，因此是Kong安装的反面模式。  
注意：此插件的功能与0.10.2之前的Kong版本捆绑在一起，与此处记录的不同。
有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

# 配置

## 在服务上启用插件
通过发出以下请求在[服务](https://docs.konghq.com/latest/admin-api/#service-object)上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=file-log"  \
    --data "config.path=/tmp/file.log"
```
`service`:此插件配置将绑定的服务的ID或名称。

## 在路由上启用插件

在[Route](https://docs.konghq.com/latest/admin-api/#Route-object)上配置此插件：
```
$ curl -X POST http://kong:8001/routes/{route_id}/plugins \
    --data "name=file-log"  \
    --data "config.path=/tmp/file.log"
```
`route_id`:此插件配置将绑定的路由的ID。

## 在Consumer上启用插件

您可以使用 `http://localhost:8001/plugins` 端点在特定的[Consumers](https://docs.konghq.com/latest/admin-api/#Consumer-object)上启用此插件：
```
$ curl -X POST http://kong:8001/plugins \
    --data "name=file-log" \
    --data "consumer_id={consumer_id}"  \
    --data "config.path=/tmp/file.log"
```
其中，`consumer_id`是我们想要与此插件关联的消费者的ID。您可以组合`consumer_id`和`service_id`。在同一个请求中，进一步缩小插件的范围。

## 全局插件
可以使用`http://kong:8001/plugins/` 配置所有插件。与任何服务，路由或消费者（或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数名称 | 默认值 | 描述 |
| -------- | ------ | ---- |
| `name`  |  | 要使用的插件的名称，在本例中为`file-log` |
| `service_id` |  | 此插件将关联的服务的ID。 |
| `route_id` |  | 此插件将关联的路由的ID。 |
| `enabled` | `true` | 是否将应用此插件。 |
| `consumer_id` |  | 此插件将定位的绑定的id。 |
| `config.path	` |  | 输出日志文件的文件路径。<br>如果该文件尚不存在，该插件将创建该文件。<br>确保Kong对此文件具有写入权限。 |
| `config.reopen` | `false` | 在kong`0.10.2`引入。确定是否关闭日志文件并在每个请求时重新打开。 如果文件未重新打开，并且已被删除/循环，则插件将继续写入过时的文件描述符，从而丢失信息。|


# 日志格式

每个请求将分别记录在由新行`\n`分隔的JSON对象中，格式如下：
```
{
    "request": {
        "method": "GET",
        "uri": "/get",
        "url": "http://httpbin.org:8000/get",
        "size": "75",
        "querystring": {},
        "headers": {
            "accept": "*/*",
            "host": "httpbin.org",
            "user-agent": "curl/7.37.1"
        }
    },
    "upstream_uri": "/",
    "response": {
        "status": 200,
        "size": "434",
        "headers": {
            "Content-Length": "197",
            "via": "kong/0.3.0",
            "Connection": "close",
            "access-control-allow-credentials": "true",
            "Content-Type": "application/json",
            "server": "nginx",
            "access-control-allow-origin": "*"
        }
    },
    "tries": [
        {
            "state": "next",
            "code": 502,
            "ip": "127.0.0.1",
            "port": 8000
        },
        {
            "ip": "127.0.0.1",
            "port": 8000
        }
    ],
    "authenticated_entity": {
        "consumer_id": "80f74eef-31b8-45d5-c525-ae532297ea8e",
        "id": "eaa330c0-4cff-47f5-c79e-b2e4f355207e"
    },
    "route": {
        "created_at": 1521555129,
        "hosts": null,
        "id": "75818c5f-202d-4b82-a553-6a46e7c9a19e",
        "methods": null,
        "paths": [
            "/example-path"
        ],
        "preserve_host": false,
        "protocols": [
            "http",
            "https"
        ],
        "regex_priority": 0,
        "service": {
            "id": "0590139e-7481-466c-bcdf-929adcaaf804"
        },
        "strip_path": true,
        "updated_at": 1521555129
    },
    "service": {
        "connect_timeout": 60000,
        "created_at": 1521554518,
        "host": "example.com",cuowu
        "id": "0590139e-7481-466c-bcdf-929adcaaf804",
        "name": "myservice",
        "path": "/",
        "port": 80,
        "protocol": "http",
        "read_timeout": 60000,
        "retries": 5,
        "updated_at": 1521554518,
        "write_timeout": 60000
    },
    "workspaces": [
        {
            "id":"b7cac81a-05dc-41f5-b6dc-b87e29b6c3a3",
            "name": "default"
        }
    ],
    "consumer": {
        "username": "demo",
        "created_at": 1491847011000,
        "id": "35b03bfc-7a5b-4a23-a594-aa350c585fa8"
    },
    "latencies": {
        "proxy": 1430,
        "kong": 9,
        "request": 1921
    },
    "client_ip": "127.0.0.1",
    "started_at": 1433209822425
}
```

关于上述JSON对象的一些注意事项：

- `request` 包含有关客户端发送的请求的属性
- `response` 包含有关发送到客户端的响应的属性
- `tries` 包含负载均衡器为此请求进行的（重新）尝试（成功和失败）列表
- `route` 包含有关所请求的特定路线的Kong属性
- `service` 包含与所请求的路线相关联的服务的Kong属性
- `authenticated_entity` 包含有关经过身份验证的凭据的Kong属性（如果已启用身份验证插件）
- `workspaces` 包含与请求的路由关联的工作空间的Kong属性。**仅限Kong Enterprise版本> = 0.34**
- `consumer` 包含经过身份验证的使用者（如果已启用身份验证插件）
- `latencies` 包含一些有关延迟的数据：
	- `proxy` 是最终服务处理请求所花费的时间
	- `kong` 是运行所有插件所需的内部Kong延迟
	- `request` 是从客户端读取的第一个字节之间以及最后一个字节发送到客户端之间经过的时间。用于检测慢速客户端。
- `client_ip` 包含原始客户端IP地址
- `started_at` 包含开始处理请求的UTC时间戳。

# Kong执行错误

此日志记录插件仅记录HTTP请求和响应数据。
如果您正在寻找Kong进程错误文件（这是nginx错误文件），那么您可以在以下路径找到它：`{prefix}/logs/error.log`










