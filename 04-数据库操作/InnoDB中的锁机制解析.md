# InnoDB中的锁机制解析

大家好，我是顾南，平时我们开发时使用最多的数据库是MySQL，而InnoDB由于其支持行锁，多版本并发控制，事务等许多应用中必不可少的特性，所以全盘的写写InnoDB的并发控制，锁，索引，事务模型等，想全部在一篇博客中写完不现实，容我娓娓道来，慢慢的把来龙去脉说清楚，今天就主要和大家聊一聊InnoDB中的锁；

# 并发控制

并发的对某一临界资源进行操作，如果不采取措施，很容易造成数据的不一致，丢失更新，所以必须进行并发控制；而事务中的四个特性原子性（A）、一致性（C）、隔离性（I）、持久性（D）中的隔离型就依赖于并发控制； 在技术上进行并发控制（保证隔离性）的手段主要有两个；

- 锁
- mvcc

ps（事务的分类，隔离级别，在各个隔离级别下产生的现象比较基础就不讲了）

# 锁的分类

锁的分类可以分为三个维度； 按照兼容性分：共享锁，排他锁； 按照锁粒度分：库锁，表锁，页锁，行锁； 其中表锁有自增锁和意向锁 行锁分为记录锁，间隙锁（Gap Lock）,next-key lock 在给某个行记录加锁之前会给他的上一层加上意向锁页锁；



![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/75dbe5b45ace46ef9bc1dfdace44f419~tplv-k3u1fbpfcp-zoom-1.image)



扩展哦^_^

> 想到了在行锁下边有更细粒度的锁需求怎么办，InnoDB还没有字段级别的锁，我们通过业务实现 ，一行记录的锁竞争太频繁，大体上分两种情况

- 冲突的在一个字段，比如并发扣库存
- 冲突的在不同字段

对于第一种情况 我们可以采取行拆分的方法，还是以并发扣库存为例，秒杀等并发量高的场景，对热门商品库存的行记录并发竞争很大，可以把某件商品的库存由一行拆分为五行,把某行的锁竞争降为原来的1/5； 对于第二种情况，冲突的是不同的字段，我们可以采用纵向拆表的方式拆锁

# 行锁

震惊 InnoDB的select竟然可以阻塞insert操作；

标准的RR隔离级别下，是允许幻读的情况发生的，InnoDB通过next-key lock算法，使事务没有幻读的情况发生；

## 行锁的三种算法

- Record Lock : 单个行记录上的锁
- Gap Lock : 间隙锁，锁定一个范围，但是不包括记录本身
- Next-Key Lock : Gap Lock+Record Lock,锁定一个范围，并且锁定记录本身

本质上 Next-Key Lock是为了解决幻读的问题 幻读不只是影响事务中的隔离性，在某些情况下还会影响主从的一致性，比如binlog设置为statement,多个session的提交顺序未知，造成主从数据不一致，这也是RC隔离级别下为什么要把binlog的格式设置为row(binlog的问题以后再讲，先挖坑)；

- 行锁加的基本单位是Next-key Lock,只有在某些情况写Next-key Lock才会退化为 Gap Lock和Record Lock,Next-key Lock是前开后闭区间；
- 查找过程中访问的对象才会加锁
- 索引上的等值查询，再给聚集索引加锁的时候，Next-key Lock退化为Record Lock
- 索引上的等值查询，向右遍历时最后一个不满足等值条件的时候，Next-key Lock退化为Gap Lock

建表测试

```sql
CREATE TABLE `lk_t` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inv` int(11) DEFAULT NULL,
  `item_id` varchar(12) DEFAULT '0.00',
  `gunan` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `item` (`item_id`),
  KEY `gunan` (`gunan`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8

```

id是主键，item_id 是唯一索引，gunan这列是普通索引

```sql
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (1, 1, '1', 1);
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (5, 5, '5', 5);
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (10, 10, '10', 10);
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (15, 15, '15', 15);
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (20, 20, '20', 20);
INSERT INTO `fescar`.`lk_t`(`id`, `inv`, `item_id`, `gunan`) VALUES (25, 25, '25', 25);

```

间隙为(1,5],(5,10],(10,15],(15,20],(20,25]

## 普通索引等值锁

| sessionA                                            | sessionB                                   | sessionC                                                     |
| --------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| begin;                                              |                                            |                                                              |
| select * from lk_t where gunan=7 lock in share mode |                                            |                                                              |
|                                                     | insert into lk_t values(8,8,8,8) (blocked) |                                                              |
|                                                     |                                            | update lk_t set inv = 11 where gunan = 10 (Affected rows: 1) |

等值查询7,一个不存在的记录，加锁单位Next-key Lock ，sessionA加锁范围是（5,10] gunan=10不满足gunan=7,所以Next-key Lock退化为Gap Lock；最终区间是（5，10）； 所以sessionB向插入gunan=8的记录会被阻塞

这里我有一个好问题，

> sessionA查询gunan=7这一列ok，在我没有commit之前，就算sessionB插入了gunan=8的这一行数据，session查询gunan=7还是id=7这条数据，也不会把id=8这条数据查出来，并没有造成幻读现象，那么，为什么InnerDB要把gunan=8这一行给锁起来呢？

实际上由于gunan这一列只是普通索引，防止幻读就要阻塞guan=7的插入，gunan=7插入按照B+树的数据结构，只能插入到（5，10）区间，阻塞了gunan=8这一列是因为技术限制,没有完美的技术方案。

唯一索引范围锁

| sessionA                                              | sessionB                                          | sessionC                                        |
| ----------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------- |
| begin;                                                |                                                   |                                                 |
| select * from lk_t where id>=10 and id <11 for update |                                                   |                                                 |
|                                                       | insert into lk_t values(8,8,8,8) Affected rows: 1 |                                                 |
|                                                       | insert into lk_t values(13,13,13,13) (block)      |                                                 |
|                                                       |                                                   | update lk_t set inv=inv+1 where id = 15 (block) |

分析

找到id=10这一行，加Next-key Lock(5,10],因为实在id上的等值查询，退化为行锁，只加在id=10这一行； 查找到id=15停止；因此next-key lock(10,15]