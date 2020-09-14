## 【60期】事务隔离级别中的可重复读能防幻读吗?（MySQL面试第二弹）

码农阿宇 [Java面试题精选](javascript:void(0);) *3月13日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

# **前言** 

每次谈到数据库的事务隔离级别，大家一定会看到这张表。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNiaEy9vZM1w4q973kSr0GTPYasiccVXHXYpmp2dscasEtUBMIgTKQH0pg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

其中，可重复读这个隔离级别，有效地防止了脏读和不可重复读，但仍然可能发生幻读，可能发生幻读就表示可重复读这个隔离级别防不住幻读吗?



我不管从数据库方面的教科书还是一些网络教程上,经常看到RR级别是可以重复读的，但是无法解决幻读，只有可串行化(Serializable)才能解决幻读，这个说法是否正确呢?



在这篇文章中,我将重点围绕MySQL中**可重复读（Repeatable read）能防住幻读吗?**这一问题展开讨论，相信看完这篇文章后你一定会对事务隔离级别有新的认识。



我们的数据库中有如下结构和数据的Users表，下文中我们将对这张表进行操作

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNWs6n8x0niakGVD7NibIUibp9YeLDibibWjjG5qOmlGPO9TWicJ72Mp8H7FGw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

长文预警，读完此篇文章，大概需要您二十至三十分钟。



# **什么是幻读?**



在说幻读之前，我们要先来了解脏读和不可重复读。



## 脏读

当一个事务读取到另外一个事务修改但未提交的数据时，就可能发生脏读。



![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)



在我们的例子中，事务2修改了一行，但是没有提交，事务1读了这个没有提交的数据。



现在如果事务2回滚了刚才的修改或者做了另外的修改的话，事务1中查到的数据就是不正确的了，所以这条数据就是脏读。



## 不可重复读

“不可重复读”现象发生在当执行SELECT 操作时没有获得读锁或者SELECT操作执行完后马上释放了读锁；另外一个事务对数据进行了更新，读到了不同的结果。



![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNdH2eebuQsG7crRPfZx5IHmPgrZqxemI8XGYHhdqMwFiaR8p56U3HoQg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

在这个例子中，事务2提交成功，因此他对id为1的行的修改就对其他事务可见了。导致了事务1在此前读的age=1，第二次读的age=2，两次结果不一致,这就是不可重复读。



## 幻读

“幻读”又叫"幻象读",是''不可重复读''的一种特殊场景：当事务1两次执行''SELECT ... WHERE''检索一定范围内数据的操作中间，事务2在这个表中创建了(如[[INSERT]])了一行新数据，这条新数据正好满足事务1的“WHERE”子句。



![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNsuALPxCcMlXdG1m8ZMSmw4Aa39SM0ct3FggicGvnyibibW03ZvG1Gppgg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

如图事务1执行了两遍同样的查询语句，第二遍比第一遍多出了一条数据，这就是幻读。



## 三者到底什么区别



三者的场景介绍完,但是一定仍然有很多同学搞不清楚,它们到底有什么区别，我总结一下。



**脏读**：指读到了其他事务未提交的数据。

**不可重复读**：读到了其他事务已提交的数据(update)。

不可重复读与幻读都是读到其他事务已提交的数据,但是它们针对点不同。

不可重复读：update。

幻读：delete，insert。



# **MySQL中的四种事务隔离级别**

## 未提交读

未提交读（READ UNCOMMITTED）是最低的隔离级别，在这种隔离级别下，如果一个事务已经开始写数据，则**另外一个事务则不允许同时进行写操作**，**但允许其他事务读此行数据。**



把脏读的图拿来分析分析，因为事务2更新id=1的数据后，仍然允许事务1读取该条数据,所以事务1第二次执行查询，读到了事务2更新的结果，产生了脏读。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNYvNeSzzntHpt8gX6D4M0Ge5vjXpWewfv79ehAJlPsLTPEJlibEXlohg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 已提交读

由于MySQL的InnoDB默认是使用的RR级别，所以我们先要将该session开启成RC级别，并且设置binlog的模式

- 
- 

```
SET session transaction isolation level read committed;SET SESSION binlog_format = 'ROW';（或者是MIXED）
```

在已提交读（READ COMMITTED）级别中，读取数据的事务**允许其他事务继续访问该行数据，但是未提交的写事务将会禁止其他事务访问该行，会对该写锁一直保持直到到事务提交。**



同样，我们来分析脏读，事务2更新id=1的数据后，在提交前，会对该对象写锁，所以事务1读取id=1的数据时，会一直等待事务2结束，处于阻塞状态，避免了产生脏读。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNYvNeSzzntHpt8gX6D4M0Ge5vjXpWewfv79ehAJlPsLTPEJlibEXlohg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

同样，来分析不可重复读，事务1读取id=1的数据后并没有锁住该数据，所以事务2能对这条数据进行更新，事务2对更新并提交后，该数据立即生效，所以事务1再次执行同样的查询，查询到的结果便与第一次查到的不同，所以已提交读防不了不可重复读。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNdH2eebuQsG7crRPfZx5IHmPgrZqxemI8XGYHhdqMwFiaR8p56U3HoQg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 可重复读

在可重复读（REPEATABLE READS）是介于已提交读和可串行化之间的一种隔离级别(废话😅)，它是InnoDb的默认隔离级别，它是我这篇文章的重点讨论对象，所以在这里我先卖个关子,后面我会详细介绍。

## 可串行化

可串行化（Serializable ）是高的隔离级别，它求在选定对象上的读锁和写锁保持直到事务结束后才能释放，所以能防住上诉所有问题，但因为是串行化的，所以效率较低。

![img](https://mmbiz.qpic.cn/mmbiz_jpg/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNG0hIB3lBYSqicp9Q4ELicIvpKgI4B5x0pyAeB5ibreOzc7G6ReFtGNibyw/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

了解到了上诉的一些背景知识后，下面正式开始我们的议题。



**可重复读（Repeatable read）能防住幻读吗?**

**
**

# **可重复读**

在讲可重复读之前，我们先在mysql的InnoDB下做下面的实验。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNuicrDMlLQjWnsy3vZ7YhYZpyte4hxbVGxibuQTNlupZZQyEPlJyZm8Uw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

可以看到，事务A既没有读到事务B更新的数据，也没有读到事务C添加的数据，所以在这个场景下，它既防住了不可重复读，也防住了幻读。



到此为止，相信大家已经知道答案了，这是怎么做到的呢?



## 悲观锁与乐观锁



我们前面说的在对象上加锁，是一种悲观锁机制。



有很多文章说可重复读的隔离级别防不了幻读，是认为可重复读会对读的行加锁，导致他事务修改不了这条数据，直到事务结束。



但是这种方案只能锁住数据行，如果有新的数据进来，是阻止不了的，所以会产生幻读。



可是MySQL、ORACLE、PostgreSQL等已经是非常成熟的数据库了，怎么会单纯地采用这种如此影响性能的方案呢?

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)



我来介绍一下悲观锁和乐观锁。



### **悲观锁**

正如其名，它指的是对数据被外界（包括本系统当前的其他事务，以及来自外部系统的事务处理）修改持保守态度，因此，在整个数据处理过程中，将数据处于锁定状态。



读取数据时给加锁，其它事务无法修改这些数据。修改删除数据时也要加锁，其它事务无法读取这些数据。



### **乐观锁**

相对悲观锁而言，乐观锁机制采取了更加宽松的加锁机制。悲观锁大多数情况下依靠数据库的锁机制实现，以保证操作最大程度的独占性。



但随之而来的就是数据库性能的大量开销，特别是对长事务而言，这样的开销往往无法承受。



而乐观锁机制在一定程度上解决了这个问题。乐观锁，大多是基于数据版本（ Version ）记录机制实现。



何谓数据版本？即为数据增加一个版本标识，在基于数据库表的版本解决方案中，一般是通过为数据库表增加一个 “version” 字段来实现。读取出数据时，将此版本号一同读出，之后更新时，对此版本号加一。



此时，将提交数据的版本数据与数据库表对应记录的当前版本信息进行比对，如果提交的数据版本号大于数据库表当前版本号，则予以更新，否则认为是过期数据。



MySQL、ORACLE、PostgreSQL等都是使用了以乐观锁为理论基础的MVCC（多版本并发控制）来避免不可重复读和幻读,MVCC的实现没有固定的规范，每个数据库都会有不同的实现方式，这里讨论的是InnoDB的MVCC。



## MVCC(多版本并发控制)

在InnoDB中，会在每行数据后添加两个额外的隐藏的值来实现MVCC，这两个值一个记录这行数据何时被创建，另外一个记录这行数据何时过期（或者被删除）。



在实际操作中，存储的并不是时间，而是事务的版本号，每开启一个新事务，事务的版本号就会递增。在可重读Repeatable reads事务隔离级别下：

- SELECT时，读取创建版本号<=当前事务版本号，删除版本号为空或>当前事务版本号。
- INSERT时，保存当前事务版本号为行的创建版本号
- DELETE时，保存当前事务版本号为行的删除版本号
- UPDATE时，插入一条新纪录，保存当前事务版本号为行创建版本号，同时保存当前事务版本号到原来删除的行

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNET6qoRhoywxmDsicibEicd3pyAwhH1VkJiaomib7Suib9hLOyibiaz7AXrc9Sw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

通过MVCC，虽然每行记录都要额外的存储空间来记录version，需要更多的行检查工作以及一些额外的维护工作，但可以减少锁的使用，大多读操作都不用加锁，读取数据操作简单，性能好。



细心的同学应该也看到了，通过MVCC读取出来的数据其实是历史数据，而不是最新数据。



这在一些对于数据时效特别敏感的业务中，很可能出问题，这也是MVCC的短板之处，有办法解决吗？当然有。



MCVV这种读取历史数据的方式称为快照读(snapshot read)，而读取数据库当前版本数据的方式，叫当前读(current read)。



### **快照读**

我们平时只用使用select就是快照读，这样可以减少加锁所带来的开销。

- 

```
select * from table ....
```

### **当前读**



对于会对数据修改的操作(update、insert、delete)都是采用当前读的模式。在执行这几个操作时会读取最新的记录，即使是别的事务提交的数据也可以查询到。



假设要update一条记录，但是在另一个事务中已经delete掉这条数据并且commit了，如果update就会产生冲突，所以在update的时候需要知道最新的数据。读取的是最新的数据，需要加锁。



以下第一个语句需要加共享锁，其它都需要加排它锁。

- 
- 
- 
- 
- 

```
select * from table where ? lock in share mode; select * from table where ? for update; insert; update; delete;
```

我们再利用当前读来做试验。

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNriak72vaichtiatDfGbmH7ichEAmN3I59RSF5u4zXmWgpk1vUQHxicXJHSQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

可以看到在读提交的隔离级别中，事务1修改了所有class_id=1的数据，当时当事务2 insert后，事务A莫名奇妙地多了一行class_id=1的数据，而且没有被之前的update所修改，产生了读提交下的的幻读。



而在可重复度的隔离级别下，情况就完全不同了。



事务1在update后，对该数据加锁，事务B无法插入新的数据，这样事务A在update前后数据保持一致，避免了幻读，可以明确的是，update锁的肯定不只是已查询到的几条数据，因为这样无法阻止insert，有同学会说，那就是锁住了整张表呗。



还是那句话，Mysql已经是个成熟的数据库了，怎么会采用如此低效的方法呢？其实这里的锁，是通过next-key锁实现的。



## Next-Key锁

在Users这张表里面，class_id是个非聚簇索引，数据库会通过B+树维护一个非聚簇索引与主键的关系，简单来说，我们先通过class_id=1找到这个索引所对应所有节点，这些节点存储着对应数据的主键信息，即id=1，我们再通过主键id=1找到我们要的数据，这个过程称为回表。

> 前往学习: 
>
> https://www.cnblogs.com/sujing/p/11110292.html

我本想用我们文章中的例子来画一个B+树，可是画得太丑了，为了避免拉低此偏文章B格。所以我想引用上面那边文章中作者画的B+树来解释Next-key。



假设我们上面用到的User表需要对Name建立非聚簇索引，是怎么实现的呢？我们看下图：

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNVY8BPpuEPvkuBAI7tXy4VrXZfklCqKTlibicBFWEB9icZ4aicYbQFwHLAQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



B+树的特点是所有数据都存储在叶子节点上，以非聚簇索引的秦寿生为例，在秦寿生的右叶子节点存储着所有秦寿生对应的Id，即图中的34。



在我们对这条数据做了当前读后，就会对这条数据加行锁，对于行锁很好理解，能够防止其他事务对其进行update或delete，但为什么要加GAP锁呢?



还是那句话，B+树的所有数据存储在叶子节点上，当有一个新的叫秦寿生的数据进来，一定是排在在这条id=34的数据前面或者后面的，我们如果对前后这个范围进行加锁了，那当然新的秦寿生就插不进来了。



那如果有一个新的范统要插进行呢？因为范统的前后并没有被锁住，是能成功插入的，这样就极大地提高了数据库的并发能力。



# **马失前蹄**

上文中说了可重复读能防不可重复读，还能防幻读，它能防住所有的幻读吗？当然不是，也有马失前蹄的时候。



比如如下的例子:

![img](https://mmbiz.qpic.cn/mmbiz_png/WlIksv5EUJmEthGaRbeTkaxfLAyjRibuNTOX83380X5TavVIZIKqL98TAxRCBDR0Y2kOnDg1Y6xibFqdGqshBcgA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

\1. a事务先select，b事务insert确实会加一个gap锁，但是如果b事务commit，这个gap锁就会释放（释放后a事务可以随意操作）

\2. a事务再select出来的结果在MVCC下还和第一次select一样

\3. 接着a事务不加条件地update，这个update会作用在所有行上（包括b事务新加的）

\4. a事务再次select就会出现b事务中的新行，并且这个新行已经被update修改了。



Mysql官方给出的幻读解释是：只要在一个事务中，第二次select多出了row就算幻读，所以这个场景下，算出现幻读了。



那么文章最后留个问题，你知道为什么上诉例子会出现幻读吗？欢迎留言讨论。



参考文章:

- MySQL 5.6 Reference Manual
- understanding InnoDB transaction isolation levels
- MySQL · 源码分析 · InnoDB Repeatable Read隔离级别之大不同
- 不懂数据库索引的底层原理？那是因为你心里没点b树
- Innodb中的事务隔离级别和锁的关系
- MySQL InnoDB中的行锁 Next-Key Lock消除幻读



*来源：cnblogs.com/CoderAyu/p/11525408.html*