# kong.response

客户端响应模块

下游响应模块包含一组用于产生和操纵发送回客户端（“下游”）的响应的功能。响应可以由Kong（例如，拒绝请求的认证插件）产生，或者从服务的响应主体代理回来。

与`kong.service.response`不同，此模块允许在将响应发送回客户端之前改变响应。

## kong.response.get_status()

返回当前为下游响应设置的HTTP状态代码（类型Lua number）。

如果请求被代理（根据`kong.response.get_source()`），则返回值将是来自Service的响应的值（与`kong.service.response.get_status()`相同）。

如果请求未被代理，并且响应是由Kong本身产生的（即通过`kong.response.exit()`），则返回值将按原样返回。

- 阶段
	- header_filter, body_filter, log, admin_api
- 返回
	- `number` status 当前为下游响应设置的HTTP状态代码
- 用法
	```
    kong.response.get_status() -- 200
    ```

## kong.response.get_header(name)

返回指定响应头的值，一旦收到客户端就会收到。

此函数返回的 header 列表可以包括来自代理服务的响应标头和Kong添加的 header（例如，通过`kong.response.add_header()`）。

返回值是`string`，如果在响应中找不到具有名称的header，则返回值可以为`nil`。
如果请求中多次出现具有相同名称的header，则此函数将返回此标头第一次出现的值。

- 阶段
	- header_filter, body_filter, log, admin_api
- 参数
	- name (string):header名称

标题名称不区分大小写，破折号（`-`）可以写为下划线（`_`）;也就是说，header`X-Custom-Header`也可以作为`x_custom_header`使用查询。

- 返回
	- `string|nil` header 的值
- 用法

	```
    -- Given a response with the following headers:
    -- X-Custom-Header: bla
    -- X-Another: foo bar
    -- X-Another: baz

    kong.response.get_header("x-custom-header") -- "bla"
    kong.response.get_header("X-Another")       -- "foo bar"
    kong.response.get_header("X-None")          -- nil
    ```
    
## kong.response.get_headers([max_headers])

返回一个包含响应头的Lua table，key是header头的名字。值要么是带有header头值的字符串，要么是字符串数组（如果header多次发送）。header名不区分大小写，统一为小写，破折号(`-`)可以写成下划线(`_`);也就是说，头文件`X-Custom-Header`也可以检索为`x_custom_header`。

响应最初是没有header头的，直到插件生成一个header头（例如，一个身份验证插件拒绝了一个请求）而使代理中断，或者请求已经被代理，并且后一个执行阶段之一当前正在运行。

与`kong.service.response.get_headers()`函数不同，该函数返回客户端接收到的所有头信息，包括Kong本身添加的头信息。

默认情况下，该函数最多返回100个头部。可以指定可选的max_headers参数来自定义此限制，但必须大于1且不大于1000。

- 阶段
	- header_filter, body_filter, log, admin_api
- 参数
	`max_headers`(number, optional) 限制解析多少header信息
- 返回
  1. `table` 响应的头
  2. `string` 如果出现的header比`max_headers`多，则错误为`“truncated”`的字符串。
- 用法

	```
    -- Given an response from the Service with the following headers:
    -- X-Custom-Header: bla
    -- X-Another: foo bar
    -- X-Another: baz
    
    local headers = kong.response.get_headers()
    
    headers.x_custom_header -- "bla"
    headers.x_another[1]    -- "foo bar"
    headers["X-Another"][2] -- "baz"
    
    ```

## kong.response.get_source()

- 阶段
	- header_filter, body_filter, log, admin_api
- 返回
  - `string` 源服务
- 用法

  ```
if kong.response.get_source() == "service" then
  kong.log("The response comes from the Service")
elseif kong.response.get_source() == "error" then
  kong.log("There was an error while processing the request")
elseif kong.response.get_source() == "exit" then
  kong.log("There was an early exit while processing the request")
end
  ```

## kong.response.set_status(status)

- 阶段
	- header_filter, body_filter, log, admin_api
- 参数
  - status(status):新状态
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
  kong.response.set_status(404)
  ```

## kong.response.set_header(name, value)

- 阶段
	- rewrite, access, header_filter, admin_api
- 参数
  - name(string):header的名称
  - value(string	number boolean):新header的值
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
  kong.response.set_header("X-Foo", "value")
  ```

## kong.response.add_header(name, value)

- 阶段
	- rewrite, access, header_filter, admin_api
- 参数
  - name(string):header的名称
  - value(string	number boolean):新header的值
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
  kong.response.add_header("Cache-Control", "no-cache")
  kong.response.add_header("Cache-Control", "no-store")
  ```
  
## kong.response.clear_header(name)

- 阶段
	- rewrite, access, header_filter, admin_api
- 参数
  - name(string):被清理的header的名称
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
  kong.response.set_header("X-Foo", "foo")
  kong.response.add_header("X-Foo", "bar")

  kong.response.clear_header("X-Foo")
  -- 从这里开始，响应中将不存在X-Foo头
  ```
## kong.response.set_headers(headers)

- 阶段
	- rewrite, access, header_filter, admin_api
- 参数
  - headers(table)
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
    kong.response.set_headers({
      ["Bla"] = "boo",
      ["X-Foo"] = "foo3",
      ["Cache-Control"] = { "no-store", "no-cache" }
    })
    
    -- 将按以下顺序向响应添加以下头信息:
    -- X-Bar: bar1
    -- Bla: boo
    -- Cache-Control: no-store
    -- Cache-Control: no-cache
    -- X-Foo: foo3
  ```

## kong.response.exit(status[, body[, headers]])

- 阶段
	- rewrite, access, admin_api, header_filter (只有在body为空的时候)
- 参数
  - status(table):被使用的状态
  - body(table	string, optional):被使用的返回体
  - headers(table, optional):被使用的返回头
- 返回
  - 无返回值，如果是无效输入会报错
- 用法
  
  ```
    return kong.response.exit(403, "Access Forbidden", {
      ["Content-Type"] = "text/plain",
      ["WWW-Authenticate"] = "Basic"
    })
    
    ---
    
    return kong.response.exit(403, [[{"message":"Access Forbidden"}]], {
      ["Content-Type"] = "application/json",
      ["WWW-Authenticate"] = "Basic"
    })
    
    ---
    
    return kong.response.exit(403, { message = "Access Forbidden" }, {
      ["WWW-Authenticate"] = "Basic"
    })
  ```




















