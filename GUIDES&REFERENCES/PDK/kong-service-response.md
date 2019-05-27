# kong.service.response

用来操作Service的响应

## kong.service.response.get_status()

从service返回响应的HTTP状态代码，类型为lua number。

- 阶段
	- header_filter, body_filter, log
- 返回
	- `number|nil`来自服务响应的状态代码，如果请求未被代理，则为nil(即`kong.response.get_source()`返回除`“service”`之外的任何内容。)
- 用法
	```
    kong.log.inspect(kong.service.response.get_status()) -- 418
    ```
    
## kong.service.response.get_headers([max_headers])

返回一个Lua table，其中包含来自Service的响应的头。key是header名称。值可以是带有header值的字符串，也可以是多次发送header的字符串数组。此表中的标题名称不区分大小写，短划线（`-`）可以写为下划线（`_`）;也就是说，标题`X-Custom-Header`也可以作为`x_custom_header`检索。

不同于`kong.response.get_headers()`，此函数将仅返回服务响应中存在的header（忽略Kong本身添加的标头）。如果请求未被代理到服务（例如，认证插件拒绝请求并产生HTTP 401响应），则返回的报`headers`可能为`nil`，因为没有收到来自service的响应。

默认情况下，此函数最多返回100个标题。可以指定可选参数`max_headers`来自定义此限制，但必须大于1且不大于1000。

- 阶段
	- header_filter, body_filter, log
- 参数
	- max_headers(number, optional):自定义要解析的header
- 返回
	1. `table`表格形式的响应header
	2. `string` 如果存在比`max_headers`设置更多的header，则为错误`“truncated”`的字符串。
- 用法
	```
    -- Given a response with the following headers:
    -- X-Custom-Header: bla
    -- X-Another: foo bar
    -- X-Another: baz
    local headers = kong.service.response.get_headers()
    if headers then
      kong.log.inspect(headers.x_custom_header) -- "bla"
      kong.log.inspect(headers.x_another[1])    -- "foo bar"
      kong.log.inspect(headers["X-Another"][2]) -- "baz"
    end
    ```

## kong.service.response.get_header(name)

返回指定响应header的值。

不同于`kong.response.get_header()`，如果该函数存在于service的响应中（忽略由Kong本身添加的header），则此函数将仅返回header。

- 阶段
	- header_filter, body_filter, log
- 参数
	- name(string):header的名称
- 返回
	- `string|nil` header的值，如果在响应中找不到具有名字的header，则为`nil`。如果响应中多次出现具有相同名称的header，则此函数将返回此header第一次出现的值。
- 用法
	```
    -- Given a response with the following headers:
    -- X-Custom-Header: bla
    -- X-Another: foo bar
    -- X-Another: baz

    kong.log.inspect(kong.service.response.get_header("x-custom-header")) -- "bla"
    kong.log.inspect(kong.service.response.get_header("X-Another"))       -- "foo bar"
    ```


