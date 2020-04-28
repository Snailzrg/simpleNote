# MySql常见命令
```

启动/关闭：net start mysql;、net stop mysql 
登录：mysql -u root -p 或者 mysql -h 远程地址 -P 端口号 -u root -p databaseName; 
列出数据库：show databases; 
选择数据库：use databaseName; 
列出表格：show tables； 
显示表格列的属性：show columns from tableName； 
增加一个字段：alter table tableName add column fieldName dataType; 
增加多个字段：alter table tableName add column fieldName1 dataType,add columns fieldName2 dataType; 
增加一个管理员帐户：grant all on . to user@localhost identified by “password”; 
查询时间：select now(); 
查询当前用户：select user(); 
查询数据库版本：select version(); 
查询当前使用的数据库：select database();

1、删除student_course数据库中的students数据表： 
rm -f student_course/students.*（！！！慎用！！！）

2、备份数据库：(将数据库test备份) 
mysqldump -u root -p test>c:\test.txt 
备份表格：(备份test数据库下的mytable表格) 
mysqldump -u root -p test mytable>c:\test.txt 
将备份数据导入到数据库：(导回test数据库) 
mysql -u root -p test

3、创建临时表：(建立临时表zengchao) 
create temporary table zengchao(name varchar(10));

4、创建表是先判断表是否存在 
create table if not exists students(……);

5、从已经有的表中复制表的结构 
create table table2 select * from table1 where 1<>1;

6、复制表(参考链接：https://blog.csdn.net/qq_31772441/article/details/80315411) 
create table table2 select * from table1;

7、对表重新命名 
alter table table1 rename as table2;

8、修改列的类型 
alter table table1 modify id int unsigned;//修改列id的类型为int unsigned 
alter table table1 change id sid int unsigned;//修改列id的名字为sid，而且把属性修改为int unsigned

9、创建索引 
alter table table1 add index ind_id (id); 
create index ind_id on table1 (id); 
create unique index ind_id on table1 (id);//建立唯一性索引

10、删除索引 
drop index idx_id on table1; 
alter table table1 drop index ind_id;

11、联合字符或者多个列(将列id与”:”和列name和”=”连接) 
select concat(id,’:’,name,’=’) from students;

12、limit(选出10到20条)<第一个记录集的编号是0> 
select * from students order by id limit 10, 20;

13、MySQL不支持的功能 
事务，视图，外键和引用完整性，存储过程和触发器

14、MySQL会使用索引的操作符号 
<,<=,>=,>,=,between,in,不带%或者_开头的like 
(匹配字符：可以用通配符_代表任何一个字符，％代表任何字符串;)

15、使用索引的缺点 
1)减慢增删改数据的速度； 
2）占用磁盘空间； 
3）增加查询优化器的负担； 
当查询优化器生成执行计划时，会考虑索引，太多的索引会给查询优化器增加工作量，导致无法选择最优的查询方案；

16、分析索引效率 
方法：在一般的SQL语句前加上explain(查看执行计划) 
分析结果的含义： 
1）table：表名； 
2）type：连接的类型，(ALL/Range/Ref)。其中ref是最理想的； 
3）possible_keys：查询可以利用的索引名； 
4）key：实际使用的索引； 
5）key_len：索引中被使用部分的长度（字节）； 
6）ref：显示列名字或者”const”（不明白什么意思）； 
7）rows：显示MySQL认为在找到正确结果之前必须扫描的行数； 
8）extra：MySQL的建议；

17、使用较短的定长列 
1）尽可能使用较短的数据类型； 
2）尽可能使用定长数据类型； 
a）用char代替varchar，固定长度的数据处理比变长的快些； 
b）对于频繁修改的表，磁盘容易形成碎片，从而影响数据库的整体性能； 
c）万一出现数据表崩溃，使用固定长度数据行的表更容易重新构造。使用固定长度的数据行，每个记录的开始位置都是固定记录长度的倍数，可以很容易被检测到，但是使用可变长度的数据行就不一定了； 
d）对于MyISAM类型的数据表，虽然转换成固定长度的数据列可以提高性能，但是占据的空间也大；

18、使用not null和enum 
尽量将列定义为not null，这样可使数据的出来更快，所需的空间更少，而且在查询时，MySQL不需要检查是否存在特例，即null值，从而优化查询； 
如果一列只含有有限数目的特定值，如性别，是否有效或者入学年份等，在这种情况下应该考虑将其转换为enum列的值，MySQL处理的更快，因为所有的enum值在系统内都是以标识数值来表示的；

19、使用optimize table 
对于经常修改的表，容易产生碎片，使在查询数据库时必须读取更多的磁盘块，降低查询性能。具有可变长的表都存在磁盘碎片问题，这个问题对blob数据类型更为突出，因为其尺寸变化非常大。可以通过使用optimize table来整理碎片，保证数据库性能不下降，优化那些受碎片影响的数据表。 optimize table可以用于MyISAM和BDB类型的数据表。实际上任何碎片整理方法都是用mysqldump来转存数据表，然后使用转存后的文件并重新建数据表；

20、使用procedure analyse() 
可以使用procedure analyse()显示最佳类型的建议，使用很简单，在select语句后面加上procedure analyse()就可以了；例如： 
select * from students procedure analyse(); 
select * from students procedure analyse(16,256); 
第二条语句要求procedure analyse()不要建议含有多于16个值，或者含有多于256字节的enum类型，如果没有限制，输出可能会很长；

21、使用查询缓存 
1）查询缓存的工作方式： 
第一次执行某条select语句时，服务器记住该查询的文本内容和查询结果，存储在缓存中，下次碰到这个语句时，直接从缓存中返回结果；当更新数据表后，该数据表的任何缓存查询都变成无效的，并且会被丢弃。 
2）配置缓存参数： 
变量：query_cache _type，查询缓存的操作模式。有3中模式，0：不缓存；1：缓存查询，除非与 select sql_no_cache开头；2：根据需要只缓存那些以select sql_cache开头的查询； query_cache_size：设置查询缓存的最大结果集的大小，比这个值大的不会被缓存。
```


## 补充