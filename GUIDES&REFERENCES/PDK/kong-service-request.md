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

删除对服务的请求中出现的所有指定header。

- 阶段
	- rewrite, access
- 参数
	- header(string):header名，例如“Cache-Control”
- 返回
	- 无，在无效输入上会报错。如果没有删除标头，该函数不会抛出错误。
- 用法
	```
    kong.service.request.set_header("X-Foo", "foo")
    kong.service.request.add_header("X-Foo", "bar")
    kong.service.request.clear_header("X-Foo")
    -- 从这里开始，请求中不会存在X-Foo header
    ```

## kong.service.request.set_headers(headers)
将请求的标头设置到service。与`kong.service.request.set_header()`不同，`headers`参数必须是一个table，其中每个键都是一个字符串（对应于标题的名称），每个值都是一个字符串或一个字符串数组。

生成的header按字典顺序生成。保留具有相同名称的条目的顺序（当值作为数组给出时）。

此函数将覆盖与headers参数中指定的名称相同的任何现有header。其他header保持不变。

如果设置了`“host”`标头（不区分大小写），那么这也将设置请求的SNI到服务。

- 阶段
	- rewrite, access
- 参数
	- header(string):一个table，其中每个键都是包含标题名称的字符串，每个值都是字符串或字符串数组。
- 返回
	- 无，在无效输入上会报错。如果没有删除标头，该函数不会抛出错误。
- 用法
	```
    kong.service.request.set_header("X-Foo", "foo1")
    kong.service.request.add_header("X-Foo", "foo2")
    kong.service.request.set_header("X-Bar", "bar1")
    kong.service.request.set_headers({
      ["X-Foo"] = "foo3",
      ["Cache-Control"] = { "no-store", "no-cache" },
      ["Bla"] = "boo"
    })

    -- 将按以下顺序将以下标头添加到请求中：
    -- X-Bar: bar1
    -- Bla: boo
    -- Cache-Control: no-store
    -- Cache-Control: no-cache
    -- X-Foo: foo3
    ```

## kong.service.request.set_raw_body(body)

将请求的主体设置到service。

`body`参数必须是一个字符串，不会以任何方式处理。此函数还会适当地设置`Content-Length`请求头。要设置一个空请求，可以为此函数提供一个空字符串`“”`。

有关基于请求内容类型设置正文的更高级别函数，请参阅`kong.service.request.set_body()`。

- 阶段
	- rewrite, access
- 参数
	- body(string):原始请求体
- 返回
	- 无，在无效输入上会报错。如果没有删除标头，该函数不会抛出错误。
- 用法
	```
    kong.service.request.set_raw_body("Hello, world!")
    ```

## kong.service.request.set_body(args[, mimetype])

将请求体设置到service。不同于`kong.service.request.set_raw_body()`，`args`参数必须是一个table，并将使用MIME类型进行编码。
编码MIME类型可以在可选的`mimetype`参数中指定，或者如果未指定，则将根据客户端请求的`Content-Type`header进行选择。

如果MIME类型是`application/x-www-form-urlencoded`：
- 将参数编码为表单编码：键以字典顺序生成。保留同一键内的条目顺序（当值作为数组给出时）。给定的任何字符串值都是URL编码的。

如果MIME类型是`multipart/form-data`：
- 将参数编码为多部分表单数据。

如果MIME类型是`application/json`：
- 将参数编码为JSON（与`kong.service.request.set_raw_body(json.encode(args))`相同）
- Lua类型转换为匹配的JSON types.mej

如果以上都不是，则返回nil并且指示正文无法编码的错误消息。

可选参数mimetype可以是以下之一：

- `application/x-www-form-urlencoded`
- `application/json`
- `multipart/form-data`

如果指定了`mimetype`参数，则将在对服务的请求中相应地设置`Content-Type`标头。

如果需要进一步控制请求体生成，可以使用`kong.service.request.set_raw_body()`将原始请求体作为字符串给出。

- 阶段
	- rewrite, access
- 参数
	- args(table):一个table，其中包含要转换为适当格式并存储在正文中的数据。
	- mimetype(string, optional):可以是以下之一：
		- `application/x-www-form-urlencoded`
		- `application/json`
		- `multipart/form-data`
- 返回
	1. `boolean|nil` 成功返回`true`，否则返回`nil`
	2. `string|nil` 成功返回`nil`，出现错误时直接报错。在无效输入上会引发错误。
- 用法
	```
    kong.service.set_header("application/json")
    local ok, err = kong.service.request.set_body({
      name = "John Doe",
      age = 42,
      numbers = {1, 2, 3}
    })

    -- 生成以下JSON请求体：
    -- { "name": "John Doe", "age": 42, "numbers":[1, 2, 3] }

    local ok, err = kong.service.request.set_body({
      foo = "hello world",
      bar = {"baz", "bla", true},
      zzz = true,
      blo = ""
    }, "application/x-www-form-urlencoded")

    -- 产生以下请求体：
    -- bar=baz&bar=bla&bar&blo=&foo=hello%20world&zzz
    ```
