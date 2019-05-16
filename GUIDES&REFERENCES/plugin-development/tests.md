# 微服务 API 网关 Kong 单元测试中文文档

原文链接: [https://docs.konghq.com/1.0.x/plugin-development/tests/](https://docs.konghq.com/1.0.x/plugin-development/tests/)
（如有翻译的不准确或错误之处，欢迎留言指出）  
集成测试：https://docs.konghq.com/1.0.x/plugin-development/tests/#write-integration-tests

## 介绍
如果你认真对待你写的插件，你可能想为它编写一些测试。Lua的单元测试很简单，并且可以使用许多[测试框架](http://lua-users.org/wiki/UnitTesting)。但是，您可能还想编写集成测试。Kong可以再次为您提供支援。

## 编写集成测试	

Kong的首选测试框架是[busted](http://olivinelabs.com/busted/)，它与resty-cli解释器一起运行，但如果您愿意，可以自由使用另一个。在Kong存储库中，可以在`bin/busted`找到 busted 的可执行文件。

Kong为您提供了一个帮助程序，可以在测试套件中从Lua启动和停止它：`spec.helpers`。此助手还提供了在运行测试之前在数据存储区中插入fixtures的方法，以及删除，以及各种其他helper。

如果您在自己的存储库中编写插件，则需要复制以下文件，直到Kong测试框架发布：

- `bin/busted`： 与resty-cli解释器一起运行的 busted 的可执行文件
- `spec/helpers.lua`：Kong的helper函数 可以从busted中 启动/关闭kong
- `spec/kong_tests.conf`：使用helpers模块运行的Kong实例的配置文件

假设您的`LUA_PATH`中有`spec.helpers`模块，您可以使用以下Lua代码来启动和停止Kong：

```
local helpers = require "spec.helpers"

for _, strategy in helpers.each_strategy() do
  describe("my plugin", function()

    local bp = helpers.get_db_utils(strategy)

    setup(function()
      local service = bp.services:insert {
        name = "test-service",
        host = "httpbin.org"
      }

      bp.routes:insert({
        hosts = { "test.com" },
        service = { id = service.id }
      })

      -- start Kong with your testing Kong configuration (defined in "spec.helpers")
      assert(helpers.start_kong( { plugins = "bundled,my-plugin" }))

      admin_client = helpers.admin_client()
    end)

    teardown(function()
      if admin_client then
        admin_client:close()
      endhttps://github.com/Kong/kong/tree/master/spec/03-plugins/09-key-auth

      helpers.stop_kong()
    end)

    before_each(function()
      proxy_client = helpers.proxy_client()
    end)

    after_each(function()
      if proxy_client then
        proxy_client:close()
      end
    end)

    describe("thing", function()
      it("should do thing", function()
        -- send requests through Kong
        local res = proxy_client:get("/get", {
          headers = {
            ["Host"] = "test.com"
          }
        })

        local body = assert.res_status(200, res)

        -- body is a string containing the response
      end)
    end)
  end)
end
```

> 提醒：通过test Kong配置文件，Kong运行在代理监听端口9000(HTTP),9443 (HTTPS)和端口9001上的Admin API。

如果想看一下真实的例子，可以来这里看一看  [Key-Auth plugin specs](https://github.com/Kong/kong/tree/master/spec/03-plugins/09-key-auth)
