# mysql安装 步骤 及问题

CentOS 7下编译安装MySQL 5.6.14

概述：
通过源代码安装高版本的5.6.14。

正文：
一：卸载旧版本

使用下面的命令检查是否安装有MySQL Server

rpm -qa | grep mysql
有的话通过下面的命令来卸载掉
目前我们查询到的是这样的：
[root@hsp ~]# rpm -qa | grep mysql 
mysql-libs-5.1.73-7.el6.x86_64
如果查询到了，就删除吧

rpm -e mysql_libs   //普通删除模式
rpm -e --nodeps mysql_libs    // 强力删除模式，如果使用上面命令删除时，提示有依赖的其它文件，则用该命令可以对其进行强力删除
二：安装MySQL

安装编译代码需要的包

yum -y install make gcc-c++ cmake bison-devel  ncurses-devel
下载MySQL 5.6.14 【这里我们已经下载好了,看软件文件夹】

tar xvf mysql-5.6.14.tar.gz
cd mysql-5.6.14
编译安装[源码=》编译]

cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci

编译并安装
make && make install

整个过程需要30分钟左右……漫长的等待

三：配置MySQL

设置权限

使用下面的命令查看是否有mysql用户及用户组

cat /etc/passwd 查看用户列表
cat /etc/group  查看用户组列表
如果没有就创建

groupadd mysql
useradd -g mysql mysql
修改/usr/local/mysql权限
chown -R mysql:mysql /usr/local/mysql

初始化配置，进入安装路径（在执行下面的指令），执行初始化配置脚本，创建系统自带的数据库和表
cd /usr/local/mysql
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql    [这是一条指令]
注：在启动MySQL服务时，会按照一定次序搜索my.cnf，先在/etc目录下找，找不到则会搜索"$basedir/my.cnf"，在本例中就是 /usr/local/mysql/my.cnf，这是新版MySQL的配置文件的默认位置！

注意：在CentOS 6.8版操作系统的最小安装完成后，在/etc目录下会存在一个my.cnf，需要将此文件更名为其他的名字，如：/etc/my.cnf.bak，否则，该文件会干扰源码安装的MySQL的正确配置，造成无法启动。
修改名称，防止干扰：
mv /etc/my.cnf /etc/my.cnf.bak

启动MySQL
添加服务，拷贝服务脚本到init.d目录，并设置开机启动 
[注意在 /usr/local/mysql 下执行]
cp support-files/mysql.server /etc/init.d/mysql
chkconfig mysql on
service mysql start  --启动MySQL

执行下面的命令修改root密码
cd /usr/local/mysql/bin
./mysql -uroot  
mysql> SET PASSWORD = PASSWORD('root');

简单使用：
创建一个数据库 DB1
创建一张表 user
添加一个用户，如果成功，说明我们的数据库就安装成功了！






/**************Question***************************/
MySQL 5.7.17 安装报错CMake Error at cmake/boost.cmake:81 (MESSAGE

原因  高版本mysql需要boots库的安装才可以正常运行


4.继续cmake，添加上红色部分

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DENABLED_LOCAL_INFILE=ON \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
-DCOMPILATION_COMMENT='Mysqlma' \
-DWITH_READLINE=ON \
-DWITH_BOOST=/usr/local/boost \
-DSYSCONFDIR=/data/mysqldata/3306 \
-DMYSQL_UNIX_ADDR=/data/mysqldata/3306/mysql.sock

即安装后运行：

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql -DSYSCONFDIR=/etc -DWITH_BOOST=/usr/local/boost \   即可





























