# 无数据库模式 Admin API 

> 此页面指的是用于运行Kong的Admin API，该API配置为无数据库，通过声明性配置管理内存中的实体。
有关将Kong的Admin API与数据库一起使用的信息，请参阅 [数据库模式的Admin API](https://docs.konghq.com/1.3.x/admin-api)页面。

## 目录

- [支持的 Content Types](#支持的-Content-Types)
- [Routes 信息](#Routes-信息)
	- [检索节点信息](#检索节点信息)
	- [检索节点状态](#检索节点状态)
- [声明式配置](#声明式配置)
	- [重新加载声明性配置](#重新加载声明性配置)
- [标签](#标签)
	- [列出所有标签](#列出所有标签)
	- [按标签列出实体ID](#按标签列出实体ID)
- [Service 对象](#Service-对象)
	- [Service 列表](#Service-列表)
	- [Service 检索](#Service-列表)
- [Router 对象](#Router-对象)
	- [Router 列表](#Router-列表)
	- [Router 检索](#Router-检索)
- [Consumer 对象](#Consumer-对象)
	- [Consumer 列表](#Consumer-列表)
	- [Consumer 检索](#Consumer-检索)
- [插件对象](#插件对象)
	- [优先级](#优先级)
	- [插件列表](#插件列表)
	- [插件检索](#插件检索)
	- [已启用的插件检索](#已启用的插件检索)
	- [插件schema检索](#插件schema检索)
- [证书对象](#证书对象)
	- [证书列表](#证书列表)
	- [证书检索](#证书检索)
- [CA证书对象](#CA证书对象)
	- [CA证书列表](#CA证书列表)
	- [CA证书检索](#CA证书检索)
- [SNI 对象](#SNI-对象)
	- [SNI 列表](#SNI-列表)
	- [SNI 检索](#SNI-检索)
- [Upstream 对象](#Upstream-对象)
	- [Upstream 列表](#Upstream-列表)
	- [Upstream 检索](#Upstream-检索)
	- [显示节点的Upstream运行状况](#显示节点的Upstream运行状况)
- [Target 对象](#Target-对象)
	- [Target 列表](#Target-列表)
	- [将Target设定为健康](#将Target设定为健康)
	- [将Target设置为不健康](#将Target设置为不健康)
	- [所有Target列表](#所有Target列表)

## 支持的 Content Types

Admin API在每个端点上接受2种内容类型：

- application/x-www-form-urlencoded
- application/json

## Routes 信息

### 检索节点信息

检索有关节点的常规详细信息。

```
GET /
```

*响应*

```
HTTP 200 OK
```
```
{
    "hostname": "",
    "node_id": "6a72192c-a3a1-4c8d-95c6-efabae9fb969",
    "lua_version": "LuaJIT 2.1.0-beta3",
    "plugins": {
        "available_on_server": [
            ...
        ],
        "enabled_in_cluster": [
            ...
        ]
    },
    "configuration" : {
        ...
    },
    "tagline": "Welcome to Kong",
    "version": "0.14.0"
}
```

- `node_id`：表示正在运行的Kong节点的UUID。Kong启动时会随机生成此UUID，因此该节点在每次重新启动时将具有不同的node_id。
- `available_on_server`：节点上安装的插件的名称。
- `enabled_in_cluster`：启用/配置的插件名称。也就是说，当前所有数据节点共享的数据存储中的插件配置。

### 检索节点状态

检索有关节点的使用情况信息，以及一些有关基础nginx进程正在处理的连接的基本信息，数据库连接的状态以及节点的内存使用情况。

如果要监视Kong进程，由于Kong是在nginx之上构建的，因此可以使用每个现有的nginx监视工具或代理。

```
GET /status
```
*响应*    
```
HTTP 200 OK
```
```
{
    "database": {
      "reachable": true
    },
    "memory": {
        "workers_lua_vms": [{
            "http_allocated_gc": "0.02 MiB",
            "pid": 18477
          }, {
            "http_allocated_gc": "0.02 MiB",
            "pid": 18478
        }],
        "lua_shared_dicts": {
            "kong": {
                "allocated_slabs": "0.04 MiB",
                "capacity": "5.00 MiB"
            },
            "kong_db_cache": {
                "allocated_slabs": "0.80 MiB",
                "capacity": "128.00 MiB"
            },
        }
    },
    "server": {
        "total_requests": 3,
        "connections_active": 1,
        "connections_accepted": 1,
        "connections_handled": 1,
        "connections_reading": 0,
        "connections_writing": 1,
        "connections_waiting": 0
    }
}
```

- `memory`：有关内存使用情况的指标。
	- `workers_lua_vms`：包含Kong节点的所有worker的数组，其中每个条目包含：
	- `http_allocated_gc`：由`collectgarbage（“ count”）`报告的HTTP子模块的Lua虚拟机的内存使用情况信息，适用于每个活动的worker程序，即在最近10秒钟内收到代理调用的工作程序。
	- `pid`：工作进程id号
	- `lua_shared_dicts`：与Kong节点中所有工作人员共享的词典信息的数组，其中每个数组节点包含有多少内存专用于特定的共享字典（`capacity`）以及有多少所述内存正在使用（`allocated_slabs`）。<br>
    这些共享字典具有最新使用（LRU）的清楚功能，因此`allocated_slab == capacity`所在的完整字典将正常工作。
但是对于某些字典，例如缓存HIT/MISS共享字典，增加它们的大小对整体来说是有益的。
	- 可以使用querystring参数unit和scale更改内存使用单位和精度：
		- `unit`：`b/B`，`k/K`，`m/M`，`g/G`中，它将分别以bytes、kibibytes、mebibytes或gibibytes返回结果。当请求“bytes”时，响应中的内存值将使用数字类型而不是字符串。默认为`m`。
		- `scale`：在人类可读的存储字符串（“bytes”以外的单位）示值时小数点右边的位数。默认值为2。您可以通过以下操作获得以kibibytes为单位的共享字典内存使用情况(精度为4位):`get/status?unit=k&scale=4`
- `server`：有关Nginx HTTP/S服务器的指标。
	- `total_requests`：客户端请求总数。
    - `connections_active`：当前活动的客户端连接数，包括等待连接数。
    - `connections_accepted`：接受的客户端连接总数。
    - `connections_handled`：已处理的连接总数。通常，除非已达到某些资源限制，否则参数值与接受的值相同。
    - `connections_reading`：Kong正在读取请求header的当前连接数。
    - `connections_writing`：nginx正在将响应写回到客户端的当前连接数。
    - `connections_waiting`：当前等待请求的空闲客户端连接数。
- `database`：数据库指标
	- `reachable`：反映数据库连接状态的布尔值。请注意，此标志**不反映**数据库本身的运行状况。

## 声明式配置

可以通过两种方式将实体的声明性配置加载到Kong中：在启动时，通过`declarative_config`属性，或者在运行时，通过使用`/ config`端点的Admin API。

要开始使用声明式配置，您需要一个包含实体定义的文件（YAML或JSON格式）。
您可以使用以下命令生成示例声明式配置：
```
kong config init
```
它会在当前目录中生成一个名为`kong.yml`的文件，其中包含适当的结构和示例。

### 重新加载声明性配置

该端点允许使用新的声明性配置数据文件重置无数据库的Kong。
所有先前的内容将从内存中删除，并且在给定文件中指定的实体将取代其位置。

要了解有关文件格式的更多信息，请阅读[声明性配置](https://docs.konghq.com/1.3.x/db-less-and-declarative-config)文档。

```
POST /config
```

| 属性 | 描述 |
| ---- | --- |
| `config` <br> required |要加载的配置数据（YAML或JSON格式）。 | 

*响应*
```
HTTP 200 OK
```
```
{
    { "services": [],
      "routes": []
    }
}
```
响应包含从输入文件中解析的所有实体的列表。

## 标签
### 列出所有标签
### 按标签列出实体ID

## Service 对象
### Service 列表
### Service 检索

## Router 对象
### Router 列表
### Router 检索

## Consumer 对象
### Consumer 列表
### Consumer 检索

## 插件对象
### 优先级
### 插件列表
### 插件检索
### 已启用的插件检索
### 插件schema检索

## 证书对象
### 证书列表
### 证书检索

## CA证书对象
### CA证书列表
### CA证书检索

## SNI 对象
### SNI 列表
### SNI 检索

## Upstream 对象
### Upstream 列表
### Upstream 检索
### 显示节点的Upstream运行状况

## Targe t对象
### Target 列表
### 将Target设定为健康
### 将Target设置为不健康
### 所有Target列表
















