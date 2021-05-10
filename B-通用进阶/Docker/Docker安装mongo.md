# 安装

> 运行启动命令“docker run -p 27017:27017 -v /data/mongo:/data/db --name mongodb -d mongo”
>
> docker run -p 27018:27017 -v /Users/snailzhou/softData/dockerDatas/mongo/data:/data/db --name mongodb -d mongo --auth
>
> 在上面的命令中，几个命令参数的详细解释如下：
>
> -p 映射容器服务的 27017 端口到宿主机的 27017 端口。外部可以直接通过 宿主机 ip:27017 访问到 mongo 的服务
>
> -v 为设置容器的挂载目录，这里是将本机的“/data/mongo”目录挂载到容器中的/data/db中，作为 mongodb 的存储目录
>
> --name 为设置该容器的名称
>
> -d 设置容器以守护进程方式运行

- 接着使用以下命令添加用户和设置密码，并且尝试连接。

```
$ docker exec -it mongodb mongo admin
# 创建一个名为 admin，密码为 123456 的用户。
>  db.createUser({ user:'admin',pwd:'123456',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
# 尝试使用上面创建的用户信息进行连接。
> db.auth('admin', '123456')
```