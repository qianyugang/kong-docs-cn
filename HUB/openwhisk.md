# Apache OpenWhisk

该插件调用[OpenWhisk操作](https://github.com/openwhisk/openwhisk/blob/master/docs/actions.md)。
它可以与其他请求插件结合使用以保护，管理或扩展功能。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。


## 安装

您可以使用LuaRocks软件包管理器来安装插件
```
$ luarocks install kong-plugin-openwhisk
```

或从[源码](https://github.com/Kong/kong-plugin-openwhisk)安装它。
有关插件安装的更多信息，请参阅[文档插件开发-安装/卸载插件](https://docs.konghq.com/latest/plugin-development/distribution/)


## 配置