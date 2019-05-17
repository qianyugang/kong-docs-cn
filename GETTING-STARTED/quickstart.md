# 五分钟快速开始

> 开始之前：确保你已经[安装](https://konghq.com/install/)了Kong - 只需要一分钟！

在本节中，您将学习如何管理Kong实例。
首先，我们将让您启动Kong，以便您可以访问RESTful Admin界面，通过该界面可以管理Services，Routes，Consumers等。通过Admin API发送的数据存储在Kong的数据存储区中（Kong支持PostgreSQL和Cassandra）。

## 1.启动Kong

使用以下命令以通过运行Kong的迁移来准备数据：
```
$ kong migrations bootstrap [-c /path/to/kong.conf]
```

此时应该会看到一条消息，告诉Kong已成功迁移您的数据库。如果没有，可能配置文件中数据库连接配置错误。
现在可以启动Kong：
```
$ kong start [-c /path/to/kong.conf]
```

**注意：** CLI接受配置选项（`-c /path/to/kong.conf`），允许指向自己的配置。

## 2.验证Kong是否成功启动
如果一切正常，你应该能看到一条信息(`Kong started`)，告知你Kong正在运行。

默认情况下，Kong会监听以下端口：

- `:8000`Kong用来监听来自客户端的传入HTTP流量，并将其转发到上游服务
- `:8443`Kong用来监听传入的HTTPS流量。此端口具有和`:8000`端口类似的行为，但它仅用于HTTPS流量。可以通过配置文件禁用此端口。
- `:8001`[Admin API](https://docs.konghq.com/1.1.x/admin-api)用于配置Kong监听。
- `:8444`Admin API监听HTTPS流量。

## 3.停止Kong
根据需要，可以通过执行以下命令来停止Kong进程：
```
$ kong stop
```

## 4.重载Kong
执行如下命令可以在不停机的情况下重新载入Kong
```
$ kong restart
```

## 下一步

现在你已经启动了Kong,可以使用Admin API管理。
首先，可以去[配置一个Service](https://docs.konghq.com/1.1.x/getting-started/configuring-a-service)











