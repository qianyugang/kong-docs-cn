# 什么是插件，它们如何与Kong整合？

> 原文链接：https://docs.konghq.com/1.1.x/plugin-development/

在进一步讨论之前，有必要简要解释一下Kong是如何构建的，特别是它如何与Nginx集成以及Lua与它有什么关系。

[lua-nginx-module](https://github.com/openresty/lua-nginx-module)在Nginx中启用Lua脚本功能。Kong不是用这个模块编译Nginx，而是与OpenResty一起分发，[OpenResty](https://openresty.org/)已经包含了lua-nginx-module。OpenResty不是Nginx的分支，而是一组扩展其功能的模块。

因此，Kong是一个Lua应用程序，旨在加载和执行Lua模块（我们通常称之为“插件”），并为它们提供整个开发环境，包括SDK，数据库抽象，迁移等。

插件由Lua模块组成，它们通过插件开发工具包（或“PDK”）与请求/响应对象或流交互，以实现任意逻辑。PDK是一组Lua函数，插件可以使用它来促进插件与Kong的核心（或其他组件）之间的交互。

本指南将详细探讨插件的结构，它们可以扩展的内容以及如何分发和安装它们。有关PDK的完整参考，查看 [Plugin Development Kit](https://docs.konghq.com/1.1.x/pdk)。

下一步：插件的文件结构
