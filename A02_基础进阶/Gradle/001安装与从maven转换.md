[toc]

# 一 安装Gradle及配置

> https://blog.csdn.net/achenyuan/article/details/80682288

## 1.1:说明[#](https://www.cnblogs.com/vitoboy/p/12487648.html#601756286)

 最近在学习spring源码, 需要使用到gradle, 便从小白开始吧

 ps: 基本按官方操作来完成的~

## 1.2:前提[#](https://www.cnblogs.com/vitoboy/p/12487648.html#326958039)

 从[Gradle官网](https://gradle.org/install/)的安装指导可以知道, (最新的gradle版本)要求jdk的版本是1.8, 或者更高.

```
Prerequisites
Gradle runs on all major operating systems and requires only a Java JDK or JRE version 8 or higher to be installed. To check, run java -version:
 
// 使用以下命令可以查看自己电脑的jdk版本是否满足要求
$ java -version
java version "1.8.0_121"
```

## 1.3:下载安装[#](https://www.cnblogs.com/vitoboy/p/12487648.html#2377144642)

 [Gradle官网](https://gradle.org/install/)

 [gradle下载地址](https://gradle.org/releases/)

- macOS可以使用brew安装—— [Homebrew](http://brew.sh/) is “the missing package manager for macOS”.

```shell
Copy brew install gradle
```

- 手动安装—— [gradle官网安装说明-Step 1. Download && Step 2. Unpack the distribution](https://gradle.org/install/)

  - 下载

    [gradle6.2.2版本下载](https://gradle.org/next-steps/?version=6.2.2&format=bin)

    选择自己想安装的版本, 本人下载当时的最新版本6.2.2, 选择Binary-only下载

  - 安装

    对于 Linux & MacOS 用户, 可以打开 **终端(命令行工具)** 使用以下命令

```
// 在根目录下的opt目录下, 创建gradle文件夹
// 有可能没有权限, 或者没有目录, 可以使用 "sudo mkdir -p /opt/gradle" 命令(注: 命令需要密码, 同时输入的密码不会显示)
$ mkdir /opt/gradle
 
// 将安装包, 解压到指定目录(/opt/gradle)下
// 如果提示: Permission denied, 可以使用 "sudo unzip -d /opt/gradle gradle-6.2.2-bin.zip"
// 注: 此命令是进入到了安装包的当前目录下的命令
// 如果不知道当前的安装包的路径, 可以将安装包拖入终端, 终端会自动显示此安装包的当前路径
 
$ unzip -d /opt/gradle gradle-6.2.2-bin.zip
// 查看安装包是否解压成功
$ ls /opt/gradle/gradle-6.2.2
LICENSE  NOTICE  bin  getting-started.html  init.d  lib  media
 
// ps: 本人解压后, 没有media文件(夹), 不影响
```



## 1.5:配置环境变量[#](https://www.cnblogs.com/vitoboy/p/12487648.html#3354116449)

 mac的环境变量的配置—— [gradle官网操作说明-Step 3. Configure your system environment](https://gradle.org/install/)

- 对于 Linux & MacOS 用户, 使用以下命令配置环境变量

```shell
# 进入用户目录下的配置文件
vim ~/.bash_profile

# 修改.bash_profile文件, 在文件的最后加上如下配置: 
export PATH=$PATH:/opt/gradle/gradle-6.2.2/bin

# 如果了解配置文件的运行规则的, 可以自己看着改, 如本人的配置信息如下: 
# export GRADLE=/opt/gradle/gradle-6.2.2
# export PATH=$PATH:$GRADLE/bin

# 修改后, 按[Esc], 命令":wq"保存退出, 并在终端使用如下命令使配置生效:
source ~/.bash_profile
```

## 1.6:检查安装结果[#](https://www.cnblogs.com/vitoboy/p/12487648.html#2992015375)

 检查mac的安装结果—— [gradle官网操作说明-Step 4. Verify your installation](https://gradle.org/install/)

- 使用命令查看gradle安装的结果

```shell
gradle -v

# 有出现如下的信息, 说明安装成功, 环境配置成功
------------------------------------------------------------
Gradle 6.2.2
------------------------------------------------------------
```

## 1.7 windows环境

基本同上。  path变量 新+ %GRADLE_HOME%\bin 

![image-20210303112909599](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210303112909599.png)

# 二 从maven转换成gradle工程

1. 1、	在maven项目的主目录（含有pom.xml的目录，图一）打开命令窗口，执行命令“gradle init --type pom”

![](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210303143118930.png)

1. A、	如果出现类似以下错误（图一），需要将项目中parent模块的pom.xml中的父项目发布为稳定版本（图二）。（备注：因为现在这个父项目没有稳定版本，所以暂时可以删除parent节点，然后将父项目《gris.dev.parent》中pom.xml文件配置的内容复制到本项目pom.xml文件中，并添加version节点，具体见图三）
2. ![image-20210304153604911](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210304153604911.png)



![image-20210304153642726](/Users/snailzhou/Library/Application Support/typora-user-images/image-20210304153642726.png)

![image-20210304153737674](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210304153737674.png)



![image-20210304153809224](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210304153809224.png)



# 三 导入gradle工程

## 3.1 eclipes中导入gradle工程

> https://blog.csdn.net/fulong0406/article/details/102862685

## 3.2 插件手动导入

>https://blog.csdn.net/u014234266/article/details/74000256

插件地址--->链接: https://pan.baidu.com/s/1dtSdjlCX_4slFlynY0Jg9g 提取码: qqb2 



![image-20210311102620223](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210311102620223.png)

## 3.2 idea中导入gradle工程



![image-20210311102641024](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210311102641024.png)

