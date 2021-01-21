# SQL查询语句执行顺序详解

查询操作是关系数据库中使用最为频繁的操作，也是构成其他SQL语句（如DELETE、UPDATE）的基础。当要删除或更新某些记录时，首先要查询出这些记录，然后再对其进行相应的SQL操作。因此基于SELECT的查询操作就显得非常重要。对于查询处理，可将其分为**逻辑查询**处理及**物理查询**处理。**逻辑查询处理表示执行查询应该产生什么样的结果，而物理查询代表MySQL数据库是如何得到该结果的**。两种查询的方法可能完全不同，但是得到的结果必定是相同的

## 逻辑查询处理

SQL语言不同于其他编程语言（如C、C++、Java、Python），最明显的不同体现在处理代码的顺序上。在大多数编程语言中，代码按编码顺序被处理。但在SQL语言中，第一个被处理的子句总是FROM子句

```
(8)SELECT (9)DISTINCT <select_list>
(1)FROM <left_table>
(3)<join_type>JOIN <right_table>
(2)ON<join_condition>
(4)WHERE<where_condition>
(5)GROUP BY<group_by_list>
(6)WITH {CUBE|ROLLUP}
(7)HAVING<having_condition>
(10)ORDER BY<order_by_list>
(11)LIMIT<limit_number>

```

查询语句中的序号为该查询语句的处理顺序

可以看到一共有11个步骤，最先执行的是FROM操作，最后执行的是LIMIT操作。**每个操作都会产生一张虚拟表，该虚拟表作为一个处理的输入。这些虚拟表对用户是透明的，只有最后一步生成的虚拟表才会返回给用户**。如果没有在查询中指定某一子句，则将跳过相应的步骤

具体分析查询处理的各个阶段：

1. **FROM**：对FROM子句中的左表<left_table>和右表<right_table>执行笛卡儿积（Cartesianproduct），产生虚拟表VT1
2. **ON**：对虚拟表VT1应用ON筛选，只有那些符合<join_condition>的行才被插入虚拟表VT2中
3. **JOIN**：如果指定了OUTER JOIN（如LEFT OUTER JOIN、RIGHT OUTER JOIN），那么保留表中未匹配的行作为外部行添加到虚拟表VT2中，产生虚拟表VT3。如果FROM子句包含两个以上表，则对上一个连接生成的结果表VT3和下一个表重复执行步骤1）～步骤3），直到处理完所有的表为止
4. **WHERE**：对虚拟表VT3应用WHERE过滤条件，只有符合<where_condition>的记录才被插入虚拟表VT4中
5. **GROUP BY**：根据GROUP BY子句中的列，对VT4中的记录进行分组操作，产生VT5
6. **CUBE|ROLLUP**：对表VT5进行CUBE或ROLLUP操作，产生表VT6
7. **HAVING**：对虚拟表VT6应用HAVING过滤器，只有符合<having_condition>的记录才被插入虚拟表VT7中。
8. **SELECT**：第二次执行SELECT操作，选择指定的列，插入到虚拟表VT8中
9. **DISTINCT**：去除重复数据，产生虚拟表VT9
10. **ORDER BY**：将虚拟表VT9中的记录按照<order_by_list>进行排序操作，产生虚拟表VT10。11）11. **LIMIT**：取出指定行的记录，产生虚拟表VT11，并返回给查询用户

下面通过一个查询示例来详细描述逻辑处理的11个阶段。首先根据下面的代码，创建一个用户数据表customers和orders，并填充一定量的数据

```
create table customers
(
    customer_id VARCHAR(10),
    city VARCHAR(10) NOT NULL,
    PRIMARY KEY(customer_id)
)ENGINE=InnoDB;

INSERT INTO customers VALUES('163', 'HangZhou'),('9you','ShangHai'),('TX','HangZhou'),('baidu','HangZhou');

create table orders
(
    order_id INT AUTO_INCREMENT,
    customer_id VARCHAR(10),
    PRIMARY KEY(order_id)
)ENGINE=InnoDB;

INSERT INTO orders VALUES(1, '163'),(2, '163'),(3, '9you'),(4, '9you'),(5, '9you'),(6, 'TX'),(7, NULL);

```

customers表记录![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8984a379f75346e1928015f92f7ac9d6~tplv-k3u1fbpfcp-zoom-1.image)

orders表记录![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7f1951dc236494788160da6465292dd~tplv-k3u1fbpfcp-zoom-1.image)

【通过如下语句来查询来自杭州且订单数少于2的客户，并且查询出他们的订单数量，查询结果按订单数从小到大排序】

```
SELECT c.customer_id,count(o.order_id) AS total_orders 
FROM customers as c
LEFT JOIN orders as o
ON c.customer_id = o.customer_id
WHERE c.city = 'HangZhou'
GROUP BY c.customer_id
HAVING count(o.order_id) < 2
ORDER BY total_orders DESC;

```

来自杭州且订单数少于2的顾客![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/40286e0a3fe14186b8d19d2af52e2a99~tplv-k3u1fbpfcp-zoom-1.image)

下边分析该SQL的执行过程

(1)执行笛卡尔积 第一步需要做的是对FROM子句前后的两张表进行笛卡儿积操作，也称做交叉连接（CrossJoin），生成虚拟表VT1。如果FROM子句前的表中包含a行数据，FROM子句后的表中包含b行数据，那么虚拟表VT1中将包含a*b行数据。虚拟表VT1的列由源表定义。对于前面的SQL查询语句，会先执行表orders和customers的笛卡儿积操作

```
FROM customers as c ....... JOIN orders as o

```

笛卡儿积返回的虚拟表VT1![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6d8fea2b46ba47bfa0564eadab223787~tplv-k3u1fbpfcp-zoom-1.image)

(2)应用ON过滤器 SELECT查询一共有3个过滤过程，分别是ON、WHERE、HAVING。ON是最先执行的过滤过程。根据上一小节产生的虚拟表VT1，过滤条件为：

```
ON c.customer_id = o.customer_id

```

对于大多数的编程语言而言，逻辑表达式的值只有两种：TRUE和FALSE。但是在关系数据库中起逻辑表达式作用的并非只有两种，还有一种称为三值逻辑的表达式。这是因为在数据库中对NULL值的比较与大多数编程语言不同。在C语言中， NULL ==NULL的比较返回的是1，即相等，而在关系数据库中，NULL的比较则完全不是这么回事，例如:![4edeb16b61b318429ce2b545789de94b.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/576c28e0169e43e68e532fc3742c5b9f~tplv-k3u1fbpfcp-zoom-1.image)第一个NULL值的比较返回的是NULL而不是0，第二个NULL值的比较返回的仍然是NULL，而不是1。对于比较返回值为NULL的情况，用户应该将其视为UNKNOWN，即表示未知的。因为在某些情况下，NULL返回值可能代表1，即NULL等于NULL，而有时NULL返回值可能代表0。

对于在ON过滤条件下的NULL值比较，此时的比较结果为UNKNOWN，却被视为FALSE来进行处理，即两个NULL并不相同。但是在下面两种情况下认为两个NULL值的比较是相等的：

- GROUP BY子句把所有NULL值分到同一组
- ORDER BY子句中把所有NULL值排列在一起 (这个大家可以自行测试)

因此在产生虚拟表VT2时，会增加一个额外的列来表示ON过滤条件的返回值，返回值有TRUE、FALSE、UNKNOWN。取出比较值为TRUE的记录，产生虚拟表VT2 虚拟表VT2![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffd88bda5d8147749ebe88193a899a0d~tplv-k3u1fbpfcp-zoom-1.image)

(3)添加外部行

```
customers as c LEFT JOIN orders as o

```

这一步只有在连接类型为OUTER JOIN时才发生，如LEFT OUTER JOIN、RIGHT OUTERJOIN、FULL OUTER JOIN。虽然在大多数时候我们可以省略OUTER关键字，但OUTER代表的就是外部行。LEFT OUTER JOIN把左表记为保留表，RIGHT OUTER JOIN把右表记为保留表，FULL OUTER JOIN把左右表都记为保留表。添加外部行的工作就是在VT2表的基础上添加保留表中被过滤条件过滤掉的数据，非保留表中的数据被赋予NULL值，最后生成虚拟表VT3 虚拟表VT3![img](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2f366569b1b14984a7f23968e2d5952c~tplv-k3u1fbpfcp-zoom-1.image)在这个例子中，保留表是customers，顾客baidu在VT2表中由于没有订单而被过滤，因此baidu作为外部行被添加到虚拟表VT2中，将非保留表中的数据赋值为NULL。如果需要连接表的数量大于2，则对虚拟表VT3重做本节首的步骤（1）～步骤（3），最后产生的虚拟表作为下一个步骤的输出

(4)应用WHERE过滤器 对上一步骤产生的虚拟表VT3进行WHERE条件过滤，只有符合<where_condition>的记录才会输出到虚拟表VT4中

在当前应用WHERE过滤器时，有两种过滤是不被允许的：

- 由于数据还没有分组，因此现在还不能在WHERE过滤器中使用where_condition=MIN(col)这类对统计的过滤
- 由于没有进行列的选取操作，因此在SELECT中使用列的别名也是不被允许的，如SELECT city as c FROM t WHERE c='ShangHai'是不允许出现的

看一个在WHERE过滤条件中使用分组过滤查询导致出错的例子

```
SELECT customer_id,count(customer_id)
FROM orders
WHERE COUNT(customer_id)<2;

```

![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f8d7bc64bd748a0992ed739d1381a09~tplv-k3u1fbpfcp-zoom-1.image)可以看到MySQL数据库提示错误地使用了分组函数。接着来看一个列别名使用出错的例子:

```
SELECT order_id as o, customer_id as c
FROM orders
WHERE c='163';

```

![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/436b54c25c054cb89ae488dac80c1d44~tplv-k3u1fbpfcp-zoom-1.image)因为在当前的步骤中还未进行SELECT选取列名的操作，所以此时的列别名是不被支持的，MySQL数据库抛出了错误，提示未知的列c

应用WHERE过滤器：WHERE c.city='HangZhou'，最后得到的虚拟表VT4 虚拟表VT4![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bcb24aed3a0c4a16ad1026f1b218e203~tplv-k3u1fbpfcp-zoom-1.image)此外，在WHERE过滤器中进行的过滤和在ON过滤器中进行的过滤是有所不同的。对于OUTERJOIN中的过滤，在ON过滤器过滤完之后还会添加保留表中被ON条件过滤掉的记录，而WHERE条件中被过滤掉的记录则是永久的过滤

(5)分组 在本步骤中根据指定的列对上个步骤中产生的虚拟表进行分组，最后得到虚拟表VT5

```
GROUP BY c.customer_id

SELECT * FROM customers as c LEFT JOIN orders as o ON c.customer_id = o.customer_id WHERE c.city='HangZhou' GROUP BY c.customer_id

```

虚拟表VT5![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cd67bec9c8346eb8dd7160efecb9563~tplv-k3u1fbpfcp-zoom-1.image)

(6)应用ROLLUP或CUBE 如果指定了ROLLUP选项，那么将创建一个额外的记录添加到虚拟表VT5的最后，并生成虚拟表VT6。因为我们的查询并未用到ROLLUP，所以将跳过本步骤

(7)应用HAVING过滤器 这是最后一个条件过滤器了，之前已经分别应用了ON和WHERE过滤器。在该步骤中对于上一步产生的虚拟表应用HAVING过滤器，HAVING是对分组条件进行过滤的筛选器。对于示例的查询语句，其分组条件为

```
HAVING count(o.order_id < 2)

SELECT c.customer_id,c.city,o.order_id,o.customer_id FROM customers as c LEFT JOIN orders as o ON c.customer_id = o.customer_id WHERE c.city = 'HangZhou' GROUP BY c.customer_id HAVING count(o.order_id)<2;

```

因此将customer_id为163的订单从虚拟表中删除，生成的虚拟表VT6 虚拟表VT6![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f76b8e156f064d0f930f69dd66c4fbd0~tplv-k3u1fbpfcp-zoom-1.image)需要特别注意的是，在这个分组中不能使用COUNT（1）或COUNT（*），因为这会把通过OUTER JOIN添加的行统计入内而导致最终查询结果与预期结果不同。在这个例子中只能使用COUNT o.order_id才能得到预期的结果

注意：子查询不能用做分组的聚合函数，如HAVING COUNT(SELECT ...)<2是不合法的

(8)处理SELECT列表 虽然SELECT是查询中最先被指定的部分，但是直到步骤8）时才真正进行处理。在这一步中，将SELECT中指定的列从上一步产生的虚拟表中选出 SELECT部分为：

```
SELECT c.customer_id,count(o.customer_id) AS total_orders

SELECT c.customer_id,count(o.customer_id) AS total_orders FROM customers as c LEFT JOIN orders as o ON c.customer_id = o.customer_id WHERE c.city = 'HangZhou' GROUP BY c.customer_id HAVING count(o.order_id)<2;

```

虚拟表VT7![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ad21f6727c24f4894297958b3561b83~tplv-k3u1fbpfcp-zoom-1.image)

(9)应用DISTINCT子句 如果在查询中指定了DISTINCT子句，则会创建一张内存临时表（如果内存中存放不下就放到磁盘上）。这张内存临时表的表结构和上一步产生的虚拟表一样，不同的是对进行DISTINCT操作的列增加了一个唯一索引，以此来去除重复数据。

由于在这个SQL查询中未指定DISTINCT，因此跳过本步骤。另外，对于使用了GROUP BY的查询，再使用DISTINCT是多余的，因为已经进行分组，不会移除任何行

(10)应用ORDER BY子句 根据ORDER BY子句中指定的列对上一步输出的虚拟表进行排列，返回新的虚拟表。还可以在ORDER BY子句中指定SELECT列表中列的序列号，如下面的语句:

```
SELECT order_id,customer_id 
FROM orders
ORDER BY 2,1;

等同于

SELECT order_id,customer_id 
FROM orders
ORDER BY customer_id,order_id;

```

通常情况下，并不建议采用这种方式来进行排序，因为程序员可能修改了SELECT列表中的列，而忘记修改ORDER BY中的列表。但是，如果用户对网络传输要求很高，这也不失为一种节省网络传输字节的方法

对于示例中，ORDER BY子句为：

```
ORDER BY total_orders DESC

SELECT c.customer_id,count(o.customer_id) AS total_orders FROM customers as c LEFT JOIN orders as o ON c.customer_id = o.customer_id WHERE c.city = 'HangZhou' GROUP BY c.customer_id HAVING count(o.order_id)<2 ORDER BY total_orders DESC;

```

最后得到虚拟表![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9da5010c210b423685888479e7dc7cbd~tplv-k3u1fbpfcp-zoom-1.image)相信很多DBA和开发人员都错误地认为在选取表中的数据时，记录会按照表中主键的大小顺序地取出，即结果像进行了ORDER BY一样。导致这个经典错误的原因主要是没有理解什么才是真正的关系数据库

关系数据库是在数学的基础上发展起来的，关系对应于数学中集合的概念。数据库中常见的查询操作其实对应的是集合的某些运算：选择、投影、连接、并、交、差、除。最终的结果虽然是以一张二维表的方式呈现在用户面前，但是从数据库内部来看是一系列的集合操作。因此，对于表中的记录，用户需要以集合的思想来理解

因为表中的数据是集合中的元素，而集合是无序的。因此对于没有ORDER BY子句的SQL语句，其解析结果应为：从集合中选择期望的子集合。这表明结果并不一定要有序

注意：在MySQL数据库中，NULL值在升序过程中总是首先被选出，即NULL值在ORDER BY子句中被视为最小值

(11)LIMIT子句 在该步骤中应用LIMIT子句，从上一步骤的虚拟表中选出从指定位置开始的指定行数据。对于没有应用ORDER BY的LIMIT子句，结果同样可能是无序的，因此LIMIT子句通常和ORDER BY子句一起使用

由于示例中SQL语句没有LIMIT子句，因此最后得到的结果应如下：![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7b25089d25e549ff877e34a01fc06507~tplv-k3u1fbpfcp-zoom-1.image)

## 物理查询处理

上边介绍了逻辑查询处理，并且描述了执行查询应该得到什么样的结果。但是数据库也许并不会完全按照逻辑查询处理的方式来进行查询。我们知道在MySQL数据库层有Parser和Optimizer两个组件。Parser的工作就是分析SQL语句，而Optimizer的工作就是对这个SQL语句进行优化，选择一条最优的路径来选取数据，但是必须保证物理查询处理的最终结果和逻辑查询处理是相等的

如果表上建有索引，那么优化器就会判断SQL语句是否可以利用该索引来进行优化。如果没有可以利用的索引，可能整个SQL语句的执行代价非常大。可以举个例子：

```
CREATE TABLE x(
    a int
)ENGINE=InnoDB;

CREATE TABLE y(
    a int
)ENGINE=InnoDB;

```

假设分别向x、y表中分别插入10w和18w条数据，两张表中均没有创建索引，因此最终SQL解析器解析的执行结果为逻辑处理的步骤，也就是按照上边中分析的，总共经过11个步骤来进行数据的查询。最先根据笛卡儿积生成一张虚拟表VT1，表x有10万行数据，表y有18万行数据，这意味着进行笛卡儿积后产生的虚拟表VT1总共有180亿行的数据！因此运行这个SQL语句，在一个双核笔记本上，InnoDB缓冲池配置为128M，总共需要执行50多分钟。

可能有人会认为，128MB的InnoDB缓冲池太小，从而导致内存中无法存放这么多数据而使执行需要花费这么长的时间。其实不然，表x和表y的大小都没有超过20MB，足够存放在128MB的内存缓冲池中，语句执行速度慢的主要原因是需要产生180亿次的数据。即便是在内存中产生这么多次的数据，也需要花费很长的时间。然而，如果这时对表y添加一个主键值，再执行这条SQL语句，你会惊讶地发现只需要不到1秒的时间

性能提高了3000多倍！促使这个查询时间大幅减少的原因很简单，就是在添加索引后避免了笛卡儿表的产生，因此大幅缩短了语句运行的时间。我们可以通过EXPLAIN命令来查看经SQL优化器优化后MySQL数据库实际选择的执行方式。关于MySQL中的索引，以及EXPLAIN执行计划中每一列的含义，我之前也整理过一篇文章《一篇文章带你熟悉myql索引》

```
{
    "code": 1,
    "result": false,
    "message": "请先登录",
    "meta": {
        "request_time": 0.093,
        "timestamp": 1594522447
    }
}
```

