# kong.log

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.log/

此命名空间包含“日志记录工具”的实例，该表是包含下述所有方法的表。

这个实例是每个插件命名空间，Kong将确保在执行插件之前，它会将此实例与专用于插件的日志工具交换。这允许日志以插件的名称作为前缀，以便进行调试。

## kong.log(…)

将日志行写入当前Nginx配置块的`error_log`指令指定的位置，并带有`notice`级别（类似于`print（）`）。

Nginx `error_log`指令通过`log_level`，`proxy_error_log`和`admin_error_log` Kong配置属性设置。

此函数的参数将与`ngx.log()`类似地连接，并且日志将报告调用它的Lua文件和行号。不同于`ngx.log()`，此函数将使用`[kong]`而不是`[lua]`为错误消息添加前缀。

此函数的参数可以是任何类型，但table参数将转换为字符串（因此，如果设置了table类型的参数，可能会调用表的`__tostring`元方法）。此行为不同于`ngx.log()`（如果它们定义`__tostring`元方法，它只接受表参数），旨在简化其使用并更加宽容和直观。

从核心内部调用日志记录时，生成的日志行具有以下格式：
```
[kong] %file_src:%line_src %message
```
相比之下，插件生成的日志行具有以下格式：
```
 [kong] %file_src:%line_src [%namespace] %message
```

其中：

- `%namespace`：是配置的命名空间（在这种情况下是插件名称）。
- `%file_src`：是从中调用日志的文件名。
- `%line_src`：是从中调用日志的行号。
- `%message`：是由调用者给出的连接参数组成的消息。

例如，以下调用：
```
kong.log("hello ", "world")
```

将在核心内产生类似于以下内容的日志：
```
2017/07/09 19:36:25 [notice] 25932#0: *1 [kong] some_file.lua:54 hello world, client: 127.0.0.1, server: localhost, request: "GET /log HTTP/1.1", host: "localhost"
```
如果从插件（例如`key-auth`）中调用，它将包含命名空间前缀，如下所示：
```
2017/07/09 19:36:25 [notice] 25932#0: *1 [kong] some_file.lua:54 [key-auth] hello world, client: 127.0.0.1, server: localhost, request: "GET /log HTTP/1.1", host: "localhost"
```

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 参数
	- ...:在发送到日志之前，所有参数都将被连接并字符串化
- 返回
	- 没有;在无效输入上抛出错误。
- 用法
	```
    kong.log("hello ", "world") -- alias to kong.log.notice()
    ```

## kong.log.LEVEL(…)

与`kong.log()`类似，但生成的日志将具有<level>给出的严重性，而不是通知。支持的级别是：

- kong.log.alert()
- kong.log.crit()
- kong.log.err()
- kong.log.warn()
- kong.log.notice()
- kong.log.info()
- kong.log.debug()

日志的格式与`kong.log()`的格式相同。
例如，以下调用：

```
kong.log.err("hello ", "world")
```

将在核心内产生类似于以下内容的日志：
```
 2017/07/09 19:36:25 [error] 25932#0: *1 [kong] some_file.lua:54 hello world, client: 127.0.0.1, server: localhost, request: "GET /log HTTP/1.1", host: "localhost"
```

如果从插件（例如`key-auth`）中调用，它将包含命名空间前缀，如下所示：
```
 2017/07/09 19:36:25 [error] 25932#0: *1 [kong] some_file.lua:54 [key-auth] hello world, client: 127.0.0.1, server: localhost, request: "GET /log HTTP/1.1", host: "localhost"
```

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 参数
	- ...:在发送到日志之前，所有参数都将被连接并字符串化
- 返回
	- 没有;在无效输入上抛出错误。
- 用法
	```
    kong.log.warn("something require attention")
    kong.log.err("something failed: ", err)
    kong.log.alert("something requires immediate action")
    ```
    
## kong.log.inspect(…)

就像`kong.log()`,此函数将生成具有通知级别的日志，并且还接受任意数量的参数。如果通过`kong.log.inspect.off()`禁用了检查日志记录，那么此函数不会打印任何内容，并且为了节省CPU周期而别名为“NOP”函数。
```
kong.log.inspect("...")
```

这个函数与`kong.log()`的不同之处在于参数将与空格（“”）连接，每个参数将是“美化打印”：

- number将打印为（例如`5` -> `"5"`）
- string将打印为（例如`"hi"` -> `'"hi"'`）
- 类似数组的表将呈现为（例如`{1,2,3}` -> `"{1, 2, 3}"`）
- 类字典表将在多行上呈现

此功能旨在用于调试目的，并且应避免在生产代码路径中使用，因为它可以执行昂贵的格式化操作。现有语句可以保留在生产代码中，但可以通过调用`kong.log.inspect.off()`来删除。

在编写日志时，`kong.log.inspect()`总是使用自己的格式，定义如下：
```
 %file_src:%func_name:%line_src %message
```

其中：
- `%file_src`：是从中调用日志的文件名。
- `%func_name`：是从中调用日志的函数的名称。
- `%line_src`：是从中调用日志的行号。
- `%message`：是由调用者给出的连接的，优化打印的参数组成的消息。

此函数使用[inspect.lua](https://github.com/kikito/inspect.lua)库来打印其参数。

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 参数
	- ...:参数将与它们之间的空格连接，并按照描述进行渲染
- 用法
	```
    kong.log.inspect("some value", a_variable)
    ```

## kong.log.inspect.on()

启用此日志记录工具的检查日志。对`kong.log.inspect`的调用将使用适当的参数格式编写日志行。

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 用法
	```
    kong.log.inspect.on()
    ```
    
## kong.log.inspect.off()

禁用此日志记录工具的检查日志。所有对`kong.log.inspect()`的调用都将被删除。

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 用法
	```
    kong.log.inspect.off()
    ```











