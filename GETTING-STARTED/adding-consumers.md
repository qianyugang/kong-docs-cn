# 添加 Consumers

> 本文原文链接：https://docs.konghq.com/1.1.x/getting-started/adding-consumers/

> 在开始之前  
> 1  确保你已经安装了Kong - 只需要一分钟！
> 2  确保你已经启动了Kong。
> 3  确保已在Kong配置了Service。

在上一节中，我们学习了如何向Kong添加插件，在本节中我们将学习如何将Consumer添加到Kong实例中。Consumers与使用您的Service的个人相关联，并可用于跟踪，访问管理等。

注意：本节假定您已启用插件。如果还没有，您可以[启用插件]((https://docs.konghq.com/1.1.x/getting-started/enabling-plugins)[key-auth](https://docs.konghq.com/plugins/key-authentication))或跳过第二步和第三步。

## 1. 通过RESTful API创建一个Consumer
让我们通过执行以下请求来创建一个名为Jason的用户：
```
$ curl -i -X POST \
  --url http://localhost:8001/consumers/ \
  --data "username=Jason"
```

您应该看到类似于下面的响应：
```
HTTP/1.1 201 Created
Content-Type: application/json
Connection: keep-alive

{
  "username": "Jason",
  "created_at": 1428555626000,
  "id": "bbdf1c48-19dc-4ab7-cae0-ff4f59d87dc9"
}
```
恭喜！你刚刚把你的第一个Consumer添加到Kong。

注意：在创建使用者以将使用者与现有用户数据库关联时，Kong还接受`custom_id`参数。

## 2.为Consumer发放密钥凭证
现在，我们可以通过执行以下请求为我们最近创建的消费者Jason创建一个密钥：
```
$ curl -i -X POST \
  --url http://localhost:8001/consumers/Jason/key-auth/ \
  --data 'key=ENTER_KEY_HERE'
```

## 验证你的Consumer凭证是否有效

现在，我们可以执行下面的命令，验证刚刚给Jason发放的凭证是否有效：
```
$ curl -i -X GET \
  --url http://localhost:8000 \
  --header "Host: example.com" \
  --header "apikey: ENTER_KEY_HERE"
```

## 下一步

现在，我们已经介绍了添加Service,Route,Consumer和启用插件的基础知识，欢迎继续阅读以下文档：

- [配置](../GUIDES&REFERENCES/configuration.md)
- [CLI](../GUIDES&REFERENCES/cli.md)
- [代理](../GUIDES&REFERENCES/proxy.md)
- [管理Api](../ADMIN-API)
- [集群](../GUIDES&REFERENCES/clustering.md)










