[toc]



# 一：迁移docker工作目录

> **目的：为了解决 /var/lib/docker/overlay2 占用大 /var 分区空间不够问题**

一、查看docker默认目录的方法
docker默认目录为/var/lib/docker，可以通过下面的方法查看

```
 docker info |grep "Docker Root Dir"
 Docker Root Dir: /var/lib/docker
1.查看docker镜像存放目录空间大小
du -sh /var/lib/docker/
```

- 方法1:

```
二、停止docker服务并移动原有docker文件到新目录
systemctl stop docker.service
mkdir -p /opt/soft/
mv /var/lib/docker /home/docker/lib/

## 三、重新设置 Docker Root Dir 
/opt/soft/docker
vi /usr/lib/systemd/system/docker.service
# 在 ExecStart=/usr/bin/dockerd 后追加 --graph=/home/docker，注意如果本来后面有其他参数不要搞乱了
# 示例如下（后面其他参数是我个人配置别的使用的请忽略）
ExecStart=/usr/bin/dockerd --graph=/opt/soft/docker -H fd:// --containerd=/run/containerd/containerd.sock

## 四、重新加载配置启动服务
systemctl daemon-reload
systemctl start docker.service
```

- 方法2:

```
##4.也可以通过这个命令同步
rsync -avz /var/lib/docker /home/docker/lib

5.编辑 /etc/docker/daemon.json 添加如下参数
{
  "graph":"/data/docker/lib/docker"
}
6.重新加载docker，并重启docker服务。
systemctl daemon-reload && systemctl restart docker
7.检查docker是否变更为新目录：/docker/lib/docker
8.删掉docker旧目录
rm -rf /var/lib/docker
```

**附其他几个相关命令**

```
# 类似于Linux上的df命令，用于查看Docker的磁盘使用情况
docker system df

# 用于清理磁盘，删除关闭的容器、无用的数据卷和网络，以及dangling镜像（即无tag的镜像）
docker system prune

# 清理得更加彻底，可以将没有容器使用Docker镜像都删掉（请慎重操作）
docker system prune -a

# 列出所有虚悬（dangling）镜像，也就是 TAG 为 <none> 的
docker images -f dangling=true
```



# 二：Docker的数据卷(Volume)

> 将docker数据挂载到容器[docker volume inspect](https://docs.docker.com/engine/reference/commandline/volume_inspect/) 

在Docker中，要想实现数据的持久化（所谓Docker的数据持久化即***数据不随着Container的结束而结束***），需要将数据从宿主机挂载到容器中。目前Docker提供了三种不同的方式将数据从宿主机挂载到容器中：

（1）volumes：Docker管理宿主机文件系统的一部分，默认位于 /var/lib/docker/volumes 目录中；（**最常用的方式**）

![image-20210520104814809](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210520104814809.png)

由上图可以知道，目前所有Container的数据都保存在了这个目录下边，由于没有在创建时指定卷，所以Docker帮我们默认创建许多匿名（就上面这一堆很长ID的名字）卷。

（2）bind mounts：意为着可以存储在宿主机系统的任意位置；（**比较常用的方式**）

　　但是，bind mount在不同的宿主机系统时不可移植的，比如Windows和Linux的目录结构是不一样的，bind mount所指向的host目录也不能一样。这也是为什么bind mount不能出现在Dockerfile中的原因，因为这样Dockerfile就不可移植了。

（3）tmpfs：挂载存储在宿主机系统的内存中，而不会写入宿主机的文件系统；（**一般都不会用的方式**）

## 2.1: 简单使用

### 2.1.1:  管理卷

```
# docker volume create snail_portainer// 创建一个自定义容器卷
# docker volume ls // 查看所有容器卷
# docker volume inspect edc-nginx-vol // 查看指定容器卷详情信息
```

　　例如，这里我们创建一个自定义的容器卷，名为"snail_portainer"：





## 编写dockerFilee文件

```
FROM ubuntu
VOLUME ["/data","/data/snail1","/data/snail2"]
CMD echo "i finshed.."
CMD /bin/bash
~                                                                              
```

![image-20210530001145258](/Users/snailzhou/Library/Application Support/typora-user-images/image-20210530001145258.png)

![image-20210530001400121](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210530001400121.png)





## 三：Docker开启远程访问API(2375端口)

docker daemon(docker守护进程)是一个运行在宿主机（DOCKER-HOST）的后台进程，可通过 docker client(docker客户端)与之通信。Docker守护进程可以通过三种不同类型的套接字监听Docker引擎API请求：unix、tcp和fd。上面还提到如果需要远程访问Docker守护进程，则需要启用tcp套接字。请注意，默认设置提供对Docker守护进程的未加密和未经身份验证的直接访问，应该使用内置的HTTPS加密套接字或在其前面放置一个安全的web代理来进行保护

### 3.1:Mac环境下

有款叫socat的网络工具提供的镜像来做docker for Mac的远程访问：

> https://hub.docker.com/r/alpine/socat
>
> ```
> $ docker pull alpine/socat
> $ docker run -d --restart=always \
>     -p 127.0.0.1:2376:2375 \
>     -v /var/run/docker.sock:/var/run/docker.sock \
>     alpine/socat \
>     tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
> ```





## 3.2:Linux 环境下

vi /usr/lib/systemd/system/docker.service

在docker.service中找到 ExecStart，在最后面添加 -H tcp://0.0.0.0:2375然后重启docker daemon和docker，

当然还要防火墙放开2375端口：

```
添加指定需要开放的端口：
firewall-cmd --add-port=2375/tcp --permanent
重载入添加的端口：
firewall-cmd --reload
查询指定端口是否开启成功：
firewall-cmd --query-port=2375/tcp

systemctl daemon-reload
systemctl start docker
```

