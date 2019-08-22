# Prometheus 插件

以Prometheus exposition格式公开与Kong和代理上游服务相关的指标，Prometheus服务器可以对这些指标进行抓取。

> 注意：要在具有高吞吐量的配置中保持性能，还需要配置[StatsD](https://docs.konghq.com/hub/kong-inc/statsd/)插件或[StatsD Advanced](https://docs.konghq.com/hub/kong-inc/statsd-advanced/)插件。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`
- `tcp`
- `tls`
- `grpc`
- `grpcs`

此插件与无DB模式兼容。
在DB-less的 Prometheus 中，数据库总是报告为“可访问”。
## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=prometheus" 
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: prometheus
  service: {service}
  config: 
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。



## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`ip-restriction`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `enabled` |  `true` | 是否将应用此插件。  |

可以在 `http://localhost:8001/metrics` 端点的Admin API上获得度量标准。
请注意，Admin API的URL将特定于您的安装;
请参阅以下访问指标。

此插件在节点级别记录和公开指标。您的Prometheus服务器将需要通过服务发现机制发现所有的Kong节点，并使用来自每个节点的配置`/metric`端点的数据。仅设置为proxy的Kong节点(通过指定`admin_listen=off`禁用了它们的管理API)将需要使用[自定义Nginx配置模板](https://docs.konghq.com/latest/configuration/#custom-nginx-configuration)来公开度量数据。

## Grafana 仪表板

插件导出的度量标准可以使用下拉仪表板在Grafana中绘制：https://grafana.com/dashboards/7424 。

## 可用指标

- **Status codes**:状态码，上游服务返回的HTTP状态代码。这些服务适用于每个服务和所有服务。
- **Latencies Histograms**:延迟直方图:在Kong测量的延迟:
	- **Request**:Kong和上游服务为请求服务所花费的总时间。
	- **Kong**:Kong为路由请求并运行所有已配置的插件所花费的时间。
	- **Upstream**:上游服务响应请求所花费的时间。
- **Bandwidth**:流经Kong的总带宽（出口/入口）。该指标可用于每项服务，也可作为所有服务的总和。
- **DB reachability**:一种值为0或1的仪表类型，表示Kong节点是否可以到达DB。
- **Connections**:各种Nginx连接指标，如活动，读取，写入和已接受连接的数量。

以下是您可以从`/metrics`端点获得的输出示例：

```
$ curl -i http://localhost:8001/metrics
HTTP/1.1 200 OK
Server: openresty/1.11.2.5
Date: Mon, 11 Jun 2018 01:39:38 GMT
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Access-Control-Allow-Origin: *

# 帮助kong_bandwidth_total所有代理请求的总带宽(以字节为单位)
# 类型kong_bandwidth_total计数器
kong_bandwidth_total{type="egress"} 1277
kong_bandwidth_total{type="ingress"} 254

# 在Kong中，每个服务消耗的总带宽(以字节为单位)
# 类型kong_bandwidth计数器
kong_bandwidth{type="egress",service="google"} 1277
kong_bandwidth{type="ingress",service="google"} 254

# 从Kong可以访问的数据存储，0是不可访问的
# 类型kong_datastore_available量规
kong_datastore_reachable 1

# HELP kong_http_status_total HTTP状态码在Kong中的所有服务中聚合
# 类型kong_http_status_total计数器
kong_http_status_total{code="301"} 2

# 在kong中的每个服务中都有HTTP状态代码
# kong_http_status计数器类型
kong_http_status{code="301",service="google"} 2

# HELP kong_latency延迟，Kong中每个服务的总请求时间和上游延迟
#类型kong_latency直方图
kong_latency_bucket{type="kong",service="google",le="00001.0"} 1
kong_latency_bucket{type="kong",service="google",le="00002.0"} 1
.
.
.
kong_latency_bucket{type="kong",service="google",le="+Inf"} 2
kong_latency_bucket{type="request",service="google",le="00300.0"} 1
kong_latency_bucket{type="request",service="google",le="00400.0"} 1
.
.
kong_latency_bucket{type="request",service="google",le="+Inf"} 2
kong_latency_bucket{type="upstream",service="google",le="00300.0"} 2
kong_latency_bucket{type="upstream",service="google",le="00400.0"} 2
.
.
kong_latency_bucket{type="upstream",service="google",le="+Inf"} 2
kong_latency_count{type="kong",service="google"} 2
kong_latency_count{type="request",service="google"} 2
kong_latency_count{type="upstream",service="google"} 2
kong_latency_sum{type="kong",service="google"} 2145
kong_latency_sum{type="request",service="google"} 2672
kong_latency_sum{type="upstream",service="google"} 527

# HELP kong_latency_total Latency(由Kong添加的总延迟)、总请求时间和在Kong中聚合的所有服务的上游延迟
#类型kong_latency_total histogram
kong_latency_total_bucket{type="kong",le="00001.0"} 1
kong_latency_total_bucket{type="kong",le="00002.0"} 1
.
.
kong_latency_total_bucket{type="kong",le="+Inf"} 2
kong_latency_total_bucket{type="request",le="00300.0"} 1
kong_latency_total_bucket{type="request",le="00400.0"} 1
.
.
kong_latency_total_bucket{type="request",le="+Inf"} 2
kong_latency_total_bucket{type="upstream",le="00300.0"} 2
kong_latency_total_bucket{type="upstream",le="00400.0"} 2
.
.
.
kong_latency_total_bucket{type="upstream",le="+Inf"} 2
kong_latency_total_count{type="kong"} 2
kong_latency_total_count{type="request"} 2
kong_latency_total_count{type="upstream"} 2
kong_latency_total_sum{type="kong"} 2145
kong_latency_total_sum{type="request"} 2672
kong_latency_total_sum{type="upstream"} 527
# HELP kong_nginx_http_current_connections Number of HTTP connections
# TYPE kong_nginx_http_current_connections gauge
kong_nginx_http_current_connections{state="accepted"} 8
kong_nginx_http_current_connections{state="active"} 1
kong_nginx_http_current_connections{state="handled"} 8
kong_nginx_http_current_connections{state="reading"} 0
kong_nginx_http_current_connections{state="total"} 8
kong_nginx_http_current_connections{state="waiting"} 0
kong_nginx_http_current_connections{state="writing"} 1
# HELP kong_nginx_metric_errors_total Number of nginx-lua-prometheus errors
# TYPE kong_nginx_metric_errors_total counter
kong_nginx_metric_errors_total 0
```


## 访问指标
在大多数配置中，Kong Admin API将位于防火墙后面或需要设置为需要身份验证，以下是允许访问`/metrics`端点到Prometheus的几个选项。

1. Kong Enterprise用户可以使用Prometheus服务器用来访问度量标准数据的[RBAC用户](https://docs.konghq.com/enterprise/latest/setting-up-admin-api-rbac)来保护admin`/metrics`端点。还需要配置通过任何防火墙的访问。
2. 您可以通过Kong本身代理Admin API，然后使用插件来限制访问。例如，您可以创建路由`/metrics`端点，让Prometheus访问此端点以覆盖指标，同时阻止其他人访问它。具体配置方式取决于您的具体设置。阅读文档[保护Admin API](https://docs.konghq.com/latest/secure-admin-api/#kong-api-loopback)以获取详细信息。
3. 最后，您可以使用带有Kong的[自定义Nginx模板](https://docs.konghq.com/latest/configuration/#custom-nginx-configuration)，使用自定义服务器块在不同端口上提供内容。

	以下块是Kong可以使用的示例自定义nginx模板：
    ```
     server {
     server_name kong_prometheus_exporter;
     listen 0.0.0.0:9542; # can be any other port as well

     location / {
         default_type text/plain;
         content_by_lua_block {
             local serve = require "kong.plugins.prometheus.serve"
             serve.prometheus_server()
         }
     }

     location /nginx_status {
         internal;
         access_log off;
         stub_status;
     }
 	}
    ```






















