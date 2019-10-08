# AWS Lambda 插件

从Kong调用 [AWS Lambda](https://aws.amazon.com/lambda/)函数。它可以与其他请求插件结合使用以保护，管理或扩展功能。

> 注意：此插件与0.14.0之前的Kong版本和0.34之前的Kong Enterprise捆绑在一起的功能与此处记录的功能不同。
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

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=aws-lambda"  \
    --data-urlencode "config.aws_key=AWS_KEY" \
    --data-urlencode "config.aws_secret=AWS_SECRET" \
    --data "config.aws_region=AWS_REGION" \
    --data "config.function_name=LAMBDA_FUNCTION_NAME"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: aws-lambda
  service: {service}
  config: 
    aws_key: AWS_KEY
    aws_secret: AWS_SECRET
    aws_region: AWS_REGION
    function_name: LAMBDA_FUNCTION_NAME
```
在这两种情况下，`{service}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Route 上启用插件

**使用数据库：**

通过发出以下请求在 Route 上配置此插件：
```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=aws-lambda"  \
    --data-urlencode "config.aws_key=AWS_KEY" \
    --data-urlencode "config.aws_secret=AWS_SECRET" \
    --data "config.aws_region=AWS_REGION" \
    --data "config.function_name=LAMBDA_FUNCTION_NAME"
```

**不使用数据库：**

通过添加此部分在 Route 上配置此插件执行声明性配置文件：

```
plugins:
- name: aws-lambda
  route: {route}
  config: 
    aws_key: AWS_KEY
    aws_secret: AWS_SECRET
    aws_region: AWS_REGION
    function_name: LAMBDA_FUNCTION_NAME
```
在这两种情况下，，`{route}`是此插件配置将定位的 route 的`id`或`name`。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=aws-lambda" \
     \
    --data-urlencode "config.aws_key=AWS_KEY" \
    --data-urlencode "config.aws_secret=AWS_SECRET" \
    --data "config.aws_region=AWS_REGION" \
    --data "config.function_name=LAMBDA_FUNCTION_NAME"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: aws-lambda
  consumer: {consumer}
  config: 
    aws_key: AWS_KEY
    aws_secret: AWS_SECRET
    aws_region: AWS_REGION
    function_name: LAMBDA_FUNCTION_NAME
```
在这两种情况下，`{consumer`}都是此插件配置将定位的`Consumer`的`id`或`username`。  
您可以组合`consumer_id`和`service_id` 。 
在同一个请求中，进一步缩小插件的范围。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`aws-lambda`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.aws_key` | | 调用功能时要使用的AWS密钥凭证。 | 
| `config.aws_secret`  |  | 调用功能时要使用的AWS秘密凭证 |
| `config.aws_region`  |  | Lambda函数所在的AWS区域。支持的区域是：`us-east-1`,`us-east-2`, `ap-northeast-1`, `ap-northeast-2`, `ap-southeast-1`, `ap-southeast-2`, `eu-central-1`, `eu-west-1` |
| `config.function_name` | | 要调用的AWS Lambda函数名称 |
| `config.qualifier` <br> *optional* | |  调用功能时要使用的 [Qualifier ](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html#API_Invoke_RequestSyntax)。 |
| `config.invocation_type`  <br> *optional*  | `RequestResponse` | 调用函数时要使用的 [InvocationType](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html#API_Invoke_RequestSyntax)。可用类型为 `RequestResponse`，`Event`，`DryRun`  |
| `config.log_type`  <br> *optional*   | `Tail` |  调用函数时要使用的[LogType](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html#API_Invoke_RequestSyntax)。默认情况下，不支持`none`和`Tail` |
| `config.timeout`  <br> *optional*  | `60000` | 调用该函数时的可选超时（以毫秒为单位）  |
| `config.keepalive`  <br> *optional* | `60000` | 可选值（以毫秒为单位），用于定义空闲连接在关闭之前将存活多长时间  |
| `config.unhandled_status` <br> *optional*  | `200`,`202` 或 `204` | [Unhandled Function Error](https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html#API_Invoke_ResponseSyntax)时使用的响应状态代码（而不是默认的`200`、`202`或`204`）  |
| `config.forward_request_body` <br> *optional*  | `false` |  一个可选值，用于定义是否在JSON编码请求的`request_body`字段中发送请求正文。如果可以解析正文参数，则将在请求的单独的`request_body_args`字段中发送它们。正文参数可以针对`application/json`，`application/x-www-form-urlencoded`和`multipart/form-data`内容类型进行解析。 |
| `config.forward_request_headers` <br> *optional*  |`false` | 一个可选值，用于定义是否将原始HTTP请求标头作为映射发送到JSON编码请求的`request_headers`字段中。  |
| `config.forward_request_method` <br> *optional*  |`false` | 一个可选值，用于定义是否在JSON编码请求的`request_method`字段中发送原始HTTP请求方法动词。  |
| `config.forward_request_uri`  <br> *optional* |`false` | 一个可选值，用于定义是否在JSON编码请求的`request_uri`字段中发送原始HTTP请求URI。请求URI参数（如果有）将在JSON主体的单独的`request_uri_args`字段中发送。  |
| `config.is_proxy_integration`  <br> *optional* |`false` | 一个可选值，它定义是否将从Lambda接收的响应格式转换为此格式。请注意，未实现参数`isBase64Encoded`。  |


**提醒：** 默认情况下，curl将发送带有`application/x-www-form-urlencoded` MIME类型的有效负载，该负载自然会由Kong进行URL解码。
为确保正确解码可能出现在您的AWS密钥或机密中的特殊字符（如`+`），您必须对其进行URL编码，因此如果使用curl，请使用`--data-urlencode`。
这种方法的替代方法是使用其他MIME类型（例如`application/json`）发送有效负载，或使用其他HTTP客户端。

### 发送参数

与请求一起发送的任何表单参数也将作为参数发送到AWS Lambda函数。

### 已知的问题

**使用伪造的上游服务**

使用AWS Lambda插件时，响应将由插件本身返回，而无需将请求代理到任何上游服务。
这意味着服务的`host`, `port`, `path`属性将被忽略，但仍必须为由Kong验证的实体指定。
主机属性尤其必须是IP地址，或者是由名称服务器解析的主机名。

**响应插件**

系统中存在一个已知限制，该限制会阻止执行某些响应插件。
我们计划将来删除此限制。


## 分步指南












