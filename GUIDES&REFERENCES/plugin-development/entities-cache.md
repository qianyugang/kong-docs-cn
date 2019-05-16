# 微服务 API 网关 Kong 插件开发 - 缓存自定义实体

原文地址：https://docs.konghq.com/1.1.x/plugin-development/entities-cache/ （不能保证所有的翻译都是准确无误的，所有如有翻译的不准确或错误之处，请一定记得查看原文，并欢迎留言指出）。

## 介绍

您的插件可能需要经常访问每个请求 和/或 响应的自定义实体（在[前一章](https://docs.konghq.com/1.1.x/plugin-development/custom-entities/)中可见）。通常，加载它们一次并将它们缓存在内存中会显着提高性能，同时确保数据存储区不会因负载增加而受到压力。

考虑一个api-key身份验证插件，需要在每个请求上验证api-key，从而在每个请求中从数据存储区加载自定义凭据对象。当客户端提供api-key以及请求时，通常你会查询数据存储区以检查该密钥是否存在，然后，阻止请求或检索 Consumer ID以识别用户，这将在每个请求上发生，并且效率非常低：
- 查询数据存储会增加每个请求的延迟，使请求处理速度变慢。
- 数据存储区也会受到负载增加，可能崩溃或减速的影响，这反过来会影响每个Kong节点。

为避免每次都查询数据存储区，我们可以在节点上缓存内存中的自定义实体，这样频繁的实体查找不会每次都触发数据存储区查询（仅限第一次），而是在内存中查询，从数据存储区查询它（特别是在高负载下）更快更可靠。

## Modules

```
kong.plugins.<plugin_name>.daos
```

## 缓存自定义实体
一旦定义了自定义实体，就可以使用[插件开发工具包](https://docs.konghq.com/1.1.x/pdk)提供的 [kong.cache](https://docs.konghq.com/1.1.x/pdk/#kong-cache) 模块将它们缓存在代码中的内存中：
```
local cache = kong.cache
```

有两级缓存：

1. L1：Lua内存缓存 - nginx worker的本地缓存这可以包含任何类型的Lua值。
2. L2：共享内存缓存（SHM） - nginx节点的本地缓存，但在所有工作者之间共享。这只能保存标量值，因此需要（反）序列化。

从数据库中提取数据时，它将存储在两个缓存中。现在，如果同一个工作进程再次请求数据，它将从Lua内存缓存中检索以前反序列化的数据。如果同一Nginx节点中的另一个工作程序请求该数据，它将在SHM中找到数据，对其进行反序列化（并将其存储在自己的Lua内存缓存中），然后将其返回。

该模块公开以下功能：

| FUNCTION NAME | DESCRIPTION | 
| ------------- | ----------- |
| `value, err = cache:get(key, opts?, cb, ...)` | 从缓存中检索值。如果缓存没有值（未命中）,在保护模式下调用`cb`。`cb`必须返回一个（并且只有一个）将被缓存的值。它可能会抛出错误，因为这些错误会被Kong捕获并正确记录在`ngx.ERR`级别。 此函数会缓存否定结果（nil）。因此，在检查错误时必须依赖其第二个参数`err`。| 
| `ttl, err, value = cache:probe(key)` | 检查是否缓存了值。如果是，则返回其剩余的TTL。它没有，返回零。
缓存的值也可以是负缓存。第三个返回值是被缓存的值本身。 | 
| `cache:invalidate_local(key)`| 从节点缓存中移除一个值。 |
| `cache:invalidate(key)` | 从节点的缓存中删除一个值，并将删除事件传播到集群中的所有其他节点。 |
| `cache:purge()` | 从节点缓存中删除所有值。 |

回到我们的身份验证插件示例，要查找具有特定api-key的凭据，我们将编写类似于:

```
-- access.lua

local function load_entity_key(api_key)
  -- 重要: 回调是在锁中执行的，因此我们不能在这里终止请求，我们必须始终返回。
  local apikeys, err = kong.dao.apikeys:find_all({key = api_key}) -- Lookup in the datastore
  if err then
    error(err) -- 被kong.cache捕获并记录
  end

  if not apikeys then
    return nil -- 没有找到 (cached for `neg_ttl`)
  end

  -- 假设键是唯一的，我们总是只有一个值…
  return apikeys[1] -- cache the credential (cached for `ttl`)
end

-- 从请求querystring检索apikey
local querystring = kong.request.get_query()
local apikey = querystring.apikey

-- 我们使用缓存。首先检查apikey是否已经存在
-- 存储在内存缓存中的键值为:“apikeys”。. .apikey
-- 如果不是，则查找数据存储并返回凭据对象。
-- 内部缓存。get将把值保存在内存中，然后返回凭据。
local credential, err = kong.cache:get("apikeys." .. apikey, nil,
                                       load_entity_key, apikey)
if err then
  return kong.response.exit(500, "Unexpected error: " .. err)
end

if not credential then
  -- 缓存和数据存储中没有凭据
  return kong.response.exit(403, "Invalid authentication credentials")
end

-- 如果凭据存在且有效，则设置上游标头
kong.service.request.set_header("X-API-Key", credential.apikey)
```

注意，在上面的示例中，我们使用插件开发工具包中的各种组件与请求、缓存模块交互，甚至从插件生成响应。    
现在，有了上面的机制，一旦使用者使用API键发出请求，缓存就会被认为是热的，随后的请求不会导致数据库查询。
在Key-Auth插件处理程序中，缓存用于多个位置。让我们来看看官方插件是如何使用缓存的。

### 更新或者删除一个缓存实体

每次在数据存储中更新或删除缓存的自定义实体(即使用Admin API)时，都会在数据存储中的数据与缓存在Kong节点内存中的数据之间产生不一致。为了避免这种不一致，我们需要从内存存储中删除缓存的实体，并强制Kong从数据存储中再次请求它。我们将此过程称为缓存失效。

## 缓存失效

如果希望缓存的实体在CRUD操作时失效，而不是等待它们到达TTL，则必须执行以下步骤。对于大多数实体，这个过程都可以自动化，但是手动订阅一些CRUD事件可能需要使一些具有更复杂关系的实体失效。

### 自动缓存失效

如果依赖于实体模式的cache_key属性，则可以为实体提供开箱即用的缓存失效。例如，在下面的模式中:
```
local SCHEMA = {
  primary_key = { "id" },
  table = "keyauth_credentials",
  cache_key = { "key" }, -- 此实体的缓存键
  fields = {
    id = { type = "id" },
    created_at = { type = "timestamp", immutable = true },
    consumer_id = { type = "id", required = true, foreign = "consumers:id"},
    key = { type = "string", required = false, unique = true }
  }
}

return { keyauth_credentials = SCHEMA }
```

我们可以看到，我们将这个`API key`实体的缓存键声明为它的`key`属性。这里使用`key`是因为它有一个唯一的约束。因此，添加到`cache_key`的属性应该产生唯一的组合，这样就不会有两个实体产生相同的缓存键。  
添加此值允许您在该实体的DAO上使用以下函数:
```
cache_key = kong.db.<dao>:cache_key(arg1, arg2, arg3, ...)
```
其中参数必须是模式的`cache_key`属性中指定的属性，按照指定的顺序，然后，此函数计算确保唯一的字符串值`cache_key`。  
例如，如果我们要生成API密钥的cache_key：
```
local cache_key = kong.db.keyauth_credentials:cache_key("abcd")
```
这将为API密钥`“abcd”`（从查询的一个参数中检索）生成一个cache_key，我们可以使用它来从缓存中检索密钥（如果缓存是未命中，则从数据库中获取）：
```
local apikey = kong.request.get_query().apikey
local cache_key = kong.db.keyauth_credentials:cache_key(apikey)

local credential, err = kong.cache:get(cache_key, nil, load_entity_key, apikey)
if err then
  return kong.response.exit(500, "Unexpected error: " .. err)
end

-- do something with the credential
```
如果`cache_key`是这样生成的并且在实体的模式中指定，则缓存失效将是一个自动过程：影响此API密钥的每个CRUD操作都将使make生成受影响的`cache_key`，并将其广播到群集上的所有其他节点，以便他们可以从缓存中逐出该特定值，并在下一个请求中从数据存储区中获取新值。

当父实体正在接收CRUD操作时（例如，拥有此API密钥的消费者，根据我们的模式的consumer_id属性），Kong为父实体和子实体执行缓存失效机制。

注意：请注意Kong提供的负面缓存。在上面的示例中，如果给定密钥的数据存储区中没有API密钥，则缓存模块将存储未命中，就像它是命中一样。这意味着Kong也会传播“创建”事件（使用此给定密钥创建API密钥的事件），以便存储未命中的所有节点都可以驱逐它，并从数据存储中正确地获取新创建的API密钥。

请参阅[群集指南](https://docs.konghq.com/1.1.x/clustering/)以确保为此类失效事件正确配置了群集。

### 手动缓存失效

在某些情况下，实体架构的`cache_key`属性不够灵活，并且必须手动使其缓存无效。原因可能是插件没有通过传统的`foreign =“parent_entity：parent_attribute”`语法定义与另一个实体的关系，或者因为它没有使用来自其DAO的`cache_key`方法，或者甚至因为它以某种方式滥用缓存机制。

在这些情况下，您可以手动将自己的订户设置为Kong正在收听的相同失效频道，并执行您自己的自定义失效工作。

要监听Kong内部的失效通道，请在插件的init_worker处理程序中实现以下内容：
```
function MyCustomHandler:init_worker()
  -- listen to all CRUD operations made on Consumers
  kong.worker_events.register(function(data)

  end, "crud", "consumers")

  -- or, listen to a specific CRUD operation only
  kong.worker_events.register(function(data)
    kong.log.inspect(data.operation)  -- "update"
    kong.log.inspect(data.old_entity) -- old entity table (only for "update")
    kong.log.inspect(data.entity)     -- new entity table
    kong.log.inspect(data.schema)     -- entity's schema
  end, "crud", "consumers:update")
end
```

一旦上述侦听器适用于所需的实体，您就可以根据需要对插件已缓存的任何实体执行手动失效。
例如：
```
kong.worker_events.register(function(data)
  if data.operation == "delete" then
    local cache_key = data.entity.id
    kong.cache:invalidate("prefix:" .. cache_key)
  end
end, "crud", "consumers")
```

## 扩展Admin API

您可能已经知道，Admin API是Kong用户与Kong通信以设置其API和插件的地方。他们可能还需要能够与您为插件实现的自定义实体进行交互（例如，创建和删除API密钥）。这样做的方法是扩展Admin API，我们将在下一章详细介绍：[扩展Admin API](https://docs.konghq.com/1.1.x/plugin-development/admin-api/)。















