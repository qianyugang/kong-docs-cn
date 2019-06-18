# CORS

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/cors/

通过启用此插件，轻松将跨源资源共享（CORS）添加到 Service, Route 。

## 配置

### 在 Service 上启用插件

通过发出以下请求在 [Service](https://docs.konghq.com/latest/admin-api/#service-object) 上配置此插件：

```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=cors"  \
    --data "config.origins=http://mockbin.com" \
    --data "config.methods=GET, POST" \
    --data "config.headers=Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Auth-Token" \
    --data "config.exposed_headers=X-Auth-Token" \
    --data "config.credentials=true" \
    --data "config.max_age=3600"
```

- `service`：此插件配置将绑定的服务的ID或名称。

### 在 Route 上启用插件

通过发出以下请求在 [Route](https://docs.konghq.com/latest/admin-api/#Route-object) 上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route_id}/plugins \
    --data "name=cors"  \
    --data "config.origins=http://mockbin.com" \
    --data "config.methods=GET, POST" \
    --data "config.headers=Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Auth-Token" \
    --data "config.exposed_headers=X-Auth-Token" \
    --data "config.credentials=true" \
    --data "config.max_age=3600"
```

### 全局插件

可以使用`http://kong:8001/plugins/ ` 配置所有插件。与任何Service, Route 或者 Consumer（或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

### 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数名称 | 默认值 | 描述 | 
| -------- | ------ | ---- |
| name |  | 要使用的插件的名称，在本例中为cors | 
| service_id | | 此插件将绑定的 Service 的ID。 |
| route_id |  | 此插件将绑定的 Route 的ID。 |
| enabled | `true` |  是否将应用此插件。 |
| config.origins <br> *optional* |  | `Access-Control-Allow-Origin`标头的允许域，用逗号分割，如果想允许所有，就使用`*`。接受的值可以是flat strings 或PCRE正则表达式。 <br> 注意：在Kong 0.10.x之前，此参数是`config.origin`（请注意`s`的更改），并且只接受单个值或`*`特殊值。|
| config.methods <br> *optional* | `GET`, `HEAD`, `PUT`, `PATCH`, `POST` | `Access-Control-Allow-Methods` header的值，使用逗号分隔的字符串（例如`GET`，`POST`）。 |
| config.headers <br> *optional* | `Access-Control-Request-Headers`请求header的值 | `Access-Control-Allow-Headers` header的值，使用逗号分割（例如`Origin`，`Authorization`）。 |
| config.exposed_headers <br> *optional* | | `Access-Control-Expose-Headers` header 的值，使用逗号分割（例如`Origin`，`Authorization`），如果未指定，则不会开放自定义header。 |
| config.credentials <br> *optional* | `false` | 用于确定是否应使用`true`作为值发送`Access-Control-Allow-Credentials` header。
| config.max_age <br> *optional* | | 指示可以缓存预检请求的结果的时间长度（以秒为单位）。 |
| config.preflight_continue <br> *optional* | `false` | 一个布尔值，指示插件将`OPTIONS`预检请求代理到上游服务。 |

## 相关问题

以下是此插件的已知问题或限制的列表。

### CORS限制

如果客户端是浏览器，则由于CORS规范的限制导致此插件存在已知问题，该限制不允许在预检`OPTIONS`请求中指定自定义header。  
由于此限制，此插件仅适用于已使用路径设置配置的路由，并且对于使用自定义DNS（`hosts`属性）解析的路由不起作用。  
要了解如何为Route配置路径，请阅读[代理参考](https://docs.konghq.com/0.12.x/proxy/#request-uri)











