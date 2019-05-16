# 微服务 API 网关 Kong 插件开发 - 文件结构

原文地址：https://docs.konghq.com/1.1.x/plugin-development/file-structure/ （不能保证所有的翻译都是准确无误的，所有如有翻译的不准确或错误之处，请一定记得查看原文，并欢迎留言指出）。

> 本章假定你已经会使用Lua语言

## 介绍

将您的插件视为一组[Lua模块](http://www.lua.org/manual/5.1/manual.html#6.3)。本章中描述的每个文件都被视为一个单独的模块。如果他们的名字遵循这个约定，Kong将检测并加载你的插件的模块：

```
kong.plugins.<plugin_name>.<module_name>
```

*您的模块当然需要通过[package.path](http://www.lua.org/manual/5.1/manual.html#pdf-package.path)变量访问，可以通过[lua_package_path](https://docs.konghq.com/1.1.x/configuration/#development-miscellaneous-section)配置属性调整您的需求。但是，安装插件的首选方法是通过[LuaRocks](https://luarocks.org/)，它与Kong本身集成。有关LuaRocks安装的插件的更多信息，请参阅本指南后面的内容。*

为了让Kong意识到必须查找插件的模块，你必须将它添加到配置文件中的plugins属性中，这是一个以逗号分隔的列表。例如
```
plugins = bundled,my-custom-plugin # 你的插件名称
```
或者，如果您不想加载任何自带的插件：
```
plugins = my-custom-plugin  # 你的插件名称
```
现在，Kong将尝试从以下命名空间加载几个Lua模块：
```
kong.plugins.my-custom-plugin.<module_name>
```
其中一些模块是必需的（例如`handler.lua`），有些是可选的，并且允许插件实现一些额外的功能（例如`api.lua`以扩展Admin API）。现在让我们准确描述您可以实现的模块以及它们的用途。

## 基本插件模块
在最基本的形式中，插件包含两个必需的模块：
```
simple-plugin
├── handler.lua
└── schema.lua
```

- 每个函数将在请求的生命周期中的所需时刻运行。
- 由用户。此模块保存该配置的模式并在其上定义规则，以便用户只能输入有效的配置值。

## 高级插件模块

有些插件可能需要与Kong更深入地集成：在数据库中拥有自己的表，在Admin API中公开端点等等......每个插件都可以通过向插件添加新模块来完成。如果它实现了所有可选模块，那么插件的结构如下：
```
complete-plugin
├── api.lua
├── daos.lua
├── handler.lua
├── migrations
│   ├── cassandra.lua
│   └── postgres.lua
└── schema.lua
```

以下是要实施的可能模块的完整列表以及其目的的简要说明。
本指南将详细介绍，让您掌握其中的每一个文件。

| 模块文件名称 | 是否必须 | 描述 |
| ------------ | -------- | ---- |
| api.lua | No | 定义Admin API中可用的端点列表，以与插件处理的实体自定义实体进行交互。 |
| daos.lua | No | 定义DAO（数据库访问对象）列表，这些DAO是插件所需并存储在数据存储区中的自定义实体的抽象。 |
| handler.lua | Yes | 一个接口的实现。每个函数都由Kong在请求的生命周期中的所需时刻运行。 |
| migrations/xxxx.lua | No | 给定数据存储的相应迁移。只有当您的插件必须在数据库中存储自定义实体并通过daos.lua定义的其中一个DAO与它们进行交互时，才需要进行迁移。 |
| schema.lua | Yes | 保存插件配置的架构，以便用户只能输入有效的配置值。 |

[Key-Auth 插件](https://docs.konghq.com/plugins/key-authentication/)是具有此文件结构的插件的示例。
有关详细信息，请参阅其[源代码](https://github.com/Kong/kong/tree/master/kong/plugins/key-auth)。













