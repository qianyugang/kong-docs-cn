# 无数据库模式 Admin API 

> 此页面指的是用于运行Kong的Admin API，该API配置为无数据库，通过声明性配置管理内存中的实体。
有关将Kong的Admin API与数据库一起使用的信息，请参阅 [数据库模式的Admin API](https://docs.konghq.com/1.3.x/admin-api)页面。

## 目录

- [支持的 Content Types](#支持的-content-types)
- [Routes 信息]()
	- [检索节点信息]()
	- [检索节点状态]()
- [声明式配置]()
	- [重新加载声明性配置]()
- [标签]()
	- [列出所有标签]()
	- [按标签列出实体ID]()
- [Service 对象]()
	- [Service 列表]()
	- [Service 检索]()
- [Router对象]()
	- [Router 列表]()
	- [Router 检索]()
- [Consumer对象]()
	- [Consumer 列表]()
	- [Consumer 检索]()
- [插件对象]()
	- [优先级]()
	- [插件列表]()
	- [插件检索]()
	- [已启用的插件检索]()
	- [插件schema检索]()
- [证书对象]()
	- [证书列表]()
	- [证书检索]()
- [CA证书对象]()
	- [CA证书列表]()
	- [CA证书检索]()
- [SNI对象]()
	- [SNI 列表]()
	- [SNI 检索]()
- [Upstream对象]()
	- [Upstream 列表]()
	- [Upstream 检索]()
	- [显示节点的Upstream运行状况]()
- [Target对象]()
	- [Target 列表]()
	- [将Target设定为健康]()
	- [将Target设置为不健康]()
	- [所有Target列表]()

## 支持的 Content Types

Admin API在每个端点上接受2种内容类型：

- application/x-www-form-urlencoded
- application/json
