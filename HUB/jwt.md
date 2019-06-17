# JWT 插件

验证包含HS256或RS256签名JSON Web令牌的请求（如[RFC 7519](https://tools.ietf.org/html/rfc7519)中所述）。每个消费者都将拥有JWT凭证（公钥和密钥），这些凭证必须用于签署其JWT。然后可以通过令牌传递如下：

- 查询字符串参数
- 一个 cookie
- 或者带有 Authorization 的头

如果验证了令牌的签名，Kong会将请求代理到您的上游服务，否则将丢弃该请求。Kong还可以对RFC 7519（exp和nbf）的一些注册声明进行验证。

## 相关术语

- `plugin`:在请求被代理到上游API之前或之后，在Kong内部执行操作的插件
- `Service`:表示外部上游API或微服务的Kong实体。
- `Route`:Kong实体表示将下游请求映射到上游服务的方法
- `upstream service`:这是指位于Kong后面的您自己的API /服务，转发客户端请求
- `API`:上游服务的实例。在[CE 0.13.0](https://github.com/Kong/kong/blob/master/CHANGELOG.md#0130---20180322) and [EE 0.32](https://docs.konghq.com/enterprise/changelog/#0-32)版本后被弃用，替换为service

## 配置

### 在service上启用插件
通过发出以下请求在[service](https://docs.konghq.com/latest/admin-api/#service-object)上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=jwt" 
```

- `service`：此插件将要代理的service的id或者name

### 在路由上启用插件
通过以下请求在[router](https://docs.konghq.com/latest/admin-api/#Route-object)上配置:
```
$ curl -X POST http://kong:8001/routes/{route_id}/plugins \
    --data "name=jwt"
```

- `rouer_id`:将要启动插件的路由id

### 在API上启用插件
如果您正在使用老版本的	Kong（在[CE 0.13.0](https://github.com/Kong/kong/blob/master/CHANGELOG.md#0130---20180322) and [EE 0.32](https://docs.konghq.com/enterprise/changelog/#0-32)版本后被弃用，替换为service） 。您可以通过发出以下请求在此类API之上配置此插件：

```
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=jwt" 
```

- `api`:此插件配置将定位的API的ID或名称。

### 全局插件

可以使用`http://kong:8001/plugins/`配置所有插件，一个插件跟任何service ，router， api 或者 Consumer 没有强关联，都可以考虑把它做成全局插件，将在每个请求上运行，有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)相关文档。

### 参数
以下是可在此插件配置中使用的所有参数的列表：

| 参数名称 | 默认值 | 描述 |
| -------- | ------ | ---- |
| `name` |  | 要使用的插件的名称，在本例中为`jwt` |
| `service_id` |  | 此插件将定位的服务的ID。|
| `route_id` |  | 此插件将定位的路由的ID。 |
| `enabled` | `true` | 是否将应用此插件 |
| `api_id` |  | 此插件配置将定位的API的ID或名称。(在[CE 0.13.0](https://github.com/Kong/kong/blob/master/CHANGELOG.md#0130---20180322) and [EE 0.32](https://docs.konghq.com/enterprise/changelog/#0-32)版本后被弃用，替换为service) | 
| `config.uri_param_names`（可选）| `jwt` | Kong用来查询JWT字符串的uri参数列表。 |  
| `config.cookie_names`（可选）| | Kong用来查询JWT字符串的ucookies参数列表。   | 
| `config.claims_to_verify`（可选） | | 需要被验证的声明（也就是payload），支持的值为 `exp`, `nbf` |
| `config.key_claim_name`（可选）| `iss` | 需要被验证的key标示的名称，从0.13.1开始插件将尝试按此顺序从JWT有效负载和标题中读取此声明。 |
| `config.secret_is_base64`（可选）| `false` | 如果为true，则插件假定凭证的秘密为base64编码。您需要为您的消费者创建base64编码的秘密，并使用原始密码签署您的JWT。 |
| `config.anonymous`（可选）| | 如果身份验证失败，则用作“匿名”使用者的可选字符串（使用者uuid）值。如果为空（默认），请求将失败，并且身份验证失败4xx。请注意，此值必须引用Kong内部的Consumer id属性，而不是其custom_id。 |
| `config.run_on_preflight`（可选）| true | 指示插件是否应在OPTIONS预检请求上运行（并尝试进行身份验证），如果设置为false，则始终允许OPTIONS请求。 （此参数仅适用于版本`0.11.1`及更高版本）|
| `config.maximum_expiration`（可选）| 0 | JWT的生命周期限制为将来的maximum_expiration秒的整数。任何具有更长生命周期的JWT都将被拒绝（HTTP 403）。如果指定了这个值，则还必须在claim_to_verify属性中指定exp。默认值0表示无限期。配置此值时应考虑潜在的时钟偏差。 | 

## 文档

为了使用该插件，首先需要创建一个Consumer然后关联一个或多个JWT凭证（保存用于验证令牌的公钥和私钥）。
消费者代表了开发人员使用最终服务。

### 创建一个Consumer

您需要将credential与现有的Consumer对象相关联。要创建使用者，您可以执行以下请求：
```
$ curl -X POST http://kong:8001/consumers \
    --data "username=<USERNAME>" \
    --data "custom_id=<CUSTOM_ID>"
HTTP/1.1 201 Created
```

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `username` (半可选)  | | Consumer的用户名,custom_id和username必须至少有一个 |
| `custom_id` (半可选) | |用于将Consumer映射到外部数据库的自定义标识符。custom_id和username必须至少有一个|

一个[Consumer](https://docs.konghq.com/latest/admin-api/#consumer-object)可以拥有许多JWT凭证。

### 创建一个 JWT credential

您可以通过发出以下HTTP请求来配置新的HS256 JWT凭证：

```
$ curl -X POST http://kong:8001/consumers/{consumer}/jwt -H "Content-Type: application/x-www-form-urlencoded"
HTTP/1.1 201 Created

{
    "consumer_id": "7bce93e1-0a90-489c-c887-d385545f8f4b",
    "created_at": 1442426001000,
    "id": "bcbfb45d-e391-42bf-c2ed-94e32946753a",
    "key": "a36c3049b36249a3c9f8891cb127243c",
    "secret": "e71829c351aa4242c2719cbfbe671c09"
}
```

- `consumer`: 通过 `id` 或者 `username` 把 credential 关联到相对应credential

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `key`(可选) | | 标识凭证的唯一字符串。如果不传的话将自动生成一个.|
| `algorithm`(可选) | `HS256` |  用于验证令牌签名的算法.可选值为`HS256`, `HS384`, `HS512`, `RS256`, `ES256`.|
| `rsa_public_key`(可选) |  | 如果参数 `algorithm` 是 `RS256` 或者 `ES256` ,则用于验证令牌签名的公钥（采用PEM格式）。|
| `secret`(可选) | |  如果参数 `algorithm` 是 `RS256` 或者 `ES256` ,用于为此凭证签署JWT的秘钥.如果不传的话将自动生成一个.| 

### 删除一个 JWT credential

您可以通过发出以下HTTP请求来删除Consumer的JWT：

```
$ curl -X DELETE http://kong:8001/consumers/{consumer}/jwt/{id}
HTTP/1.1 204 No Content
```

- `consumer` : 通过 `id` 或者 `username` 把 credential 关联到相对应credential
- `id`: JWT credential 的id

### JWT credential 列表

您可以通过发出以下HTTP请求列出Consumer的JWT凭证：
```
$ curl -X GET http://kong:8001/consumers/{consumer}/jwt
HTTP/1.1 200 OK
```

- `consumer`: 通过 `id` 或者 `username` 把 credential 关联到相对应credential

```
{
    "data": [
        {
            "rsa_public_key": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgK .... -----END PUBLIC KEY-----",
            "consumer_id": "39f52333-9741-48a7-9450-495960d91684",
            "id": "3239880d-1de5-4dbc-bccf-78f7a4280f33",
            "created_at": 1491430568000,
            "key": "c5a55906cc244f483226e02bcff2b5e",
            "algorithm": "RS256",
            "secret": "b0970f7fc9564e65xklfn48930b5d08b1"
        }
    ],
    "total": 1
}
```

### 创建一个带秘钥的JWT(HS256)

既然您的消费者拥有凭证，并且假设我们想要使用HS256进行签名，那么JWT应按照以下方式制作（[RFC 7519](https://tools.ietf.org/html/rfc7519)）：

首先,它的header必须是
```
{
    "typ": "JWT",
    "alg": "HS256"
}
```

然后,claims参数中必须包含秘钥的key,在config.key_claim_name配置中.该声明默认为`iss`(发行者字段),将其值设置为我们先前创建的凭证key,claims可能包含其他值。自Kong 0.13.1起，将会在 JWT 的payload和header中都会查找该字段.

```
{
    "iss": "a36c3049b36249a3c9f8891cb127243c"
}
```

可以在https://jwt.io 中调试 JWT ,header (HS256), claims (iss, etc),秘钥字段绑定key(e71829c351aa4242c2719cbfbe671c09),你将会得到这样的一个字符串

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImV4cCI6MTQ0MjQzMDA1NCwibmJmIjoxNDQyNDI2NDU0LCJpYXQiOjE0NDI0MjY0NTR9.AhumfY35GFLuEEjrOXiaADo7Ae6gt_8VLwX7qffhQN4
```

### 发起一个带有JWT的请求

现在,可以把JWT以添加在HEADER中的形式来发起一个请求:

```
$ curl http://kong:8000/{route path} \
    -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImV4cCI6MTQ0MjQzMDA1NCwibmJmIjoxNDQyNDI2NDU0LCJpYXQiOjE0NDI0MjY0NTR9.AhumfY35GFLuEEjrOXiaADo7Ae6gt_8VLwX7qffhQN4'
```

如果在配置文件中配置了config.uri_param_names字段,也可以把JWT以url参数的形式传入:
声明必须包含秘密的密钥字段（这不是用于生成令牌的私钥，而只是该配置声明中的标识符）（来自config.key_claim_name）。
```
curl http://kong:8000/{route path}?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImV4cCI6MTQ0MjQzMDA1NCwibmJmIjoxNDQyNDI2NDU0LCJpYXQiOjE0NDI0MjY0NTR9.AhumfY35GFLuEEjrOXiaADo7Ae6gt_8VLwX7qffhQN4
```

如果在配置文件中配置了config.cookie_names,也可以cookies的形式传入:

```
curl --cookie jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMzZjMzA0OWIzNjI0OWEzYzlmODg5MWNiMTI3MjQzYyIsImV4cCI6MTQ0MjQzMDA1NCwibmJmIjoxNDQyNDI2NDU0LCJpYXQiOjE0NDI0MjY0NTR9.AhumfY35GFLuEEjrOXiaADo7Ae6gt_8VLwX7qffhQN4 http://kong:8000/{route path}
```

这个请求将会被kong检查,取决于验证字段是否有效

| 请求 | 是否被代理到上游服务 | 响应状态码 |
| ---- | -------------- | ---------- |
| 没有携带JWT串 | no | 401 |
| 缺失了 `iss` claim | no | 401 |
| 无效签名 | no | 403 |
| 有效签名 | yes | 代理上游的请求返回值 |
| 有效签名，但是没有  `iss` claim| no | 403 |

> 提示:当JWT有效并代理上游服务时，除了添加标识Consumer的标头之外，不会对请求进行任何修改。
JWT将会被转发给上游服务，该服务可以检验此jwt的合法性。
然后上游服务的作用是base64解码JWT然后使用。

### (可选)验证claims

如[RFC 7519](https://tools.ietf.org/html/rfc7519)中所定义，Kong还可以对已注册的claims执行验证。要对声明claims验证，请将其添加到config.claims_to_verify属性:

可以给已经存在的jwt插件补充如下:
```
# 增加了对 nbf 和 exp claims的验证:
curl -X PATCH http://kong:8001/plugins/{jwt plugin id} \
    --data "config.claims_to_verify=exp,nbf"
```

支持的claims

| claim 名称 | 校验  |
| ---------- | ----- |
| exp  | JWT 是否过期 |
| nbf | 校验是否过期 |

### (可选) Base64 encoded 秘钥

如果你的秘密包含二进制数据，你可以将它们存储为Kong中的base64编码。

可以给已经存在的router补充如下:

```
$ curl -X PATCH http://kong:8001/routes/{route id}/plugins/{jwt plugin id} \
    --data "config.secret_is_base64=true"
```

或者已经存在的api:
```
$ curl -X PATCH http://kong:8001/apis/{api}/plugins/{jwt plugin id} \
    --data "config.secret_is_base64=true"
```

然后base64 encode consumers的 secrets:
```
# secret is: "blob data"
curl -X POST http://kong:8001/consumers/{consumer}/jwt \
  --data "secret=YmxvYiBkYXRh"
```

### 使用JWT 的 public/private keys (RS256 or ES256)

如果你想使用RS256 / ES256 来验证JWT,那么创建一个JWT的credential,选择RS256 或者 ES256 作为 algorithm,然后在rsa_public_key直接上传public key(包含 ES256 签名过的token)
```
$ curl -X POST http://kong:8001/consumers/{consumer}/jwt \
      -F "rsa_public_key=@/path/to/public_key.pem" \
HTTP/1.1 201 Created

{
    "consumer_id": "7bce93e1-0a90-489c-c887-d385545f8f4b",
    "created_at": 1442426001000,
    "id": "bcbfb45d-e391-42bf-c2ed-94e32946753a",
    "key": "a36c3049b36249a3c9f8891cb127243c",
    "rsa_public_key": "-----BEGIN PUBLIC KEY----- ..."
}
```

创建签名的时候,header 会是这样:
```
{
    "typ": "JWT",
    "alg": "RS256"
}
```

然后,claims 必须包含秘密的key字段（这不是用于生成令牌的private key，而只是该配置的claim）（来自config.key_claim_name）。
该claim 默认为iss（发行者字段）,将其值设置为我们先前创建的credential的 key.claims可能包含其他值.自Kong 0.13.1起，将会在 JWT 的payload和header中都会查找该字段.

```
{
    "iss": "a36c3049b36249a3c9f8891cb127243c"
}
```

接着,然后使用您的私钥创建签名。
使用https://jwt.io 上的JWT调试器，设置正确的header（RS256），claims（iss等）和相关的 public key。
然后将结果值附加到Authorization header中，例如：

```
$ curl http://kong:8000/{route path} \
    -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxM2Q1ODE0NTcyZTc0YTIyYjFhOWEwMDJmMmQxN2MzNyJ9.uNPTnDZXVShFYUSiii78Q-IAfhnc2ExjarZr_WVhGrHHBLweOBJxGJlAKZQEKE4rVd7D6hCtWSkvAAOu7BU34OnlxtQqB8ArGX58xhpIqHtFUkj882JQ9QD6_v2S2Ad-EmEx5402ge71VWEJ0-jyH2WvfxZ_pD90n5AG5rAbYNAIlm2Ew78q4w4GVSivpletUhcv31-U3GROsa7dl8rYMqx6gyo9oIIDcGoMh3bu8su5kQc5SQBFp1CcA5H8sHGfYs-Et5rCU2A6yKbyXtpHrd1Y9oMrZpEfQdgpLae0AfWRf6JutA9SPhst9-5rn4o3cdUmto_TBGqHsFmVyob8VQ'
```

### 生成一个 public/private keys

要创建一对全新的public/private keys，可以运行以下命令：

```
$ openssl genrsa -out private.pem 2048
```

这个私钥必须保密。要生成与私钥对应的公钥，执行
```
$ openssl rsa -in private.pem -outform PEM -pubout -out public.pem
```

如果运行上述命令，则公钥将写入public.pem，而私钥将写入private.pem。

### 在JWT插件中使用Auth0

[Auth0](https://auth0.com/)是一种流行的授权解决方案，并且在很大程度上依赖于JWT。
Auth0依赖于RS256，不进行base64编码，并公开托管用于签署令牌的公钥证书。
出于指南的目的，帐户名称被称为“COMPANYNAME”。  

要开始，请创建service，使用该服service的router或创建API。  
注意：Auth0不使用base64编码的秘密。

创建一个service:

```
$ curl -i -f -X POST http://localhost:8001/services \
    --data "name=example-service" \
    --data "=http://httpbin.org"
```

然后创建一个router

```
$ curl -i -X POST http://localhost:8001/apis \
    --data "name={api}" \
    --data "hosts=example.com" \
    --data "upstream_url=http://httpbin.org"
```

添加JWT插件
添加插件到你的router
```
$ curl -X POST http://localhost:8001/route/{route id}/plugins \
    --data "name=jwt"
```

添加插件到你的api
```
$ curl -X POST http://localhost:8001/apis/{api}/plugins \
    --data "name=jwt"
```

下载你的Auth0帐户的X509证书:
```
$ curl -o {COMPANYNAME}.pem https://{COMPANYNAME}.auth0.com/pem
```

从X509证书中提取公钥:`
```
$ openssl x509 -pubkey -noout -in {COMPANYNAME}.pem > pubkey.pem
```

使用 Auth0 public key 创建一个Consumer:

```
curl -i -X POST http://kong:8001/consumers \
    --data "username=<USERNAME>" \
    --data "custom_id=<CUSTOM_ID>"

curl -i -X POST http://localhost:8001/consumers/{consumer}/jwt \
    -F "algorithm=RS256" \
    -F "rsa_public_key=@./pubkey.pem" \
    -F "key=https://{COMPAYNAME}.auth0.com/" # the `iss` field
```

默认情况下，JWT插件会针对令牌中的iss字段验证key_claim_name。Auth0颁发的密钥将其iss字段设置为`http://{COMPANYNAME}.auth0.com/`.在创建Consumer时，可以使用jwt.io验证key参数的iss字段。

通过发送请求，只有Auth0签名的令牌才能正常工作：
```
$ curl -i http://localhost:8000 \
    -H "Host:example.com" \
    -H "Authorization:Bearer "
```
成功!

### 上游 Headers
当JWT有效时，Consumer已经过身份验证，插件会在将请求代理到上游服务之前将一些头附加到请求中，以便您可以在代码中识别Consumer：

- `X-Consumer-ID`, Consumer 在 Kong 的 ID
- `X-Consumer-Custom-ID`, Consumer的custom_id  (如果存在)
- `X-Consumer-Username`, Consumer的username  (如果存在)
- `X-Anonymous-Consumer`,身份验证失败时将设置为true，并设置“匿名”使用者。

您可以使用此信息来实现其他逻辑。
您可以使用X-Consumer-ID值来查询Kong Admin API并检索有关Consumer的更多信息。

### 通过JWT分页

> 提示：此功能在Kong 0.11.2中引入。

您可以使用以下请求为所有使用者分配JWT：

```
$ curl -X GET http://kong:8001/jwts

{
    "total": 3,
    "data": [
        {
            "created_at": 1509593911000,
            "id": "381879e5-04a1-4c8a-9517-f85fbf90c3bc",
            "algorithm": "HS256",
            "key": "UHVwIly5ZxZH7g52E0HRlFkFC09v9yI0",
            "secret": "KMWyDsTTcZgqqyOGgRWTDgZtIyWeEtJh",
            "consumer_id": "3c2c8fc1-7245-4fbb-b48b-e5947e1ce941"
        },
        {
            "created_at": 1511389527000,
            "id": "0dfc969b-02be-42ae-9d98-e04ed1c05850",
            "algorithm": "ES256",
            "key": "vcc1NlsPfK3N6uU03YdNrDZhzmFF4S19",
            "secret": "b65Rs6wvnWPYaCEypNU7FnMOZ4lfMGM7",
            "consumer_id": "c0d92ba9-8306-482a-b60d-0cfdd2f0e880"
        },
        {
            "created_at": 1509593912000,
            "id": "d10c6f3b-71f1-424e-b1db-366abb783460",
            "algorithm": "HS256",
            "key": "SqSNfg9ARmPnpycyJSMAc2uR6nxdmc9S",
            "secret": "CCh6ZIcwDSOIWacqkkWoJ0FWdZ5eTqrx",
            "consumer_id": "3c2c8fc1-7245-4fbb-b48b-e5947e1ce941"
        }
    ]
}
```

您可以使用以下查询参数过滤列表：

| 属性 | 描述 |
| ---- | ---- |
| `id`(可选) |  基于JWT credential ID字段的列表上的过滤器。 |
| `key`(可选) | 基于JWT  credential key 字段的列表上的过滤器。 |
| `consumer_id`(可选) | 基于JWT credential consumer_id字段的列表上的过滤器。 |
| `size`(可选) | 要返回的对象数量的限制(默认100) |
| `offset`(可选) |用于分页的游标。offset是一个对象标识符，用于定义列表中的位置。 |

### 检索与JWT关联的使用者

> 提示：此功能在Kong 0.11.2中引入。

可以使用以下请求检索与JWT关联的[ Consumer ](https://docs.konghq.com/latest/admin-api/#consumer-object)：
```
$ curl -X GET http://kong:8001/jwts/{key or id}/consumer

{
   "created_at":1507936639000,
   "username":"foo",
   "id":"c0d92ba9-8306-482a-b60d-0cfdd2f0e880"
}
```

`key or id`: JWT的`id`或`key`属性，用于获取关联的Consumer。

