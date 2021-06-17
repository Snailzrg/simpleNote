## PostgreSQL安装



## 1 Docker

> Docker pull postgres:12
>
> 

docker run --name snail_pg -e POSTGRES_PASSWORD=123456 -e TZ=PRC -p 5433:5432 -v /Users/snailzhou/softData/dockerDatas/postgres/data:/var/lib/postgresql/data -d postgres:12  --restart=always 

如果创建时未指定 --restart=always ,可通过 update 命令

```
docker update --restart=always snail_pg
```



## 1 Linux

```
# Install the repository RPM:
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install PostgreSQL:
sudo yum install -y postgresql12-server
## yum install postgresql12-contrib

# Optionally initialize the database and enable automatic start:
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb
sudo systemctl enable postgresql-12
sudo systemctl start postgresql-12
```

初始化数据库

```
/usr/pgsql-12/bin/postgresql-12-setup initdb
```

配置开机启动与启动

```
systemctl enable postgresql-12
systemctl start postgresql-12
```

切换到postgres用户。然后执行修改用户密码SQL语句。其中“postgres”为要修改密码的用户，“123456”为用户的密码

```
su - postgres
psql -c "alter user postgres with password '123456'"
```

配置远程访问

```
vi /var/lib/pgsql/12/data/postgresql.conf
将“#listen_addresses = ‘localhost’”改为“listen_addresses = ‘*’
```

打开并编辑文件“/var/lib/pgsql/12/data/pg_hba.conf”。在文件的末尾添加“host all all 0.0.0.0/0 md5”

重启服务

```
systemctl  restart postgresql-12

```

![image-20210530221428928](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210530221428928.png)

--

![image-20210601171804804](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210601171804804.png)



## 简单入门

```
su - postgres

createdb mydb


-- dropdb
dropdb superSnailMall;


-- DROP DATABASE 删除数据库
DROP DATABASE 会删除数据库的系统目录项并且删除包含数据的文件目录。
DROP DATABASE 只能由超级管理员或数据库拥有者执行。
DROP DATABASE 命令需要在 PostgreSQL 命令窗口来执行，语法格式如下：
DROP DATABASE [ IF EXISTS ] name

-- 删除若失败 
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname='superSnailMall' AND pid<>pg_backend_pid();

```

![image-20210601171458416](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210601171458416.png)





```
CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
```

我们可以使用 **\d** 命令来查看表格是否创建成功：

```
runoobdb=# \d
           List of relations
 Schema |    Name    | Type  |  Owner   
--------+------------+-------+----------
 public | company    | table | postgres
 public | department | table | postgres
(2 rows)
```

**\d tablename** 查看表格信息：

```
runoobdb=# \d company
                  Table "public.company"
 Column  |     Type      | Collation | Nullable | Default 
---------+---------------+-----------+----------+---------
 id      | integer       |           | not null | 
 name    | text          |           | not null | 
 age     | integer       |           | not null | 
 address | character(50) |           |          | 
 salary  | real          |           |          | 
Indexes:
    "company_pkey" PRIMARY KEY, btree (id)
```



 **删除表格-DROP TABLE** 语法格式如下：

```
DROP TABLE table_name;
```

# PostgreSQL 模式（SCHEMA）

PostgreSQL 模式（SCHEMA）可以看着是一个表的集合。

一个模式可以包含视图、索引、数据类型、函数和操作符等。

相同的对象名称可以被用于不同的模式中而不会出现冲突，例如 schema1 和 myschema 都可以包含名为 mytable 的表。

使用模式的优势：

- 允许多个用户使用一个数据库并且不会互相干扰。
- 将数据库对象组织成逻辑组以便更容易管理。
- 第三方应用的对象可以放在独立的模式中，这样它们就不会与其他对象的名称发生冲突。

模式类似于操作系统层的目录，但是模式不能嵌套。

### 语法

我们可以使用 **CREATE SCHEMA** 语句来创建模式，语法格式如下：

接下来我们连接到 runoobdb 来创建模式 myschema：

```
runoobdb=# create schema myschema;
CREATE SCHEMA
```

输出结果 "CREATE SCHEMA" 就代表模式创建成功。

接下来我们再创建一个表格：

```
runoobdb=# create table myschema.company(
   ID   INT              NOT NULL,
   NAME VARCHAR (20)     NOT NULL,
   AGE  INT              NOT NULL,
   ADDRESS  CHAR (25),
   SALARY   DECIMAL (18, 2),
   PRIMARY KEY (ID)
);
```

以上命令创建了一个空的表格，我们使用以下 SQL 来查看表格是否创建：

```
runoobdb=# select * from myschema.company;
 id | name | age | address | salary 
----+------+-----+---------+--------
(0 rows)
```





## springboot 连接 postgresql 指定模式Schema
一般的连接方式，我们创建数据库之后，在public 的Schema（模式）下建表，这时使用连接方式

```
jdbc:postgresql://localhost:5432/postgresql
在这种连接方式下，默认连接使用的是postgresql数据库的public 模式
```

在业务场景中有时允许多个用户使用一个数据库并且不会互相干扰。这时需要在使用同一个数据库 新建其他模式进行连接。这时在springboot的数据源jdbc配置时注意。

```
postgresql-> 9.3 及以前的版本指定方式
spring.datasource.url=jdbc:postgresql://localhost:5432/postgresql?searchpath=newschema
```

```
postgresql-> 9.4 及以后的版本指定方式
spring.datasource.url=jdbc:postgresql://localhost:5432/postgresql?currentSchema=newschema
```

