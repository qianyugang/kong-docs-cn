# kong.service.request

操作对service的请求

## kong.service.request.set_scheme(scheme)

设置将请求代理到service时使用的协议。

- 阶段
	- access
- 参数
	- scheme (string): 要使用的协议。支持的值为`“http”`或`“https”`
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_scheme("https")
    ```

## kong.service.request.set_path(path)

设置服务请求的路径组件。它没有以任何方式规范化，也不应该包含查询字符串。

- 阶段
	- access
- 参数
	- path: 要使用的协议。支路径字符串。例如：“/v2/movies”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_path("/v2/movies")
    ```
    
## kong.service.request.set_raw_query(query)

将请求的查询字符串设置到Service。查询参数是一个字符串（没有前导`?`字符），不会以任何方式处理。

有关从Lua参数表设置查询字符串的更高级函数，请参阅`kong.service.request.set_query()`。

- 阶段
	- rewrite, access
- 参数
	- query(string): 原始的查询字符串。例如：“foo=bar&bla&baz=hello%20world”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_raw_query("zzz&bar=baz&bar=bla&bar&blo=&foo=hello%20world")
    ```

## kong.service.request.set_method(method)

设置service请求的HTTP方法。

- 阶段
	- rewrite, access
- 参数
	- method: 方法字符串，应以全部大写形式给出。支持的值有：`"GET"`, `"HEAD"`, `"PUT"`, `"POST"`, `"DELETE"`, `"OPTIONS"`, `"MKCOL"`, `"COPY"`, `"MOVE"`, `"PROPFIND"`, `"PROPPATCH"`, `"LOCK"`, `"UNLOCK"`, `"PATCH"`, `"TRACE"`。
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_method("DELETE")
    ```
## kong.service.request.set_query(args)
## kong.service.request.set_header(header, value)
## kong.service.request.add_header(header, value)
## kong.service.request.clear_header(header)
## kong.service.request.set_headers(headers)
## kong.service.request.set_raw_body(body)
## kong.service.request.set_body(args[, mimetype])

