# 标签

> 本文原文链接：https://docs.konghq.com/1.1.x/admin-api/#service-object

标签是与Kong中的实体相关联的字符串。每个标记必须由一个或多个字母数字字符组成，`_`， `-` ，`.` 或者 `~`。

在创建或编辑时，大多数核心实体可以通过其`tags`属性进行标记。

标签也可用于通过`?tags`标签查询字符串参数过滤核心实体。

例如：如果您通常通过以下方式获取所有服务的列表：

```
GET /services
```

您可以通过执行以下操作获取所有服务标记`example`的列表：
```
GET /services?tags=example
```

同样，如果您想过滤服务，以便只获得标记为`example`和`admin`的服务，您可以这样做：
```
GET /services?tags=example,admin
```

最后，如果您想过滤服务标记的`example`或`admin`，您可以使用：
```
GET /services?tags=example/admin
```

一些说明：

- 在单个请求中可以同时查询最多5个标签`,`或者`/`
- 不支持混合运算符：如果您尝试使用`,`和`/`在同一个查询字符串中混合，则会收到错误。
- 从命令行使用它们时，您可能需要引用和/或转义某些字符。
- 外键关系端点不支持按标记过滤。例如，在诸如`GET/services/foo/routes?tags=a,b`的请求中将忽略`tags`参数。
- 如果更改或删除`tags`参数，则无法保证`offset`参数有效。

## 列出所有标签

返回系统中所有标记的分页列表。

实体列表不会限制为单个实体类型：标记有标签的所有实体都将出现在此列表中。

如果实体标记有多个标记，则该实体的`entity_id`将在结果列表中出现多次。
同样，如果多个实体已使用相同的标记进行标记，则该标记将显示在此列表的多个项目中。

```
GET /tags
```

响应
```
HTTP 200 OK
```
```
{
    {
      "data": [
        { "entity_name": "services",
          "entity_id": "acf60b10-125c-4c1a-bffe-6ed55daefba4",
          "tag": "s1",
        },
        { "entity_name": "services",
          "entity_id": "acf60b10-125c-4c1a-bffe-6ed55daefba4",
          "tag": "s2",
        },
        { "entity_name": "routes",
          "entity_id": "60631e85-ba6d-4c59-bd28-e36dd90f6000",
          "tag": "s1",
        },
        ...
      ],
      "offset" = "c47139f3-d780-483d-8a97-17e9adc5a7ab",
      "next" = "/tags?offset=c47139f3-d780-483d-8a97-17e9adc5a7ab",
    }
}
```

## 按标签列出实体ID

返回已使用指定标记标记的实体。

实体列表不会限制为单个实体类型：标记有标签的所有实体都将出现在此列表中。

```
GET /tags/:tags
```

响应
```
HTTP 200 OK
```

```
{
    {
      "data": [
        { "entity_name": "services",
          "entity_id": "c87440e1-0496-420b-b06f-dac59544bb6c",
          "tag": "example",
        },
        { "entity_name": "routes",
          "entity_id": "8a99e4b1-d268-446b-ab8b-cd25cff129b1",
          "tag": "example",
        },
        ...
      ],
      "offset" = "1fb491c4-f4a7-4bca-aeba-7f3bcee4d2f9",
      "next" = "/tags/example?offset=1fb491c4-f4a7-4bca-aeba-7f3bcee4d2f9",
    }
}
```







