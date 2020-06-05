# Kong 2.0 升级指南

原文地址：https://docs.konghq.com/2.0.x/upgrading/  （不能保证所有的翻译都是准确无误的，所有如有翻译的不准确或错误之处，请一定记得查看原文，并欢迎留言指出）

注意: 下面是2.0.x的升级指南。如果您试图升级到早期版本的Kong，请阅读[upgrade.md](UPGRADE.md file in the Kong repo)文件。

本指南将告诉您在升级时应该注意的重大更改，并指导您完成正确的步骤顺序，以便在不同的升级场景中实现无停机迁移。


# 升级到 2.0.0

Kong坚持语义化版本，区分“主要”、“次要”和“补丁”版本。升级路径与您要迁移的前一个版本不同。升级到2.0。是一个主要的版本升级，所以要注意在[CHANGELOG.md](https://github.com/Kong/kong/blob/2.0.0/CHANGELOG.md)文档中列出的任何重大更改。


## 1. 依赖项

如果您正在使用已提供的二进制包，那么所有必要的依赖项都已绑定，可以跳过此部分。

如果您是手动构建您的依赖项，那么自上一个版本以来有一些更改，因此您将需要使用最新的补丁重新构建它们。

所需的OpenResty版本是[1.15.8.2](http://openresty.org/en/changelog-1015008.html)，其中包含的OpenResty补丁集已经改变，包括最新版本的[lua-kong-nginx-module](lua-kong-nginx-module)。我们的[kong-build-tools](https://github.com/Kong/kong-build-tools)库允许您轻松地使用必要的补丁和模块构建OpenResty。

对于GO的支持，你还需要[Kong go-pluginserver](https://github.com/kong/go-pluginserver)。这是与Kong二进制包绑定的，如果在Kong的配置中启用Go插件支持，它会自动启动。注意，用于编译任何Go插件的Go版本需要匹配`go-pluginserver`的Go版本。可以检查用于构建运行`go-pluginserver`版本的`gopluginserver`二进制文件的Go版本。

## 2. 重大修改项

Kong 2.0.0包含了对Kong 1.x的一些重大更改，且都和移除Service Mesh相关：

- **删除了Service Mesh支持**：在Kong 1.4中已经被弃用了，并且默认设置了，现在代码已经在2.0中直接去掉。对于Service Mesh，我们现在有了Kuma，这是从一开始就为Mesh模式设计的，所以我们对移除Kong的本地Service Mesh功能感到放心，并专注于其作为网关的核心功能。
- 作为服务网格移除的一部分，无服务代理被移除。在创建用于无服务器插件(如`aws-lambda`或`request-termination`)的路由时，您仍然可以设置`service = null`。
- 移除 `origins` 属性。
- 移除 `transparent` 属性。
- 移除了用于服务网格的 Sidecar Injector plugin 插件。
- **NGINX 配置文件改变**：这意味着如果您使用自定义模板，则需要对其进行更新。改进了流模式支持，使Nginx注入系统更加强大，这样定制模板就不那么必要了。下面的差异中详细介绍了这些变化。
    - **警告**：注意`kong_cache` shm被分割成两个shm: `kong_core_cache`和k`ong_cache`。如果使用自定义Nginx模板，请确保定义了核心缓存共享字典，包括无数据库模式阴影定义。这两个缓存值都依赖于已经存在的`mem_cache_size`配置选项来设置它们的大小，因此当从以前的Kong版本升级时，如果不调整该值，缓存内存消耗可能会翻倍。

Nginx 配置改变如下：

```
diff --git a/kong/templates/nginx_kong.lua b/kong/templates/nginx_kong.lua
index 5c6c1db03..6b4b4a818 100644
--- a/kong/templates/nginx_kong.lua
+++ b/kong/templates/nginx_kong.lua
@@ -5,52 +5,46 @@ server_tokens off;
 > if anonymous_reports then
 $
 > end
-
 error_log $ $;

-> if nginx_optimizations then
->-- send_timeout 60s;          # default value
->-- keepalive_timeout 75s;     # default value
->-- client_body_timeout 60s;   # default value
->-- client_header_timeout 60s; # default value
->-- tcp_nopush on;             # disabled until benchmarked
->-- proxy_buffer_size 128k;    # disabled until benchmarked
->-- proxy_buffers 4 256k;      # disabled until benchmarked
->-- proxy_busy_buffers_size 256k; # disabled until benchmarked
->-- reset_timedout_connection on; # disabled until benchmarked
-> end
-
-client_max_body_size $;
-proxy_ssl_server_name on;
-underscores_in_headers on;
-
 lua_package_path       '$;;';
 lua_package_cpath      '$;;';
 lua_socket_pool_size   $;
+lua_socket_log_errors  off;
 lua_max_running_timers 4096;
 lua_max_pending_timers 16384;
+lua_ssl_verify_depth   $;
+> if lua_ssl_trusted_certificate then
+lua_ssl_trusted_certificate '$';
+> end
+
 lua_shared_dict kong                        5m;
+lua_shared_dict kong_locks                  8m;
+lua_shared_dict kong_healthchecks           5m;
+lua_shared_dict kong_process_events         5m;
+lua_shared_dict kong_cluster_events         5m;
+lua_shared_dict kong_rate_limiting_counters 12m;
+lua_shared_dict kong_core_db_cache          $;
+lua_shared_dict kong_core_db_cache_miss     12m;
 lua_shared_dict kong_db_cache               $;
-> if database == "off" then
-lua_shared_dict kong_db_cache_2     $;
-> end
 lua_shared_dict kong_db_cache_miss          12m;
 > if database == "off" then
+lua_shared_dict kong_core_db_cache_2        $;
+lua_shared_dict kong_core_db_cache_miss_2   12m;
+lua_shared_dict kong_db_cache_2             $;
 lua_shared_dict kong_db_cache_miss_2        12m;
 > end
-lua_shared_dict kong_locks          8m;
-lua_shared_dict kong_process_events 5m;
-lua_shared_dict kong_cluster_events 5m;
-lua_shared_dict kong_healthchecks   5m;
-lua_shared_dict kong_rate_limiting_counters 12m;
 > if database == "cassandra" then
 lua_shared_dict kong_cassandra              5m;
 > end
-lua_socket_log_errors off;
-> if lua_ssl_trusted_certificate then
-lua_ssl_trusted_certificate '$';
+> if role == "control_plane" then
+lua_shared_dict kong_clustering             5m;
+> end
+
+underscores_in_headers on;
+> if ssl_ciphers then
+ssl_ciphers $;
 > end
-lua_ssl_verify_depth $;

 # injected nginx_http_* directives
 > for _, el in ipairs(nginx_http_directives) do
@@ -66,61 +60,47 @@ init_worker_by_lua_block {
     Kong.init_worker()
 }

-
-> if #proxy_listeners > 0 then
+> if (role == "traditional" or role == "data_plane") and #proxy_listeners > 0 then
 upstream kong_upstream {
     server 0.0.0.1;
     balancer_by_lua_block {
         Kong.balancer()
     }

-# injected nginx_http_upstream_* directives
-> for _, el in ipairs(nginx_http_upstream_directives) do
+    # injected nginx_upstream_* directives
+> for _, el in ipairs(nginx_upstream_directives) do
     $(el.name) $(el.value);
 > end
 }

 server {
     server_name kong;
-> for i = 1, #proxy_listeners do
-    listen $(proxy_listeners[i].listener);
+> for _, entry in ipairs(proxy_listeners) do
+    listen $(entry.listener);
 > end
+
     error_page 400 404 408 411 412 413 414 417 494 /kong_error_handler;
     error_page 500 502 503 504                     /kong_error_handler;

     access_log $;
     error_log  $ $;

-    client_body_buffer_size $;
-
 > if proxy_ssl_enabled then
     ssl_certificate     $;
     ssl_certificate_key $;
+    ssl_session_cache   shared:SSL:10m;
     ssl_certificate_by_lua_block {
         Kong.ssl_certificate()
     }
-
-    ssl_session_cache shared:SSL:10m;
-    ssl_session_timeout 10m;
-    ssl_prefer_server_ciphers on;
-    ssl_ciphers $;
-> end
-
-> if client_ssl then
-    proxy_ssl_certificate $;
-    proxy_ssl_certificate_key $;
-> end
-
-    real_ip_header     $;
-    real_ip_recursive  $;
-> for i = 1, #trusted_ips do
-    set_real_ip_from   $(trusted_ips[i]);
 > end

     # injected nginx_proxy_* directives
 > for _, el in ipairs(nginx_proxy_directives) do
     $(el.name) $(el.value);
 > end
+> for i = 1, #trusted_ips do
+    set_real_ip_from  $(trusted_ips[i]);
+> end

     rewrite_by_lua_block {
         Kong.rewrite()
@@ -171,43 +151,93 @@ server {
         proxy_pass_header     Server;
         proxy_pass_header     Date;
         proxy_ssl_name        $upstream_host;
+        proxy_ssl_server_name on;
+> if client_ssl then
+        proxy_ssl_certificate $;
+        proxy_ssl_certificate_key $;
+> end
         proxy_pass            $upstream_scheme://kong_upstream$upstream_uri;
     }

     location @grpc {
         internal;
+        default_type         '';
         set $kong_proxy_mode 'grpc';

+        grpc_set_header      TE                $upstream_te;
         grpc_set_header      Host              $upstream_host;
         grpc_set_header      X-Forwarded-For   $upstream_x_forwarded_for;
         grpc_set_header      X-Forwarded-Proto $upstream_x_forwarded_proto;
         grpc_set_header      X-Forwarded-Host  $upstream_x_forwarded_host;
         grpc_set_header      X-Forwarded-Port  $upstream_x_forwarded_port;
         grpc_set_header      X-Real-IP         $remote_addr;
-
+        grpc_pass_header     Server;
+        grpc_pass_header     Date;
         grpc_pass            grpc://kong_upstream;
     }

     location @grpcs {
         internal;
+        default_type         '';
         set $kong_proxy_mode 'grpc';

+        grpc_set_header      TE                $upstream_te;
         grpc_set_header      Host              $upstream_host;
         grpc_set_header      X-Forwarded-For   $upstream_x_forwarded_for;
         grpc_set_header      X-Forwarded-Proto $upstream_x_forwarded_proto;
         grpc_set_header      X-Forwarded-Host  $upstream_x_forwarded_host;
         grpc_set_header      X-Forwarded-Port  $upstream_x_forwarded_port;
         grpc_set_header      X-Real-IP         $remote_addr;
-
+        grpc_pass_header     Server;
+        grpc_pass_header     Date;
+        grpc_ssl_name        $upstream_host;
+        grpc_ssl_server_name on;
+> if client_ssl then
+        grpc_ssl_certificate $;
+        grpc_ssl_certificate_key $;
+> end
         grpc_pass            grpcs://kong_upstream;
     }

+    location = /kong_buffered_http {
+        internal;
+        default_type         '';
+        set $kong_proxy_mode 'http';
+
+        rewrite_by_lua_block       {;}
+        access_by_lua_block        {;}
+        header_filter_by_lua_block {;}
+        body_filter_by_lua_block   {;}
+        log_by_lua_block           {;}
+
+        proxy_http_version 1.1;
+        proxy_set_header      TE                $upstream_te;
+        proxy_set_header      Host              $upstream_host;
+        proxy_set_header      Upgrade           $upstream_upgrade;
+        proxy_set_header      Connection        $upstream_connection;
+        proxy_set_header      X-Forwarded-For   $upstream_x_forwarded_for;
+        proxy_set_header      X-Forwarded-Proto $upstream_x_forwarded_proto;
+        proxy_set_header      X-Forwarded-Host  $upstream_x_forwarded_host;
+        proxy_set_header      X-Forwarded-Port  $upstream_x_forwarded_port;
+        proxy_set_header      X-Real-IP         $remote_addr;
+        proxy_pass_header     Server;
+        proxy_pass_header     Date;
+        proxy_ssl_name        $upstream_host;
+        proxy_ssl_server_name on;
+> if client_ssl then
+        proxy_ssl_certificate $;
+        proxy_ssl_certificate_key $;
+> end
+        proxy_pass            $upstream_scheme://kong_upstream$upstream_uri;
+    }
+
     location = /kong_error_handler {
         internal;
+        default_type                 '';
+
         uninitialized_variable_warn  off;

         rewrite_by_lua_block {;}
-
         access_by_lua_block  {;}

         content_by_lua_block {
@@ -215,13 +245,13 @@ server {
         }
     }
 }
-> end
+> end -- (role == "traditional" or role == "data_plane") and #proxy_listeners > 0

-> if #admin_listeners > 0 then
+> if (role == "control_plane" or role == "traditional") and #admin_listeners > 0 then
 server {
     server_name kong_admin;
-> for i = 1, #admin_listeners do
-    listen $(admin_listeners[i].listener);
+> for _, entry in ipairs(admin_listeners) do
+    listen $(entry.listener);
 > end

     access_log $;
@@ -233,11 +263,7 @@ server {
 > if admin_ssl_enabled then
     ssl_certificate     $;
     ssl_certificate_key $;
-
-    ssl_session_cache shared:SSL:10m;
-    ssl_session_timeout 10m;
-    ssl_prefer_server_ciphers on;
-    ssl_ciphers $;
+    ssl_session_cache   shared:AdminSSL:10m;
 > end

     # injected nginx_admin_* directives
@@ -265,20 +291,20 @@ server {
         return 200 'User-agent: *\nDisallow: /';
     }
 }
-> end
+> end -- (role == "control_plane" or role == "traditional") and #admin_listeners > 0

 > if #status_listeners > 0 then
 server {
     server_name kong_status;
-> for i = 1, #status_listeners do
-    listen $(status_listeners[i].listener);
+> for _, entry in ipairs(status_listeners) do
+    listen $(entry.listener);
 > end

     access_log $;
     error_log  $ $;

-    # injected nginx_http_status_* directives
-> for _, el in ipairs(nginx_http_status_directives) do
+    # injected nginx_status_* directives
+> for _, el in ipairs(nginx_status_directives) do
     $(el.name) $(el.value);
 > end

@@ -303,4 +329,26 @@ server {
     }
 }
 > end
+
+> if role == "control_plane" then
+server {
+    server_name kong_cluster_listener;
+> for _, entry in ipairs(cluster_listeners) do
+    listen $(entry.listener) ssl;
+> end
+
+    access_log off;
+
+    ssl_verify_client   optional_no_ca;
+    ssl_certificate     $;
+    ssl_certificate_key $;
+    ssl_session_cache   shared:ClusterSSL:10m;
+
+    location = /v1/outlet {
+        content_by_lua_block {
+            Kong.serve_cluster_listener()
+        }
+    }
+}
+> end -- role == "control_plane"
 ]]
 
```

## 3. 建议升级路径


### 从`0.x`升级到`2.0.0`

Kong 2.0.0支持迁移的最低版本是1.0.0。如果您是从低于0.14.1的版本迁移，那么首先需要迁移到0.14.1。然后，如果是从0.14.1开始迁移，请先升级到到1.5.0。

从0.14.1升级到1.5.0的步骤与从0.14.1升级到Kong 1.0的步骤相同。请遵循Kong 1.0建议升级路径中的“从0.14迁移步骤”中描述的步骤，并添加`kong migrations migrate-apis`命令，您可以使用该命令迁移保留`apis`配置。

当迁移到1.5.0之后，可以按照下面一节中的说明迁移到2.0.0。

### 从`1.0.0` - `1.5.0` 升级到 `2.0.0`

Kong 2.0.0支持无停机迁移模型。这意味着在迁移过程中，您将运行两个Kong集群，共享相同的数据库。(这有时被称为蓝/绿迁移模型。)

迁移的设计使得不需要完全复制数据。但这也意味着它们的设计方式使得新版Kong能够在迁移过程中使用数据，并且要以一种方式来完成它，使旧的Kong集群能够一直工作，直到它最终下线。由于这个原因，整个迁移现在分成两个步骤，通过命令`kong migrations up`(只执行非破性操作)和`kong migrations finish`(将数据库置于kong 2.0.0的最终预期状态)执行。

1. 下载2.0.0，并将其配置为指向与旧集群(1.0到1.5)相同的数据存储。运行`kong migration up`。
2. 一旦它完成运行，旧集群和新集群(2.0.0)现在可以在同一个数据存储上同时运行。开始供应2.0.0节点，但还不使用它们的管理API。如果需要执行管理API请求，应该对旧集群的节点执行这些请求。其原因是为了防止新集群生成旧集群无法识别的数据。
3. 逐渐将流量从旧节点转移到2.0.0集群中。监控你的流程以确保一切顺利。
4. 当您的流量完全迁移到2.0.0集群时，下线您的旧节点。
5. 在2.0.0集群中运行:`kong migration finish`。从现在起，将不能在旧集群中启动指向相同数据存储的节点。只有在确信迁移成功时才运行此命令。从现在开始，您可以安全地向2.0.0节点发出管理API请求。

### 在新的数据存储上安装2.0.0

下面的命令应该用于从新的数据存储准备新的2.0.0集群:

```
$ kong migrations bootstrap [-c config]
$ kong start [-c config]
```


