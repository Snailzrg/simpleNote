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



# 二:d







