# kong.ctx

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.ctx/

当前请求上下文数据

## kong.ctx.shared

一个具有当前请求生命周期并在所有插件之间共享的表。它可用于在给定请求中的多个插件之间共享数据。  

由于仅在请求的上下文中相关，因此无法从Lua模块的顶级块访问此表。 相反，它只能在请求阶段中访问，这些阶段由插件接口的`rewrite`，`access`，`header_filter`，`body_filter`和`log`阶段表示。在这些函数（及其被调用者）中访问此表是可以的。

所有其他插件都可以看到插件在此表中插入的值。在与其值进行交互时必须谨慎，因为命名冲突可能导致数据覆盖。

- 阶段
	- rewrite, access, header_filter, body_filter, log
- 用法
	```
    -- 两个插件 A and B, 如果插件 A 比 B有更高的优先级
    -- (在 B之前执行):

    -- plugin A handler.lua
    function plugin_a_handler:access(conf)
      kong.ctx.shared.foo = "hello world"

      kong.ctx.shared.tab = {
        bar = "baz"
      }
    end

    -- plugin B handler.lua
    function plugin_b_handler:access(conf)
      kong.log(kong.ctx.shared.foo) -- "hello world"
      kong.log(kong.ctx.shared.tab.bar) -- "baz"
    end
    ```

## kong.ctx.plugin

具有当前请求生命周期的表 - 与`kong.ctx.shared`不同，此表不在插件之间共享。相反，它仅对当前插件实例可见。也就是说，如果配置了速率限制插件的多个实例（例如，在不同的Services上），则每个实例都有自己的表，用于每个请求。

由于它的命名空间性质，这个表比`kong.ctx.shared`更安全，因为它避免了潜在的命名冲突，这可能导致几个插件在不知不觉中覆盖彼此的数据。

由于仅在请求的上下文中相关，因此无法从Lua模块的顶级块访问此表。相反，它只能在请求阶段中访问，这些阶段由插件接口的`rewrite`，`access`，`header_filter`，`body_filter`和`log`阶段表示。在这些函数（及其被调用者）中访问此表是可以的。

插件在此表中插入的值仅在此插件实例的成功阶段中可见。例如，如果插件想要在日志阶段保存一些值以进行后处理：

- 阶段
	- rewrite, access, header_filter, body_filter, log
- 用法
	```
    -- plugin handler.lua

    function plugin_handler:access(conf)
      kong.ctx.plugin.val_1 = "hello"
      kong.ctx.plugin.val_2 = "world"
    end

    function plugin_handler:log(conf)
      local value = kong.ctx.plugin.val_1 .. " " .. kong.ctx.plugin.val_2

      kong.log(value) -- "hello world"
    end
    ```
























