# 信息路由

> 本文原文链接：https://docs.konghq.com/1.1.x/admin-api/#information-routes

## 检索节点信息

检索有关节点的一般详细信息。
```
GET /
```
响应
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

- `node_id`：表示正在运行的Kong节点的UUID。当Kong启动时，该UUID是随机生成的，因此每次重启节点时节点都会有不同的`node_id`。
- `available_on_server`：节点上安装的插件的名称。
- `enabled_in_cluster`：已启用/配置的插件的名称。也就是说，所有Kong节点共享的数据存储区中当前的插件配置。

## 检索节点状态

检索有关节点的使用信息，以及有关底层nginx进程正在处理的连接的一些基本信息，以及数据库连接的状态。

如果你想监视Kong过程，因为Kong是建立在nginx之上的，所以可以使用每个现有的nginx监视工具或代理。

```
GET /status
```

响应
```
HTTP 200 OK
```
```
{
    "server": {
        "total_requests": 3,
        "connections_active": 1,
        "connections_accepted": 1,
        "connections_handled": 1,
        "connections_reading": 0,
        "connections_writing": 1,
        "connections_waiting": 0
    },
    "database": {
        "reachable": true
    }
}
```

- `server`：有关nginx HTTP/S 服务器的相关指标
	- `total_requests`：客户端请求总数。
	- `connections_active`：当前活动客户端连接数，包括等待连接。
	- `connections_accepted`：已接受的客户端连接总数。
	- `connections_handled`：已处理连接的总数。通常，除非已达到某些资源限制，否则参数值与accept相同。
	- `connections_reading`：Kong正在读取请求标头的当前连接数。
	- `connections_writing`：nginx将响应写回客户端的当前连接数。
	- `connections_waiting`：当前等待请求的空闲客户端连接数。
- `database`：有关数据库的指标。
	- `reachable`：反映数据库连接状态的布尔值。请注意，此标志不反映数据库本身的运行状况。











