# 日志

## 日志等级

日志级别在Kong的配置中设置。以下是日志级别，按照严重程度顺序递增，`debug`, `info`, `notice`, `warn`, `error` and `crit`。

- `debug`:它提供有关插件的runloop和每个插件或其他组件的调试信息。只是在调试期间使用，因为它的消息量太多了。
- `info`/`notice`:kong没有在这两个级别上产生很大的差异。提供有关正常行为的信息，其中大多数行为可以忽略。
- `warn`:要记录任何不会导致事务丢失但需要进一步调查的异常行为，应使用警告级别。
- `error`:用于记录导致请求被停止的错误（例如，获取HTTP 500错误）。需要监控此类日志的速率。
- `crit`:当Kong在紧急条件下工作而不能正常工作从而影响多个客户时，使用此级别。

默认情况下，`notice`是使用和建议的日志级别。然而，如果日志变得过于繁琐，他们可能会被提升到更高的水平，就像`warn`一样。

## 从Kong日志中删除某些元素

随着围绕保护私人数据（如GDPR）的新规定，您可能需要改变您的日志记录习惯。如果您使用Kong作为API网关，则可以在一个位置完成此操作以使所有API生效。本指南将引导您完成一个实现此目的的方法，但总有不同的方法来满足不同的需求。请注意，这些更改将影响NGINX访问日志的输出。这对Kong的日志插件没有任何影响。

举个例子，假设您要从kong日志中删除任何电子邮件地址实例。电子邮件地址可能以不同的方式出现，例如`/apiname/v2/verify/alice@example.com` 或者 `/v3/verify?alice@example.com`。为了防止这些被添加到日志中，我们需要使用自定义NGINX模板。

要开始使用自定义NGINX模板，请先获取我们模板的副本。
这可以在 https://docs.konghq.com/latest/configuration/#custom-nginx-templates-embedding-kong 找到或从下面复制
```
# ---------------------
# custom_nginx.template
# ---------------------

worker_processes $; # can be set by kong.conf
daemon $;                     # can be set by kong.conf

pid pids/nginx.pid;                      # this setting is mandatory
error_log logs/error.log $; # can be set by kong.conf

events {
    use epoll; # custom setting
    multi_accept on;
}

http {
    # include default Kong Nginx config
    include 'nginx-kong.conf';

    # custom server
    server {
        listen 8888;
        server_name custom_server;

        location / {
          ... # etc
        }
    }
}
```

为了控制日志中的内容，我们将在模板中使用NGINX 的map模块。有关使用map指令的更多详细信息，[请参阅本指南](http://nginx.org/en/docs/http/ngx_http_map_module.html)。这将创建一个新变量，其值取决于第一个参数中指定的一个或多个源变量的值。格式为：
```
map $paramater_to_look_at $variable_name {
    pattern_to_look_for 0;
    second_pattern_to_look_for 0;

    default 1;
}
```
举个例子，我们将映射一个名为`keeplog`的新变量，该变量依赖于`$request_uri`中出现的某些值。我们将把map指令放在http块的开头，这必须在 `include'nginx-kong.conf'` 之前。因此，对于我们的示例，我们将添加以下内容：
```
map $request_uri $keeplog {
    ~.+\@.+\..+ 0;
    ~/servicename/v2/verify 0;
    ~/v3/verify 0;

    default 1;
}
```

您可能会注意到这些行中的每一行都以波形符号开头。这就是NGINX在评估生产线时使用RegEx的原因。
在这个例子中我们有三件事需要寻找：

- 第一行使用正则表达式查找x@y.z格式的任何电子邮件地址
- 第二行查找URI的任何部分，即/servicename/v2/verify
- 第三行查看包含/v3/verify的URI的任何部分

因为所有这些都具有0以外的值，如果请求具有其中一个元素，则不会将其添加到日志中。

现在，我们需要为日志中保留的内容设置日志格式。我们将使用`log_format`模块并为我们的新日志指定show_everything的名称。日志的内容可以根据您的需要进行定制，但在这个例子中，我会简单地将一切改回kong标准，要查看可以使用的完整选项列表，请[参阅本指南](https://nginx.org/en/docs/http/ngx_http_core_module.html#variables)。
```
log_format show_everything '$remote_addr - $remote_user [$time_local] '
    '$request_uri $status $body_bytes_sent '
    '"$http_referer" "$http_user_agent"';
```
现在，我们的自定义NGINX模板已经可以使用了。如果您一直观察，您的文件现在应该如下所示：
```
# ---------------------
# custom_nginx.template
# ---------------------

worker_processes $; # can be set by kong.conf
daemon $;                     # can be set by kong.conf

pid pids/nginx.pid;                      # this setting is mandatory
error_log stderr $; # can be set by kong.conf



events {
    use epoll; # custom setting
    multi_accept on;
}

http {


    map $request_uri $keeplog {
        ~.+\@.+\..+ 0;
        ~/v1/invitation/ 0;
        ~/reset/v1/customer/password/token 0;
        ~/v2/verify 0;

        default 1;
    }
    log_format show_everything '$remote_addr - $remote_user [$time_local] '
        '$request_uri $status $body_bytes_sent '
        '"$http_referer" "$http_user_agent"';

    include 'nginx-kong.conf';
}
```

我们需要做的最后一件事是告诉Kong使用新创建的日志，`show_everything`，为此，我们将改变Kong变量`prpxy_access_log`。通过打开和编辑`etc/kong/kong.conf`或使用环境变量` KONG_PROXY_ACCESS_LOG= `来修改默认位置以显示。
```
proxy_access_log=logs/access.log show_everything if=$keeplog
```

最后一步，重启kong，使修改东西都生效，你可以使用`kong restart`命令来操作。

现在，将不再记录使用其中的电子邮件地址发出的任何请求。
当然，我们可以使用此逻辑以条件方式从日志中删除任何我们想要的内容。


















