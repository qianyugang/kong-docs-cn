# 网络&防火墙

## 简介

在本节中，您将找到有关Kong的推荐网络和防火墙设置的摘要。

## 端口

Kong对于多个目标使用多连接。
- 代理
- admin api

### 代理

代理端口是Kong接收其传入流量的地方。有两个端口具有以下默认值：

- `8000`：用于代理HTTP流量
- `8443`：用于代理HTTPS流量

有关HTTP/HTTPS代理监听选项的更多详细信息，请参阅[proxy_listen](https://docs.konghq.com/1.1.x/configuration/#proxy_listen)。
对于生产环境，通常将HTTP和HTTPS监听端口更改为`80`和`443`。

Kong还可以代理 TCP/TLS 流。默认情况下禁用流代理。有关流代理侦听选项以及如何启用它的更多详细信息，请参阅[stream_listen](https://docs.konghq.com/1.1.x/configuration/#stream_listen)（如果您计划代理除 HTTP/HTTPS 流量之外的任何其他内容）。

通常，代理端口是应该为您的客户端提供的唯一端口。

### Admin Api

这是Kong公开其管理API的端口。因此，在生产中，该端口应采用防火墙以防止未经授权的访问。

- `8001`端口提供给Kong的Admin API，您可以使用HTTP请求来管理Kong。请参阅[admin_listen](https://docs.konghq.com/1.1.x/configuration/#admin_listen)。
- `8444`端口提供给Kong的Admin API，您可以使用HTTPS请求来管理Kong，请参阅[admin_listen](https://docs.konghq.com/1.1.x/configuration/#admin_listen)和`ssl`后缀。

## 防火墙

以下是推荐的防火墙设置：
- Kong后面的上游服务将通过[proxy_listen](https://docs.konghq.com/1.1.x/configuration/#proxy_listen) interface/port 值提供。根据您要授予上游服务的访问级别配置这些值。
- 如果要将Admin API绑定到对外开放的界面（通过[admin_listen](https://docs.konghq.com/1.1.x/configuration/#admin_listen)），请将其保护为仅允许受信任的客户端访问Admin API。另请参阅[保证 Admin API 安全](https://docs.konghq.com/1.1.x/secure-admin-api)。
- 您的代理需要为您配置的任何 HTTP/HTTPS和TCP/TLS流监听器添加规则。例如，如果您希望Kong管理端口`4242`上的流量，则您的防火墙将需要允许上述端口上的流量。

### 透明代理

值得一提的是，`transparent`透明监听选项可以应用于[proxy_listen](https://docs.konghq.com/1.1.x/configuration/#proxy_listen)和[tream_listen](https://docs.konghq.com/1.1.x/configuration/#stream_listen)配置。使用`iptables`（Linux）或`pf`（macOS / BSD）或硬件 路由器/交换机 等数据包过滤，您可以为TCP数据包指定预路由或重定向规则，以便修改原始目标地址和端口。例如，目标地址为`10.0.0.1`，目标端口为`80`的HTTP请求可以在端口`8000`重定向到`127.0.0.1`。为了使它工作起来，您需要（使用Linux）将`transparent`透明监听选项添加到Kong代理，`proxy_listen=8000 transparent`。这允许Kong看到请求的原始目的地（`10.0.0.1:80`），即使Kong实际上没有直接监听到它。有了这些信息，Kong可以正确地路由请求。透明监听选项只应与Linux一起使用。macOS/BSD 只允许透明代理而不允许透明侦听选项。使用Linux，您可能还需要以root用户身份启动Kong或为可执行文件设置所需的功能。





















