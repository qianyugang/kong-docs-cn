
## 介绍
提供的CLI（命令行界面Command Line Interface）允许启动，停止和管理Kong实例。CLI可以管理本地节点（如在当前计算机上）。

如果您还没有使用，我们建议您阅读[配置参考](https://docs.konghq.com/1.0.x/configuration)。

## 通用标志参数

所有命令都将一组特殊的可选标志作为参数：

- `--help`：打印此命令的帮助信息
- `--v`：启用详细模式
- `--vv`：启用调试模式（很多输出）

## 可用命令

### kong check

```
Usage: kong check <conf>

检查给定Kong配置文件的有效性。

<conf> (default /etc/kong/kong.conf) 配置文件

```

### kong health

```
Usage: kong health [OPTIONS]

验证Kong 的服务组件是否正常运行

Options:
 -p,--prefix      (可选参数) Kong运行位置的前缀

```

### kong migrations

```
Usage: kong migrations COMMAND [OPTIONS]

管理数据库迁移。

可用的命令如下：
  bootstrap                         引导数据库并运行全部迁移（初始化）。

  up                                运行新迁移。

  finish                            完成正在等待中的迁移命令，在执行`up`后。

  list                              列出已执行的迁移。

  reset                             重置数据库。

Options（可选）:
 -y,--yes                           假设提示“yes”，并运行非交互模式

 -q,--quiet                         忽略所有输出

 -f,--force                         依旧执行迁移，即使数据库报告已经执行过了。

 --db-timeout     (default 60)      超时时间，以秒为单位，所有数据库操作通用（包括Cassandra的schema consensus）。

 --lock-timeout   (default 60)      超时时间，以秒为单位, 节点等待领导节点迁移完成。

 -c,--conf        (optional string) 配置文件。

```

### kong prepare

此命令用来准备Kong前缀文件夹及其子文件夹和文件。

```
Usage: kong prepare [OPTIONS]

在配置的前缀目录中准备Kong前缀。这个命令可以用于从nginx二进制文件启动Kong而不使用`kong start`命令。

Example usage:
  kong migrations up
  kong prepare -p /usr/local/kong -c kong.conf
  nginx -p /usr/local/kong -c /usr/local/kong/nginx.conf

Options:
  -c,--conf       (optional string) 配置文件
  -p,--prefix     (optional string) 覆盖前缀目录
  --nginx-conf    (optional string) 自定义Nginx配置模板

```

### kong quit

```
Usage: kong quit [OPTIONS]

优雅地退出一个正在运行的Kong节点（Nginx和其他节点）在给定的前缀目录中配置的服务。

此命令将会向Nginx发送SIGQUIT信号，表示全部请求将在关闭之前完成处理。
如果达到超时延迟，则该节点将被强制执行停止（SIGTERM）

Options:
 -p,--prefix      (optional string) kong正在运行的前缀
 -t,--timeout     (default 10) 强制停止前的超时

```

### kong reload

```
Usage: kong reload [OPTIONS]

重新加载Kong节点（并启动其他已配置的服务）在给定的前缀目录中。

此命令将HUP信号发送到Nginx，它将生成workers（告知account配置变更），当他们处理完成当前的请求后就停止旧的。

Options:
  -c,--conf       (optional string) 配置文件
  -p,--prefix     (optional string) 覆盖前缀目录
  --nginx-conf    (optional string) 自定义Nginx配置模板

```

### kong restart

```
Usage: kong restart [OPTIONS]

重新启动Kong节点（以及其他配置的服务，如Serf）在给定的前缀目录中。

这个命令相当于同时执行`kong stop`和`kong start`。

Options:
 -c,--conf        (optional string)   配置文件
 -p,--prefix      (optional string)   Kong运行的前缀
 --nginx-conf     (optional string)   自定义Nginx配置模板
 --run-migrations (optional boolean)  可选地在DB上运行迁移
 --db-timeout     (default 60)
 --lock-timeout   (default 60)

```

### kong start

```
Usage: kong start [OPTIONS]

在配置中启动Kong（Nginx和其他配置的服务）。

Options:
 -c,--conf        (optional string)   配置文件。

 -p,--prefix      (optional string)   覆盖前缀目录。

 --nginx-conf     (optional string)   自定义Nginx配置模板。

 --run-migrations (optional boolean)  在开始之前运行迁移。

 --db-timeout     (default 60)      超时时间，以秒为单位，所有数据库操作通用（包括Cassandra的schema consensus）。

 --lock-timeout   (default 60)      超时时间，以秒为单位, 节点等待领导节点迁移完成。

```

### kong stop

```
Usage: kong stop [OPTIONS]

停止给定的正在运行的Kong节点（Nginx和其他已配置的服务）在指定的前缀目录。

此命令将SIGTERM信号发送到Nginx。

Options:
 -p,--prefix      (optional string) Kong运行的前缀

```

### kong version

```
Usage: kong version [OPTIONS]

打印kong的版本。
使用-a选项，将打印所有底层依赖项的版本。

Options:
 -a,--all         获取所有依赖项的版本

```

