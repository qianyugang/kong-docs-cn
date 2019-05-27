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

## kong.service.request.set_path(path)# kong.service.request

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

将请求的查询字符串设置到service。

不同于`kong.service.request.set_raw_query()`，`query`参数必须是一个表，其中每个键都是一个字符串（对应于一个参数名称），每个值都是一个布尔值，一个字符串或一个字符串或布尔数组。此外，所有字符串值都将进行URL编码。

生成的查询字符串将包含按字典顺序排列的键。保留同一键内的条目顺序（当值作为数组给出时）。

如果需要进一步控制查询字符串生成，可以使用`kong.service.request.set_raw_query()`将原始查询字符串作为字符串给出。

- 阶段
	- rewrite, access
- 参数
	- args(table): 一个table，其中每个键都是一个字符串（对应于一个参数名称），每个值都是布尔值，字符串或字符串或布尔数组。给定的任何字符串值都是URL编码的。
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_query({
      foo = "hello world",
      bar = {"baz", "bla", true},
      zzz = true,
      blo = ""
    })
    -- 将生成以下查询字符串：
    -- bar=baz&bar=bla&bar&blo=&foo=hello%20world&zzz
    ```
    
## kong.service.request.set_header(header, value)

使用给定值在服务请求中设置header。将覆盖任何具有相同名称的现有header。

如果`header`参数是`“host”`（不区分大小写），那么这也将设置请求的SNI到服务。

- 阶段
	- rewrite, access
- 参数
	- header(string):header名，例如“X-Foo”
	- value(string boolean number):header值，例如“hello world”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_header("X-Foo", "value")
    ```
## kong.service.request.add_header(header, value)

将具有给定值的请求header添加到对service的请求中。不同于`kong.service.request.set_header()`，此函数不会删除任何具有相同名称的现有header。相反，请求中将出现多次出现的标头。保留添加标头的顺序。

- 阶段
	- rewrite, access
- 参数
	- header(string):header名，例如“Cache-Control”
	- value(string boolean number):header值，例如“no-cache”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.add_header("Cache-Control", "no-cache")
	kong.service.request.add_header("Cache-Control", "no-store")
    ```

## kong.service.request.clear_header(header)
## kong.service.request.set_headers(headers)
## kong.service.request.set_raw_body(body)
## kong.service.request.set_body(args[, mimetype])



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

将请求的查询字符串设置到service。

不同于`kong.service.request.set_raw_query()`，`query`参数必须是一个表，其中每个键都是一个字符串（对应于一个参数名称），每个值都是一个布尔值，一个字符串或一个字符串或布尔数组。此外，所有字符串值都将进行URL编码。

生成的查询字符串将包含按字典顺序排列的键。保留同一键内的条目顺序（当值作为数组给出时）。

如果需要进一步控制查询字符串生成，可以使用`kong.service.request.set_raw_query()`将原始查询字符串作为字符串给出。

- 阶段
	- rewrite, access
- 参数
	- args(table): 一个table，其中每个键都是一个字符串（对应于一个参数名称），每个值都是布尔值，字符串或字符串或布尔数组。给定的任何字符串值都是URL编码的。
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_query({
      foo = "hello world",
      bar = {"baz", "bla", true},
      zzz = true,
      blo = ""
    })
    -- 将生成以下查询字符串：
    -- bar=baz&bar=bla&bar&blo=&foo=hello%20world&zzz
    ```
    
## kong.service.request.set_header(header, value)

使用给定值在服务请求中设置header。将覆盖任何具有相同名称的现有header。

如果`header`参数是`“host”`（不区分大小写），那么这也将设置请求的SNI到服务。

- 阶段
	- rewrite, access
- 参数
	- header(string):header名，例如“X-Foo”
	- value(string boolean number):header值，例如“hello world”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.set_header("X-Foo", "value")
    ```
## kong.service.request.add_header(header, value)

将具有给定值的请求header添加到对service的请求中。不同于`kong.service.request.set_header()`，此函数不会删除任何具有相同名称的现有header。相反，请求中将出现多次出现的标头。保留添加标头的顺序。

- 阶段
	- rewrite, access
- 参数
	- header(string):header名，例如“Cache-Control”
	- value(string boolean number):header值，例如“no-cache”
- 返回
	- 无，在无效输入上会报错。
- 用法
	```
    kong.service.request.add_header("Cache-Control", "no-cache")
	kong.service.request.add_header("Cache-Control", "no-store")
    ```

## kong.service.request.clear_header(header)
## kong.service.request.set_headers(headers)
## kong.service.request.set_raw_body(body)
## kong.service.request.set_body(args[, mimetype])

