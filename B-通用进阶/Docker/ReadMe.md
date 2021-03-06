



阿里云docker镜像加速 ： https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors

sudo tee /etc/docker/daemon.json <<-'EOF'

 {  "registry-mirrors": ["https://zv20hmxu.mirror.aliyuncs.com"] } 



# 只要一小时，零基础入门Docker

[笑虎](https://www.zhihu.com/people/xianhu)

不想当产品的程序员不是好的数据分析师！

取消关注

2,599 人赞同了该文章

Docker是什么？

Docker是一个虚拟环境容器，可以将你的开发环境、代码、配置文件等一并打包到这个容器中，并发布和应用到任意平台中。比如，你在本地用Python开发网站后台，开发测试完成后，就可以将Python3及其依赖包、Flask及其各种插件、Mysql、Nginx等打包到一个容器中，然后部署到任意你想部署到的环境。

Docker官方文档比较全，建议有能力的读一下[官方文档](https://link.zhihu.com/?target=https%3A//docs.docker.com/)。





## Docker的三个概念

1. 镜像（Image）：类似于虚拟机中的镜像，是一个包含有文件系统的面向Docker引擎的只读模板。任何应用程序运行都需要环境，而镜像就是用来提供这种运行环境的。例如一个Ubuntu镜像就是一个包含Ubuntu操作系统环境的模板，同理在该镜像上装上Apache软件，就可以称为Apache镜像。
2. 容器（Container）：类似于一个轻量级的沙盒，可以将其看作一个极简的Linux系统环境（包括root权限、进程空间、用户空间和网络空间等），以及运行在其中的应用程序。Docker引擎利用容器来运行、隔离各个应用。容器是镜像创建的应用实例，可以创建、启动、停止、删除容器，各个容器之间是是相互隔离的，互不影响。注意：镜像本身是只读的，容器从镜像启动时，Docker在镜像的上层创建一个可写层，镜像本身不变。
3. 仓库（Repository）：类似于代码仓库，这里是镜像仓库，是Docker用来集中存放镜像文件的地方。注意与注册服务器（Registry）的区别：注册服务器是存放仓库的地方，一般会有多个仓库；而仓库是存放镜像的地方，一般每个仓库存放一类镜像，每个镜像利用tag进行区分，比如Ubuntu仓库存放有多个版本（12.04、14.04等）的Ubuntu镜像。





## Docker的安装和卸载

Docker可以安装在Windows、Linux、Mac等各个平台上。具体可以查看文档[Install Docker](https://link.zhihu.com/?target=https%3A//docs.docker.com/engine/installation/)。安装完成之后，可以查看Docker的版本信息：

```text
[root@xxx ~]# docker version
Client:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:
 OS/Arch:      linux/amd64

Server:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:
 OS/Arch:      linux/amd64
```

查看Docker的帮助信息：# docker --help。各种命令的用法也不再赘述，后边用到哪些命令时会作出一定的解释。





## Docker中关于镜像的基本操作

安装完Docker引擎之后，就可以对镜像进行基本的操作了。

我们从官方注册服务器（[https://hub.docker.com](https://link.zhihu.com/?target=https%3A//hub.docker.com)）的仓库中pull下CentOS的镜像，前边说过，每个仓库会有多个镜像，用tag标示，如果不加tag，默认使用latest镜像：

```text
[root@xxx ~]# docker search centos    # 查看centos镜像是否存在
[root@xxx ~]# docker pull centos    # 利用pull命令获取镜像
Using default tag: latest
latest: Pulling from library/centos
08d48e6f1cff: Pull complete
Digest: sha256:b2f9d1c0ff5f87a4743104d099a3d561002ac500db1b9bfa02a783a46e0d366c
Status: Downloaded newer image for centos:latest

[root@xxx ~]# docker images    # 查看当前系统中的images信息
REPOSITORY      TAG            IMAGE ID       CREATED        SIZE
centos          latest         0584b3d2cf6d   9 days ago     196.5 MB
```

以上是下载一个已有镜像，此外有两种方法可以帮助你新建自有镜像。

（1）利用镜像启动一个容器后进行修改 ==> 利用commit提交更新后的副本



```text
[root@xxx ~]#                                                                                                                
# 启动一个容器
[root@72f1a8a0e394 /]#    # 这里命令行形式变了，表示已经进入了一个新环境
[root@72f1a8a0e394 /]# git --version    # 此时的容器中没有git
bash: git: command not found
[root@72f1a8a0e394 /]# yum install git    # 利用yum安装git
......
[root@72f1a8a0e394 /]# git --version   # 此时的容器中已经装有git了
git version 1.8.3.1
```

此时利用exit退出该容器，然后查看docker中运行的程序（容器）：

```text
[root@xxx ~]# docker ps -a
CONTAINER ID  IMAGE    COMMAND      CREATED   STATUS   PORTS    NAMES
72f1a8a0e394  centos:latest "/bin/bash"  9 minutes ago   Exited (0) 3 minutes ago      angry_hodgkin
```

这里将容器转化为一个镜像，即执行commit操作，完成后可使用docker images查看：

```text
[root@xxx ~]# docker commit -m "centos with git" -a "qixianhu" 72f1a8a0e394 xianhu/centos:git

[root@xxx ~]# docker images
REPOSITORY       TAG    IMAGE ID         CREATED             SIZE
xianhu/centos    git    52166e4475ed     5 seconds ago       358.1 MB
centos           latest 0584b3d2cf6d     9 days ago          196.5 MB
```

其中，-m指定说明信息；-a指定用户信息；72f1a8a0e394代表容器的id；xianhu/centos:git指定目标镜像的用户名、仓库名和 tag 信息。注意这里的用户名xianhu，后边会用到。

此时Docker引擎中就有了我们新建的镜像xianhu/centos:git，此镜像和原有的CentOS镜像区别在于多了个Git工具。此时我们利用新镜像创建的容器，本身就自带git了。

```text
[root@xxx ~]# docker run -it xianhu/centos:git /bin/bash
[root@520afc596c51 /]# git --version
git version 1.8.3.1
```

利用exit退出容器。注意此时Docker引擎中就有了两个容器，可使用docker ps -a查看。

（2）利用Dockerfile创建镜像

Dockerfile可以理解为一种配置文件，用来告诉docker build命令应该执行哪些操作。一个简易的Dockerfile文件如下所示，官方说明：[Dockerfile reference](https://link.zhihu.com/?target=https%3A//docs.docker.com/engine/reference/builder/)：

```text
# 说明该镜像以哪个镜像为基础
FROM centos:latest

# 构建者的基本信息
MAINTAINER xianhu

# 在build这个镜像时执行的操作
RUN yum update
RUN yum install -y git

# 拷贝本地文件到镜像中
COPY ./* /usr/share/gitdir/
```

有了Dockerfile之后，就可以利用build命令构建镜像了：

```text
[root@xxx ~]# docker build -t="xianhu/centos:gitdir" .
```

其中-t用来指定新镜像的用户信息、tag等。最后的点表示在当前目录寻找Dockerfile。

构建完成之后，同样可以使用docker images命令查看：

```text
[root@xxx ~]# docker images
REPOSITORY        TAG       IMAGE ID      CREATED            SIZE
xianhu/centos     gitdir    0749ecbca587  34 minutes ago     359.7 MB
xianhu/centos     git       52166e4475ed  About an hour ago  358.1 MB
centos            latest    0584b3d2cf6d  9 days ago         196.5 MB
```

以上就是构建自己镜像的两种方法。其中也涉及到了容器的一些操作。如果想删除容器或者镜像，可以使用rm命令，注意：删除镜像前必须先删除以此镜像为基础的容器。

```text
[root@xxx ~]# docker rm container_name/container_id
[root@xxx ~]# docker rmi image_name/image_id
```

镜像其他操作指令：

```text
[root@xxx ~]# docker save -o centos.tar xianhu/centos:git    # 保存镜像, -o也可以是--output
[root@xxx ~]# docker load -i centos.tar    # 加载镜像, -i也可以是--input
```



## Docker中关于容器的基本操作

在前边镜像的章节中，我们已经看到了如何基于镜像启动一个容器，即docker run操作。

```text
[root@xxx ~]# docker run -it centos:latest /bin/bash
```

这里-it是两个参数：-i和-t。前者表示打开并保持stdout，后者表示分配一个终端（pseudo-tty）。此时如果使用exit退出，则容器的状态处于Exit，而不是后台运行。如果想让容器一直运行，而不是停止，可以使用快捷键 ctrl+p ctrl+q 退出，此时容器的状态为Up。

除了这两个参数之外，run命令还有很多其他参数。其中比较有用的是-d后台运行：



```text
[root@xxx ~]# docker run centos:latest /bin/bash -c "while true; do echo hello; sleep 1; done"
[root@xxx ~]# docker run -d centos:latest /bin/bash -c "while true; do echo hello; sleep 1; done"
```

这里第二条命令使用了-d参数，使这个容器处于后台运行的状态，不会对当前终端产生任何输出，所有的stdout都输出到log，可以使用docker logs container_name/container_id查看。

启动、停止、重启容器命令：

```text
[root@xxx ~]# docker start container_name/container_id
[root@xxx ~]# docker stop container_name/container_id
[root@xxx ~]# docker restart container_name/container_id
```

后台启动一个容器后，如果想进入到这个容器，可以使用attach命令：

```text
[root@xxx ~]# docker attach container_name/container_id
```

删除容器的命令前边已经提到过了：

```text
[root@xxx ~]# docker rm container_name/container_id
```



## Docker中关于仓库的基本操作

Docker官方维护了一个DockerHub的公共仓库，里边包含有很多平时用的较多的镜像。除了从上边下载镜像之外，我们也可以将自己自定义的镜像发布（push）到DockerHub上。

在镜像操作章节中，我们新建了一个xianhu/centos:git镜像。

（1）访问[https://hub.docker.com/](https://link.zhihu.com/?target=https%3A//hub.docker.com/)，如果没有账号，需要先注册一个。

（2）利用命令docker login登录DockerHub，输入用户名、密码即可登录成功：

```text
[root@xxx ~]# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: xianhu
Password:
Login Succeeded
```

（3）将本地的镜像推送到DockerHub上，这里的xianhu要和登录时的username一致：

```text
[root@xxx ~]# docker push xianhu/centos:git    # 成功推送
[root@xxx ~]# docker push xxx/centos:git    # 失败
The push refers to a repository [docker.io/xxx/centos]
unauthorized: authentication required
```

（4）以后别人就可以从你的仓库中下载合适的镜像了。

```text
[root@xxx ~]# docker pull xianhu/centos:git
```

对应于镜像的两种创建方法，镜像的更新也有两种：

- 创建容器之后做更改，之后commit生成镜像，然后push到仓库中。
- 更新Dockerfile。在工作时一般建议这种方式，更简洁明了。


这里再一次回顾一下三个重要的概念：镜像、容器、仓库：

> 从仓库（一般为DockerHub）下载（pull）一个镜像，Docker执行run方法得到一个容器，用户在容器里执行各种操作。Docker执行commit方法将一个容器转化为镜像。Docker利用login、push等命令将本地镜像推送（push）到仓库。其他机器或服务器上就可以使用该镜像去生成容器，进而运行相应的应用程序了。



## 利用Docker创建一个用于Flask开发的Python环境

上边已经解释和练习了Docker的基本操作命令，下边以实例的形式完整走一遍流程。

我们创建一个用于Flask开发的Python环境，包含Git、Python3、Flask以及其他依赖包等。

完整命令如下：

```text
[root@xxx ~]# docker pull centos
[root@xxx ~]# docker run -it centos:latest /bin/bash
# 此时进入容器，安装Python3、Git、Flask及其依赖包等，安装完成后exit退出
[root@xxx ~]# docker commit -m "Flask" -a "xianhu" container_id xianhu/flask:v1
[root@xxx ~]# docker push xianhu/flask:v1
```



Docker的功能和特性还有很多，各种运行命令、参数等也都有待学习和练习，比如如何管理数据、如何管理网络、如何互相配合工作、如何编写更专业的Dockerfile等。本文先入门为主，以后有时间再慢慢更新关于Docker的知识。