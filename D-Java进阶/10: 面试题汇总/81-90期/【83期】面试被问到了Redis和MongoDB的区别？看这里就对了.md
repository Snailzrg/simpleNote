## 【83期】面试被问到了Redis和MongoDB的区别？看这里就对了

劈天造陆 [Java面试题精选](javascript:void(0);) *5月8日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

项目中用的是MongoDB，但是为什么用其实当时选型的时候也没有太多考虑，只是认为数据量比较大，所以采用MongoDB。

**最近又想起为什么用MongoDB，就查阅一下，汇总汇总：**

之前也用过redis，当时是用来存储一些热数据，量也不大，但是操作很频繁。现在项目中用的是MongoDB，目前是百万级的数据，将来会有千万级、亿级。

就Redis和MongoDB来说，大家一般称之为Redis缓存、MongoDB数据库。这也是有道有理有根据的，Redis主要把数据存储在内存中，其“缓存”的性质远大于其“数据存储“的性质，其中数据的增删改查也只是像变量操作一样简单；

MongoDB却是一个“存储数据”的系统，增删改查可以添加很多条件，就像SQL数据库一样灵活，这一点在面试的时候很受用。

MongoDB语法与现有关系型数据库SQL语法比较

> https://www.cnblogs.com/java-spring/p/9488200.html

## Mongodb与Redis应用指标对比

MongoDB和Redis都是NoSQL，采用结构型数据存储。二者在使用场景中，存在一定的区别，这也主要由于二者在内存映射的处理过程，持久化的处理方法不同。MongoDB建议集群部署，更多的考虑到集群方案，Redis更偏重于进程顺序写入，虽然支持集群，也仅限于主-从模式。

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XDZw9HWiar2kjLKI2LUbWC74DwsceSbrBZgAE1c8ug1CIT8KvPFibDx9ibk2rg0UuAicTZ3FZLSghVpNA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



> 来源：cnblogs.com/java-spring/p/9488227.html