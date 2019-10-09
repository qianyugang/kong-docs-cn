# Serverless Functions 插件

在 access 阶段从Kong动态运行Lua代码。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

该插件与无数据库模式部分兼容。

这些函数将被执行，但是如果配置的函数试图写入数据库，则写入将失败。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=serverless-functions"  \
    --data "config.functions=[]"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: serverless-functions
  service: {service}
  config: 
    functions: []
```
在这两种情况下，，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

通过发出以下请求在 Route 上配置此插件：
```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=serverless-functions"  \
    --data "config.functions=[]"
```

**不使用数据库：**

通过添加此部分在 Route 上配置此插件执行声明性配置文件：

```
plugins:
- name: serverless-functions
  route: {route}
  config: 
    functions: []
```
在这两种情况下，，`{route}`是此插件配置将定位的 route 的`id`或`name`。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`http-log`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `config.functions` | [] | 在访问阶段要缓存并按顺序运行的字符串化Lua代码数组。  |

## 插件名称

Serverless Functions 作为两个单独的插件来。每个插件在插件链中以不同的优先级运行。
- `pre-function`
	- 在访问阶段其他插件运行之前运行。
- `post-function`
	- 在访问阶段在其他插件之后运行。

## 演示

### 使用数据库
	
1. 在Kong上创建一个 Service： 
    
    ```
    $ curl -i -X  POST http://localhost:8001/services/ \
   	--data "name=plugin-testing" \
   	--data "url=http://httpbin.org/headers"
 	
    HTTP/1.1 201 Created
    ```

2. 将 Route 添加到 Service ：
	```
    $ curl -i -X  POST http://localhost:8001/services/plugin-testing/routes \
   	--data "paths[]=/test"

 	HTTP/1.1 201 Created
 	...
    ```

3. 创建一个名为`custom-auth.lua`的文件，其内容如下：
	```
       -- 获取请求头列表
       local custom_auth = kong.request.get_header("x-custom-auth")

       -- 如果我们的自定义身份验证头不存在，终止请求
       if not custom_auth then
         return kong.response.exit(401, "Invalid Credentials")
       end

       -- 从请求中删除自定义身份验证标头
       kong.service.request.clear_header('x-custom-auth')
    ```

4. 确保文件内容：
	```
     $ cat custom-auth.lua
    ```

5. 使用带有cURL文件上传功能的插件来应用我们的Lua代码

	```
     $ curl -i -X POST http://localhost:8001/services/plugin-testing/plugins \
     -F "name=pre-function" \
     -F "config.functions=@custom-auth.lua"

 	HTTP/1.1 201 Created
 	...
    ```
    
6. 测试没有任何头传递时，我们的Lua代码将终止请求：

	```
     curl -i -X GET http://localhost:8000/test

     HTTP/1.1 401 Unauthorized
     ...
     "Invalid Credentials"
    ```

7. 通过发出有效请求来测试我们刚刚应用的Lua代码：
	
    ```
     curl -i -X GET http://localhost:8000/test \
   	--header "x-custom-auth: demo"

 	HTTP/1.1 200 OK
 	...
    ```


### 不使用数据库

1. 在声明性配置文件上创建Service，Route和Associated插件：

	```
     services:
     - name: plugin-testing
       url: http://httpbin.org/headers

     routes:
     - service: plugin-testing
       paths: [ "/test" ]

     plugins:
     - name: pre-function
       config:
         functions: |
           -- Get list of request headers
           local custom_auth = kong.request.get_header("x-custom-auth")

           -- Terminate request early if our custom authentication header
           -- does not exist
           if not custom_auth then
             return kong.response.exit(401, "Invalid Credentials")
           end

           -- Remove custom authentication header from request
           kong.service.request.clear_header('x-custom-auth')
    ```

2. 测试没有任何头传递时，我们的Lua代码将终止请求：

	```
     curl -i -X GET http://localhost:8000/test

     HTTP/1.1 401 Unauthorized
     ...
     "Invalid Credentials"
    ```

3. 通过发出有效请求来测试我们刚刚应用的Lua代码：

	```
     curl -i -X GET http://localhost:8000/test \
   	--header "x-custom-auth: demo"

 	HTTP/1.1 200 OK
 	...
    ```

这只是这些插件所赋予功能的一个小例子。
我们能够将Lua代码动态注入插件 access 阶段，以动态终止或转换请求，而无需创建自定义插件或重新 reloading / redeployin部署Kong。
简而言之，无服务器功能可在访问阶段为您提供自定义插件的全部功能，而无需重新 reloading / redeployin启动Kong。

### 笔记

**Upvalues**

在插件的0.3版本之前，提供的Lua代码将作为函数运行。
从版本0.3开始，还可以返回一个函数，以允许升值。

因此，较旧的版本可以做到这一点（仍然适用于0.3及更高版本）：

```
-- this entire block is executed on each request
ngx.log(ngx.ERR, "hello world")
```

使用此版本版本，您可以返回一个在每个请求上运行的函数，从而允许升值使请求之间保持状态：

```
-- this runs once when Kong starts
local count = 0

return function()
  -- this runs on each request
  count = count + 1
  ngx.log(ngx.ERR, "hello world: ", count)
end
```

**缩小Lua**

由于我们以字符串格式发送代码，因此建议使用curl文件上传`@file.lua`（请参见演示）或使用[Minifier](https://mothereff.in/lua-minifier)缩小Lua代码。
