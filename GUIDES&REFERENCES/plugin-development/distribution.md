# 微服务 API 网关 Kong 插件开发 - 安装/卸载插件

原文地址：https://docs.konghq.com/1.1.x/plugin-development/entities-cache/ （不能保证所有的翻译都是准确无误的，所有如有翻译的不准确或错误之处，请一定记得查看原文，并欢迎留言指出）。

## 介绍

Kong的自定义插件由Lua源文件组成，这些源文件需要位于每个Kong节点的文件系统中。本指南将为您提供逐步说明，使Kong节点了解您的自定义插件。这些步骤应该应用于Kong集群中的每个节点，以确保每个节点上都有自定义插件。

## 打包源

您可以使用常规打包策略（例如tar），也可以使用LuaRocks包管理器为您执行此操作。我们推荐使用LuaRocks，因为它在使用其中一个官方分发包时与Kong一起安装。

使用LuaRocks时，您必须创建一个`rockspec`文件，用来指定包的内容。有关示例，请参阅[Kong插件模板](https://github.com/Kong/kong-plugin)，有关该格式的更多信息，请参阅有关[rockspecs的LuaRocks文档](https://github.com/keplerproject/luarocks/wiki/Creating-a-rock)。

使用以下命令打包你的rock（来自插件仓库）：
```
# install it locally (based on the `.rockspec` in the current directory)
$ luarocks make

# 打包已安装的rock
$ luarocks pack <plugin-name> <version>
```

假设你的插件rockspec的名字为`kong-plugin-myPlugin-0.1.0-1.rockspec`，上面就会变成：
```
$ luarocks pack kong-plugin-myPlugin 0.1.0-1
```

LuaRocks `pack`命令现在已经创建了一个`.rock`文件（这只是一个包含安装rock所需内容的zip文件）。

如果您不使用或不能使用LuaRocks，则使用`tar`将插件所包含的`.lua`文件打包到`.tar.gz`存档中。
如果目标系统上有LuaRocks，也可以包含`.rockspec`文件。

该插件的内容应该接近以下内容：
```
$ tree <plugin-name>
<plugin-name>
├── INSTALL.txt
├── README.md
├── kong
│   └── plugins
│       └── <plugin-name>
│           ├── handler.lua
│           └── schema.lua
└── <plugin-name>-<version>.rockspec
```

## 安装插件

要使Kong节点能够使用自定义插件，必须在主机的文件系统上安装自定义插件的Lua源。有多种方法：通过LuaRocks，或手动。
选择一个，然后跳转到第3部分。

1. 来自新建的'rock'的LuaRocks。  
	`.rock`文件是一个自包含的软件包，可以在本地安装，也可以从远程服务器安装。  
    如果您的系统中安装了`luarocks`实用程序（如果使用其中一个官方安装包，可能就是这种情况），您可以在LuaRocks树（LuaRocks安装Lua模块的目录）中安装“rock”。  
    它可以通过以下方式安装：  
    ```
    $ luarocks install <rock-filename>
    ```
    文件名可以是本地名称，或任何支持的方法。  
    例如：`http://myrepository.lan/rocks/myplugin-0.1.0-1.all.rock`
2. 从源档案中通过LuaRocks安装。
	如果您的系统中安装了luarocks实用程序（如果使用其中一个官方安装包，可能就是这种情况），您可以在LuaRocks树（LuaRocks安装Lua模块的目录）中安装Lua源代码。  
    您可以通过将当前目录更改为提取的存档来实现，其中rockspec文件是：  
    ```
    $ cd <plugin-name>
    ```
    然后运行以下命令：
    ```
    $ luarocks make
    ```
    这将在系统的LuaRocks树中的`kong/plugins/<plugin-name>`中安装Lua源代码，其中所有的Kong源都已存在。
3. 手动  
	安装插件源的一种更保守的方法是避免“污染”LuaRocks树，而是将Kong指向包含它们的目录。  
    这是通过调整Kong配置的`lua_package_path`属性来完成的。如果你熟悉它，那么这个属性是Lua VM的`LUA_PATH`变量的别名。  
    这些属性包含以分号分隔的目录列表，用于搜索Lua源。它应该在您的Kong配置文件中设置如下：
    ```
    lua_package_path = /<path-to-plugin-location>/?.lua;
    ```
    继续:   
    4.`/<path-to-plugin-location>`是包含提取的存档的目录的路径。它应该是归档中`kong`目录的位置。  
    5.`?`是一个占位符，将被`kong.plugins`替换。`<plugin-name>`当Kong将尝试加载你的插件。   
    6.`;;`“默认Lua路径”的占位符。不要改变它。  
    例如:  
    插件位于文件系统上，使处理程序文件为：
    ```
    /usr/local/custom/kong/plugins/<something>/handler.lua
    ```
    kong目录的位置是：`/usr/local/custom`，因此正确的路径设置将是：
    ```
    lua_package_path = /usr/local/custom/?.lua;;
    ```
    
    多个插件：
    
    如果您希望以这种方式安装两个或更多自定义插件，可以将变量设置为：
    ```
     lua_package_path = /path/to/plugin1/?.lua;/path/to/plugin2/?.lua;;
    ```
    
    	7.`;`是目录之间的分隔符。
    	8.`;;`仍然意味着“默认的Lua路径”。

	注意：您还可以通过其等效的环境变量`KONG_LUA_PACKAGE_PATH`设置此属性。
    
提醒：无论您使用哪种方法来安装插件的源，您仍必须为Kong群集中的每个节点执行此操作。

## 加载插件

您现在必须将自定义插件的名称添加到Kong配置中的插件列表中（在每个Kong节点上）：
```
plugins = bundled,<plugin-name>
```
或者，如果您不想包含默认捆绑的插件：
```
plugins = <plugin-name>
```
或者
```
plugins = plugin1,plugin2
```
注意：您还可以通过其等效的环境变量`KONG_PLUGINS`来设置此属性。
提醒：不要忘记更新Kong群集中每个节点的plugins指令。
提醒：插件重启后会生效：
```
kong restart
```
但是，如果你想在kong永不停止时应用插件，你可以使用：
```
kong prepare
kong reload
```

## 验证加载插件

你现在应该能够毫无问题地启动Kong。
请参阅自定义插件有关如何在服务，路由或消费者实体上启用/配置插件的说明。  

为确保您的插件由Kong加载，您可以使用调试日志级别启动Kong：
```
log_level = debug
```
或者
```
KONG_LOG_LEVEL=debug
```
然后，您应该看到正在加载的每个插件的以下日志：
```
[debug] Loading plugin <plugin-name>
```

## 删除插件

完全删除插件有三个步骤。

1. 从您的Kong Service或Route配置中删除插件。确保它不再适用于全局，也不适用于任何服务，路由或使用者。对于整个Kong集群，只需执行一次，不需要重新启动/重新加载。此步骤本身将使插件不再使用。但它仍然可用，仍然可以重新应用插件。
2. 从`plugins`指令中删除插件（在每个Kong节点上）。确保在执行此操作之前已完成步骤1。在此步骤之后，任何人都无法将插件重新应用于任何Kong Service，Route，Consumer甚至全局。此步骤需要重新启动/重新加载Kong节点才能生效。
3. 要彻底删除插件，请从每个Kong节点中删除与插件相关的文件。在删除文件之前，请确保已完成步骤2，包括重新启动/重新加载Kong。如果你使用LuaRocks来安装插件，你可以使用`luarocks remove <plugin-name>`来删除它。

## 分发插件

这样做的首选方法是使用[LuaRocks](https://luarocks.org/)，Lua模块的包管理器。它称这些模块为“rocks”。
**您的模块不必存在于Kong存储库中**，但如果您希望维护Kong设置，则可能就是这样。

通过在[rockspec](https://github.com/keplerproject/luarocks/wiki/Creating-a-rock)文件中定义模块（及其最终依赖项），您可以通过LuaRocks在您的平台上安装这些模块。

您也可以在LuaRocks上传模块并将其提供给所有人！  

有关示例，请参阅[Kong插件模板](https://github.com/Kong/kong-plugin)，有关该格式的更多信息，请参阅有关[rockspecs的LuaRocks文档](https://github.com/keplerproject/luarocks/wiki/Creating-a-rock)。

## 故障排除

由于以下几个原因，配置错误的自定义插件可能无法启动：

- “plugin is in use but not enabled” -> 您从另一个节点配置了一个自定义插件，并且该插件配置在数据库中，但您尝试启动的当前节点在其`plugins`指令中没有它。要解决此问题，请将插件的名称添加到节点的`plugins`指令中。
- “plugin is enabled but not installed” -> 插件的名称出现在`plugins`指令中，但是Kong无法从文件系统加载`handler.lua`源文件。要解决此问题，请确保正确设置[lua_package_path](https://docs.konghq.com/1.1.x/configuration/#development-miscellaneous-section)指令以加载此插件的Lua源。
- “no configuration schema found for plugin” -> 插件已在`plugins`指令中安装，但是Kong无法从文件系统加载`schema.lua`源文件。要解决此问题，请确保`schema.lua`文件与插件的`handler.lua`文件一起存在。

















