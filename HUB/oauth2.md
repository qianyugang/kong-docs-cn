# OAuth 2.0 Authentication 认证插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/oauth2/

使用[授权码模式(Authorization Code Grant)](https://tools.ietf.org/html/rfc6749#section-4.1)，[客户端凭证模式( Client Credentials)](https://tools.ietf.org/html/rfc6749#section-4.4)，[简化授权模式(Implicit Grant)](https://tools.ietf.org/html/rfc6749#section-4.2)或[密码模式(Resource Owner Password Credentials Grant)](https://tools.ietf.org/html/rfc6749#section-4.3)授予流添加OAuth 2.0身份验证层。

> 注意：根据OAuth2规范，此插件要求通过HTTPS提供底层服务。为避免混淆，我们建议您将用于服务底层服务的Route配置为仅接受HTTPS流量（通过其`protocols`属性）。

> 注意：此插件的功能与0.12.0之前的Kong版本捆绑在一起，与此处记录的不同。有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。


## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式**不兼容**。

为了让它正常工作，插件需要生成和删除令牌，并将这些更改提交到数据库，这与无DB的数据库不兼容。除此之外，其Admin API端点还为令牌和凭据提供了多种POST，PATCH，PUT和DELETE方法。他们都不会在无DB的情况下工作。














