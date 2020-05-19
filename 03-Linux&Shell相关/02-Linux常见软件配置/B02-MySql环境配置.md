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
```
+  执行安装脚本
```
./scripts/mysql_install_db --user=mysql
!!!指定初始化!!!!!!
./mysql_install_db --defaults-file=../conf/my.cnf 
若报错 则安装命令：yum-y install autoconf
```

+  权限修改
```
安装完之后修改当前目录拥有者为root用户，修改data目录拥有者为mysql
chown -R root:root ./
chown -R mysql:mysql data
```

+  启动
```
 ./support-files/mysql.server start
 !!!如果报错 显示日志目录不存在 则在报错目录新建并且!!!
[root@localhost mysql]# touch /var/log/mariadb/mariadb.log
[root@localhost mysql]# chown -R mysql:mysql  /var/log/mariadb/
```
+  修改密码并登录
```
./bin/mysqladmin -u root -h localhost.localdomain password 'root'
./bin/mysql -h127.0.0.1 -uroot -proot
```
	
+ 远程登录 
```
登录之后将其他用户的密码也可改为root
update mysql.user set password=password('root') where user='root'; flush privileges;
然后上面是可以本机127.0.0.1登录 下面配置远程
grant all privileges on *.* to root@'%' identified by 'root'; flush privileges;
```

+ 将MySQL加入Service系统服务 
```
cp support-files/mysql.server /etc/init.d/mysqld chkconfig --add mysqld chkconfig mysqld on service mysqld restart  service mysqld status
```

+ 配置my.cnf
```
vim my.cnf #添加以下两条语句并保存退出 default-character-set=utf8 lower_case_table_names=1 max_allowed_packet=100M
```





####  方式二：编译安装
[教程](https://blog.csdn.net/zhang_referee/article/details/88212695?utm_medium=distribute.pc_relevant.none-task-blog-baidujs-2)












#### 方式三: 源码安装







###  报错解决






###  MySQL5.7版本安装













## 利用shell脚本安装配置
   待续.......


