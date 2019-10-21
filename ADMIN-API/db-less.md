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
	- `workers_lua_vms`：
	- `http_allocated_gc`：
	- `pid`：
	- `lua_shared_dicts`：
	- 可以使用querystring参数unit和scale更改内存使用单位和精度：
		- `unit`：
		- `scale`：
- `server`：
	- `total_requests`：
    - `connections_active`：
    - `connections_accepted`：
    - `connections_handled`：
    - `connections_reading`：
    - `connections_writing`：
    - `connections_waiting`
- `database`：
	- `reachable`：


## 声明式配置
### 重新加载声明性配置

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
















