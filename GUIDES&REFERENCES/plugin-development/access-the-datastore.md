# 访问数据存储区

> 本文原文链接：https://docs.konghq.com/1.1.x/plugin-development/access-the-datastore/

## 简介

Kong通过我们称为“DAOs”的类与模型层交互。本章将详细介绍与数据存储交互的可用API。Kong支持两个主数据存储：[Cassandra 3.x.x](http://cassandra.apache.org/)和[PostgreSQL 9.5+](http://www.postgresql.org/)。


# kong.db

Kong 的所有实例表示为：

- 描述实体在数据存储区中与哪个表相关的模式，对其字段的约束，如外键，非空约束等...此schema是[插件配置](https://docs.konghq.com/1.1.x/plugin-development/plugin-configuration/)章节中描述的表。
- DAO类的一个实例映射到当前正在使用的数据库（Cassandra或PostgreSQL）。此类的方法使用模式并公开方法来插入，更新，查找和删除该类型的实体。

Kong的核心实体是：Services, Routes, Consumers 和 Plugins。所有这些都可以作为数据访问对象（DAO）通过kong.db全局单例访问：

```
-- Core DAOs
local services_dao = kong.db.services
local routes_dao = kong.db.routes
local consumers_dao = kong.db.consumers
local plugins_dao = kong.dao.plugins
```
来自Kong的核心实体和插件中的自定义实体都可以通过`kong.db.*`。

## The DAO Lua API

DAO类负责在数据存储区中的给定表上执行的操作，通常映射到Kong的实体。所有底层支持的数据库（目前是Cassandra和PostgreSQL）都遵循相同的接口，从而使DAO与所有这些兼容。
例如，插入服务和插件非常简单：
```
local inserted_service, err = kong.db.services:insert({
  name = "mockbin",
  url = "http://mockbin.org",
})

local inserted_plugin, err = kong.db.plugins:insert({
  name = "key-auth",
  service_id = { id = inserted_service.id },
})
```

有关在插件中使用的DAO的实际示例，请参阅 [Key-Auth plugin 的源代码](https://github.com/Kong/kong/blob/master/kong/plugins/key-auth/handler.lua)。

















