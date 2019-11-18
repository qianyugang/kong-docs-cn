# kong.router

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.router/

Router模块用于访问请求的路由属性的一组功能。

## kong.router.get_route()

返回当前路由实体。请求与此路由匹配。

- 阶段
	- access, header_filter, body_filter, log
- 返回
	- `table` `route` 的实体。
- 用法
	```
    if kong.router.get_route() then
      -- routed by route & service entities
    else
      -- routed by a legacy API entity
    end
    ```
    
## kong.router.get_service()

返回当前`service`实体。该请求将针对此上游服务。

- 阶段
	- access, header_filter, body_filter, log
- 返回
	- `table` `service` 的实体。
- 用法
	```
    if kong.router.get_service() then
  	-- routed by route & service entities
    else
      -- routed by a legacy API entity
    end
    ```






















