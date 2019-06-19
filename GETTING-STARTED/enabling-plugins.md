# 启用插件

> 本文原文链接：https://docs.konghq.com/1.1.x/getting-started/enabling-plugins/

> 在开始之前  
> 1  确保你已经安装了Kong - 只需要一分钟！
> 2  确保你已经启动了Kong。
> 3  确保已在Kong配置了Service。

在本节中，您将学习如何配置Kong插件。Kong的核心原则之一是它通过插件实现的可扩展性。插件允许您轻松地向服务添加新功能或使其更易于管理。

在下面的步骤中，您将配置key-auth插件以向您的Service添加身份验证。在添加此插件之前，您的Service的所有请求都将代理到上游。当你添加配置了这个插件，只有具有正确密钥的请求才会被代理 - 所有其他请求将被Kong拒绝，从而保护您的上游服务免遭未经授权的使用。

## 1.配置key-auth插件

要为您在Kong中[配置的服务](https://www.pocketdigi.com/book/kong/started/configuring-service.html)添加key-auth插件，请执行以下cURL请求：
```
$ curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=key-auth'
```

**注意：** 这个插件同时接受`config.key_names`参数，默认值是`['apiKey']`，这是一个header和参数名的列表（两者都支持），用于在请求时发送apiKey。

## 2.验证插件是否正确配置

执行以下cURL请求以验证是否在服务上正确配置了[key-auth](https://docs.konghq.com/plugins/key-authentication)插件：
```
$ curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com'
```

由于您未指定所需的`apikey` header 或参数，因此响应应为`401 Unauthorized：`

```
HTTP/1.1 401 Unauthorized
...

{
  "message": "No API key found in request"
}
Permalink
```

## 下一步

现在你已经配置好key-auth插件，接下来我们学习如何为Service[添加Consumer](adding-consumers.md)，以便我们可以通过认证继续通过Kong代理请求。













