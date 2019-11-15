# 扩展Admin API

> 本文原文：https://docs.konghq.com/1.1.x/plugin-development/admin-api/

> 注意：本章假设您具有[Lapis](http://leafo.net/lapis/)的相关知识。

## 简介

可以使用被称为[Admin API](https://docs.konghq.com/1.1.x/admin-api/)的REST接口配置Kong。插件可以通过添加自己的路径来扩展它，以适应自定义实体或其他个性化管理需求。典型的例子是API密钥的创建，查找和删除（通常称为“CRUD操作”）。

Admin API是[Lapis](http://leafo.net/lapis/)应用程序，Kong的抽象级别使您可以轻松添加路径。

## Module
```
kong.plugins.<plugin_name>.api
```

## 将路径添加到Admin API

如果在名为的模块中定义路径，Kong将检测并加载路径：
```
"kong.plugins.<plugin_name>.api"
```
该模块必须返回一个包含一个或多个属性的表，其结构如下：
```
{
  ["<path>"] = {
     schema = <schema>,
     methods = {
       before = function(self) ... end,
       on_error = function(self) ... end,
       GET = function(self) ... end,
       PUT = function(self) ... end,
       ...
     }
  },
  ...
}
```

其中：

- `<path>` 应该是一个表示像`/users`这样的路由的字符串（请参阅[Lapis路由和URL模式](http://leafo.net/lapis/reference/actions.html#routes--url-patterns)）以获取详细信息。请注意，路径可以包含插值参数，类似`/users/:users/new`。
- `<schema>` 是架构定义。核心和自定义插件实体的schema可通过`kong.db.<entity>.schema`。schema用于根据类型解析某些字段;例如，如果一个字段被标记为一个整数，它将被传递给一个函数时被解析（默认表单字段都是字符串）。
- `methods`子表包含由字符串索引的函数。
	- `before`键是可选的，可以保存一个函数。如果存在，则在调用任何其他函数之前，将对每个命中路径的请求执行该函数。
	- 可以使用HTTP方法名称（如`GET`或`PUT`）索引一个或多个函数。匹配适当的HTTP方法和路径时，将执行这些函数。如果路径上存在before函数，则首先执行该函数。请记住，`before`函数可以使用kong.response.exit来提前完成。有效地取消了“常规”http方法功能。
	- `on_error`键是可选的，可以保存一个函数。如果存在，当来自其他函数的代码（来自之前或“http方法”）抛出错误时，将执行该函数。如果不存在，那么Kong将使用默认错误处理程序来返回错误。

例如：
```
local endpoints = require "kong.api.endpoints"

local credentials_schema = kong.db.keyauth_credentials.schema
local consumers_schema = kong.db.consumers.schema

return {
  ["/consumers/:consumers/key-auth"] = {
    schema = credentials_schema,
    methods = {
      GET = endpoints.get_collection_endpoint(
              credentials_schema, consumers_schema, "consumer"),

      POST = endpoints.post_collection_endpoint(
              credentials_schema, consumers_schema, "consumer"),
    },
  },
}
```
此代码将在`/consumers/:consumers/key-auth`中创建两个Admin API路径。获取（`GET`）和创建（`POST`）与给定使用者相关联的凭证。在此示例中，函数由`kong.api.endpoints`库提供。如果您想查看更完整的示例，并在函数中使用自定义代码，请参阅[key-auth插件中的api.lua文件](https://github.com/Kong/kong/blob/master/kong/plugins/key-auth/api.lua)。

`endpoints`模块当前包含Kong中最常用的CRUD操作的基本实现。此模块为您提供任何插入，查询，更新或删除操作的帮助程序，并执行必要的DAO操作并使用相应的HTTP状态代码进行回复。它还为您提供从路径中查询参数的功能，例如 Service的名称或ID，或Consumer的用户名或ID。

如果提供的`endpoints`功能不够，则可以使用常规的Lua函数。
从那里你可以使用：

- `endpoints`模块提供的几个功能。
- [PDK](https://docs.konghq.com/1.1.x/pdk)提供的所有功能
- `self`参数，即Lapis请求对象。
- 当然，如果需要，您可以`require`任何Lua模块。如果选择此方法，请确保它们与OpenResty兼容。	 

```
local endpoints = require "kong.api.endpoints"

local credentials_schema = kong.db.keyauth_credentials.schema
local consumers_schema = kong.db.consumers.schema

return {
  ["/consumers/:consumers/key-auth/:keyauth_credentials"] = {
    schema = credentials_schema,
    methods = {
      before = function(self, db, helpers)
        local consumer, _, err_t = endpoints.select_entity(self, db, consumers_schema)
        if err_t then
          return endpoints.handle_error(err_t)
        end
        if not consumer then
          return kong.response.exit(404, { message = "Not found" })
        end

        self.consumer = consumer

        if self.req.method ~= "PUT" then
          local cred, _, err_t = endpoints.select_entity(self, db, credentials_schema)
          if err_t then
            return endpoints.handle_error(err_t)
          end

          if not cred or cred.consumer.id ~= consumer.id then
            return kong.response.exit(404, { message = "Not found" })
          end
          self.keyauth_credential = cred
          self.params.keyauth_credentials = cred.id
        end
      end,
      GET  = endpoints.get_entity_endpoint(credentials_schema),
      PUT  = function(self, db, helpers)
        self.args.post.consumer = { id = self.consumer.id }
        return endpoints.put_entity_endpoint(credentials_schema)(self, db, helpers)
      end,
    },
  },
}
```

在前面的例子中，`/consumers/:consumers/key-auth/:keyauth_credentials`路径有三个功能：

- before函数是一个自定义Lua函数，它使用多个`endpoints`提供的实用程序（endpoints.handle_error）以及PDK函数（kong.response.exit）。它还会填充`self.consumer`以供后续使用的函数使用。
- GET功能完全使用`endpoints`构建。这是可能的，因为之前已经预先“准备好”了东西，比如self.consumer。
- PUT函数在调用`endpoints`提供的`put_entity_endpoint`函数之前填充`self.args.post.consumer`。

下一步：[为你的插件编写单元测试](https://docs.konghq.com/1.1.x/plugin-development/tests/)



































