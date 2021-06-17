[toc]

# Mysql 安装配置

> 文件下载：http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/
>
> 官网下载：https://dev.mysql.com/downloads/mysql/5.7.html#downloads



## 一：mysql5.6 与5.7 安装对比

> 由于MySQL在CentOS7中收费了，所以已经不支持MySQL了，取而代之在CentOS7内部集成了mariadb，而安装MySQL的话会和MariaDB的文件冲突，所以需要先卸载掉MariaDB.

### 1.1：通用配置

- 检查是否已经安装过

  ```
  find / -name mysql    --> 	rm -rf 上边查找到的路径，多个路径用空格隔开
  find / -name mysql|xargs rm -rf   #或者使用这一条命令即可
  
  rpm -qa | grep -i mysql
  卸载命令 这是通过rpm安装多
  则用以下命令尝试：rpm -e --noscripts 包名
  ```

- 使用rpm 命令查找出要删除的mariadb文件；

  ```
  rpm -pa | grep mariadb
  可能的显示结果如下：
  mariadb-libs-5.5.56-2.el7.x86_64
  删除上面的程序
  rpm -e mariadb-libs-5.5.56-2.el7.x86_64
  可能出现错误提示如下：
  依赖检测失败： 
  libmysqlclient.so.18()(64bit) 被 (已安裝) postfix-2:2.10.1-6.el7.x86_64 需要
  libmysqlclient.so.18(libmysqlclient_18)(64bit) 被 (已安裝) postfix-2:2.10.1-6.el7.x86_64 需要 
  libmysqlclient.so.18(libmysqlclient_18)(64bit) 被 (已安裝) postfix-2:2.10.1-6.el7.x86_64 需要
  使用强制删除：
  rpm -e --nodeps mariadb-libs-5.5.56-2.el7.x86_64
  至此就将原来有的mysql 和mariadb数据库删除了；
  ```

- 下载解压mysql

  ```
  	tar -zxvf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz -C /usr/local/  (建议 解压到usr/local下) 
  ```

- 检查mysql组和mysql用户（建议-也可以不用）

  ```
  chown -R mysql:mysql ./
   groups mysql  #看是否有
   groupadd mysql
   useradd -r -g mysql mysql
  
   #进入mysql目录更改权限
   chown -R mysql:mysql ./
  ```

- 执行本地yum源安装依赖包

  ```
  yum install -y perl perl-devel libaio
  yum-y install autoconf
  ```

### 1.2：mysql5.6

- 初始化

  `./scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql/mysql-5.6 --datadir=/usr/local/mysql/data/`

- 修改etc/my.cnf

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
  
  ./scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql/mysql5.6 --datadir=/usr/local/mysql/data
    
  [mysqld]
  # # http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html
  datadir=/usr/local/mysql/data
  basedir=/usr/local/mysql/mysql5.6
  socket=/tmp/mysql.sock
  user=mysql
  port=3306
  character-set-server=utf8
  # # 取消密码验证
  # skip-grant-tables
   # Disabling symbolic-links is recommended to prevent assorted security risks
  symbolic-links=0
  ## skip-grant-tables
  [mysqld_safe]
  log-error=/usr/local/mysql/logs/mysqld.log
  pid-file=/usr/local/mysql/logs/mysqld.pid
  
  ```
  
- 启动

  ```
  ./support-files/mysql.server start
   !!!如果报错 显示日志目录不存在 则在报错目录新建并且!!!
  [root@localhost mysql]# touch /var/log/mariadb/mariadb.log
  [root@localhost mysql]# chown -R mysql:mysql   /var/log/mariadb/
  ```

- 登录，修改密码，添加用户，添加远程访问

  ```
  /usr/local/mysql/bin/mysql -uroot -p
  --
  update user set password=password('root') where user='root';
  CREATE USER 'snailzhou'@'%' IDENTIFIED BY 'snail1234';
  GRANT ALL PRIVILEGES ON *.* TO 'snailzhou'@'%' identified by 'snail1234';
  
  grant all privileges on *.* to snailzhou@'localhost' identified by 'snail1234';
  flush privileges;
  ```

- 将mysql加入到服务

  ```
  #cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
  开机启动
  #chkconfig mysql on
  启动mysql
  #service mysql start
  配置环境变量---->配置后可以用 #mysql -u root -p 启动客户端
  #export PATH=$PATH:/usr/local/mysql/bin
  /usr/local/mysql/mysql-5.6/bin
  ```

`./scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql/mysql5.6 --datadir=/usr/local/mysql/mysql5.6/data`

### 1.3：mysql5.7

对于MySQL 5.7.19和更高版本：通用Linux版本中增加了对非统一内存访问（NUMA）的支持，该版本现在对libnuma库具有依赖性 。

\# install library

```
[root@mysql mysql]# yum install libnuma
```

- 初始化（注意控制台初始密码）

  ```
  ./mysqld --initialize --user=root --basedir=/root/data/mysql/mysql5.7_3306 --datadir=/root/data/mysql/database/mysql3306/data
   ./mysqld --initialize --user=root --basedir=/root/data/mysql/mysql5.7_3305 --datadir=/root/data/mysql/database/mysql3305/data
   
   2:接下来创建安全传输所需的证书和key
  ./mysql_ssl_rsa_setup  --datadir=/root/data/mysql/database/mysql3306/data
  [通过这个命令创建了在非加密连接上使用SSL和RSA进行安全传输所需的SSL证书和key，RSA键值对]
  
   --- ubuntu
  ./mysqld --initialize --user=mysql --basedir=/usr/local/mysql/mysql-5.7 --datadir=/usr/local/mysql/data
  ./mysql_ssl_rsa_setup  --datadir=/usr/local/mysql/data
  ```

- 修改配置文件

  ```
  [client]
  port=3306
  socket=/tmp/mysql3306.sock
  [mysqld]
  port=3306
  basedir=/root/data/mysql/mysql5.7_3306
  datadir=/root/data/mysql/database/mysql3306/data
  socket=/tmp/mysql3306.sock
  symbolic-links=0
  [mysqld_safe]
  log-error=/root/data/mysql/database/mysql3306/logs/error.log
  pid-file=/root/data/mysql/database/mysql3306/logs/mariadb.pid
  # !includedir /etc/my.cnf.d
  ```

- 启动mysql

  > 5.7版本以后好像都是使用mysqld_safe命令启动服务的，也可以使用support-file目录下的mysql.server来启动，不过mysql.server也是使用mysqld_safe来启动的。mysqld_safe的命令如下： `“./mysqld_safe --defaults-file=/root/data/mysql/mysql5.7_3306/my.cnf --user=root --port=3306 &”`
  >
  > 关键的是要指定my.cnf路径，因为我没有安装在默认目录下，而且我们是要在一个机器上安装两个mysql的。这里面要注意的是“--defaults-file”一定要作为第一个参数，不然会报错，有相应提示；另外就是命令末尾的“&”，这个是告诉系统将mysql这个实例作为后台进程，这样退出命令的时候mysql服务器才能继续运行。

  ```
  ./mysqld_safe --defaults-file=/root/data/mysql/mysql5.7_3306/my.cnf --user=root --port=3306 &
  ./mysqld_safe --defaults-file=/root/data/mysql/mysql5.7_3305/my.cnf --user=root --port=3305 &
  ./mysql -uroot -P3305 -S/tmp/mysql3305.sock -p 
  ./mysql -uroot -P3306 -S/tmp/mysql3306.sock -p 
  ```

- 登录

  ```
   mysql -u root -p123456 -P3306  -S /tmp/mysql3306.sock
   mysql -u root -p123456 -P3305  -S /tmp/mysql3305.sock
  ```

- 修改密码 新建用户 开启远程访问

  ```
  update user set authentication_string=password('123456') where user='root';
  alter user 'root'@'localhost' identified by '123456';
  CREATE USER 'snailzhou'@'%' IDENTIFIED WITH mysql_native_password BY 'snail1234';
  GRANT ALL PRIVILEGES ON *.* TO 'snailzhou'@'%';
  flush privileges;
  ```
  



   ### 1.4 mysql5.7 多实例

拷贝support-files中的mysql-server到/etc/init.d/目录下
注意拷贝之前需要修改mysqld_multi.server中的为你的安装目录

```
#cd support-files
#vim mysqld_multi.server
---添加如下内容
basedir=/var/mysql/mysql-5.7.18
bindir=/var/mysql/mysql-5.7.18/bin
---复制到/etc/init.d/目录下
#cp mysqld_multi.server     /etc/init.d/mysqld_multi   
#cp mysql.server  /etc/init.d/mysql
```

#### 1.4.2.创建配置文件

创建数据目录和日志目录

```
#mkdir  /usr/local/mysql/{data3305,data3304}
#chown -R mysql:mysql ./*
#chmod 766 mysql:mysql /usr/local/mysql/data3305, /usr/local/mysql/data3304
```

创建my.cnf

```
#vim /etc/my.cnf
```

my.cnf配置如下

```
[mysqld_multi]
mysqld=/usr/local/mysql/mysql-5.7/bin/mysqld_safe
mysqladmin=/usr/local/mysql/mysql-5.7/bin/mysqladmin
log=/var/log/mysqld_multi.log
#user=	mysql
#password=mysql

[mysqld]
port=3306
basedir=/usr/local/mysql/mysql-5.7
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
symbolic-links=0
log-error=/usr/local/mysql/logs/error-mysqld3306.log #错误日志
pid-file=/usr/local/mysql/logs/mysqld3306.pid  #进程文件

#language=/usr/local/mysql/mysql-5.7/share/english       #使用提示语言，这里目录下必须包含errmsg.sys 
max_allowed_packet=256M
query_cache_size=256M
max_connections=2000
max_connect_errors=10000
key_buffer_size=6000M
read_buffer_size=32M
read_rnd_buffer_size = 32M
myisam_sort_buffer_size=512M
tmp_table_size=1024M
sort_buffer_size=128M
symbolic-links=0

[mysqld3305]
port=3305
basedir=/usr/local/mysql/mysql-5.7
datadir=/usr/local/mysql/data3305
socket=/tmp/mysql3305.sock
log-error=/usr/local/mysql/logs/error-mysqld3305.log
pid-file=/usr/local/mysql/logs/mysqld3305.pid

#language=/usr/mysql/mysql-5.7.18/share/english
max_allowed_packet = 256M
query_cache_size=256M
max_connections=2000
max_connect_errors=10000
key_buffer_size=6000M
read_buffer_size=32M
read_rnd_buffer_size = 32M
myisam_sort_buffer_size=512M
tmp_table_size=1024M
sort_buffer_size=128M
symbolic-links=0

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/usr/local/mysql/logs/mysqld.pid

[mysqld3304]
port=3304
basedir=/usr/local/mysql/mysql-5.7
datadir=/usr/local/mysql/data3304
socket=/tmp/mysql3304.sock
log-error=/usr/local/mysql/logs/error-mysqld3304.log
pid-file=/usr/local/mysql/logs/mysqld3304.pid

#language=/usr/mysql/mysql-5.7.18/share/english
max_allowed_packet=256M
query_cache_size=256M
max_connections=2000
max_connect_errors=10000
key_buffer_size=6000M
read_buffer_size=32M
read_rnd_buffer_size = 32M
myisam_sort_buffer_size=512M
tmp_table_size=1024M
sort_buffer_size=128M
symbolic-links=0

[mysqldump]
quick
max_allowed_packet = 512M

[mysql]
no-auto-rehash

[isamchk]
key_buffer=512M
sort_buffer_size=32M
read_buffer=2M
write_buffer=2M

[myisamchk]
key_buffer=512M
sort_buffer_size=32M
read_buffer=2M
write_buffer=2M


[mysqlhotcopy]
interactive-timeout
```

### 1.4.3  .初始化数据库实例

```
---执行初始化命令(跳过3306 前面已经实现)
./mysqld --initialize  --user=mysql  --basedir=/usr/local/mysql/mysql-5.7 --datadir=/usr/local/mysql/data

 ./mysqld --initialize --user=mysql --basedir=/usr/local/mysql/mysql-5.7 --datadir=/usr/local/mysql/data3305
 ./mysqld --initialize --user=mysql --basedir=/usr/local/mysql/mysql-5.7 --datadir=/usr/local/mysql/data3304
```

这个过程可能遇到如下问题的解决办法

```
Q:./mysqld: /lib/ld-linux.so.2: bad ELF interpreter: 没有那个文件或目录
#yum install glibc.i686
Q:./mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file:
 No such file or directory
#yum install libaio libaio-devel
```

创建日志

日志必须手动创建，系统不会自动创建。此外权限是766，用户是mysql，否则无法启动

```
---切换到root
$ su - root
#cd  /usr/mysq/mysql-5.7.18/logs
--创建日志和进程文件，以3306实例为例
#touch mysqld3306.pid
#touch error-mysqld3306.log
#chmod 766 /usr/mysq/mysql-5.7.18/logs/*
#chown -R mysql:mysql /usr/mysq/mysql-5.7.18/logs/
```

#### 1.4.3 启动实例

```
# su - mysql
$ mysql_multi start 3306 // mysql启动    ./support-files/mysql.server start    service mysql start
mysqld_multi start 3305
mysql -uroot -p -P 3305 -S /tmp/mysql3305.sock
-- 停止
 mysqladmin -h127.0.0.1 -P3305 -uroot -p shutdown
 
mysqld_multi start 3304
mysql -uroot -p -P 3304 -S /tmp/mysql3304.sock
-- 停止
mysqladmin -h127.0.0.1 -P3304 -uroot -p shutdown


```

如果启动成功，我们可以从如下命令中找到

```
#su - root
#netstat -lntp -p 4 | grep 330
tcp        0      0 :::3307                 :::*                    LISTEN      27717/mysqld        
tcp        0      0 :::3308                 :::*                    LISTEN      25537/mysqld        
tcp        0      0 :::3306                 :::*                    LISTEN      27334/mysqld
```

然后我们登录即可,这里以3306数据库为例

```
# mysql -h 172.20.11.62 -P 3306 -S /usr/mysql/mysql-5.7.18/logs/mysqld3306.sock -u root -p
```

注意：首次登录时使用初始化临时密码，然后在数据库中修改为自己的密码

```
>SET PASSWOR=PASSWORD('admin123');
```



##  二：安装中的错误

### 1: error while loading shared libraries: libaio.so.1: cannot open shared o错误解决

执行./mysqld --initialize 后

./bin/mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory

原因是没有安装libaio.so.1，安装即可。

Ubuntu下执行：

    apt-get install libaio1 libaio-dev

Redhat/Fedora/CentOS下执行：

    yum install libaio



### 2 ：忘记密码

- 先修改my.cnf 添加  **vi /etc/my.cnf，在[mysqld]中添加** skip-grant-tables（=1）

- 登录 mysql 修改密码

  - 5.7之前版本：update user set password=password("123456") where user="root";
  - 5.7之后版本：update user set authentication_string=password('123456') where user='root';
  - ​                         update user set authentication_string=password('密码') where user="用户"
  - alter user 'root'@'localhost' identified by '123456';

  **6 .刷新权限**  flush privileges;

  **7 .退出** exit;

  **8 .删除第1部增加的配置信息** skip-grant-tables

  **9 .重启mysql ** service mysql restart

  
  
  

### 3:  主从复制中从库报错

mysql> start slave;
ERROR 1872 (HY000): Slave failed to initialize relay log info structure from the repository
mysql> reset slave
    -> ;

先 reset slave 再 start slave;



### 4: mysqld_multi stop 不生效 

使用mysqld_multi start 启动了多个mysql，但是mysqld_multi stop 却不能停止

原因：因为你还没有授权
/usr/local/mysql/bin/mysqld_multi stop  
但是默认是停不掉的，需要我们做一个授权
alter user 'root'@'localhost' identified by '123456';

grant shutdown on *.* to 'root'@'localhost' identified by '123456'

另外还需要在my.cnf配置文件中加上：
[mysqld_multi]
mysqld = /usr/local/mysql/bin/mysqld_safe
mysqladmin = /usr/local/mysql/bin/mysqladmin
user = username
password = password



\ mysqladmin -h127.0.0.1 -P3305 -uroot -p shutdown



## 三：单机实现多个mysql实例

### 1: 利用mysql中的 mysqld_multi来配置管理

> 先按步骤配置好单机一个服务 默认的3306

- 配置文件 /etc/my.cnf

```
[mysqld]
basedir=/usr/local/mysql/mysql-5.6
datadir=/usr/local/mysql/data
port=3306
socket=/tmp/mysql.sock
character-set-server=utf8

# 主从配置 略
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 


## ================================= 下面是mysql多个实例  ====================================== ##
[mysqld_multi]
mysqld=/usr/local/mysql/mysql-5.6/bin/mysqld_safe #根据自己的mysql目录配置
mysqladmin=/usr/local/mysql/mysql-5.6/bin/mysqladmin

[mysqld1]
port=3305
socket=/tmp/3305mysql.sock
pid-file=/data/mysqlData/mysql3305/3305mysql.pid
basedir=/usr/local/mysql/mysql-5.6
datadir=/data/mysqlData/mysql3305/data
log-bin=mysql1-9003-bin
#user=cloud1
user=mysql

## 从机配置1 略

[mysqld2]
port=3304
socket=/tmp/mysql.sock2
pid-file=/data/mysqlData/mysql3304/3304mysql.pid
basedir=/usr/local/mysql/mysql-5.6
datadir=/data/mysqlData/mysql3304/data
log-bin=mysql2-9003-bin
user=mysql

## 从配置2 略
## ============================================================================================ ##                 
```

- 初始化从实列数据库

```
./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/mysql3305/data  --basedir=/usr/local/mysql/mysql-5.6
./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/mysql3304/data --basedir=/usr/local/mysql/mysql-5.6
```

​       初始话成功，会提示OK，否则查看数据库目录是否有权限。

- 启动实例

        使用如下参数来启动mysqld_multi： (注：该命令在mysql的bin目录中 ) 。
     mysqld_multi [options] [GNR[,GNR]...]
        start,stop和report是指你想到执行的操作。你可以在单独的服务或是多服务上指定一个操作，区别于选项后面的GNR列表。如果没有指定GNR列表，那么mysqld_multi将在所有的服务中根据选项文件进行操作。
         每一个GNR的值是组的序列号或是一个组的序列号范围。此项的值必须是组名字最后的数字，比如说如果组名为mysqld17，那么此项的值则为 17。如果指定一个范围，使用"-"(破折号)来连接二个数字。如GNR的值为10-13,则指组mysqld10到组mysqld13。

> mysqld_multi --defaults-file=/opt/mysql/server-5.6/my.cnf start 1-2
> 或者

```
mysqld_multi --defaults-file=/usr/local/mysql/mysql-5.6/my.cnf start 1
mysqld_multi --defaults-file=/usr/local/mysql/mysql-5.6/my.cnf start 2

mysqld_multi start 1
mysqld_multi start 2

./support-files/mysql.server start
## 使用etc/my.cnf 可以不指定my.cnf
	mysqld_multi start 3305  
  mysqld_multi start 3304
```

- 修改密码，登陆

```
mysqladmin -u root -p -P 3305 -S /tmp/mysql.sock1 password  //刚开始默认没有密码，如果要输入密码，直接回车
mysql -u root -p -P 3305 -S /tmp/mysql.sock1
```

```
mysql -uroot -p -P 3305 -S /tmp/3305mysql.sock
mysql -uroot -p -P 3304 -S /tmp/3304mysql.sock



mysqladmin -u root -p -P 3304 -S /tmp/mysql3304.sock
-- 停止
 mysqladmin -h127.0.0.1 -P3305 -uroot -p shutdown
```

-- 修改密码通用 

https://blog.csdn.net/weixin_57720070/article/details/116612937

### 2: 利用多份配置文件 [暂未实现！！fuck]

```
ps -ef|grep mysql|awk '{print $2}'|xargs kill -9
```

>  tar -zxvf mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz  -C /usr/local/



## 四： 配置主从

todo::: See https://www.jianshu.com/p/1e18c1249b9b

> mysql的主从复制不像redis那样全量复制----mysql是从建立主从复制的时间点进行复制同步到从库
>

vim /etc/my.cng

```

##### 主从配置 -- 主
server_id=20
log-bin=master-bin
binlog-format=ROW
expire_logs_days=7 
#### // binlog每个日志文件大小
max_binlog_size=150M
max_connections=1000
binlog-ignore-db=mysql
binlog-ignore-db=sys
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema

##### 主从配置 -- 从1
server_id=21
log_bin=3305_slave-bin
relay_log=3305_slave-relay-bin
log_slave_updates=1
read_only=1
expire_logs_days=7
###  //binlog每个日志文件大小
max_binlog_size=100m
replicate_ignore_db=information_schema
replicate_ignore_db=performance_schema
replicate_ignore_db=mysql
replicate_ignore_db=sys

##### 主从配置 -- 从2
server_id=22
log_bin=3304_slave-bin
relay_log=3304_slave-relay-bin
log_slave_updates=1
read_only=1
expire_logs_days=7
max_binlog_size=100m
# 
replicate_ignore_db=information_schema
replicate_ignore_db=performance_schema
replicate_ignore_db=mysql
replicate_ignore_db=sys
```



### 主库操作

- 主服务器上配置新用户 只给主从复制的权限

```
CREATE USER zrgick@'192.168.%.%' IDENTIFIED BY 'zrgick'; 
grant replication slave,replication client on *.* to zrgick@'192.168.%.%' identified by 'zrgick';
flush privileges;

--5.7
CREATE USER zrgick@'192.168.%.%' IDENTIFIED WITH mysql_native_password BY 'snail1234';

```

- 查看主库此时状态

  mysql> show master status ; [记录此时的position]

```
+-------------------+----------+--------------+-------------------------------------------------+-------------------+
| File              | Position | Binlog_Do_DB | Binlog_Ignore_DB                                | Executed_Gtid_Set |
+-------------------+----------+--------------+-------------------------------------------------+-------------------+
| master-bin.000001 |     1030 |              | mysql,sys,information_schema,performance_schema |                   |
+-------------------+----------+--------------+-------------------------------------------------+-------------------+
1 row in set (0.00 sec)
```



### 从库操作

- 通过刚刚主库的状态

```
 CHANGE MASTER TO MASTER_HOST='192.168.225.219',MASTER_USER='zrgick',MASTER_PASSWORD='zrgick',MASTER_LOG_FILE='master-bin.000001',MASTER_LOG_POS=1030;
 
 CHANGE MASTER TO MASTER_HOST='192.168.225.227',MASTER_USER='zrgick',MASTER_PASSWORD='zrgick',MASTER_LOG_FILE='master-bin.000004',MASTER_LOG_POS=601;
 
 CHANGE MASTER TO MASTER_HOST='192.168.225.228',MASTER_USER='zrgick',MASTER_PASSWORD='zrgick',MASTER_LOG_FILE='master-bin.000001',MASTER_LOG_POS=1193;
```

- 开启从库

  ```
  reset slave
  先执行下“stop slave;”，
  以停止slave线程。
  然后启动线程"start slave;" 
  ```

- 查看此时状态

  show slave status\G；

  ```
  *************************** 1. row ***************************
                 Slave_IO_State: Waiting for master to send event
                    Master_Host: 192.168.225.133
                    Master_User: zrgick
                    Master_Port: 3306
                  Connect_Retry: 60
                Master_Log_File: master-bin.000001
            Read_Master_Log_Pos: 580
                 Relay_Log_File: slave-relay-bin.000002
                  Relay_Log_Pos: 744
          Relay_Master_Log_File: master-bin.000001
               Slave_IO_Running: Yes
              Slave_SQL_Running: Yes
                Replicate_Do_DB: 
            Replicate_Ignore_DB: information_schema,performance_schema,mysql,sys
             Replicate_Do_Table: 
         Replicate_Ignore_Table: 
        Replicate_Wild_Do_Table: 
    Replicate_Wild_Ignore_Table: 
                     Last_Errno: 0
                     Last_Error: 
                   Skip_Counter: 0
            Exec_Master_Log_Pos: 580
                Relay_Log_Space: 917
                Until_Condition: None
                 Until_Log_File: 
                  Until_Log_Pos: 0
             Master_SSL_Allowed: No
             Master_SSL_CA_File: 
             Master_SSL_CA_Path: 
                Master_SSL_Cert: 
              Master_SSL_Cipher: 
                 Master_SSL_Key: 
          Seconds_Behind_Master: 0
  Master_SSL_Verify_Server_Cert: No
                  Last_IO_Errno: 0
                  Last_IO_Error: 
                 Last_SQL_Errno: 0
                 Last_SQL_Error: 
    Replicate_Ignore_Server_Ids: 
               Master_Server_Id: 1
                    Master_UUID: 3946768c-9a18-11ea-9504-000c297fef26
               Master_Info_File: /data/mysqlData/mysql3305/data/master.info
                      SQL_Delay: 0
            SQL_Remaining_Delay: NULL
        Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
             Master_Retry_Count: 86400
                    Master_Bind: 
        Last_IO_Error_Timestamp: 
       Last_SQL_Error_Timestamp: 
                 Master_SSL_Crl: 
             Master_SSL_Crlpath: 
             Retrieved_Gtid_Set: 
              Executed_Gtid_Set: 
                  Auto_Position: 0
  1 row in set (0.01 sec)
  
  ```

  >  当  Slave_IO_Running: Yes
  >            Slave_SQL_Running: Yes
  >
  > 表示 正常

  

  ```
  CREATE TABLE IF NOT EXISTS `zrgick`(
     `id` INT UNSIGNED,
     `name` VARCHAR(100),
     PRIMARY KEY ( `id` )
  )ENGINE=InnoDB DEFAULT CHARSET=utf8;
  ```
  
  