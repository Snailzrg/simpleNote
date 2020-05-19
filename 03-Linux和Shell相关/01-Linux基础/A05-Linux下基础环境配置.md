# jdk
  下载安装jdk tar.gz源码包
> wget http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz

1.先卸载centeros自带jdk
- rpm-qa|grepopenjdk 
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


