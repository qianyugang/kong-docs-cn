# SNI对象

> 本文原文链接：https://docs.konghq.com/1.1.x/admin-api/#sni-objects

SNI对象表示主机名与证书的多对一映射。也就是说，证书对象可以有许多与之关联的主机名；当Kong收到SSL请求时，它使用Client Hello中的SNI字段根据与证书关联的SNI查找证书对象。

SNI可以通过[标签进行标记和过滤](https://docs.konghq.com/1.1.x/admin-api/#tags)。

```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"d044b7d4-3dc2-4bbc-8e9f-6b7a69416df6"}
}
```

## 添加SNI

### 创建一个SNI

```
POST /snis
```

### 创建与特定证书关联的SNI

```
POST /certificates/{certificate name or id}/snis
```

| 参数 | 描述 | 
| ---- | ---- |
| `certificate name or id` <br> *required* | 应与新创建的SNI关联的证书的唯一标识符或名称属性。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要与给定证书关联的SNI名称。|
| `tags` <br> optional | 与SNI关联的可选字符串集，用于分组和过滤。|
| `certificate` | 用于将SNI主机名与表单编码关联的证书的id（UUID），符号是`certificate.id=<certificate_id>` ,使用JSON，`"certificate":{"id":"<certificate_id>"}` |

*响应*

```
HTTP 201 Created
```

```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"d044b7d4-3dc2-4bbc-8e9f-6b7a69416df6"}
}
```

## SNIs 列表

### 列出所有SNIs

```
GET /snis
```

### 列出与特定证书相关的SNI

```
GET /certificates/{certificate name or id}/snis
```

| 参数 | 描述 | 
| ---- | ---- |
| `certificate name or id` <br> *required* | 应与新创建的SNI关联的证书的唯一标识符或名称属性。|

*响应*

```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a9b2107f-a214-47b3-add4-46b942187924",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"04fbeacf-a9f1-4a5d-ae4a-b0407445db3f"}
}, {
    "id": "43429efd-b3a5-4048-94cb-5cc4029909bb",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["admin", "high-priority", "critical"],
    "certificate": {"id":"d26761d5-83a4-4f24-ac6c-cff276f2b79c"}
}],

    "next": "http://localhost:8001/snis?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

## 更新 SNI

## 更新一个 SNI

```
PATCH /snis/{name or id}
```

| 参数 | 描述 | 
| ---- | ---- |
| `name or id` <br> *required* | 要更新的唯一标识符或SNI的名称。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要与给定证书关联的SNI名称。|
| `tags` <br> optional | 与SNI关联的可选字符串集，用于分组和过滤。|
| `certificate` | 用于将SNI主机名与表单编码关联的证书的id（UUID），符号是`certificate.id=<certificate_id>` ,使用JSON，`"certificate":{"id":"<certificate_id>"}` |


*响应*

```
HTTP 200 OK
```

```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"d044b7d4-3dc2-4bbc-8e9f-6b7a69416df6"}
}

```


## 更新或创建 SNI

## 更新或创建一个 SNI

```
PUT /snis/{name or id}
```

| 参数 | 描述 | 
| ---- | ---- |
| `name or id` <br> *required* | 要更新的唯一标识符或SNI的名称。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要与给定证书关联的SNI名称。|
| `tags` <br> optional | 与SNI关联的可选字符串集，用于分组和过滤。|
| `certificate` | 用于将SNI主机名与表单编码关联的证书的id（UUID），符号是`certificate.id=<certificate_id>` ,使用JSON，`"certificate":{"id":"<certificate_id>"}` |


使用正文中指定的定义在请求的资源下插入（或替换）SNI。SNI将通过`name or id`属性进行标识。

当`name or id`属性具有UUID的结构时，插入/替换的SNI将由其`id`标识。否则将通过其`name`识别。

在没有指定`id`的情况下创建新的SNI（既不在URL中也不在正文中），它将自动生成。

请注意，不允许在URL中指定`name`，也不允许在请求正文中指定其他名称。

## 删除 SNI

### 删除一个 SNI

```
DELETE /snis/{name or id}
```

| 参数 | 描述 | 
| ---- | ---- |
| `name or id` <br> *required* | 要更新的唯一标识符或SNI的名称。|

*响应*

```
HTTP 204 No Content
```














