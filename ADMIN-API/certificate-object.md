# 证书对象

> 本文原文链接：https://docs.konghq.com/1.1.x/admin-api/#certificate-object

证书对象表示SSL证书的 certificate/private 对。Kong使用这些对象来处理加密请求的 SSL/TLS 终止。证书可选地与SNI对象相关联，以将 cert/key 对与一个或多个主机名绑定。

证书可以通过[标签进行标记和过滤](https://docs.konghq.com/1.1.x/admin-api/#tags)。

```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```

## 添加证书

### 创建一个证书

```
POST /certificates
```

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `cert` | PEM编码格式的SSL密钥对的公共证书。 | 
| `key` |  SSL密钥对的PEM编码格式私钥。 | 
| `tags` <br> *optional* |  与证书关联的可选字符串集，用于分组和过滤。 | 
| `snis` <br> *shorthand-attribute* | 与此证书关联的零个或多个主机名的数组，如SNI。这是一个糖参数，为方便起见，它将创建一个SNI对象并将其与此证书相关联。 | 

*响应*

```
HTTP 201 Created
```
```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```


## 证书列表

### 列出所有证书

```
GET /certificates
```

*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "02621eee-8309-4bf6-b36b-a82017a5393e",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}, {
    "id": "66c7b5c4-4aaf-4119-af1e-ee3ad75d0af4",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/certificates?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```


## 查询证书

### 查询证书

```
GET /certificates/{certificate id}
```

| 参数 | 描述 |
| ---- | ---- |
| `certificate id` <br> *required* | 要查询的证书的唯一标识符。 | 

*响应*

```
HTTP 200 OK
```
```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```

## 更新证书

### 更新一个证书

```
PATCH /certificates/{certificate id}
```

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `cert` | PEM编码格式的SSL密钥对的公共证书。 | 
| `key` |  SSL密钥对的PEM编码格式私钥。 | 
| `tags` <br> *optional* |  与证书关联的可选字符串集，用于分组和过滤。 | 
| `snis` <br> *shorthand-attribute* | 与此证书关联的零个或多个主机名的数组，如SNI。这是一个糖参数，为方便起见，它将创建一个SNI对象并将其与此证书相关联。 | 

*响应*

```
HTTP 200 OK
```
```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```

## 更新或创建证书

### 更新或创建一个证书

```
PUT /certificates/{certificate id}
```

*请求体*

| 参数 | 描述 |
| ---- | ---- |
| `cert` | PEM编码格式的SSL密钥对的公共证书。 | 
| `key` |  SSL密钥对的PEM编码格式私钥。 | 
| `tags` <br> *optional* |  与证书关联的可选字符串集，用于分组和过滤。 | 
| `snis` <br> *shorthand-attribute* | 与此证书关联的零个或多个主机名的数组，如SNI。这是一个糖参数，为方便起见，它将创建一个SNI对象并将其与此证书相关联。 | 

使用正文中指定的定义在所请求的资源下插入（或替换）证书。证书将通过`name or id`属性标识。

当`name or id`属性具有UUID的结构时，插入/替换的证书将由其`id`标识。否则将通过其`name`识别。

在创建新证书而不指定`id`（既不在URL中也不在body中）时，它将自动生成。

请注意，不允许在URL中指定`name`，也不允许在请求正文中指定其他名称。

*响应*
```
HTTP 201 Created or HTTP 200 OK
```

请参阅POST和PATCH响应。

## 删除证书

### 删除一个证书

```
DELETE /certificates/{certificate id}
```

| 参数 | 描述 |
| ---- | ---- |
| `certificate id` <br> *required* | 要查询的证书的唯一标识符。 | 

*响应*
```
HTTP 204 No Content
```


























