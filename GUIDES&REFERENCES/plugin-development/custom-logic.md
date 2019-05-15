
## 简介

Kong插件允许您在 request/response 的生命周期中的几个入口点注入自定义逻辑（使用 Lua 语言），因为它由Kong代理。为此，必须实现`base_plugin.lua` 接口的一个或多个方法。这些方法将在命名空间下的模块中实现：`kong.plugins。<plugin_name> .handler`。

## Module

```
kong.plugins.<plugin_name>.handler
```

## 可用的请求上下文

插件接口允许您覆盖handler.lua文件中的以下任何方法，以在Kong的执行生命周期的各个入口点实现自定义逻辑：

| 函数名 | LUA-NGINX-MODULE Context | 描述 |
| ------ | ------ | ------ |
| `:init_worker()` | [init_worker_by_lua](https://github.com/openresty/lua-nginx-module#init_worker_by_lua) | 在每个 Nginx 工作进程启动时执行 |
| `:certificate()` | [ssl_certificate_by_lua](https://github.com/openresty/lua-nginx-module#ssl_certificate_by_lua_block) | 在SSL握手阶段的SSL证书服务阶段执行 |
| `:rewrite()` | [rewrite_by_lua](https://github.com/openresty/lua-nginx-module#rewrite_by_lua_block) | 从客户端接收作为重写阶段处理程序的每个请求执行。在这个阶段，无论是API还是消费者都没有被识别，因此这个处理器只在插件被配置为全局插件时执行 |
| `:access()` | [access_by_lua](https://github.com/openresty/lua-nginx-module#access_by_lua) | 为客户的每一个请求而执行，并在它被代理到上游服务之前执行 |
| `:header_filter()` | [header_filter_by_lua](https://github.com/openresty/lua-nginx-module#header_filter_by_lua) | 从上游服务接收到所有响应头字节时执行 |
| `:body_filter()` | 	[body_filter_by_lua](https://github.com/openresty/lua-nginx-module#body_filter_by_lua) | 从上游服务接收的响应体的每个块时执行。由于响应流回客户端，它可以超过缓冲区大小，因此，如果响应较大，该方法可以被多次调用 |
| `:log()` | 	[log_by_lua](https://github.com/openresty/lua-nginx-module#log_by_lua) | 当最后一个响应字节已经发送到客户端时执行 |

所有这些函数都使用一个参数，该参数由Kong在调用时给出：插件的配置。此参数是Lua表，并包含用户根据插件的架构（在`schema.lua`模块中描述）定义的值。有关插件模式的更多信息将在[下一章](https://docs.konghq.com/1.1.x/plugin-development/plugin-configuration/)中介绍。

## handler.lua规范

handler.lua文件必须返回一个表，该表实现了您希望执行的函数。为简洁起见，这里有一个注释示例模块，它实现了所有可用的方法：
```
-- 扩展基本插件处理程序是可选的，因为Lua中没有真正的接口概念，
-- 但是基本插件处理程序的方法可以从子实现中调用，
-- 并将在“error.log”中打印日志(其中打印所有日志)。
local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()

-- 你的插件处理程序的构造函数。
-- 如果要扩展基本插件处理程序，它的唯一作用就是用名称实例化自己。
-- 该名称是您的插件名称，因为它将打印在日志中
function CustomHandler:new()
  CustomHandler.super.new(self, "my-custom-plugin")
end

function CustomHandler:init_worker()
  -- 最终，执行父实现
  -- (将记录您的插件正在进入此上下文)
  CustomHandler.super.init_worker(self)

  -- 在此实现任何自定义逻辑
end

function CustomHandler:certificate(config)
  -- 最终，执行父实现
  -- (将记录您的插件正在进入此上下文)
  CustomHandler.super.certificate(self)

  -- Implement any custom logic here
end

function CustomHandler:rewrite(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  CustomHandler.super.rewrite(self)

  -- Implement any custom logic here
end

function CustomHandler:access(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  CustomHandler.super.access(self)

  -- Implement any custom logic here
end

function CustomHandler:header_filter(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  CustomHandler.super.header_filter(self)

  -- Implement any custom logic here
end

function CustomHandler:body_filter(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  CustomHandler.super.body_filter(self)

  -- Implement any custom logic here
end

function CustomHandler:log(config)
  -- Eventually, execute the parent implementation
  -- (will log that your plugin is entering this context)
  CustomHandler.super.log(self)

  -- Implement any custom logic here
end

-- 该模块需要返回创建的表
-- 让Kong 可以执行这些功能。
return CustomHandler
```

当然，插件本身的逻辑可以抽象到另一个模块中，并从处理程序模块调用。许多现有的插件在逻辑冗长时已经选择了这种模式，但它是完全可选的:
```
local BasePlugin = require "kong.plugins.base_plugin"

-- 实际的逻辑是在这些模块中实现的
local access = require "kong.plugins.my-custom-plugin.access"
local body_filter = require "kong.plugins.my-custom-plugin.body_filter"

local CustomHandler = BasePlugin:extend()

function CustomHandler:new()
  CustomHandler.super.new(self, "my-custom-plugin")
end

function CustomHandler:access(config)
  CustomHandler.super.access(self)

  -- 从“access”中加载的模块执行任何函数，
  -- 例如，`execute()`并将插件的配置传递给它。
  access.execute(config)
end

function CustomHandler:body_filter(config)
  CustomHandler.super.body_filter(self)

  -- Execute any function from the module loaded in `body_filter`,
  -- for example, `execute()` and passing it the plugin's configuration.
  body_filter.execute(config)
end

return CustomHandler
```

有关实际处理程序代码的示例，请参阅[Key-Auth插件的源代码](https://github.com/Kong/kong/blob/master/kong/plugins/key-auth/handler.lua)。

## 插件开发套件

在这些阶段中实现的逻辑很可能必须与请求/响应对象或核心组件交互(例如访问缓存、数据库……)。Kong提供了一个[插件开发套件](https://docs.konghq.com/1.1.x/pdk)（简称PSK），一组Lua函数和变量，插件可以使用这些Lua函数和变量来执行各种网关操作，确保它们与将来的Kong版本向前兼容。

当您试图实现一些需要与Kong交互的逻辑时(例如检索请求头、从插件生成响应、记录一些错误或调试信息……)，您应该参考[插件开发工具包](https://docs.konghq.com/1.1.x/pdk)。

## 插件执行顺序

一些插件可能依赖于其他插件的执行来执行一些操作。例如，依赖于消费者身份的插件必须在身份验证插件之后运行。考虑到这一点，Kong定义了插件执行之间的优先级，以确保顺序得到遵守。

你的插件的优先级可以通过一个属性来配置，在返回的handler table 中一个数字:
```
CustomHandler.PRIORITY = 10
```
优先级越高，相对于其他插件的阶段(如:access()、:log()等)，插件的阶段执行得越快。
已有捆绑插件的当前执行顺序为:

| 插件 | 优先级 |
| ---- | ------ |
| pre-function | `+inf` |
| zipkin | 100000 | 
| ip-restriction | 3000 |
| bot-detection	 | 2500 |
| cors | 25000 |
| jwt | 1005 |
| oauth2 | 1004 |
| key-auth | 1003 |
| ldap-auth | 1002 |
| basic-auth | 1001 |
| hmac-auth	 | 1000 |
| request-size-limiting | 951 |
| acl | 950 |
| rate-limiting	 | 901 |
| response-ratelimiting	 | 900 |
| request-transformer | 801 |
| response-transformer | 800 |
| aws-lambda | 750 |
| azure-functions | 749 |
| prometheus | 13 |
| http-log | 12 |
| statsd | 11 |
| datadog | 10 |
| file-log | 9 |
| udp-log | 8 |
| tcp-log | 7 |
| loggly | 6 |
| syslog | 4 |
| galileo | 3 |
| request-termination | 2 |
| correlation-id | 1 |
| post-function  | -1000 | 








