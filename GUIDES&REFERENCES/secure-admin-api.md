# 保证 Admin API 安全

## 简介

Kong的Admin API为 Services, Routes, Plugins, Consumers, 和 Credentials的管理和配置提供RESTful接口。由于此API允许完全控制Kong，因此保护此API以防止不必要的访问非常重要。本文档介绍了一些保护Admin API的方法。

## 网络层访问限制

### 最小监听痕迹

默认情况下，自0.12.0版本开始，Kong将仅接受来自本地接口的请求，如其默认的`admin_listen`的值所指定：
```
admin_listen = 127.0.0.1:8001
```
如果更改此值，请始终确保将侦听范围保持在最低限度，以避免将管理API暴露给第三方，不然可能严重损害整个群集的安全性。例如，通过使用诸如`0.0.0.0:8001`之类的值，**避免将Kong绑定到所有接口**。

## 3/4层网络控制

如果Admin API必须在localhost接口之外公开，则网络安全最佳实践要求尽可能限制网络层访问。可以考虑一个Kong监听专用网络接口的环境，但只能通过IP范围的一小部分来访问。在这种情况下，基于主机的防火墙（例如iptables）在限制进入流量范围方面大有作用。例如：
```
# 假设Kong正在监听下面定义的地址，定义为一个 /24 CIDR（无类别域间路由，Classless Inter-Domain Routing）块，
# 此范围内只有少数几个主机应该有权访问；

grep admin_listen /etc/kong/kong.conf
admin_listen 10.10.10.3:8001

# 显式地允许端口8001上的TCP数据包来自Kong节点本身
# ，如果没有从节点发送Admin API请求，则没有必要这样做
iptables -A INPUT -s 10.10.10.3 -m tcp -p tcp --dport 8001 -j ACCEPT

# 从以下地址明确允许端口8001上的TCP数据包
iptables -A INPUT -s 10.10.10.4 -m tcp -p tcp --dport 8001 -j ACCEPT
iptables -A INPUT -s 10.10.10.5 -m tcp -p tcp --dport 8001 -j ACCEPT

# 丢弃端口8001上的所有TCP数据包，而不是上面的IP列表
iptables -A INPUT -m tcp -p tcp --dport 8001 -j DROP

```

鼓励使用其他控件，例如在网络设备级别应用的类似ACL，但不在本文档的讨论范围之内。

## kong Api 回路

Kong的路由设计允许它作为Admin API本身的代理。通过这种方式，Kong本身可用于为Admin API提供细粒度的访问控制。这样的环境需要引导一个新的Service，该Service将`admin_liste`n地址定义为服务的`url`。例如：
```
# 假设Kong已经将admin_listen定义为127.0.0.1:8001, 
# 我们想要通过url `/admin-api`来访问Admin API

curl -X POST http://localhost:8001/services \
  --data name=admin-api \
  --data host=localhost \
  --data port=8001

curl -X POST http://localhost:8001/services/admin-api/routes \
  --data paths[]=/admin-api

# 我们现在可以通过代理服务器透明地访问Admin API
curl localhost:8000/admin-api/apis
{
   "data":[
      {
         "uris":[
            "\/admin-api"
         ],
         "id":"653b21bd-4d81-4573-ba00-177cc0108dec",
         "upstream_read_timeout":60000,
         "preserve_host":false,
         "created_at":1496351805000,
         "upstream_connect_timeout":60000,
         "upstream_url":"http:\/\/localhost:8001",
         "strip_uri":true,
         "https_only":false,
         "name":"admin-api",
         "http_if_terminated":true,
         "upstream_send_timeout":60000,
         "retries":5
      }
   ],
   "total":1
}
```

从这里开始，只需像往常一样对任何其他Kong API应用所需的特定于Kong的安全控件（例如 [basic](https://docs.konghq.com/plugins/basic-authentication/) 或 [key authentication](https://docs.konghq.com/plugins/key-authentication) ， [IP restrictions](https://docs.konghq.com/plugins/ip-restriction), 或者 [access control lists](https://docs.konghq.com/plugins/acl)）。

## 自定义Nginx配置

Kong与Nginx紧密结合，作为HTTP守护进程，因此可以集成到具有自定义Nginx配置的环境中。通过这种方式，具有复杂 security/access 控制要求的用例可以使用 Nginx/OpenResty 的全部功能来构建 server/location 块以根据需要容纳Admin API。除了提供可以构建custom/complex 安全控件的OpenResty环境之外，这允许此类环境利用本机Nginx授权和身份验证机制，ACL模块等。有关将Kong集成到自定义Nginx配置的更多信息，请参阅[自定义Nginx配置和嵌入Kong](https://docs.konghq.com/1.1.x/configuration/#custom-nginx-configuration)。

## 基于角色的访问控制

> 此功能仅适用于企业订阅。

企业用户可以配置基于角色的访问控制，以保护对Admin API的访问。RBAC允许基于用户角色和权限模型对资源访问进行细粒度控制。用户被分配到一个或多个角色，每个角色又拥有一个或多个权限，授予或拒绝对特定资源的访问权限。通过这种方式，可以强制执行对特定Admin API资源的细粒度控制，同时进行扩展以允许复杂的特定于案例的用途。

如果您不是Kong Enterprise客户，可以通过[联系我们](https://docs.konghq.com/enterprise)来咨询我们的企业产品。




