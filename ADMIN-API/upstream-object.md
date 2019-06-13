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
 



















