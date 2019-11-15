# 插件配置

> 本文原文链接：https://docs.konghq.com/1.1.x/plugin-development/plugin-configuration/

## 简介

大多数情况下，您的插件可以配置为满足您的所有用户需求。当插件被执行的时候，您的插件的配置存储在Kong的数据存储区中，以检索它并将其传递给[handler.lua](https://docs.konghq.com/1.1.x/plugin-development/custom-logic/)方法。

配置由Kong中的Lua表组成，我们称之为 **schema**。它包含用户在通过[Admin API](https://docs.konghq.com/1.1.x/admin-api)启用插件时将设置的键/值属性。Kong为您提供了一种验证用户插件配置的方法。

当用户向Admin API发出请求以启用或更新给定Service，Route和/或Consumer上的插件时，将根据您的架构schema插件的配置。

例如，用户执行以下请求：
```
$ curl -X POST http://kong:8001/services/<service-name-or-id>/plugins/ \
    -d "name=my-custom-plugin" \
    -d "config.foo=bar"
```

如果配置对象的所有`config`都根据您的模式有效，则API将返回`201 Created`，并且插件将与其配置一起存储在数据库中（在这种情况下为`{foo =“bar”}`）。如果配置无效，Admin API将返回`400 Bad Request`和相应的错误消息。

## 模块

```
kong.plugins.<plugin_name>.schema
```

## schema.lua规范

此模块将返回一个Lua表，其中包含将定义用户以后如何配置插件的属性的属性。
可用的属性是：

| 属性名称 | Lua type | 默认值 | 描述 |
| -------- | -------- | ------ | ---- |
| `no_consumer` | Boolen | `false` | 如果为true，则无法将此插件应用于特定的Consumer。此插件必须仅应用于服务和路由。例如：身份验证插件。|
| `fields` | Table | `{}` | 你插件的schema，可用属性及其规则的键/值表。 |
| `self_check` | Function | nil | 如果要在接受插件配置之前执行任何自定义验证，则要实现的功能。 |

self_check函数必须按如下方式实现：
```
-- @param `schema` 描述插件配置的架构（规则）的表。
-- @param `config` 当前插件配置的键/值表。
-- @param `dao` DAO的一个实例 (查看 DAO 章节).
-- @param `is_updating` 一个布尔值，指示是否在更新的上下文中执行此检查。
-- @return `valid` 一个布尔值，指示插件的配置是否有效。
-- @return `error` 一个 DAO 错误 (查看 DAO 章节)
```

以下是一个可能的schema.lua文件的示例：
```
return {
  no_consumer = true, -- 此插件仅适用于服务或路由，
  fields = {
    -- 在此处描述您的插件配置架构。
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    -- 执行任何自定义验证
    return true
  end
}
```

## 描述您的配置schema

`schema.lua`文件的`fields`自选描述了插件配置的schema。它是一个灵活的键/值表，其中每个键都是插件的有效配置属性，每个键都是一个描述该属性规则的表。例如：
```
 fields = {
    some_string = {type = "string", required = true},
    some_boolean = {type = "boolean", default = false},
    some_array = {type = "array", enum = {"GET", "POST", "PUT", "DELETE"}}
  }
```
以下是属性的规则列表：

| 规则 | LUA TYPE(S) | 可使用的值 | 描述 |
| ---- | ----------- | ---------- | ---- |
| `type` | string | “id”, “number”, “boolean”, “string”, <br>“table”, “array”, “url”, “timestamp” | 验证属性的类型。 | 
| `required` | boolean |  | 默认值：false。<br> 如果为true，则该属性必须存在于配置中。  | 
| `unique` | boolean |  | 默认值：false。<br> 如果为true，则该值必须是唯一的（请参阅下面的注释）。  | 
| `default` | any |  | 如果未在配置中指定该属性，则将该属性设置为给定值。  | 
| `immutable` | boolean |  | 默认值：false。<br> 如果为true，则在创建插件配置后将不允许更新该属性。 | 
| `enum` | table |  | 属性的可接受值列表。不接受此列表中未包含的任何值。  | 
| `regex` | string |  | 用于验证属性值的正则表达式。 | 
| `schema` | table |  | 如果属性的类型是table，则定义用于验证这些子属性的模式。 | 
| `func` | function |  | 用于对属性执行任何自定义验证的函数。请参阅后面的示例，了解其参数和返回值。 | 

- **type:**将转换从请求参数中检索的值。如果类型不是本机Lua类型之一，则会对其执行自定义验证：
	- id:必须是string
	- timestamp:必须是nember
	- uri:必须是有效的URL
	- array:必须是整数索引表（相当于Lua中的数组）。在Admin API中，可以通过在请求的正文中使用不同值的属性键的多次来发送这样的数组，或者通过单个body参数以逗号分隔。
- **unique:**此属性对插件配置没有意义，但在插件需要在数据存储区中存储自定义实体时使用。
- **schema:**如果您需要对嵌套属性进行深化验证，则此字段允许您创建嵌套模式。模式验证是递归的。任何级别的嵌套都是有效的，但请记住，这会影响插件的可用性。
- **附加到配置对象但schema中不存在的任何属性也将使所述配置无效。** 

## 例子

[key-auth](https://docs.konghq.com/plugins/key-authentication/)插件的`schema.lua`文件定义了API密钥的可接受参数名称的默认列表，以及默认设置为`false`的布尔值：

```
-- schema.lua
return {
  no_consumer = true,
  fields = {
    key_names = {type = "array", required = true, default = {"apikey"}},
    hide_credentials = {type = "boolean", default = false}
  }
}
```

于是，当在[handler.lua](https://docs.konghq.com/1.1.x/plugin-development/custom-logic/)中实现插件的`access()`函数并且用户使用默认值启用插件时，您可以如下：
```
-- handler.lua
local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()

function CustomHandler:new()
  CustomHandler.super.new(self, "my-custom-plugin")
end

function CustomHandler:access(config)
  CustomHandler.super.access(self)

  kong.log.inspect(config.key_names)        -- {"apikey"}
  kong.log.inspect(config.hide_credentials) -- false
end

return CustomHandler
```

请注意，上面的示例使用[插件开发工具包(PDK)](https://docs.konghq.com/1.1.x/pdk)的[kong.log.inspect](http://localhost:3000/docs/0.14.x/pdk/kong.log/#kong_log_inspect)函数将这些值打印到Kong日志中。

一个更复杂的示例，可用于最终日志记录插件：
```
-- schema.lua

local function server_port(given_value, given_config)
  -- 自定义验证
  if given_value > 65534 then
    return false, "port value too high"
  end

  -- 如果环境是“开发”，8080将是默认端口
  if given_config.environment == "development" then
    return true, nil, {port = 8080}
  end
end

return {
  fields = {
    environment = {type = "string", required = true, enum = {"production", "development"}}
    server = {
      type = "table",
      schema = {
        fields = {
          host = {type = "url", default = "http://example.com"},
          port = {type = "number", func = server_port, default = 80}
        }
      }
    }
  }
}
```

这样的配置将允许用户将配置发布到您的插件，如下所示：
```
curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
    -d "name=my-custom-plugin" \
    -d "config.environment=development" \
    -d "config.server.host=http://localhost"
```

以下内容将在[handler.lua](https://docs.konghq.com/1.1.x/plugin-development/custom-logic/)中提供：
```
-- handler.lua
local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()

function CustomHandler:new()
  CustomHandler.super.new(self, "my-custom-plugin")
end

function CustomHandler:access(config)
  CustomHandler.super.access(self)

  kong.log.inspect(config.environment) -- "development"
  kong.log.inspect(config.server.host) -- "http://localhost"
  kong.log.inspect(config.server.port) -- 8080
end

return CustomHandler
```

您还可以在[Key-Auth插件源代码](https://github.com/Kong/kong/blob/master/kong/plugins/key-auth/schema.lua)中查看schema的真实示例。



















