# kong.request

Client request 模块是一组函数，用于获取有关客户端发出的传入请求的信息。

## kong.request.get_scheme()

返回请求的URL的协议组件。返回值规范化为小写形式。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 一个字符串，类似 `"http"` 或者 `"https"`
- 用法
	```
    -- Given a request to https://example.com:1234/v1/movies

	kong.request.get_scheme() -- "https"
    ```
    
## kong.request.get_host()

返回请求的URL的host组件，或“Host”标头的值。返回值规范化为小写形式。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` host
- 用法
	```
    -- Given a request to https://example.com:1234/v1/movies

    kong.request.get_host() -- "example.com"
    ```
    
## kong.request.get_port()

返回请求URL的端口组件。该值以Lua number 返回。

- 阶段
	- certificate, rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `number` 端口号
- 用法
	```
    -- Given a request to https://example.com:1234/v1/movies

    kong.request.get_port() -- 1234
    ```
    
## kong.request.get_forwarded_scheme()

返回请求的URL的协议组件，但如果它来自可信源，也会考虑`X-Forwarded-Proto`。返回值规范化为小写。

此函数是否考虑X-Forwarded-Proto取决于几个Kong配置参数： 

- [trusted_ips](https://getkong.org/docs/latest/configuration/#trusted_ips)
- [real_ip_header](https://getkong.org/docs/latest/configuration/#real_ip_header)
- [real_ip_recursive](https://getkong.org/docs/latest/configuration/#real_ip_recursive)

提醒：由于ngx_http_realip_module不支持Forwarded HTTP Extension（RFC 7239），因此尚未提供支持。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 转发的协议
- 用法
	```
    kong.request.get_forwarded_scheme() -- "https"
    ```
    
## kong.request.get_forwarded_host()

返回请求的URL的主机组件或“host”标头的值。不同于`kong.request.get_host()`，在保证可靠来源的情况下，它也会考虑使用`X-Forwarded-Host`。返回值规范化为小写。

此函数是否考虑X-Forwarded-Proto取决于几个Kong配置参数：

- [trusted_ips](https://getkong.org/docs/latest/configuration/#trusted_ips)
- [real_ip_header](https://getkong.org/docs/latest/configuration/#real_ip_header)
- [real_ip_recursive](https://getkong.org/docs/latest/configuration/#real_ip_recursive)

提醒：由于ngx_http_realip_module不支持Forwarded HTTP Extension（RFC 7239），因此尚未提供支持。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 转发的host
- 用法
	```
    kong.request.get_forwarded_host() -- "example.com"
    ```
    
## kong.request.get_forwareded_port()

返回请求的URL的端口组件。不同于`kong.request.get_host()`，在保证可靠来源的情况下，它也会考虑使用`X-Forwarded-Host`。返回值规范化为lua number。

此函数是否考虑X-Forwarded-Proto取决于几个Kong配置参数：

- [trusted_ips](https://getkong.org/docs/latest/configuration/#trusted_ips)
- [real_ip_header](https://getkong.org/docs/latest/configuration/#real_ip_header)
- [real_ip_recursive](https://getkong.org/docs/latest/configuration/#real_ip_recursive)

提醒：由于ngx_http_realip_module不支持Forwarded HTTP Extension（RFC 7239），因此尚未提供支持。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `number` 转发的端口
- 用法
	```
    kong.request.get_forwarded_port() -- 1234
    ```
    
## kong.request.get_http_version()

返回客户端在请求中使用的HTTP版本作为Lua number，返回值`“1.1”`和`“2.0”`，或者对于无法识别的值返回`nil`。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string|nil` HTTP版号
- 用法
	```
    kong.request.get_http_version() -- "1.1"
    ```
    
## kong.request.get_method()

返回请求的HTTP方法。该值返回规范化为大写。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 请求方法
- 用法
	```
    kong.request.get_method() -- "GET"
    ```

## kong.request.get_path()

返回请求URL的路径组件。它没有以任何方式标准化，也不包括url内参数。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 路径
- 用法
	```
    -- Given a request to https://example.com:1234/v1/movies?movie=foo

    kong.request.get_path() -- "/v1/movies"
    ```

## kong.request.get_path_with_query()

返回路径，包括url内的参数（如果有）。没有进行转换/标准化。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 带参数的路径
- 用法
	```
    -- Given a request to https://example.com:1234/v1/movies?movie=foo

	kong.request.get_path_with_query() -- "/v1/movies?movie=foo"
    ```
    
## kong.request.get_raw_query()

返回请求的URL的查询参数组件。它没有以任何方式进行标准化（甚至不对特殊字符进行URL解码）并且不包括最前面的`?`
字符标示。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string` 请求的URL的查询参数
- 用法
	```
    -- Given a request to https://example.com/foo?msg=hello%20world&bla=&bar

    kong.request.get_raw_query() -- "msg=hello%20world&bla=&bar"
    ```

## kong.request.get_query_arg()

返回从当前请求的查询参数获取的指定参数的值。

返回的值是字符串，如果没有给出值，则返回布尔值`true`;如果找不到带有`name`的参数，则返回`nil`。

如果在查询字符串中多次出现具有相同名称的参数，则此函数将返回第一次出现的值。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 返回
	- `string|boolean|nil` 参数的值
- 用法
	```
    -- Given a request GET /test?foo=hello%20world&bar=baz&zzz&blo=&bar=bla&bar

    kong.request.get_query_arg("foo") -- "hello world"
    kong.request.get_query_arg("bar") -- "baz"
    kong.request.get_query_arg("zzz") -- true
    kong.request.get_query_arg("blo") -- ""
    ```

## kong.request.get_query([max_args])

返回从查询字符串获取的查询参数table。key是查询参数名称。值可以是带参数值的字符串，如果参数未赋值，则为布尔值`true`;如果在查询字符串中多次给出参数，则为数组。键和值根据URL编码的转义规则未转义。

请注意，查询参数字符串`?foo＆bar`转换为两个布尔值`true`参数，而`?foo=&bar=`转换为包含空字符串的两个字符串参数。

默认情况下，此函数最多返回100个参数。可以指定可选的`max_args`参数来自定义此限制，但必须大于1且不大于1000。

- 阶段
	- rewrite, access, header_filter, body_filter, log, admin_api
- 参数
	- max_args(number, optional):设置已解析参数的最大数量限制
- 返回
	- `table` 查询参数的表
- 用法
	```
    -- Given a request GET /test?foo=hello%20world&bar=baz&zzz&blo=&bar=bla&bar

    for k, v in pairs(kong.request.get_query()) do
      kong.log.inspect(k, v)
    end

    -- Will print
    -- "foo" "hello world"
    -- "bar" {"baz", "bla", true}
    -- "zzz" true
    -- "blo" ""
    ```

## kong.request.get_header(name)
## kong.request.get_headers([max_headers])
## kong.request.get_raw_body()
## kong.request.get_body([mimetype[, max_args]])
  