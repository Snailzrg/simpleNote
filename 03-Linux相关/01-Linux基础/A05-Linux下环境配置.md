# jdk
  下载安装jdk tar.gz源码包
> wget http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz

1.先卸载centeros自带jdk
- rpm-qa|grep openjdk 
查询出来的自带的openjdk
- 2.删除 rpm-e--nodeps

上传jdk 解压
 vi /etc/profile
    　　  可以看到这个文件的内容，profile文件有点类似于windows系统里面的环境变量的配置，
    　　  shift + g 定位到最后一行
    　　  这个时候按一下a或i键，进入编辑模式
 
#jdk1.8
export JAVA_HOME=/data/soft/jdk1.8
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

source /etc/profile 生效
 
 
 # maven 配置
export M2_HOME=/data/soft/apache-maven-3.6.3	
export PATH=$PATH:$M2_HOME/bin



# git 配置




# tomcat 配置






#ngnix 
配置### centos yum的配置文件 repo文件详解

> repo文件是Fedora中yum源（软件仓库）的配置文件，通常一个repo文件定义了一个或者多个软件仓库的细节内容，例如我们将从哪里下载需要安装或者升级的软件包，repo文件中的设置内容将被yum读取和应用！




### openJdk
> 在搭建Jenkins环境时，由于系统JAVA_HOME配置的问题，导致tomcat启动不起来，报了如下错误。

/root/hbk/apache-tomcat-7.0.78/bin/catalina.sh:行415: /etc/alternatives/jre_1.8.0_openjdk/jre/bin/java: 没有那个文件或目录

原因是我的JAVA_HOME配置有问题。

因为当时是通过yum install java安装的，虽然说不用配置环境变量，但是有的应用如tomcat是需要依赖JAVA_HOME等环境变量的，这就涉及到一个问题，如何找到正确的JAVA_HOME位置。

[root@localhost apache-tomcat-7.0.78]# which java
/usr/bin/java
[root@localhost apache-tomcat-7.0.78]# ls -lrt /usr/bin/java
lrwxrwxrwx. 1 root root 22 7月  23 14:43 /usr/bin/java -> /etc/alternatives/java
[root@localhost apache-tomcat-7.0.78]# ls -lrt /etc/alternatives/java
lrwxrwxrwx. 1 root root 73 7月  23 14:43 /etc/alternatives/java -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64/jre/bin/java

可以看到，都是一系列的软连接，最终我们配置如下环境变量，vi /etc/profile

追加：

JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

使配置生效

source /etc/profile