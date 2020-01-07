# decK 插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/deck/

decK以声明方式帮助管理Kong的配置。它可以将配置同步到运行中的Kong群集，比较配置以检测任何漂移或手动更改，并备份Kong的配置。它还可以使用标签以分布式方式管理Kong的配置，从而帮助您将Kong的配置分散到各个团队中。

## decK：Kong的声明式配置

decK是一个CLI工具，可使用单个配置文件以声明方式配置Kong。
[![alt text](https://asciinema.org/a/238318.svg "title")](https://asciinema.org/a/238318)

## 功能

- 导出
	- 将现有的Kong配置保存到YAML配置文件中可用于备份Kong的配置。
- 导入
	- 可以使用导出的或手写的配置文件填充Kong的数据库。
- 比较和同步功能
	- decK可以将配置文件中的配置与Kong数据库中的配置进行比较，然后进行同步。这可用于检测配置偏差或手动干预。
- 反向同步
	- decK也以另一种方式支持同步，这意味着如果一个实体是在Kong中创建的，并且没有将它添加到配置文件中，decK将检测到变化。
- 重置
	- 这可用于删除Kong数据库中的所有实体。
- 平行作业
	- 使用线程并行执行对Kong的所有Admin API调用，以加快同步速度。
- 支持的实体
	- Routes 和 services
	- Upstreams 和 targets
	- Certificates 和SNI
	- Consumers
	- Plugins（全局，每个route，每个service和每个Consumers）
- Kong的认证
	- 自定义HTTP标头可以注入到Kong的Admin API的请求中，以进行身份验证/授权。
- 使用多个配置文件管理Kong的配置
	- 根据实体之间共享的标签集将Kong的配置分为多个逻辑文件

## 兼容性

cK与Kong 1.x兼容

## 安装

如果您使用的是macOS，请使用brew安装decK：

```
$ brew tap hbagdi/deck
$ brew install deck
```
如果您使用的是Linux，则可以从Github发布页面使用Debian或RPM归档文件，也可以通过下载二进制文件进行安装：
```
$ curl -sL https://github.com/hbagdi/deck/releases/download/v0.4.0/deck_0.4.0_linux_amd64.tar.gz -o deck.tar.gz
$ tar -xf deck.tar.gz -C /tmp
$ cp /tmp/deck /usr/local/bin/
```
安装完成后，请使用以下命令获取帮助：
```
$ deck --help
```

## 文档

您可以在文档网站https://deck.yolo42.com上找到更多文档。
