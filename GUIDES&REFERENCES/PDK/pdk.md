# 插件开发套件中文

插件开发工具包 Plugin Development Kit（或“PDK”）是一组Lua函数和变量，插件可以使用这些函数和变量来实现自己的逻辑。PDK是一个[语义版本](https://semver.org/)的组件，最初在Kong 0.14.0中发布。PDK将保证从1.0.0版本开始向前兼容。

截至本版本，PDK尚未达到1.0.0，但插件作者已经可以依赖它来使用安全可靠的方式进行请求、响应或者做一些核心组件。

可以从kong全局变量访问插件开发工具包，并在此表下命名各种功能，例如`kong.request`，`kong.log`等...

## kong.version

一个可以直观阅读的字符串，包含当前正在运行的节点的版本号。

### 用法

```
print(kong.version) -- "0.14.0"
Back to TOC
```

## kong.version_num

表示当前运行节点的版本号的整数，用于比较和特征存在检查。

### 用法

```
if kong.version_num < 13000 then -- 000.130.00 -> 0.13.0
  -- no support for Routes & Services
end
```

## kong.pdk_major_version

表示当前PDK主要版本的数字（例如1）。
对于作为PDK用户的特征存在检查或向后兼容行为很有用。

### 用法

```
if kong.pdk_version_num < 2 then
  -- PDK is below version 2
end
Back to TOC
```

## kong.pdk_version

一个可以直观阅读的字符串，包含当前PDK的版本号。


### 用法

```
print(kong.pdk_version) -- "1.0.0"
```

## kong.configuration

包含当前Kong节点配置的只读表，基于配置文件和环境变量。
有关详细信息，请参阅[kong.conf.default](https://github.com/Kong/kong/blob/master/kong.conf.default)。
该文件中以逗号分隔的列表将被提升为此表中的字符串数组。

### 用法
```
print(kong.configuration.prefix) -- "/usr/local/kong"
-- this table is read-only; the following throws an error:
kong.configuration.prefix = "foo"
```
## kong.db
Kong的DAO实例（`kong.db`模块）。
包含各种实体的访问者对象。
### 用法

```
kong.db.services:insert()
kong.db.routes:select()
```

将来可以提供有关此DAO和新模式定义的更全面的文档。

## kong.dns
Kong的DNS解析器实例，来自[lua-resty-dns-c](https://github.com/kong/lua-resty-dns-client)模块的客户端对象。
注意：此模块的使用目前保留给核心或高级用户。
## kong.worker_events
Kong的IPC模块实例，用于来自[lua-resty-worker-events](https://github.com/Kong/lua-resty-worker-events)模块的员工间通信。
注意：此模块的使用目前保留给核心或高级用户。
## kong.cluster_events
用于节点间通信的Kong的集群事件模块的实例。
注意：此模块的使用目前保留给核心或高级用户。
回到TOC
## kong.cache

来自kong.cache模块的Kong数据库缓存对象的实例。
注意：此模块的使用目前保留给核心或高级用户。











