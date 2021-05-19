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



