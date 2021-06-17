[toc]



# 一: Docker  生产SSH服务的镜像

### 1.1 ubuntu 安装 curl

Docker镜像为了精简容量，默认删除这些信息，安装的时候又下面两种方式：

1. 使用 apt-get update 更新一次
2. 编辑/etc/apt/sources.list文件，将默认软件源改为国内的源

```
apt-get update
apt-get install curl
```

### 1.2 创建支持SSH服务的镜像

#### 基于commit 命令创建

```
docker commit CONTAINER [REPOSITORY[:TAG]]
```

1.启动ubuntu

```
docker run -it --name ssh ubuntu:14.04 /bin/bash
```

2.更新源(已更新的可忽略)

```
apt-get update
```

3.安装ssh

```
apt-get install openssh-server
```

如果速度慢可以改成国内源，具体源百度一下就有了，修改位置如下

```
vi /etc/apt/sources.list.d/163.list
```

4.启动ssh服务，需要/var/run/sshd存在，手动创建并启动服务

```
mkdir -p /var/run/sshd
/usr/sbin/sshd -D &
```

5.查看22端口(ssh 服务默认监听端口),看是否正常启动

```
netstat -tunlp
```

6.修改服务的安全登录配置，取消pam登录限制

```
sed -ri 's/session required pam_loginuid.so/#session required pam_loginuid.so/g' /etc/pam.d/sshd
```

7.当前这个容器 root 用户目录下建立.ssh目录，复制需要的公钥到 authorized_keys 文件

```
mkdir root/.ssh
vi /root/.ssh/authorized_keys
```

**注意：authorized_keys文件的权限很特殊需要设置为600，才可以**(具体原因后面补充)

```
chmod 600 authorized_keys
```

因为我是在虚拟机中创建的，所以我可以把虚拟机的公钥粘贴到authorized_keys文件中进行测试。

使用 ssh-keygen -t rsa 命令生成(dsa 不同的加密方式)

```
ssh-keygen -t dsa

cat /root/.ssh/id_rsa.pub

//复制粘贴到启动容器的authorized_keys中
```

8.创建自动启动ssh服务的run.sh,并添加可执行权限

```
vi /run.sh
chmod +x run.sh
```

内容为：

```
#!/bin/bash
/usr/sbin/sshd -D
```

9.退出容器

```
exit
```

10.保存镜像(上面容器运行的时候取名容器名为ssh)

```
//保存容器为镜像
docker commit ssh sshd:ubuntu

//查看镜像
docker images
```

11.启动一个新容器，并添加端口映射10022-->22. 10022为宿主机端口，22是容器ssh服务监听端口端口

```
docker run -p 10022:22 -d sshd:ubuntu /run.sh

//启动后查看运行情况
docker ps
```

12.虚拟机中测试连接情况

```
ssh 192.168.1.200 -p 10022
```

进去后敲ls命令的时候需要使用 /bin/ls （暂时没找到这个解决 后面补充）

#### 1.3 使用Dockerfile创建

1.创建一个sshd_ubuntu工作目录

```
mkdir sshd_ubuntu
```

2.创建Dockerfile 和 run.sh

```
cd sshd_ubuntu
touch Dockerfile run.sh
```

3.编写run.sh脚本

```
#!/bin/bash
/usr/sbin/sshd -D
```

4.编写authorized_keys文件

```
ssh-keygen -t rsa
...
cat ~/.ssh/id_rsa.pub > authorized_keys
```

5.编写Dockerfile文件

```
# 设置继承镜像
FROM ubuntu:14.04

# 提供一些作者信息
MAINTAINER from www.dockerpool.com by waitfish

# 下面开始运行命令
RUN apt-get update

# 安装ssh服务
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

# 取消pam限制
RUN sed -ri 's/session required pam_loginuid.so/#session required pam_loginuid.so/g' /etc/pam.d/sshd

# 复制配置文件到相应位置，并赋予脚本可执行权限
ADD authorized_keys /root/.ssh/authorized_keys
ADD run.sh /run.sh
RUN chmod 755 /run.sh

# 开放端口
EXPOSE 22

# 设置自启动命令
CMD ["/run.sh"]
```

6.创建镜像

在sshd_ubuntu目录下，使用docker build 命令来创建镜像，最后还需要加"."表示当前目录

```
docker build -t sshd:dockerfile .
```

7.运行容器

```
docker run -d -p 10022:22 sshd:dockerfile

docker ps
```

8.虚拟机中测试连接情况

```
ssh 192.168.1.200 -p 10022
```

在推出其他高效对容器维护之前，ssh服务还是比较重要的。比较适合生产环节。



# 二:一些常见命令

## 2.1重命名

> docker rename 旧容器名 新容器名

## 2.2 docker挂载

> ```
> # docker run -it -v /宿主机目录:/容器目录 镜像名 /bin/bash
> 
> 譬如我要启动一个centos容器，宿主机的/test目录挂载到容器的/soft目录，可通过以下方式指定：
> # docker run -it -v /test:/soft centos /bin/bash
> 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录。
> 
> 一、容器目录不可以为相对路径
> 二、宿主机目录如果不存在，则会自动生成
> # docker run -it -v test1:/soft centos /bin/bash
> 三、宿主机的目录如果为相对路
>      ・容器内的/soft目录挂载的是宿主机上的/var/lib/docker/volumes/test1/_data目录
>  
>      ・所谓的相对路径指的是/var/lib/docker/volumes/，
> 　　　　与宿主机的当前目录无关。
>  
> 四、如果在容器内修改了目录的属主和属组，那么对应的挂载点会跟着修改
> ```

这里-it是参数作用是：

**-i:** 以交互模式运行容器，通常与 -t 同时使用；

**-t:** 为容器重新分配一个伪输入终端，通常与 -i 同时使用；

就是容器与你的终端通信输入输出。

最后的/bin/bash是command参数。

这里一开始我搞错的地方是挂载方向，因此不理解到底有何用。

要知道，这句的意思是将宿主机目录挂载到容器里，这个方向要搞清，那么剩下的作用是什么的疑惑就搞清楚了。

这里把容器想成一个单独的系统，或者说电脑，而你的宿主机目录是一个U盘，挂载后，你往宿主机该目录里放文件，那么通过容器里对应目录便可以访问到此文件，不需要重新生成容器就可以在“容器外部”添加和修改某些文件，如我用Mythri工具检测智能合约漏洞，采用docker容器如下命令：docker run -v $(pwd):/tmp mythril/myth analyze /tmp/test.sol，将宿主机当前目录挂载到容器的tmp目录，则在容器中操作时tmp目录就是当前的目录，在当期目录中新建智能合约或者改变旧的合约如test.sol的内容，再通过analyze命令检测合约即可，既不用重新生成容器，也不需要知道容器的绝对路径从而将新合约复制进去，只需要复制到当前目录即可

## 2.3: 绑定挂载

1.run

https://www.cnblogs.com/wdliu/p/10429819.html

docker run [OPTIONS] IMAGE [COMMOND] [ARGS...]

OPTIONS 说明

	--name="容器新名字": 为容器指定一个名称；
	-d: 后台运行容器，并返回容器ID，也即启动守护式容器；
	-i：以交互模式运行容器，通常与 -t 同时使用；
	-t：为容器重新分配一个伪输入终端，通常与 -i 同时使用；
	-P: 随机端口映射；
	-p: 指定端口映射，有以下四种格式
	      ip:hostPort:containerPort
	      ip::containerPort
	      hostPort:containerPort
	      containerPort
	      
	  常用OPTIONS补足：
	  --name：容器名字
	  --network：指定网络
	  --rm：容器停止自动删除容器
	  -i：--interactive,交互式启动
	  -t：--tty，分配终端
	  -v：--volume,挂在数据卷
	  -d：--detach，后台运行
	  
	-d, --detach=false # 后台运行容器，并返回容器ID；
	-i, --interactive=false # 以交互模式运行容器，通常与 -t 同时使用；
	-t, --tty=false # 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
	-u, --user="" # 指定容器的用户
	-a, --attach=[] # 登录容器（必须是以docker run -d启动的容器）
	-w, --workdir="" # 指定容器的工作目录
	-c, --cpu-shares=0 # 设置容器CPU权重，在CPU共享场景使用
	-e, --env=[] # 指定环境变量，容器中可以使用该环境变量
	-m, --memory="" # 指定容器的内存上限
	-P, --publish-all=false # 指定容器暴露的端口
	-p, --publish=[] # 指定容器暴露的端口
	-h, --hostname="" # 指定容器的主机名
	-v, --volume=[] # 给容器挂载存储卷，挂载到容器的某个目录
	--volumes-from=[] # 给容器挂载其他容器上的卷，挂载到容器的某个目录
	--cap-add=[] # 添加权限，权限清单详见：http://linux.die.net/man/7/capabilities
	--cap-drop=[] # 删除权限，权限清单详见：http://linux.die.net/man/7/capabilities
	--cidfile="" # 运行容器后，在指定文件中写入容器PID值，一种典型的监控系统用法
	--cpuset="" # 设置容器可以使用哪些CPU，此参数可以用来容器独占CPU
	--device=[] # 添加主机设备给容器，相当于设备直通
	--dns=[] # 指定容器的dns服务器
	--dns-search=[] # 指定容器的dns搜索域名，写入到容器的/etc/resolv.conf文件
	--entrypoint="" # 覆盖image的入口点
	--env-file=[] # 指定环境变量文件，文件格式为每行一个环境变量
	--expose=[] # 指定容器暴露的端口，即修改镜像的暴露端口
	--link=[] # 指定容器间的关联，使用其他容器的IP、env等信息
	--lxc-conf=[] # 指定容器的配置文件，只有在指定--exec-driver=lxc时使用
	--name="" # 指定容器名字，后续可以通过名字进行容器管理，links特性需要使用名字
	--net="bridge" # 容器网络设置:
	    bridge  # 使用docker daemon指定的网桥
	    host  # 容器使用主机的网络
	    container:NAME_or_ID > # 使用其他容器的网路，共享IP和PORT等网络资源
	    none # 容器使用自己的网络（类似--net=bridge），但是不进行配置
	--privileged=false # 指定容器是否为特权容器，特权容器拥有所有的capabilities
	--restart="no" # 指定容器停止后的重启策略:
	    no # 容器退出时不重启
	    on-failure # 容器故障退出（返回值非零）时重启
	    always # 容器退出时总是重启
	--rm=false # 指定容器停止后自动删除容器(不支持以docker run -d启动的容器)
	--sig-proxy=true # 设置由代理接受并处理信号，但是SIGCHLD、SIGSTOP和SIGKILL不能被代理

> 1. \# eg: 使用镜像centos:latest以交互模式启动一个容器,在容器内执行/bin/bash命令。
> 2. docker run -it centos /bin/bash



# 三： docker 可视化工具

> https://juejin.cn/post/6847902192217620494
>
> 常见的可视化工具如`DockerUI`、`Shipyard`、`Rancher`、`Portainer`等。查看对比了一番，最后觉得`Portainer`还不错

## 3.1: Portainer

`Portainer`是一个轻量级的`Docker`环境管理UI，主要优点有：

- 轻量级，镜像只有几十M，相对其它UI工具来说十分轻巧；
- 使用方便，它也是一个`Docker`应用，直接拉取镜像后启动即可；
- 持续更新，作为优秀的开源项目，`GitHub`还在持续维护和更新；
- 功能齐全，如以下几点：
  - 完备的权限管理（团队、角色、用户控制）；
  - 镜像管理；
  - 容器管理；
  - 主机和集群状态显示；
  - 应用模板快速部署；
  - 事件日志显示；
  - 其它`Docker`相关功能等。

### 3.1.1：安装

先拉取最新的镜像：

```
$ docker pull portainer/portainer:latest
```

为`Portainer`创建一个`volume`：

```
$ docker volume create snail_portainer
```

一条命令启动：

```
$ docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v snail_portainer:/data portainer/portainer
```

注意`--restart=always`作用是`Docker`重启时，自动重启容器。

成功启动后，访问地址`http://localhost:9000/`就可以了。

### 3.1.2: 几个重要功能

第一次进入界面时，需要创建管理员账号，密码长度必须要8位及以上。12345678

![image-20210520124556335](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210520124556335.png)



配置Local完成后，查看`Dashboard`，就能看到`Docker`环境的整体情况了，如镜像个数、容器个数及运行状态、`Volume`等





## docker后台启动 

docker run --name snailzrgubt -d ubuntu /bin/bash	-c  "while true; do echo hello; sleep 2;done"

> 👆上面方式启动容器 不会立即退出 

snailzhou@SnaildeMBP ~ % docker exec -it snailzrgubt /bin/bash



snailzhou@SnaildeMBP ~ % docker logs snailzrgubt

> 上面查看容器日志



## docker 查看容器细节

 docker inspect mysqlzrg

显示json串





## docker 分层结构

比如 下载一个tomcat 中 发现居然400m

由于 tomcat依赖--jdk8依赖--centeros依赖--kernel；

所以看拉tomcat镜像中会下载一堆id的镜像
