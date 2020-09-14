## 【58期】盘点那些面试中最常问的MySQL问题，第一弹！

[Java面试题精选](javascript:void(0);) *3月9日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

### 1、MySQL中myisam与innodb的区别

**MyISAM：**

- 不支持事务，但是每次查询都是原子的；
- 支持表级锁，即每次操作对整个表加锁；
- 存储表的总行数；
- 一个MYISAM表有三个文件：索引文件、表结构文件、数据文件；
- 采用非聚集索引，索引文件的数据域存储指向数据文件的指针。辅索引与主索引基本一致，但是辅索引不用保证唯一性。

**InnoDb：**

- 支持ACID的事务，支持事务的四种隔离级别；
- 支持行级锁及外键约束：因此可以支持写并发；
- 不存储总行数；
- 一个InnoDb引擎存储在一个文件空间（共享表空间，表大小不受操作系统控制，一个表可能分布在多个文件里），也有可能为多个（设置为独立表空，表大小受操作系统文件大小限制，一般为2G），受操作系统文件大小的限制；
- 主键索引采用聚集索引（索引的数据域存储数据文件本身），辅索引的数据域存储主键的值；因此从辅索引查找数据，需要先通过辅索引找到主键值，再访问辅索引；最好使用自增主键，防止插入数据时，为维持B+树结构，文件的大调整。

**两者的适用场景：**

因为MyISAM相对简单所以在效率上要优于InnoDB.如果系统读多，写少。对原子性要求低。那么MyISAM最好的选择。且MyISAM恢复速度快。可直接用备份覆盖恢复。

如果系统读少，写多的时候，尤其是并发写入高的时候。InnoDB就是首选了。

***扩展问题：myisam与innodb引擎下select count(\*)哪个更快，为什么？\***

知道的童鞋，欢迎留言说出正确答案~

### 2、MySQL INT和CHAR隐式类型转换需要注意什么？

主要需要记住下面两点：

1、当查询字段是INT类型，如果查询条件为CHAR，将查询条件转换为INT，如果是字符串前导都是数字，将截取前导数字用来比较，如果没有前导数字，则转换为0。

2.、当查询字段是CHAR/VARCHAR类型，如果查询条件为INT，将查询字段转换为INT再进行比较，可能会造成全表扫描。

**答案解析**

有如下一张测试表product，id为int类型，name为varchar类型。

```
+----+----------+
| id | name   |
+----+----------+
|  1 | apple   |
|  2 | banana |
|  3 | 99cat   |
+----+----------+
```

情况1:

```
// 查询条件转化为数字1再比较
mysql> select * from product where id = '1abc23';
+----+---------+
| id | name  |
+----+---------+
|  1 | apple  |
+----+---------+
```

情况2:

```
// 查询字段全部转化成数字，id:1和id:2字段值转化为0，id:3转化成99，再比较
mysql> select * from product where name=0;
+----+----------+
| id | name   |
+----+----------+
|  1 | apple   |
|  2 | banana |
+----+----------+
```

### 3、MySQL 如何高效率随机获取N条数据？

假设表叫做mm_account。

ID连续的情况下（注意不能带where，否则结果不好）：

```
SELECT *
FROM `mm_account` AS t1 JOIN (SELECT ROUND(RAND() * (SELECT MAX(id) FROM `mm_account`)) AS id) AS t2
WHERE t1.id >= t2.id
ORDER BY t1.id ASC LIMIT 4;
```

ID不连续的情况下：

```
SELECT * FROM `mm_account` 
WHERE id >= (SELECT floor(RAND() * (SELECT MAX(id) FROM `mm_account`)))  and city="city_91" and showSex=1
ORDER BY id LIMIT 4;
```

如果有一个字段叫id，最快的方法如下（随机获取5条）：

```
SELECT * FROM mm_account 
WHERE id >= ((SELECT MAX(id) FROM mm_account)-(SELECT MIN(id) FROM mm_account)) * RAND() + (SELECT MIN(id) FROM mm_account)
limit 5;
```

如果带where语句，上面就不适合了，带where语句请看下面：

```
SELECT *
FROM `mm_account` AS t1 JOIN (SELECT ROUND(RAND() * (
(SELECT MAX(id) FROM `mm_account` where id<1000 )-(SELECT MIN(id) FROM `mm_account` where id<1000 ))+(SELECT MIN(id) FROM `mm_account` where id<1000 )) AS id) AS t2
WHERE t1.id >= t2.id
ORDER BY t1.id LIMIT 5;
```

### 4、说说你知道的MySQL的索引类型，并分别简述一下各自的场景。

**普通索引：**没有任何限制条件的索引，该索引可以在任何数据类型中创建。

**唯一索引：**使用UNIQUE参数可以设置唯一索引。创建该索引时，索引列的值必须唯一，但允许有空值。通过唯一索引，用户可以快速地定位某条记录，主键索引是一种特殊的唯一索引。

**全文索引：**仅可用于 MyISAM 表，针对较大的数据，生成全文索引耗时耗空间。

**空间索引：**只能建立在空间数据类型上。这样可以提高系统获取空间数据类型的效率。仅可用于 MyISAM 表，索引的字段不能为空值。使用SPATIAL参数可以设置索引为空间索引。

**单列索引：**只对应一个字段的索引。

**多列索引：**在表的多个字段上创建一个索引。该索引指向创建时对应的多个字段，用户可以通过这几个字段进行查询，想使用该索引，用户必须使用这些字段中的一个字段。

***扩展问题：MySQL索引是如何提高查询效率的呢？\***

可以留言各抒己见，下期专门分析这个问题。