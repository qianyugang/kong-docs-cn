# Kong  Gateway 3.6.x 正式发布，较大改变！

在升级之前，请审查此版本和之前版本中的任何配置或重大更改，这些更改可能会影响
当前的安装。

# 重大更改和弃用项

# 通用项

如果您在自定义代码中使用 `ngx.var.http_*` 来访问 HTTP 头，那么当同一个头部在单个请求中多次使用时，该变量的行为稍有变化。以前，它只会返回第一个值；现在它会返回所有值，以逗号分隔。Kong Gateway PDK header 获取和设置工作方式保持不变。

# Wasm

为了避免与其他与Wasm相关的`nginx.conf`指令产生歧义，Wasm `shm_kv` nginx.conf指令的前缀已从 `nginx_wasm_shm_` 更改为`nginx_wasm_shm_kv_` 。Kong/kong/pull/11919

# Admin API

对于consumer groups（`/consumer_groups`）和consumers（`/consumers`）的接口，现在它们会返回分页结果。列表的 JSON 的 key 已经从 `consumer_groups` 或 `consumers` 更改为 `data`。

# 配置更改

`dns_no_sync` 选项的默认值已经更改为关闭`off`。

# TLS 变更

## 3.6.0

最近的 OpenResty 升级包括 TLS 1.3，并弃用了 TLS 1.1。如果您仍需要支持 TLS 1.1，请将 `ssl_cipher_suite` 设置为 `old`。

在 OpenSSL 3.2 中，默认的 SSL/TLS 安全级别已从 1 更改为 2。这意味着安全级别被设置为 112 位安全。因此，以下操作被禁止：

- RSA、DSA 和 DH 密钥长度小于 2048 bits
- ECC 密钥长度小于 224 bits
- 任何使用 RC4 的密码套件
- SSL 版本 3 此外，压缩已被禁用。

## 3.6.1

现在在OpenSSL 3.x中默认禁用 TLSv1.1 和更低版本。

## 插件变更

- ACME (acme), Rate Limiting (rate-limiting), Response Rate Limiting (response-ratelimiting)插件：跨插件标准化的 Redis 配置。Redis 配置现在遵循一个通用的模式，该模式在其他插件之间共享。
- Azure Functions (azure-functions)：Azure Functions 插件现在删除了 upstream/request  URI，并且仅在请求 Azure API 时使用 routeprefix 配置字段来构造请求路径。 
- OAS Validation (oas-validation)：在内容类型不是 application/json 时绕过模式验证。
- Proxy Cache Advanced (proxy-cache-advanced）：已删除 `proxy-cache-advanced/migrations/001_035_to_050.lua` 文件，该文件阻止了从 OSS 到 Enterprise 的迁移。这是一个重大更改，仅当您从 Kong Gateway 版本 0.3.5 到 0.5.0 之间升级时才会生效。
- SAML (saml)：调整了 SAML 插件的优先级为 1010，以纠正 SAML 插件与其他基于customer的插件之间的集成。

## 已知问题

以下是可能在未来版本中修复的已知问题列表。

### 操作系统要求

Kong Gateway 3.6.0.0 需要更高的 ulimit 才能正常运行。如果 ulimit 设置为 1024 或更低，它将无法正确启动。我们建议将您的操作系统的 ulimit 设置至少为 4096。

### 在3.6.1.0中修复的问题

虽然通常建议为 Kong Gateway 设置更高的 ulimit，但您可以升级到 3.6.1.0，再次从默认值 1024 开始启动。


## HTTP/2 对于读取 request body 的插件需要 Content-Length

Kong 3.6.x 引入了一个对于读取传入请求主体的插件的回归。Clients 必须指定一个表示请求主体长度的 Content-Length 头部。如果不包含此头部，或者依赖 Transfer-Encoding: chunked，将导致 HTTP 响应的错误代码为 500。

影响如下插件：

- jq
- Request Size Limiting
- Request Validator
- AI Request Transformer
- Request Transformer
- Request Transformer Advanced

Kong官方正在寻找解决方案。
