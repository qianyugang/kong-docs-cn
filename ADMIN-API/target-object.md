# 目标 Target

> 本文原文链接：https://docs.konghq.com/1.1.x/admin-api/#target-object

目标是IP地址/主机名，其端口标识后端服务的实例。每个上游(upstream)都可以有多个目标(target)，并且可以动态添加目标。并且更改是在运行中实现的。

由于上游维护目标更改的历史记录，因此无法删除或修改目标。要禁用目标，请发布一个`weight=0`的新目标;或者，使用`DELETE`方便方法来完成相同的操作。

当前目标对象定义是具有最新`created_at`的定义。

目标可以通过[tag进行标记和过滤](https://docs.konghq.com/1.1.x/admin-api/#tags)。

```
{
    "id": "a3ad71a8-6685-4b03-a101-980a953544f6",
    "created_at": 1422386534,
    "upstream": {"id":"b87eb55d-69a1-41d2-8653-8d706eecefc0"},
    "target": "example.com:8000",
    "weight": 100,
    "tags": ["user-level", "low-priority"]
}
```

## 添加 Target

### 创建与指定上游相关联的目标

```
POST /upstreams/{upstream host:port or id}/targets
```

| 参数 | 描述 |
| ---- | ---- |
| `upstream host:port or id` <br> *required* | 上游的唯一标识符或`host:port`属性，应与新创建的Target关联。 |

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `target` | 目标地址（ip或主机名）和端口。如果主机名解析为SRV记录，则`port`值将被DNS记录中的值覆盖。|
| `weight`<br>*optional* | 他将这个目标的重量放在上游负载均衡器（`0`-`1000`）内。如果主机名解析为SRV记录，则`weight`将被DNS记录中的值覆盖。默认为`100`。|
| `tags`<br>*optional* | 与Target关联的一组可选字符串，用于分组和过滤。 |

*响应*

```
HTTP 201 Created
```
```
{
    "id": "a3ad71a8-6685-4b03-a101-980a953544f6",
    "created_at": 1422386534,
    "upstream": {"id":"b87eb55d-69a1-41d2-8653-8d706eecefc0"},
    "target": "example.com:8000",
    "weight": 100,
    "tags": ["user-level", "low-priority"]
}
```

## Targets 列表

### 列出与指定上游相关联的目标

```
GET /upstreams/{upstream host:port or id}/targets
```

| 参数 | 描述 |
| ---- | ---- |
| `upstream host:port or id` <br> *required* | 上游的唯一标识符或`host:port`属性，应与新创建的Target关联。 |

*响应*

```
HTTP 201 Created
```
```
{
"data": [{
    "id": "4e8d95d4-40f2-4818-adcb-30e00c349618",
    "created_at": 1422386534,
    "upstream": {"id":"58c8ccbb-eafb-4566-991f-2ed4f678fa70"},
    "target": "example.com:8000",
    "weight": 100,
    "tags": ["user-level", "low-priority"]
}, {
    "id": "ea29aaa3-3b2d-488c-b90c-56df8e0dd8c6",
    "created_at": 1422386534,
    "upstream": {"id":"4fe14415-73d5-4f00-9fbc-c72a0fccfcb2"},
    "target": "example.com:8000",
    "weight": 100,
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/targets?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```


## 删除 Target

禁用负载均衡器中的target。在内部实现中，此方法为给定目标定义创建一个`weight`为0的新条目。
```
DELETE /upstreams/{upstream name or id}/targets/{host:port or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `upstream name or id`<br> *required*  | 要删除目标的上游的唯一标识符或名称。 |
| `host:port or id` <br> *required* | 要删除的目标的host:port组合元素，或现有目标条目的`id`。 |

*响应*

```
HTTP 204 No Content
```

## 将 Target 设置为健康状态

将负载均衡器中目标的当前运行状况设置为整个Kong集群中的“正常”。

此端点可用于手动重新启用上游运行[健康检查](https://docs.konghq.com/1.1.x/health-checks-circuit-breakers)程序先前禁用的目标。上游仅向健康节点转发请求，因此此调用告诉Kong再次开始使用此目标。

这将重置在Kong节点的所有工作程序中运行的运行状况检查程序的运行状况计数器，并广播群集范围的消息，以便将“健康”状态传播到整个Kong群集。

```
POST /upstreams/{upstream name or id}/targets/{target or id}/healthy
```

| 参数 | 描述 |
| ---- | ---- |
| `upstream name or id`<br> *required*  | 唯一标识符或上游名称。 |
| `host:port or id` <br> *required* | 要设置为运行状况健康的目标的主机/端口组合元素，或现有目标条目的`id`。 |

*响应*

```
HTTP 204 No Content
```


## 将 Target 设置为不健康状态

将负载均衡器中目标的当前运行状况设置为整个Kong集群中的“不健康状态”。

此端点可用于手动禁用目标并使其停止响应请求。上游仅向健康节点转发请求，因此该调用告诉Kong开始在环平衡器算法中跳过此目标。

此调用重置在Kong节点的所有工作程序中运行的运行状况检查程序的运行状况计数器，并广播群集范围的消息，以便将“不健康”状态传播到整个Kong群集。

对不健康的目标继续执行[主动健康检查](https://docs.konghq.com/1.1.x/health-checks-circuit-breakers/#active-health-checks)。
请注意，如果启用了活动运行状况检查并且探测器检测到目标实际上正常，则它将自动再次重新启用它。要从环状负载均衡中永久删除目标，您应该[删除目标](https://docs.konghq.com/1.1.x/admin-api/#delete-target)。

```
POST /upstreams/{upstream name or id}/targets/{target or id}/unhealthy
```

| 参数 | 描述 |
| ---- | ---- |
| `upstream name or id`<br> *required*  | 唯一标识符或上游名称。 |
| `host:port or id` <br> *required* | 要设置为运行状况不健康的目标的主机/端口组合元素，或现有目标条目的`id`。 |

*响应*

```
HTTP 204 No Content
```

## 列出所有 Target

列出上游的所有目标。可以返回同一目标的多个目标对象，显示指定目标的更改历史记录。具有最新`created_at`的目标对象是当前定义。

```
GET /upstreams/{name or id}/targets/all/
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id`<br> *required*  | 要列出目标的唯一标识符或上游名称。 |

*响应*

```
HTTP 200 OK
```

```
{
    "total": 2,
    "data": [
        {
            "created_at": 1485524883980,
            "id": "18c0ad90-f942-4098-88db-bbee3e43b27f",
            "target": "127.0.0.1:20000",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 100
        },
        {
            "created_at": 1485524914883,
            "id": "6c6f34eb-e6c3-4c1f-ac58-4060e5bca890",
            "target": "127.0.0.1:20002",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 200
        }
    ]
}
```


















