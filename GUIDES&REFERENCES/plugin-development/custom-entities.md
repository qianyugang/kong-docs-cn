# 存储自定义实体

## 介绍

虽然不是所有插件都需要它，但是您的插件可能需要在数据库中存储比配置更多的东西。在这种情况下，Kong在其主要数据存储之上提供了一个抽象，允许您存储自定义实体。

如[前一章节访问数据存储区](https://docs.konghq.com/1.1.x/plugin-development/access-the-datastore/)所述。Kong通过我们称之为“DAOs”的类与模型层交互，并且可以在通常被称为“DAO Factory”的单例上使用。本章将解释如何为您自己的实体提供一个抽象体。

## Modules

```
kong.plugins.<plugin_name>.daos
kong.plugins.<plugin_name>.migrations.init
kong.plugins.<plugin_name>.migrations.000_base
kong.plugins.<plugin_name>.migrations.001_xxx
kong.plugins.<plugin_name>.migrations.002_yyy
```
## 创建migrations文件夹

一旦定义了model，您必须创建将由Kong执行的migration modules，创建将存储您的实体记录的表。迁移文件包含一系列迁移，并返回它们。  
如果您的插件旨在支持Cassandra和PostgreSQL，那么必须编写两个migrations。  
如果您的插件还没有migrations文件夹，你应该添加一个`<plugin_name>/migrations`文件夹。如果里面没有`init.lua`文件，你应该创建一个。这是引导插件所有迁移的地方。  
`migrations/init.lua`文件的初始版本将指向单个迁移。  
在这种情况下，我们称之为`000_base`。 
```
-- `migrations/init.lua`
return {
  "000_base",
}
```
这意味着`<plugin_name>/migrations/000_base.lua`中将包含一个包含初始迁移的文件。  
我们将在一分钟内看到这是如何完成的。

## 迁移文件的语法

虽然Kong的核心迁移支持PostgreSQL和Cassandra，但自定义插件可以选择支持它们或只支持一个。

迁移文件是一个Lua文件，它返回一个具有以下结构的表：

```
-- `<plugin_name>/migrations/000_base.lua`
return {
  postgresql = {
    up = [[
      CREATE INDEX IF NOT EXISTS "routes_name_idx" ON "routes" ("name");
    ]],
    teardown = function(connector, helpers)
      assert(connector:connect_migrations())
      assert(connector:query('DROP TABLE IF EXISTS "schema_migrations" CASCADE;'))
    end,
  },

  cassandra = {
    up = [[
      CREATE INDEX IF NOT EXISTS routes_name_idx ON routes(name);
    ]],
    teardown = function(connector, helpers)
      assert(connector:connect_migrations())
      assert(connector:query("DROP TABLE IF EXISTS schema_migrations"))
    end,
  }
}
```

如果插件仅支持PostgreSQL或Cassandra，则只需要这个策略的一部分。每个策略部分都有两个部分，`up`和`teardown`。

- `up`是一个可选的原始SQL / CQL语句字符串。当执行`ong migrations up`时，将执行这些语句。
- `teardown`是一个可选的Lua函数，它接受一个`connector`参数。此类连接器可以调用查询方法来执行SQL/CQL查询。删除是由`kong migrations finish`触发。

建议在`up`部分上完成所有非破坏性操作，例如创建新表和添加新记录。而在进行破坏性操作（例如删除数据，更改行类型，插入新数据）时候在`teardown`部分。

在这两种情况下，建议编写所有SQL/CQL语句，以使它们尽可能重入。`DROP TABLE IF EXISTS`代替`DROP TABLE`，`CREATE INDEX IF NOT EXIST`代替`CREATE INDEX`等等。如果迁移由于某种原因而失败，则预计解决问题的第一次尝试将只是重新运行迁移。

虽然PostgreSQL没有，但Cassandra不支持诸如“NOT NULL”，“UNIQUE”或“FOREIGN KEY”之类的约束，但是，当您定义模型的模式时，Kong会为您提供此类功能。请记住，这个模式对于PostgreSQL和Cassandra都是相同的，因此，您可能会为使用Cassandra的模式权衡纯SQL模式。

> 重要：如果您的`schema`使用`unique`约束，那么Kong将为Cassandra强制执行它，但对于PostgreSQL，您必须在迁移中设置此约束。

## 从DAO Factory检索您的自定义DAO

要使DAO Factory加载自定义DAO，您需要定义实体的架构（就像描述[插件配置](https://docs.konghq.com/1.1.x/plugin-development/plugin-configuration/)的模式一样）。此模式包含更多值，因为它必须描述实体在数据存储区中与哪个表相关，对其字段的约束（如外键，非空约束等）。

此模式将在名为的模块中定义：
```
"kong.plugins.<plugin_name>.daos"
```
一旦该模块返回您的实体模式，并假设您的插件由Kong加载（请参阅`kong.conf`中的`plugins`属性），DAO Factory将使用它来实例化DAO对象。

以下是如何定义用于在其数据库中存储API密钥的模式的示例：

```
-- daos.lua
local SCHEMA = {
  primary_key = {"id"},
  table = "keyauth_credentials", -- 数据库中的表
  fields = {
    id = {type = "id", dao_insert_value = true}, -- DAO本身要插入的值（想想序列号和这里所需的唯一性）
    created_at = {type = "timestamp", immutable = true, dao_insert_value = true}, -- DAO本身也有所涉及
    consumer_id = {type = "id", required = true, foreign = "consumers:id"}, -- Consumer's id 的外键
    key = {type = "string", required = false, unique = true} --  唯一 API key
  }
}

return {keyauth_credentials = SCHEMA} -- 这个插件只产生一个自定义DAO， 名为 `keyauth_credentials`
```

由于您的插件可能必须处理多个自定义DAO（在您要存储多个实体的情况下），此模块必须返回一个键/值表，其中键是DAO Factory中可用的自定义DAO的名称。

您将注意到架构定义中的一些新属性（与[schema.lua](https://docs.konghq.com/1.1.x/plugin-development/plugin-configuration/)文件进行比较）

| 属性名 | LUA TYPE | 描述 |
| -------| -------- | ---- |
| `primary_key` | Integer indexed table | 每个部分column family的主键的数组,它还支持复合键，即使所有Kong实体当前都使用简单`ID`来管理[Admin API](https://docs.konghq.com/1.1.x/admin-api/)的可用性。如果主键是组合键，则只包含分区键的组成部分。 |
| `fields.*.dao_insert_value` | Boolean | 如果为true，则指定此字段由DAO（在base_dao实现中）自动填充，具体取决于其类型。id类型的属性将是生成的uuid，时间戳是具有第二精度的时间戳。 |
| `fields.*.queryable` | Boolean | 如果为true，则指定Cassandra在指定column上维护索引。允许查询由该column过滤的column family 。 |
| `fields.*.foreign` | String | 指定此column是另一个实体列的外键。格式为：`dao_name:column_name`，这使得Cassandra不支持外键。当父行将被删除时，Kong还将删除包含父列值的行。 |

您的DAO现在将由DAO Factory加载并作为其属性之一提供。因为DAO工厂是由插件开发工具包的kong global(参见kong)公开的。dao，可以这样检索:
```
local key_credential, err = kong.dao.key_credentials:insert({
  consumer_id = consumer.id,
  key = "abcd"
})
```

可以从DAO Factory访问的DAO名称（keyauth_credentials），取决于您在daos.lua的返回表中导出DAO的键。

您可以在[Key-Auth daos.lua](https://github.com/Kong/kong/blob/master/kong/plugins/key-auth/daos.lua)文件中看到此示例。

## 缓存自定义实体

有时每个request/response都需要自定义实体，每次都会在数据存储区上触发查询。这样效率非常低，因为查询数据存储会增加延迟并降低request/response速度。并且由此导致的数据存储区负载增加可能会影响数据存储区性能本身，进而影响其他Kong节点。

当每个请求/响应都需要自定义实体时，最好通过利用Kong提供的内存缓存API将其缓存在内存中。

下一章将重点介绍如何缓存自定义实体，并在数据存储区中更改时使它们失效：缓存自定义实体。






















