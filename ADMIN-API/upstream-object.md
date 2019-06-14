# Upstream 上游

上游对象表示虚拟主机名，可用于通过多个服务（目标）对传入请求进行负载均衡。例如，对于主机为`service.v1.xyz`的 Service 对象，上游名为 `service.v1.xyz`。对此服务的请求将代理到上游定义的目标。

上游还包括[健康检查](https://docs.konghq.com/1.2.x/health-checks-circuit-breakers)程序，该检查程序能够基于其能力或无法提供请求来启用和禁用目标。运行状况检查程序的配置存储在上游对象中，并应用于其所有目标。

上游可以通过[标签进行标记和过滤](https://docs.konghq.com/1.2.x/admin-api/#tags)。
```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}
```


## 添加

### 创建一个upstream

```
POST /upstreams
```

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `name` | 这是主机名，必须等于Service的`host`。|
| `hash_on` <br> *optional* | 什么用hash输入：`none`（导致加权循环方案没有hash），`consumer`，`ip`，`header`或`cookie`。默认为`“none”`。 | 
| `hash_fallback` <br> *optional* | 如果主`hash_on`没有返回hash(例如。header丢失，或没有consumer识别).`consumer`，`ip`，`header`或`cookie`其中之一。如果`hash_on`设置为`cookie`，则不可用。默认为`“none”`。|
| `hash_on_header` <br> *semi-optional* | header名称，用于将值作为hash输入。仅在`hash_on`设置为标头时才需要。|
| `hash_fallback_header`  <br> *semi-optional* | 标头名称，用于将值作为hash输入。仅`在hash_fallback`设置为`header`时才需要。|
| `hash_on_cookie` <br> *semi-optional*  | cookie名称从哈希输入中获取值。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。如果指定的cookie不在请求中，Kong将生成一个值并在响应中设置cookie。|
| `hash_on_cookie_path`  <br> *semi-optional* | 要在响应标头中设置的cookie路径。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。默认为`“/”`。|
| `slots`  <br> *optional*  | 负载均衡器算法中的插槽数（`10`-`65536`）。默认为`10000`。|
| `healthchecks.active.https_verify_certificate` <br> *optional* | 使用HTTPS执行活动运行状况检查时是否检查远程主机的SSL证书的有效性。默认为`true`。 |
| `healthchecks.active.unhealthy.http_statuses`  <br> *optional* | 一组HTTP状态，用于在活动运行状况检查中由探测器返回时考虑失败，指示不健康。默认`[429, 404, 500, 501, 502, 503, 504, 505]` ， 用 form-encoded 的时候，参数`http_statuses[]=429&http_statuses[]=404`；使用JSON，参数使用数组即可 | 
| `healthchecks.active.unhealthy.tcp_failures` <br> *optional*  | 活动探测器中用于考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.active.unhealthy.timeouts` <br> *optional*  | 活动探测器中用于考虑目标不健康的超时次数。默认为`0`。|
| `healthchecks.active.unhealthy.http_failures` <br> *optional* | 活动探测器中的HTTP故障数（由`healthchecks.active.unhealthy.http_statuses`定义）以考虑目标运行状况不佳。默认为`0`。|
| `healthchecks.active.unhealthy.interval` <br> *optional* | 不健康目标的活动健康检查之间的间隔（以秒为单位）。值为零表示不应执行不健康目标的活动探测。默认为`0`。|
| `healthchecks.active.http_path` <br> *optional* | 在GET HTTP请求中使用的路径，作为活动运行状况检查的探测运行。默认为`“/”`。 |
| `healthchecks.active.timeout` <br> *optional* | 活动运行状况检查的套接字超时（以秒为单位）。默认为`1`。 |
| `healthchecks.active.healthy.http_statuses`  <br> *optional*  | 一组HTTP状态，用于在主动健康检查中由探针返回时考虑成功，指示健康状况。默认`[200, 302]` 。使用 form-encoded 参数为`http_statuses[]=200&http_statuses[]=302` ； 使用JSON，参数使用数组即可。 |
|  `healthchecks.active.healthy.interval`  <br> *optional* | 健康目标的主动健康检查之间的间隔（以秒为单位）。值为零表示不应执行健康目标的活动探测。默认为`0`。|
| `healthchecks.active.healthy.successes` <br> *optional* | 活动探针中的成功次数（由`healthchecks.active.healthy.http_statuses`定义）以考虑目标健康。默认为`0`。|
| `healthchecks.active.https_sni` <br> *optional*  | 使用HTTPS执行主动健康检查时用作SNI（服务器名称标识）的主机名。当使用IP配置目标时，这尤其有用，因此可以使用正确的SNI验证目标主机的证书。|
| `healthchecks.active.concurrency` <br> *optional*  | 在活动主动健康检查中同时检查的目标数。默认为`10`。|
| `healthchecks.active.type` <br> *optional*  | 是使用HTTP还是HTTPS执行活动运行状况检查，还是仅尝试TCP连接。可能的值为`tcp`，`http`或`https`。默认为`“http”`。|
| `healthchecks.passive.unhealthy.http_failures` <br> *optional*  | 代理流量，(由`healthchecks.passive.unhealthy.http_statuses` 定义)，中的HTTP故障数，以考虑目标不健康，如被动运行状况检查所观察到的那样。默认为`0`. |
| `healthchecks.passive.unhealthy.tcp_failures` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.passive.unhealthy.timeouts` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的超时次数。默认为`0`。 | 
| `healthchecks.passive.type` <br> *optional* | 是否执行解释 HTTP/HTTPS 状态的被动运行状况检查，或仅检查TCP连接是否成功。可能的值是`tcp`，`http`或`https`（在被动检查中，`http`和`https`选项是等效的。）。默认为`“http”`。|
| `healthchecks.passive.healthy.successes` <br> *optional* | 代理流量的成功次数（由`healthchecks.passive.healthy.http_statuses`定义）以考虑目标健康，如被动健康检查所观察到的那样。默认为`0`。 |
| `healthchecks.passive.healthy.http_statuses` <br> *optional* | 一组HTTP状态，表示由代理流量生成的健康状况，如被动健康检查所观察到的那样。默认`[200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]`，使用 form-encoded，参数为`http_statuses[]=200&http_statuses[]=201` ，使用 JSON，参数为数组即可。|
| `tags` <br> *optional*  | 与上游关联的可选字符串集，用于分组和过滤。|

*响应*

```
HTTP 201 Created
```
```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}

```
 
## Upstream 列表

## 列出所有upstrem
```
GET /upstreams 
```

*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a2e013e8-7623-4494-a347-6d29108ff68b",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}, {
    "id": "147f5ef0-1ed6-4711-b77f-489262f8bff7",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/upstreams?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

## 搜索 Upstream

### 搜索 Upstream
```
GET /upstreams/{name or id}
```
| 参数 | 描述 |
| ---- | ---- |
| `name or id` | 要检索的上游的唯一标识符或名称。 |

### 检索与特定目标关联的Upstream

```
GET /targets/{target host:port or id}/upstream
```

| 参数 | 描述 |
| ---- | ---- |
| `target host:port or id` | 与要检索的上游相关联的Target的唯一标识符或host：port。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}

```

## 更新 Upstream

### 更新一个 Upstream

```
PATCH /upstreams/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id` | 要检索的上游的唯一标识符或名称。 |

### 更新与特定目标关联的Upstream

```
PATCH /targets/{target host:port or id}/upstream
```

| 参数 | 描述 |
| ---- | ---- |
| `target host:port or id` | 与要检索的上游相关联的Target的唯一标识符或host：port。 |

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `name` | 这是主机名，必须等于Service的`host`。|
| `hash_on` <br> *optional* | 什么用hash输入：`none`（导致加权循环方案没有hash），`consumer`，`ip`，`header`或`cookie`。默认为`“none”`。 | 
| `hash_fallback` <br> *optional* | 如果主`hash_on`没有返回hash(例如。header丢失，或没有consumer识别).`consumer`，`ip`，`header`或`cookie`其中之一。如果`hash_on`设置为`cookie`，则不可用。默认为`“none”`。|
| `hash_on_header` <br> *semi-optional* | header名称，用于将值作为hash输入。仅在`hash_on`设置为标头时才需要。|
| `hash_fallback_header`  <br> *semi-optional* | 标头名称，用于将值作为hash输入。仅`在hash_fallback`设置为`header`时才需要。|
| `hash_on_cookie` <br> *semi-optional*  | cookie名称从哈希输入中获取值。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。如果指定的cookie不在请求中，Kong将生成一个值并在响应中设置cookie。|
| `hash_on_cookie_path`  <br> *semi-optional* | 要在响应标头中设置的cookie路径。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。默认为`“/”`。|
| `slots`  <br> *optional*  | 负载均衡器算法中的插槽数（`10`-`65536`）。默认为`10000`。|
| `healthchecks.active.https_verify_certificate` <br> *optional* | 使用HTTPS执行活动运行状况检查时是否检查远程主机的SSL证书的有效性。默认为`true`。 |
| `healthchecks.active.unhealthy.http_statuses`  <br> *optional* | 一组HTTP状态，用于在活动运行状况检查中由探测器返回时考虑失败，指示不健康。默认`[429, 404, 500, 501, 502, 503, 504, 505]` ， 用 form-encoded 的时候，参数`http_statuses[]=429&http_statuses[]=404`；使用JSON，参数使用数组即可 | 
| `healthchecks.active.unhealthy.tcp_failures` <br> *optional*  | 活动探测器中用于考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.active.unhealthy.timeouts` <br> *optional*  | 活动探测器中用于考虑目标不健康的超时次数。默认为`0`。|
| `healthchecks.active.unhealthy.http_failures` <br> *optional* | 活动探测器中的HTTP故障数（由`healthchecks.active.unhealthy.http_statuses`定义）以考虑目标运行状况不佳。默认为`0`。|
| `healthchecks.active.unhealthy.interval` <br> *optional* | 不健康目标的活动健康检查之间的间隔（以秒为单位）。值为零表示不应执行不健康目标的活动探测。默认为`0`。|
| `healthchecks.active.http_path` <br> *optional* | 在GET HTTP请求中使用的路径，作为活动运行状况检查的探测运行。默认为`“/”`。 |
| `healthchecks.active.timeout` <br> *optional* | 活动运行状况检查的套接字超时（以秒为单位）。默认为`1`。 |
| `healthchecks.active.healthy.http_statuses`  <br> *optional*  | 一组HTTP状态，用于在主动健康检查中由探针返回时考虑成功，指示健康状况。默认`[200, 302]` 。使用 form-encoded 参数为`http_statuses[]=200&http_statuses[]=302` ； 使用JSON，参数使用数组即可。 |
|  `healthchecks.active.healthy.interval`  <br> *optional* | 健康目标的主动健康检查之间的间隔（以秒为单位）。值为零表示不应执行健康目标的活动探测。默认为`0`。|
| `healthchecks.active.healthy.successes` <br> *optional* | 活动探针中的成功次数（由`healthchecks.active.healthy.http_statuses`定义）以考虑目标健康。默认为`0`。|
| `healthchecks.active.https_sni` <br> *optional*  | 使用HTTPS执行主动健康检查时用作SNI（服务器名称标识）的主机名。当使用IP配置目标时，这尤其有用，因此可以使用正确的SNI验证目标主机的证书。|
| `healthchecks.active.concurrency` <br> *optional*  | 在活动主动健康检查中同时检查的目标数。默认为`10`。|
| `healthchecks.active.type` <br> *optional*  | 是使用HTTP还是HTTPS执行活动运行状况检查，还是仅尝试TCP连接。可能的值为`tcp`，`http`或`https`。默认为`“http”`。|
| `healthchecks.passive.unhealthy.http_failures` <br> *optional*  | 代理流量，(由`healthchecks.passive.unhealthy.http_statuses` 定义)，中的HTTP故障数，以考虑目标不健康，如被动运行状况检查所观察到的那样。默认为`0`. |
| `healthchecks.passive.unhealthy.tcp_failures` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.passive.unhealthy.timeouts` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的超时次数。默认为`0`。 | 
| `healthchecks.passive.type` <br> *optional* | 是否执行解释 HTTP/HTTPS 状态的被动运行状况检查，或仅检查TCP连接是否成功。可能的值是`tcp`，`http`或`https`（在被动检查中，`http`和`https`选项是等效的。）。默认为`“http”`。|
| `healthchecks.passive.healthy.successes` <br> *optional* | 代理流量的成功次数（由`healthchecks.passive.healthy.http_statuses`定义）以考虑目标健康，如被动健康检查所观察到的那样。默认为`0`。 |
| `healthchecks.passive.healthy.http_statuses` <br> *optional* | 一组HTTP状态，表示由代理流量生成的健康状况，如被动健康检查所观察到的那样。默认`[200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]`，使用 form-encoded，参数为`http_statuses[]=200&http_statuses[]=201` ，使用 JSON，参数为数组即可。|
| `tags` <br> *optional*  | 与上游关联的可选字符串集，用于分组和过滤。|

*响应*

```
HTTP 200 OK
```
```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}
```

## 更新或创建 Upstream

### 更新或创建一个 Upstream
```
PUT /upstreams/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id` | 要更新或创建的上游的唯一标识符或名称。 |

### 更新或创建一个与特定目标关联的Upstream

```
PUT /targets/{target host:port or id}/upstream
```

| 参数 | 描述 |
| ---- | ---- |
| `target host:port or id` | 与要更新或创建的上游相关联的Target的唯一标识符或host：port。 |

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `name` | 这是主机名，必须等于Service的`host`。|
| `hash_on` <br> *optional* | 什么用hash输入：`none`（导致加权循环方案没有hash），`consumer`，`ip`，`header`或`cookie`。默认为`“none”`。 | 
| `hash_fallback` <br> *optional* | 如果主`hash_on`没有返回hash(例如。header丢失，或没有consumer识别).`consumer`，`ip`，`header`或`cookie`其中之一。如果`hash_on`设置为`cookie`，则不可用。默认为`“none”`。|
| `hash_on_header` <br> *semi-optional* | header名称，用于将值作为hash输入。仅在`hash_on`设置为标头时才需要。|
| `hash_fallback_header`  <br> *semi-optional* | 标头名称，用于将值作为hash输入。仅`在hash_fallback`设置为`header`时才需要。|
| `hash_on_cookie` <br> *semi-optional*  | cookie名称从哈希输入中获取值。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。如果指定的cookie不在请求中，Kong将生成一个值并在响应中设置cookie。|
| `hash_on_cookie_path`  <br> *semi-optional* | 要在响应标头中设置的cookie路径。仅当`hash_on`或`hash_fallback`设置为`cookie`时才需要。默认为`“/”`。|
| `slots`  <br> *optional*  | 负载均衡器算法中的插槽数（`10`-`65536`）。默认为`10000`。|
| `healthchecks.active.https_verify_certificate` <br> *optional* | 使用HTTPS执行活动运行状况检查时是否检查远程主机的SSL证书的有效性。默认为`true`。 |
| `healthchecks.active.unhealthy.http_statuses`  <br> *optional* | 一组HTTP状态，用于在活动运行状况检查中由探测器返回时考虑失败，指示不健康。默认`[429, 404, 500, 501, 502, 503, 504, 505]` ， 用 form-encoded 的时候，参数`http_statuses[]=429&http_statuses[]=404`；使用JSON，参数使用数组即可 | 
| `healthchecks.active.unhealthy.tcp_failures` <br> *optional*  | 活动探测器中用于考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.active.unhealthy.timeouts` <br> *optional*  | 活动探测器中用于考虑目标不健康的超时次数。默认为`0`。|
| `healthchecks.active.unhealthy.http_failures` <br> *optional* | 活动探测器中的HTTP故障数（由`healthchecks.active.unhealthy.http_statuses`定义）以考虑目标运行状况不佳。默认为`0`。|
| `healthchecks.active.unhealthy.interval` <br> *optional* | 不健康目标的活动健康检查之间的间隔（以秒为单位）。值为零表示不应执行不健康目标的活动探测。默认为`0`。|
| `healthchecks.active.http_path` <br> *optional* | 在GET HTTP请求中使用的路径，作为活动运行状况检查的探测运行。默认为`“/”`。 |
| `healthchecks.active.timeout` <br> 检索*optional* | 活动运行状况检查的套接字超时（以秒为单位）。默认为`1`。 |
| `healthchecks.active.healthy.http_statuses`  <br> *optional*  | 一组HTTP状态，用于在主动健康检查中由探针返回时考虑成功，指示健康状况。默认`[200, 302]` 。使用 form-encoded 参数为`http_statuses[]=200&http_statuses[]=302` ； 使用JSON，参数使用数组即可。 |
|  `healthchecks.active.healthy.interval`  <br> *optional* | 健康目标的主动健康检查之间的间隔（以秒为单位）。值为零表示不应执行健康目标的活动探测。默认为`0`。|
| `healthchecks.active.healthy.successes` <br> *optional* | 活动探针中的成功次数（由`healthchecks.active.healthy.http_statuses`定义）以考虑目标健康。默认为`0`。|
| `healthchecks.active.https_sni` <br> *optional*  | 使用HTTPS执行主动健康检查时用作SNI（服务器名称标识）的主机名。当使用IP配置目标时，这尤其有用，因此可以使用正确的SNI验证目标主机的证书。|
| `healthchecks.active.concurrency` <br> *optional*  | 在活动主动健康检查中同时检查的目标数。默认为`10`。|
| `healthchecks.active.type` <br> *optional*  | 是使用HTTP还是HTTPS执行活动运行状况检查，还是仅尝试TCP连接。可能的值为`tcp`，`http`或`https`。默认为`“http”`。|
| `healthchecks.passive.unhealthy.http_failures` <br> *optional*  | 代理流量，(由`healthchecks.passive.unhealthy.http_statuses` 定义)，中的HTTP故障数，以考虑目标不健康，如被动运行状况检查所观察到的那样。默认为`0`. |
| `healthchecks.passive.unhealthy.tcp_failures` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的TCP故障数。默认为`0`。|
| `healthchecks.passive.unhealthy.timeouts` <br> *optional* | 通过被动运行状况检查观察到的代理流量中考虑目标不健康的超时次数。默认为`0`。 | 
| `healthchecks.passive.type` <br> *optional* | 是否执行解释 HTTP/HTTPS 状态的被动运行状况检查，或仅检查TCP连接是否成功。可能的值是`tcp`，`http`或`https`（在被动检查中，`http`和`https`选项是等效的。）。默认为`“http”`。|
| `healthchecks.passive.healthy.successes` <br> *optional* | 代理流量的成功次数（由`healthchecks.passive.healthy.http_statuses`定义）以考虑目标健康，如被动健康检查所观察到的那样。默认为`0`。 |
| `healthchecks.passive.healthy.http_statuses` <br> *optional* | 一组HTTP状态，表示由代理流量生成的健康状况，如被动健康检查所观察到的那样。默认`[200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]`，使用 form-encoded，参数为`http_statuses[]=200&http_statuses[]=201` ，使用 JSON，参数为数组即可。|
| `tags` <br> *optional*  | 与上游关联的可选字符串集，用于分组和过滤。|

使用正文中指定的定义在请求的资源下插入（或替换）Upstream。将通过`name or id`属性标识Upstream。

当`name or id`属性具有UUID的结构时，插入/替换的上游将由其`id`标识。否则将通过其`name`识别。

当创建新的上游而不指定`id`（既不在URL中也不在主体中）时，它将自动生成。

请注意，不允许在URL中指定`name`，也不允许在请求正文中指定其他名称。

*响应*

```
HTTP 201 Created or HTTP 200 OK
```

请参阅POST和PATCH响应。

## 删除 Upstream

### 删除一个 Upstream
```
DELETE /upstreams/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id` | 要删除的上游的唯一标识符或名称。 |

### 更新或创建一个与特定目标关联的Upstream

```
DELETE /targets/{target host:port or id}/upstream
```

| 参数 | 描述 |
| ---- | ---- |
| `target host:port or id` | 与要删除的上游相关联的Target的唯一标识符或host：port。 |

*响应*

```
HTTP 204 No Content
```

## 显示节点的Upstream运行健康状况

根据特定Kong节点的透视图显示给定Upstream的所有Targets的运行状况。请注意，作为特定于节点的信息，对Kong群集的不同节点发出相同的请求可能会产生不同的结果。例如，Kong群集的一个特定节点可能遇到网络问题，导致它无法连接到某些目标：这些目标将被该节点标记为不健康（将来自此节点的流量定向到其可以成功到达的其他目标）但对所有其他康节点都很健康（使用Target没有问题）。

响应的`data`字段包含Target对象的数组。每个Target的运行状况在其`health`字段中返回：

- 如果由于DNS问题而无法在环形平衡器中激活目标，则其状态显示为`DNS_ERROR`。
- 如果未在上游配置中启用[健康检查](https://docs.konghq.com/1.2.x/health-checks-circuit-breakers)，则活动目标的运行状况状态将显示为`HEALTHCHECKS_OFF`。
- 启用健康检查并确定Target是健康的（自动或[手动](https://docs.konghq.com/1.2.x/admin-api/#set-target-as-healthy)）后，其状态将显示为`HEALTHY`。这意味着此目标目前包含在此Upstream的负载均衡器环中。
- 当目标被主动或被动健康检查（断路器）或[手动](https://docs.konghq.com/1.2.x/admin-api/#set-target-as-healthy)禁用时，其状态显示为`UNHEALTHY`。负载均衡器不会通过此上游将任何流量定向到此目标。

```
GET /upstreams/{name or id}/health/
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id` | 要显示目标运行状况的上游的唯一标识符或名称。 |

*响应*

```
HTTP 200 OK
```
```
{
    "total": 2,
    "node_id": "cbb297c0-14a9-46bc-ad91-1d0ef9b42df9",
    "data": [
        {
            "created_at": 1485524883980,
            "id": "18c0ad90-f942-4098-88db-bbee3e43b27f",
            "health": "HEALTHY",
            "target": "127.0.0.1:20000",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 100
        },
        {
            "created_at": 1485524914883,
            "id": "6c6f34eb-e6c3-4c1f-ac58-4060e5bca890",
            "health": "UNHEALTHY",
            "target": "127.0.0.1:20002",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 200
        }
    ]
}
```








