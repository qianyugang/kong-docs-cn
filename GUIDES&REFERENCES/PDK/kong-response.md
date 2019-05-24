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




















