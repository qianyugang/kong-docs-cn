# kong.table

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.table/

Lua表的公用程序

## kong.table.new([narr[, nrec]])

返回一个表，其中包含预先分配的数组中的插槽数和散列部分。

- 参数
	- narr (number, optional): 指定要在数组部件中预分配的插槽数。
	- nrec (number, optional): 指定要在哈希部分中预分配的槽数。
- 返回
	- `table`新创建的table
- 用法
	```
    local tab = kong.table.new(4, 4)
    ```
    
## kong.table.clear(tab)

清除其所有数组和散列部分条目中的表。

- 参数 
	- tab (table): 将要被清理到table
- 返回
	- 无
- 用法
	```
    local tab = {
      "hello",
      foo = "bar"
	}

    kong.table.clear(tab)

    kong.log(tab[1]) -- nil
    kong.log(tab.foo) -- nil
    ```

