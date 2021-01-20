[toc]
# Ubuntu

## 一概述

常用的包管理包含三类工具：dpkg、apt和aptitude。[1](http://wiki.ubuntu.org.cn/包管理系统指南)

dpkg 主要是对本地的软件包进行管理，本地软件包包括已经在本地安装的软件包和已经下载但还没有安装的 deb 文件，不解决依赖关系。

- apt 包含了很多工具，apt-get 主要负责软件包的在线安装与升级，低层对 deb 包的处理还是用的 dpkg 解决依赖关系；
- apt-cache 主要用来查询软件包的状态和依赖关系；apt-file 主要负责查询软件包名称和软件包包含的文件（值得注意的是它要自己同步）；apt-cross 主要负责为交叉编译的软件包的安装与编译等。apt 还包含很多工具，如 apt-offline 可以离线安装软件包，apt-build 可以简化源码编译等等，有兴趣可以学习一下 apt 开头软件包。用`aptitude search ~n^apt`命令(~n 意思是搜索软件包名，^ 是匹配最前面 )可以得到所有以 apt 开头的软件包。
- aptitude 是更强大的安装工具，有两种基本的使用方法，一种是文本界面，另一种是命令行，这里只讨论命令行操作。

查找软件包

### 1:dpkg

```
dpkg --get-selections pattern #查找软件包名称包含 pattern 的软件包
    #可以在后面用 grep install/deinstall 来选择是否已经被 remove 的包(曾经安装过了的)
    
dpkg -I package_name.deb #参数是大写i，查找已经下载但末安装的 package_name.deb 软件包的信息
dpkg -l package #参数是小写L，查找已经安装软件包 package 的信息，精简

dpkg -c package_name.deb #查找已经下载但末安装的 package.deb 软件包包含哪些文件
dpkg -L package #查找已经安装 package 软件包包含哪些文件

dpkg -S pattern #查找已经安装的文件 pattern 属于哪个软件包
```

### 2:apt

```
apt-cache search pattern #查找软件包名称和描述包含 pattern 的软件包 (可以是安装了也可以是没有安装)，可以用参数来限制是否已经安装

apt-cache depends package #查找名称是 package 软件包的依赖关系
apt-cache rdepends package #查找哪些软件包依赖于名称是 package 软件包

apt-cache show pattern ##查找软件包pattern的信息 (可以是安装了也可以是没有安装)
apt-cache policy pattern #显示 pattern 软件包的策略(可以是安装了也可以是没有安装)
apt-cache showpkg pattern #显示pattern 软件包的其它信息(可以是安装了也可以是没有安装)

apt-file search pattern #查找文件 pattern 属于哪个软件包(可以是安装了也可以是没有安装)
apt-file show pattern #查找 pattern 软件包(可以是安装了也可以是没有安装)包含哪些文件
```

### 3:aptitude

```
aptitude search ~i #查找已经安装的软件包
aptitude search ~c #查找已经被 remove 的软件包，还有配置文件存在
aptitude search ~npattern #查找软件包名称包含 pattern 的软件包 (可以是安装了也可以是没有安装)
aptitude search \!~i~npattern #查找还没有安装的软件包名字包含 pattern 的软件包。(前面的 ! 是取反的意思，反划线是 escape 符号)

aptitude search ~R~npackage #查找名称是 package 软件包的依赖关系，可以同时看到是不是已经安装
aptitude search ~D~npackage #查找哪些软件包依赖于名称是 package 软件包

aptitude show ~npattern #显示名称是 pattern 软件包的信息(可以是安装了也可以是没有安装)
```

- 下载软件包

```
apt-get install package -d #下载软件包
aptitude download pattern #同上，不同的是下载的是符合 pattern 正则表达式的软件包
```

- 安装软件包

```
dpkg -i package_name.deb #安装本地软件包，不解决依赖关系
apt-get install package #在线安装软件包
aptitude install pattern #同上

apt-get install package --reinstall #重新安装软件包
apitude reinstall package #同上
```

- 移除软件包

```
dpkg -r package #删除软件包
apt-get remove package #同上
aptitude remove package #同上

dpkg -P #删除软件包及配置文件
apt-get remove package --purge #同上
apitude purge pattern #同上
```

- 自动移除软件包

```
apt-get autoremove #删除不再需要的软件包
```

注：aptitude 没有，它会自动解决这件事

- 清除下载的软件包

```
apt-get clean #清除 /var/cache/apt/archives 目录
aptitude clean #同上

apt-get autoclean #清除 /var/cache/apt/archives 目录，不过只清理过时的包
aptitude autoclean #同上
```

- 编译相关

```
apt-get source package #获取源码
apt-get build-dep package #解决编译源码 package 的依赖关系
aptitude build-dep pattern #解决编译源码 pattern 的依赖关系
```

- 平台相关

```
apt-cross --arch ARCH --show package 显示属于 ARCH 构架的 package 软件包信息
apt-cross --arch ARCH --get package #下载属于 ARCH 构架的 package 软件包
apt-cross --arch ARCH --install package #安装属于 ARCH 构架的 package 软件包
apt-cross --arch ARCH --remove package #移除属于 ARCH 构架的 package 软件包
apt-cross --arch ARCH --purge package #移除属于 ARCH 构架的 package 软件包
apt-cross --arch ARCH --update #升级属于 ARCH 构架的 package 软件包
```

注：慎重考虑要不要用这种方法来安装不同构架的软件包，这样会破坏系统。对于 amd64 的用户可能需要强制安装某些 i386 的包，千万不要把原来 amd64 本身的文件给 replace 了。最好只是安装一些 lib 到 /usr/lib32 目录下。同样地，可以用 apt-file 看某个其它构架的软件包包含哪些文件，或者是文件属于哪个包，不过记得最先要用 apt-file --architecture ARCH update 来升级 apt-file 的数据库，在 search 或 show 时也要指定 ARCH。

- 更新源

```
apt-get update #更新源
aptitude update #同上 
```

- 更新系统

```
apt-get upgrade #更新已经安装的软件包
aptitude safe-upgrade #同上

apt-get dist-upgrade #升级系统
aptitude full-upgrade #同上
```



## 二 替换源

### 1.备份原来的源

```shell
sudo cp /etc/apt/sources.list /etc/apt/sources_init.list
```

将以前的源备份一下，以防以后可以用的。

### 2.更换源

```shell
sudo gedit /etc/apt/sources.list
```

使用gedit打开文档，将下边的阿里源复制进去，然后点击保存关闭。

#### 阿里源 （Ubuntu 18.04）

```
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

123456789101112131415
```

### 3.更新

更新源

```shell
sudo apt-get update
```

复损坏的软件包，尝试卸载出错的包，重新安装正确版本的。

```shell
sudo apt-get -f install
```

更新软件

```shell
 sudo apt-get upgrade
```

### 4:其他常用源

西电源（只有校内网网线使用，但是不限制流量，还是十分靠谱的）

```
deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial main restricted universe multiverse
#deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-security main restricted universe multiverse
#deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-security main restricted universe multiverse

deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-updates main restricted universe multiverse
#deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-updates main restricted universe multiverse

#deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-backports main restricted universe multiverse
#deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-backports main restricted universe multiverse

#deb http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-proposed main restricted universe multiverse
#deb-src http://linux.xidian.edu.cn/mirrors/ubuntu/ xenial-proposed main restricted universe multiverse
1234567891011121314
```

#### 清华源

```sh
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
```

#### 网易源

```
deb http://mirrors.163.com/ubuntu/ wily main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ wily-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ wily-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ wily-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ wily-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ wily main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ wily-security main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ wily-updates main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ wily-proposed main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ wily-backports main restricted universe multiverse
```



## 三 常见操作

### 1: 没有可用的软件包

> 1 sudo apt-get update
> 2 sudo apt install gcc

### 2: 防火墙

> 1 sudo ufw enable       //防火墙的打开
> 
> 2 sudo ufw reload      //防火墙的重启
>
> 3 ufw allow 9000      //打开想要的端口（以9000为例）
>
> 4 ufw status         //查看本机端口使用情况

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/70.png)

### 3:  su 认证失败
> 1. 开机进入桌面，ctrl+alt+T打开终端————在此时终端显示的是
   用户名@电脑名：-$  表示普通用户
> 2. 在此处输入：sudo passwd root
> 
> 3. 此时提示:
   [sudo] password for gutar: 输入你的用户密码输入新的 UNIX 密码： 新的密码，也是root密码重新输入新的 UNIX 密码： 重复输入passwd：已成功更新密码
> 4. 然后开始使用root权限，只需要在终端上输入：su 回车键  然后输入设置的新密码，就可以使用了

 ### 4: 允许远程登录

>**（1）检查是否开启SSH服务** 
>
>　　命令：ps -e|grep ssh 查看SSH服务是否开启，或者通过命令：service sshd status 可以查看某个服务的状态。
>
>**（2）安装SSH服务**
>
>   通过apt-get 安装，命令：apt-get install ssh 
>
>**（3）启动SSH服务**
>
>　  命令：sudo /etc/init.d/ssh start
>
>**（4）修改SSH配置文件**
>
> 命令：sudo vim /etc/ssh/sshd_config，找到PermitRootLogin without-password 修改为PermitRootLogin yes
>
>**（5）重启SSH服务**
>
>　命令：service ssh restart

