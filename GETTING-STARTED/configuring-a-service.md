# 配置一个服务

> 本文原文链接：https://docs.konghq.com/1.1.x/getting-started/configuring-a-service/

> 在开始之前  
> 1  确保你已经安装了Kong - 只需要一分钟！
> 2  确保你已经启动了Kong。

在本节中，您将向Kong添加一个API。为此，您首先需要添加一个*Service*；这就是Kong用来指定它管理的上游API和微服务的名称。

出于本指南的目的，我们将创建一个指向[Mockbin API](https://mockbin.com/)的服务。Mockbin是一个“echo”类型的公共网站，它将返回请求的请求作为响应返回给请求者。这有助于了解Kong如何代理您的API请求。

在开始向Service发出请求之前，您需要为其添加一个*Route*。Route指定请求在到达Kong后如何（以及是否）发送到其服务。一个Service可以有多个Route.

在配置完Service和Route以后，就可以通过Kong使用他们发送请求。

Kong在`:8001`端口上公开了RESTful Admin API。
Kong的配置，包括添加的Service和Route，是通过对该API发送请求进行的。

## 1.使用Admin API添加您的服务

执行以下cURL请求，将你的第一个Service(指向[Mockbin API](https://mockbin.com/))添加到Kong:
```
$ curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=example-service' \
  --data 'url=http://mockbin.org'
```
您应该收到类似于的响应：
```
HTTP/1.1 201 Created
Content-Type: application/json
Connection: keep-alive

{
   "host":"mockbin.org",
   "created_at":1519130509,
   "connect_timeout":60000,
   "id":"92956672-f5ea-4e9a-b096-667bf55bc40c",
   "protocol":"http",
   "name":"example-service",
   "read_timeout":60000,
   "port":80,
   "path":null,
   "updated_at":1519130509,
   "retries":5,
   "write_timeout":60000
}
```

## 2.为服务添加一个路由

```
$ curl -i -X POST \
  --url http://localhost:8001/services/example-service/routes \
  --data 'hosts[]=example.com'
```
您应该收到类似于的响应：
```
HTTP/1.1 201 Created
Content-Type: application/json
Connection: keep-alive

{
   "created_at":1519131139,
   "strip_path":true,
   "hosts":[
      "example.com"
   ],
   "preserve_host":false,
   "regex_priority":0,
   "updated_at":1519131139,
   "paths":null,
   "service":{
      "id":"79d7ee6e-9fc7-4b95-aa3b-61d2e17e7516"
   },
   "methods":null,
   "protocols":[
      "http",
      "https"
   ],
   "id":"f9ce2ed7-c06e-4e16-bd5d-3a82daef3f9d"
}
```

Kong现在知道了这个Service并准备代理请求。


## 3.通过Kong转发您的请求

执行下面的cURL请求，验证Kong是否正确转发到你的Service。 注意，默认情况下，Kong在`:8000`端口处理代理请求。
```
$ curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com'
```

成功的响应意味着Kong现在将对`http//localhost:8000`的请求转发到我们在步骤1中配置的URL，并将响应转发给我们。Kong知道通过上面的cURL请求中定义的header来执行此操作：

- `Host: <given host>`

## 下一步

现在你已经添加了Service到Kong,接下来我们学习如何[启用插件](enabling-plugins.md)。









