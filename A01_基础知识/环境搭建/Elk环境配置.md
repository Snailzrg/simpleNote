# elk



先·卸载openjdk

yum -y remove copy-jdk-configs-3.3-10.el7_5.noarch

```
vim /etc/profile

export JAVA_HOME=/home/jdk1.8.0_151/
export JRE_HOME=/home/jdk1.8.0_151/jre
export PATH=$PATH:/home/jdk1.8.0_151/bin
export CLASSPATH=./:/home/jdk1.8.0_151/lib:/home/jdk1.8.0_151/jre/lib
```

  fs.file-max=65536

​         	

​        sysctl -p 刷新下配置，sysctl -a查看是否生效  