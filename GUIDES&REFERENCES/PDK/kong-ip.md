# kong.ip

可信任的IP模块

此模块可用于确定给定IP地址是否在`trusted_ips`配置属性定义的可信IP地址范围内。

可信IP地址是已知为客户端发送正确替换地址的IP地址（根据所选择的报头字段，例如X-Forwarded- *）。

查看[docs.konghq.com/latest/configuration/#trusted_ips](https://docs.konghq.com/latest/configuration/#trusted_ips)

## kong.ip.is_trusted(address)

根据`trusted_ips`配置属性，此函数将返回给定的ip是否可信，并且支持ipv4和ipv6。

- 阶段
	- init_worker, certificate, rewrite, access, header_filter, body_filter, log
- 参数
	- address(string):表示IP地址的字符串
- 返回
	- `boolean` 如果IP是可信的`true`，否则为`false`
- 用法
	```
    if kong.ip.is_trusted("1.1.1.1") then
  		kong.log("The IP is trusted")
	end
    ```