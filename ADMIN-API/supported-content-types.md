# 支持的Content Types

Admin API在每个端点上接受2种内容类型：

- application/x-www-form-urlencoded
	对于基本请求主体来说足够简单，您可能会在大多数时间使用它。请注意，在发送嵌套值时，Kong期望使用虚线键引用嵌套对象。例：
    ```
    config.limit=10&config.period=seconds
    ```
- application/json
	方便复杂的主体（例如：复杂的插件配置），在这种情况下，只需发送您要发送的数据的JSON表示。例：
    ```
    {
    "config": {
        "limit": 10,
        "period": "seconds"
    	}
	}
    ```