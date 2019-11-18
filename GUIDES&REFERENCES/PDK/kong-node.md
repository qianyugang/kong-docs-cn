# kong.node

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.node/

节点级公用程序

## kong.node.get_id()

返回此节点用于描述自身的id。

- 返回
	- `string` 此节点使用的v4 UUID作为其id
- 用法
	```
    local id = kong.node.get_id()
    ```
