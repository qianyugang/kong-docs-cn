### Plugin Development Guide
1. Implementing custom logic
kong.plugins.<plugin_name>.<module_name>
2. (un)Installing your plugin in kong.conf
```
lua_package_path = /etc/?.lua;./?.lua;./?/init.lua;;
plugins = bundled,my-custom-plugin
```
3. Enabling custom plugins
- prepare route&service: example-service
```
curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=example-service' \
  --data 'url=http://mockbin.org/request'

curl -i -X POST \
  --url http://localhost:8001/services/example-service/routes \
  --data 'hosts[]=example.com'
```
- enable custom plugin
```
curl -i -X POST \
  --url http://localhost:8001/services/example-service/plugins/ \
  --data 'name=my-custom-plugin' \
  -d "config.environment=development"
```
- use custom plugin
```
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com'
```

### Test Kong Cache
#### Update Redis Value
```
> docker exec -it redis redis-cli
> hset ht field val_original
``` 
Check value of `X-API-Key` after sending request

1. get data from redis and pass to upsteam service
```
hset ht field val0
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com' \
  --header 'x-cache-auth: cache_name' 
```
2. update data in redis and check kong cache data
```
hset ht field val1
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com' \
  --header 'x-cache-auth: cache_name'
```
3. clear and reset kong cache data
```
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com' \
  --header 'x-del-auth: cache_name'
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: example.com' \
  --header 'x-cache-auth: cache_name'
```

