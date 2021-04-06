## 01 忘记root密码

>- service mysql stop   停止服务
>- vim /etc/my.cnf  编辑===>找到mysqld 下面添加  skip-grant-tables
>-  ./mysql -u root -p. 不加密码登录
>-  set password for 'root'@'localhost'=password('123456');报错后，输入flush privileges;命令行执行，再执行 set password for 'root'@'localhost'=password('123456');就可以成功设置密码了
>- 重启 

## 02 本地远程登录linux上mysql 被拒

1045 - Access denied for user 'root'@'192.168.225.1' (using password: YES)

> ## 远程登录密码与mysql密码最好保持一致
>
> mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
> mysql> FLUSH PRIVILEGES;
>
> grant all privileges on *.* to root@'%' identified by "123456";



 ## 03 mysql中对应用户开放对应库全线（禁止全用root）

> Todo-----



## 04 本地navate连接报错2059authentication plugin ‘caching_sha2_passord’ …”

>  mysql 8.0 默认使用 caching_sha2_password 身份验证机制 —— 从原来的 mysql_native_password 更改为 caching_sha2_password。
> 从 5.7 升级 8.0 版本的不会改变现有用户的身份验证方法，但新用户会默认使用新的 caching_sha2_password 。
> 客户端不支持新的加密方式。
>
> 解决： 从容器内登录mysql ,修改其密码验证方式。
>
> ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
> --最后刷新一下
> flush privileges;
>
> 需要注意的就是，这个语句修改的只是root 用的验证方式，用其他用户则需修改用户名要再执行一下。
>
> 查看用户的验证方式：
>
> use mysql;
> select host,user,plugin from user;


