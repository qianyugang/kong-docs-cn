# Consumer 消费者

Consumer对象表示Service服务的使用者或用户。您可以依靠Kong作为主数据存储，也可以将使用者列表与数据库映射，以保持Kong与现有主数据存储之间的一致性。

Consumer消费者可以通过[标签进行标记和过滤](https://docs.konghq.com/1.1.x/admin-api/#tags)。
```
{
    "id": "127dfc88-ed57-45bf-b77a-a9d3a152ad31",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}
```

## 添加一个 Consumer

### 创建一个 Consumer

```
POST /consumers
```
*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `username` <br> *semi-optional* |  消费者的唯一用户名。您必须将此字段或`custom_id`与请求一起发送。|
| `custom_id` <br> *semi-optional* | 用于存储消费者的现有唯一ID的字段 - 对于将Kong与现有数据库中的用户进行映射非常有用。您必须使用此请求发送此字段或`username`。 | 
| `tags` <br> *optional* | 与Consumer关联的一组可选字符串，用于分组和过滤。|

*响应*
```
HTTP 201 Created
```
```
{
    "id": "127dfc88-ed57-45bf-b77a-a9d3a152ad31",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}
```


## 查询 Consumer

### 查询Consumer
```
GET /consumers/{username or id}
```
| 参数 | 描述 |
| ---- | ---- |
| `username or id` <br> *required* |  要检索的Consumer的唯一标识符或用户名。|

### 查询与特定插件关联的Consumer

```
GET /plugins/{plugin id}/consumer
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> *required* |  与要检索的Consumer关联的插件的唯一标识符。|

*响应*
```
{
    "id": "127dfc88-ed57-45bf-b77a-a9d3a152ad31",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}

```

## 更新 Consumer

### 更新 Consumer
```
PATCH /consumers/{username or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `username or id` <br> *required* |  要检索的Consumer的唯一标识符或用户名。|

### 更新与特定插件关联的Consumer

```
PATCH /plugins/{plugin id}/consumer
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> *required* |  与要检索的Consumer关联的插件的唯一标识符。|

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `username` <br> *semi-optional* |  消费者的唯一用户名。您必须将此字段或`custom_id`与请求一起发送。|
| `custom_id` <br> *semi-optional* | 用于存储消费者的现有唯一ID的字段 - 对于将Kong与现有数据库中的用户进行映射非常有用。您必须使用此请求发送此字段或`username`。 | 
| `tags` <br> *optional* | 与Consumer关联的一组可选字符串，用于分组和过滤。|

*响应*
```
HTTP 200 OK
```
```
{
    "id": "127dfc88-ed57-45bf-b77a-a9d3a152ad31",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}
```

## 更新或创建Consumer

### 更新或创建Consumer

```
PUT /consumers/{username or id}
```
| 参数 | 描述 |
| ---- | ---- |
| `username or id` <br> *required* |  要检索的Consumer的唯一标识符或用户名。|

### 创建或更新与特定插件关联的Consumer

| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> *required* |  与要检索的Consumer关联的插件的唯一标识符。|

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `username` <br> *semi-optional* |  消费者的唯一用户名。您必须将此字段或`custom_id`与请求一起发送。|
| `custom_id` <br> *semi-optional* | 用于存储消费者的现有唯一ID的字段 - 对于将Kong与现有数据库中的用户进行映射非常有用。您必须使用此请求发送此字段或`username`。 | 
| `tags` <br> *optional* | 与Consumer关联的一组可选字符串，用于分组和过滤。|

使用正文中指定的定义在请求的资源下插入（或替换）Consumer。将通过`username or id`属性标识Consumer。

当`username or id`属性具有UUID的结构时，插入/替换的Consumer将由其`id`标识。否则将通过其`username`识别。

在创建新的Consumer而不指定`id`（既不在URL中也不在body中）时，它将自动生成。

请注意，不允许在URL中指定`username`，在请求正文中指定其他用户名。

*响应*

```
HTTP 201 Created or HTTP 200 OK
```

## 删除 Consumer

### 删除Consumer
```
DELETE /consumers/{username or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `username or id` <br> *required* |  要检索的Consumer的唯一标识符或用户名。|

*响应*

```
HTTP 204 No Content
```








