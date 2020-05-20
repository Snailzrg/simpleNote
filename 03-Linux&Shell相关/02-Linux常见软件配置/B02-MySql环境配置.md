# Mysql
Linux下MySQL5.6与MySQL5.7安装方法略有不同 下面主要是5.6
## 安装[参考](https://blog.csdn.net/weixin_42023748/article/details/86135612)
- [官网下载地址](https://dev.mysql.com/downloads/mysql/5.7.html#downloads)
- [官网配置方式](https://dev.mysql.com/doc/refman/5.6/en/binary-installation.html)
tar -zxvf mysql-5.6.34-linux-glibc2.5-x86_64.tar.gz -C /opt/

 [my.cnf配置文件](https://blog.csdn.net/newxwj/article/details/99680887?utm_medium=distribute.pc_relevant.none-task-blog-baidujs-2)
 ###  MySQL5.6版本安装
 
 ####  方式一：源码安装
+ 检查是否已经安装过
```
find / -name mysql    --> 	rm -rf 上边查找到的路径，多个路径用空格隔开
find / -name mysql|xargs rm -rf   #或者使用这一条命令即可 
 ```
+ 下载解压源码tar.gz
```
	tar -zxvf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz -C /data/database
```
+ 检查mysql组和mysql用户
```
chown -R mysql:mysql ./
 groups mysql  #看是否有
 groupadd mysql
 useradd -r -g mysql mysql
```
+  进入mysql目录更改权限
```
chown -R mysql:mysql ./
```
+  执行本地yum源安装依赖包
```
yum install -y perl perl-devel libaio
yum-y install autoconf
```
+  初始化
```
./scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql/ --datadir=/data/database/mysql/data/
//-------------!!!指定初始化!!!!!!----------------------------------------------------->
./scripts/mysql_install_db --defaults-file=../conf/my.cnf 
//-------------下面是5.7以上的mysql版本 始化命令后面要加 --initialize----------------------->
./scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql/ --datadir=/data/database/mysql/data/  --initialize
```
+  权限修改
```
安装完之后修改当前目录拥有者为root用户，修改data目录拥有者为mysql
chown -R root:root ./
chown -R mysql:mysql data
```
+ 完成初始化后编辑配置文件 /etc/my.cnf
>会先从etc/下的my.cnf开始查找
```
[mysqld]
datadir=/usr/local/mysql/data
basedir=/usr/local/mysql
socket=/tmp/mysql.sock
user=mysql
port=3306
character-set-server=utf8
# 取消密码验证
skip-grant-tables
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# skip-grant-tables
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
+  启动
```
 ./support-files/mysql.server start
 !!!如果报错 显示日志目录不存在 则在报错目录新建并且!!!
[root@localhost mysql]# touch /var/log/mariadb/mariadb.log
[root@localhost mysql]# chown -R mysql:mysql   /var/log/mariadb/
```
+  修改密码并远程登录
```
/usr/local/mysql/bin/mysql -uroot -p
登录之后将其他用户的密码也可改为root
update mysql.user set password=password('root') where user='root'; flush privileges;
然后上面是可以本机127.0.0.1登录 下面配置远程
grant all privileges on *.* to root@'%' identified by 'root'; flush privileges;
```

+ 将MySQL加入Service系统服务 
```
将mysql加入到服务
#cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
开机启动
#chkconfig mysql on
启动mysql
#service mysql start
配置环境变量---->配置后可以用 #mysql -u root -p 启动客户端
#export PATH=$PATH:/usr/local/mysql/bin
```

+ 开放3306端口
```
systemctl status firewalld   					 //防火墙状态
# firewall-cmd --zone= public --query-port=3306/tcp  //查看3306端口是否开启
firewall-cmd --zone=public --list-ports        //查看所有打开的端口
firewall-cmd --zone=public --add-port=3306/tcp --permanent    （--permanent永久生效，没有此参数重启后失效 开放3306端口）
firewall-cmd --reload  						   //更新防火墙状态
删除开放端口
firewall-cmd --zone= public --remove-port=3306/tcp --permanent
```


####  方式二：编译安装
[教程](https://blog.csdn.net/zhang_referee/article/details/88212695?utm_medium=distribute.pc_relevant.none-task-blog-baidujs-2)
make 

###  报错解决






###  MySQL5.7版本安装













## 利用shell脚本安装配置
   待续.......


