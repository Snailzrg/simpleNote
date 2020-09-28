## 【170期】面试官：你能分别谈谈innodb下的记录锁，间隙锁，next-key锁吗？

xdd_mdd [Java面试题精选](javascript:void(0);) *1周前*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**



\>>号外：往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅

阶段汇总集合：[001期~150期汇总，方便阅读，不断更新中.....](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247485351&idx=2&sn=214225ab4345f4d9c562900cb42a52ba&chksm=e80db1d1df7a38c741137246bf020a5f8970f74cd03530ccc4cb2258c1ced68e66e600e9e059&scene=21#wechat_redirect)

**你需要知道的**

之前我们介绍了排他锁，其实innodb下的记录锁（也叫行锁），间隙锁，next-key锁统统属于排他锁。

**行锁**

记录锁其实很好理解，对表中的记录加锁，叫做记录锁，简称行锁。

**生活中的间隙锁**

编程的思想源于生活，生活中的例子能帮助我们更好的理解一些编程中的思想。

生活中排队的场景，小明，小红，小花三个人依次站成一排，此时，如何让新来的小刚不能站在小红旁边，这时候只要将小红和她前面的小明之间的空隙封锁，将小红和她后面的小花之间的空隙封锁，那么小刚就不能站到小红的旁边。

这里的小红，小明，小花，小刚就是数据库的一条条记录。

他们之间的空隙也就是间隙，而封锁他们之间距离的锁，叫做间隙锁。

**Mysql中的间隙锁**

下表中（见图一），id为主键，number字段上有非唯一索引的二级索引，有什么方式可以让该表不能再插入number=5的记录？

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqLNbXXpPdWfZnvoeicicicg2zGwcibpnj6uau0uLDopKk4G4ls2s9SIIqkg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)图一

根据上面生活中的例子，我们自然而然可以想到，只要控制几个点，number=5**之前**不能插入记录，number=5现有的记录**之间**不能再插入新的记录，number=5**之后**不能插入新的记录，那么新的number=5的记录将不能被插入进来。

那么，mysql是如何控制number=5之前，之中，之后不能有新的记录插入呢（防止幻读）？
答案是用间隙锁，在RR级别下，mysql通过间隙锁可以实现锁定number=5之前的间隙，number=5记录之间的间隙，number=5之后的间隙，从而使的新的记录无法被插入进来。

**间隙是怎么划分的？**

***注\***：为了方面理解，我们规定（id=A,number=B）代表一条字段id=A,字段number=B的记录，（C，D）代表一个区间，代表C-D这个区间范围。

图一中，根据number列，我们可以分为几个区间：（无穷小，2），（2，4），（4，5），（5，5），（5,11），（11，无穷大）。

只要这些区间对应的两个临界记录中间可以插入记录，就认为区间对应的记录之间有间隙。

例如：区间（2，4）分别对应的临界记录是（id=1,number=2），（id=3，number=4），这两条记录中间可以插入（id=2,number=3）等记录，那么就认为（id=1,number=2）与（id=3，number=4）之间存在间隙。

很多人会问，那记录（id=6，number=5）与（id=8，number=5）之间有间隙吗？
答案是有的，（id=6，number=5）与（id=8，number=5）之间可以插入记录（id=7，number=5），因此（id=6,number=5）与（id=8,number=5）之间有间隙的，

**间隙锁锁定的区域**

根据检索条件向左寻找最靠近检索条件的记录值A，作为左区间，向右寻找最靠近检索条件的记录值B作为右区间，即锁定的间隙为（A，B）。

图一中，where number=5的话，那么间隙锁的区间范围为（4,11）；

**间隙锁的目的是为了防止幻读，其主要通过两个方面实现这个目的：**

- 防止间隙内有新数据被插入
- 防止已存在的数据，更新成间隙内的数据（例如防止numer=3的记录通过update变成number=5）

**innodb自动使用间隙锁的条件：**

- 必须在RR级别下
- 检索条件必须有索引（没有索引的话，mysql会全表扫描，那样会锁定整张表所有的记录，包括不存在的记录，此时其他事务不能修改不能删除不能添加）

**接下来，通过实际操作观察下间隙锁的作用范围**

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqLNbXXpPdWfZnvoeicicicg2zGwcibpnj6uau0uLDopKk4G4ls2s9SIIqkg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)图三 表结构

**案例一：**

```
session 1:
start  transaction ;
select  * from news where number=4 for update ;

session 2:
start  transaction ;
insert into news value(2,4);#（阻塞）
insert into news value(2,2);#（阻塞）
insert into news value(4,4);#（阻塞）
insert into news value(4,5);#（阻塞）
insert into news value(7,5);#（执行成功）
insert into news value(9,5);#（执行成功）
insert into news value(11,5);#（执行成功）
```

检索条件number=4,向左取得最靠近的值2作为左区间，向右取得最靠近的5作为右区间，因此，session 1的间隙锁的范围（2，4），（4，5），如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqeyTLGkdLuibtmFycz9DGKFPjpSbK4PIU07Iy8H5YgHH8hanoyMMhg1w/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

间隙锁锁定的区间为（2，4），（4，5），即记录（id=1,number=2）和记录（id=3,number=4）之间间隙会被锁定，记录（id=3,number=4）和记录（id=6,number=5）之间间隙被锁定。

因此记录（id=2,number=4），（id=2,number=2），（id=4,number=4），（id=4,number=5）正好处在（id=3,number=4）和（id=6,number=5）之间，所以插入不了，需要等待锁的释放，而记录(id=7,number=5)，（id=9,number=5），（id=11,number=5）不在上述锁定的范围内，因此都会插入成功。

[往期：001期~150期汇总，方便阅读，不断更新中.....](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247485351&idx=2&sn=214225ab4345f4d9c562900cb42a52ba&chksm=e80db1d1df7a38c741137246bf020a5f8970f74cd03530ccc4cb2258c1ced68e66e600e9e059&scene=21#wechat_redirect)

------

**案例二：**

```
session 1:
start  transaction ;
select  * from news where number=13 for update ;

session 2:
start  transaction ;
insert into news value(11,5);#(执行成功)
insert into news value(12,11);#(执行成功)
insert into news value(14,11);#(阻塞)
insert into news value(15,12);#(阻塞)
update news set id=14 where number=11;#(阻塞)
update news set id=11 where number=11;#(执行成功)
```

检索条件number=13,向左取得最靠近的值11作为左区间，向右由于没有记录因此取得无穷大作为右区间，因此，session 1的间隙锁的范围（11，无穷大），如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqqJKVhnbBXic1XXrzczibcgZuNjvObzapqLzmsKPcZ8Hpz8MUPNRIJNbA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

此表中没有number=13的记录的，innodb依然会为该记录左右两侧加间隙锁，间隙锁的范围（11，无穷大）。

有人会问，为啥update news set id=14 where number=11会阻塞，但是update news set id=11 where number=11却执行成功呢？

间隙锁采用在指定记录的前面和后面以及中间的间隙上加间隙锁的方式避免数据被插入，此图间隙锁锁定的区域是（11，无穷大），也就是记录（id=13,number=11）之后不能再插入记录，update news set id=14 where number=11这条语句如果执行的话，将会被插入到（id=13,number=11）的后面，也就是在区间（11，无穷大）之间，由于该区间被间隙锁锁定，所以只能阻塞等待，而update news set id=11 where number=11执行后是会被插入到（id=13,number=11）的记录前面，也就不在（11，无穷大）的范围内，所以无需等待，执行成功。

------

**案例三：**

```
session 1:
start  transaction ;
select  * from news where number=5 for update;

session 2:
start  transaction ;
insert into news value(4,4);#(阻塞)
insert into news value(4,5);#(阻塞)
insert into news value(5,5);#(阻塞)
insert into news value(7,11);#(阻塞)
insert into news value(9,12);#(执行成功)
insert into news value(12,11);#(阻塞)
update news set number=5 where id=1;#(阻塞)
update news set id=11 where number=11;#(阻塞)
update news set id=2 where number=4 ;#（执行成功）
update news set id=4 where number=4 ;#（阻塞）
```

检索条件number=5,向左取得最靠近的值4作为左区间，向右取得11为右区间，因此，session 1的间隙锁的范围（4，5），（5，11），如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqPLkagqYGc2L2psyAOykZOtNQaXicMKjzibaR6qELgV4Tw51PZIu9XtuA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

有人会问，为啥insert into news value(9,12)会执行成功？间隙锁采用在指定记录的前面和后面以及中间的间隙上加间隙锁的方式避免数据被插入，（id=9,number=12）很明显在记录（13,11）的后面，因此不再锁定的间隙范围内。

为啥update news set number=5 where id=1会阻塞？

number=5的记录的前面，后面包括中间都被封锁了，你这个update news set number=5 where id=1根本没法执行，因为innodb已经把你可以存放的位置都锁定了，因为只能等待。

同理，update news set id=11 where number=11由于记录（id=10,number=5）与记录（id=13,number=11）中间的间隙被封锁了，你这句sql也没法执行，必须等待，因为存放的位置被封锁了。

------

**案例四：**

```
session 1:
start  transaction;
select * from news where number>4 for update;

session 2:
start  transaction;
update news set id=2 where number=4 ;#(执行成功)
update news set id=4 where number=4 ;#(阻塞)
update news set id=5 where number=5 ;#(阻塞)
insert into news value(2,3);#(执行成功)
insert into news value(null,13);#(阻塞)
```

检索条件number>4,向左取得最靠近的值4作为左区间，向右取无穷大，因此，session 1的间隙锁的范围（4，无穷大），如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XCIKtWXf8ellmnicEdJJdWBqicnBlIJzJlUuMKTWxV9ibGibZcCAAqOMnV6FHTIVLaeEZgVxbic6iaWQg9A/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

session2中之所以有些阻塞，有些执行成功，其实就是因为插入的区域被锁定，从而阻塞。

------

**next-key锁**

next-key锁其实包含了记录锁和间隙锁，即锁定一个范围，并且锁定记录本身，InnoDB默认加锁方式是next-key 锁。

上面的案例一session 1中的sql是：select * from news where number=4 for update ;

next-key锁锁定的范围为间隙锁+记录锁，即区间（2，4），（4，5）加间隙锁，同时number=4的记录加记录锁。