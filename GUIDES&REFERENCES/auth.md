# 认证

## 简介

上游服务（API或微服务）的流量通常由各种Kong的[身份验证插件](https://konghq.com/plugins/)的应用程序和配置控制。由于Kong的服务实体代表您自己的上游服务的一对一映射，最简单的方案是在您选择的服务上配置身份验证插件。

## 通用身份验证

最常见的情况是要求身份验证，并且不允许访问任何未经身份验证的请求。为此，可以使用任何认证插件。
这些插件的通用方案/流程如下：

1. 将auth插件应用于服务或全局（您不能将其应用于消费者） 
2. 创建一个消费者`consumer`实体
3. 为消费者提供特定身份验证方法的身份验证凭据
4. 现在每当有请求进入Kong时，都会检查提供的凭据（取决于身份验证类型），如果请求无法验证，它将阻止请求，或者在header中添加使用者和凭据详细信息并转发请求。

上面的通用流程并不总是适用，例如在使用LDAP等外部身份验证时，则不会识别任何使用者，并且只会在转发的头中添加凭据。可以在每个[插件的文档](https://konghq.com/plugins/)中找到特定于身份验证方法的元素和示例。

## 消费者

考虑消费者的最简单方法是将它们一对一地映射到用户。然而，对于kong来说这并不重要。消费者的核心原则是您可以将插件附加到它们，从而定制请求行为。因此，您可能拥有移动应用，并为每个应用或其版本定义一个消费者。或者每个平台都有一个消费者，例如Android消费者，iOS消费者等。

这对kong来说是一个不透明的概念，因此它们被称为“消费者”，而不是“用户”。

## 匿名访问

Kong能够配置给定的服务以允许经过身份验证和匿名访问。您可以使用此配置向具有低速率限制的匿名用户授予访问权限，并授予对具有更高速率限制的经过身份验证的用户的访问权限。

要配置这样的服务，首先应用您选择的身份验证插件，然后创建一个新的使用者来表示匿名用户，然后配置您的身份验证插件以允许匿名访问。接下来是一个示例，假设您已经配置了一个名为`example-service`的服务和相应的路由：

### 1.创建示例服务和路由

发出以下cURL请求以创建指向mockbin.org的`example-service`，它将显示请求：
```
 $ curl -i -X POST \
   --url http://localhost:8001/services/ \
   --data 'name=example-service' \
   --data 'url=http://mockbin.org/request'
```
添加到service的router：
```
$ curl -i -X POST \
   --url http://localhost:8001/services/example-service/routes \
   --data 'paths[]=/auth-sample'
```

url `http//localhost:8000/auth-sample`现在将显示所请求的内容。

### 2.为您的服务配置key-auth插件

发出以下cURL请求以向服务添加插件：
```
 $ curl -i -X POST \
   --url http://localhost:8001/services/example-service/plugins/ \
   --data 'name=key-auth'
```

请务必记下创建的插件 `id` - 您将在步骤5中使用它。

### 3.验证key-auth插件是否已正确配置

发出以下cURL请求以验证是否在服务上正确配置了key-auth插件：
```
 $ curl -i -X GET \
   --url http://localhost:8000/auth-sample
```
由于您未指定所需的`apikey`header	或参数，并且尚未启用匿名访问，因此响应应为`403 Forbidden`：
```
 HTTP/1.1 403 Forbidden
 ...

 {
   "message": "No API key found in headers or querystring"
 }
```

### 4.创建一个匿名消费者

Kong代理的每个请求都必须与Consumer关联。
现在，您将通过发出以下请求来创建名为`anonymous_users`的消费者（Kong将在代理匿名访问时使用）：
```
 $ curl -i -X POST \
   --url http://localhost:8001/consumers/ \
   --data "username=anonymous_users"
```
您应该看到类似于下面的响应：
```
HTTP/1.1 201 Created
 Content-Type: application/json
 Connection: keep-alive

 {
   "username": "anonymous_users",
   "created_at": 1428555626000,
   "id": "bbdf1c48-19dc-4ab7-cae0-ff4f59d87dc9"
 }
```
请务必记下消费者 `id` - 您将在下一步中使用它。

### 5.启用匿名访问

您现在将通过发出以下请求重新配置key-auth插件以允许匿名访问（使用步骤2和4中的`id`值替换下面的示例uuids）：

```
$ curl -i -X PATCH \
   --url http://localhost:8001/plugins/<your-plugin-id> \
   --data "config.anonymous=<your-consumer-id>"
```

参数`config.anonymous=<your-consumer-id>`指示此服务上的key-auth插件允许匿名访问，并将此类访问与我们在上一步中收到的Consumer `id`相关联。您需要在此步骤中提供有效且预先存在的使用者`id` - 在配置匿名访问时当前未检查使用者`id`的有效性，并且配置尚不存在的使用者`id`将导致不正确的配置。

### 6.检查匿名访问

通过发出以下请求确认您的服务现在允许匿名访问：
```
 $ curl -i -X GET \
   --url http://localhost:8000/auth-sample
```

这与您在步骤3中提出的请求相同，但这次请求应该成功，因为您在步骤＃5中启用了匿名访问。

响应（这是Mockbin收到的请求）应该具有以下元素：
```
 {
   ...
   "headers": {
     ...
     "x-consumer-id": "713c592c-38b8-4f5b-976f-1bd2b8069494",
     "x-consumer-username": "anonymous_users",
     "x-anonymous-consumer": "true",
     ...
   },
   ...
 }
```

它显示请求是成功的，但是是匿名的。


## 多重认证

Kong支持给定服务的多个身份验证插件，允许不同的客户端使用不同的身份验证方法来访问给定的服务或路由。

在评估多个身份验证凭据时，可以将auth插件的行为设置为执行逻辑`AND`或逻辑`OR`。行为的关键是`config.anonymous`属性。
- `config.anonymous`未设置  
	如果未设置此属性（为空），则auth插件将始终执行身份验证，如果未经过验证，则返回40x响应。当调用多个auth插件时，这会产生逻辑`AND`。
- `config.anonymous`设置为有效的消费者ID  
	在这种情况下，auth插件只会在尚未经过身份验证的情况下执行身份验证。身份验证失败时，它不会返回`40x`响应，而是将匿名使用者设置为使用者。当调用多个auth插件时，这会导致逻辑`OR` +'匿名访问'。
    
提示1：必须为匿名访问配置所有auth插件或不配置任何auth插件。如果它们是混合的，则行为是不确定的。

提示2：使用`AND`方法时，最后执行的插件将是设置传递给上游服务的凭据的插件。使用`OR`方法，它将成为第一个成功验证消费者的插件，或者是将设置其配置的匿名消费者的最后一个插件。

提示3：以`AND`方式使用OAuth2插件时，用于请求令牌等的OAuth2端点也需要其他已配置的auth插件进行身份验证。

> 如果在给定服务上以OR方式启用多个身份验证插件，并且希望禁止匿名访问，则应在匿名使用者上配置[请求终止插件](https://docs.konghq.com/plugins/request-termination)。如果不这样做，将会允许未经授权的请求。













