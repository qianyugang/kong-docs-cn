# 速率限制

速率限制插件就是限定了开发人员在给定的秒，分钟，小时，天，月或年中可以进行的HTTP请求数。如果底层  Service/Route （或已弃用的API实体）没有身份验证层，则将使用Client IP地址，否则，如果已配置身份验证插件，则将使用Consumer。

> 注意：此插件的功能与0.13.1之前的Kong版本和0.32之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式部分兼容。

该插件将使用`local`策略（不使用数据库）或`redis`策略（使用独立的Redis，因此它与无DB的兼容）运行良好。该插件不适用于`cluster`策略，该策略需要写入数据库。

## 在 Service 上启用插件

## 在 Route 上启用插件

## 在 Consumer 上启用插件

## 全局插件

## 参数

## 给客户端发送headers

## 实施注意事项

## 每笔交易都很重要

## 后端保护













