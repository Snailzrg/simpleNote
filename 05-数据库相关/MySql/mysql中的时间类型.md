# mysql中的时间类型
Mysql中的date与datetime，以及如何向Mysql中插入“日期+时间”数据

2016年02月26日 13:56:10 我是干勾鱼 阅读数：24124更多
所属专栏： MYSQL常见问题解析
版权声明：本文为博主原创文章，未经博主允许不得转载。	 https://blog.csdn.net/dongdong9223/article/details/50748073
转载请注明出处：http://blog.csdn.net/dongdong9223/article/details/50748073 
本文出自【我是干勾鱼的博客】
我们知道，java中有date和datetime，mysql中也有date和datetime，这里我们来说说mysql中的date和datetime。

1 mysql中的date和datetime

1.1 DATETIME

类型可用于需要同时包含日期和时间信息的值。MySQL 以：

‘YYYY-MM-DD HH:MM:SS’

格式检索与显示 DATETIME 类型。支持的范围是：

‘1000-01-01 00:00:00’ 
到 
‘9999-12-31 23:59:59’。

(“支持”的含义是，尽管更早的值可能工作，但不能保证他们均可以。)

1.2 DATE

类型可用于需要一个日期值而不需要时间部分时。MySQL 以

‘YYYY-MM-DD’

格式检索与显示DATE值。支持的范围则是

‘1000-01-01’ 
到 
‘9999-12-31’。

2 与java数据的交互

能看出来mysql中的date和datetime区别还是挺大的，date没有保存时间。但是java中的date（java.util.Date）记录的还是挺细的，日期和时间都可以记下来，那么现在问题来了，如果想在mysql中存储日期和时间，也就是用datetime，而在数据中应该如何对应呢？

我使用hibernate测了一下，发现当把mysql数据库中设置了datetime，反向工程生成的hbm.xml文件中，使用的是timestamp，如下：

<property name="Publishdate" column="publishdate" type="timestamp" not-null="false" length="10" />
1
反向生成java的pojo时，生成的还是Date。

由此可见对于mysql中datetime，与java中的date，如果要使二者正确交互，中间要使用timestamp。

如果要在JAVA中直接插入MySql的datetime类型，则可以使用：

Date date = new Date();
Timestamp timeStamp = new Timestamp(date.getTime());
1
2
再用setTimestamp()设置数据库中的“日期+时间”。

这样放入数据库的就是“yyyy-mm-dd hh:mm:ss”格式的数据。

注意，mysql中如果使用date而不是datetime是保存不下“日期+时间”的，只能保存“时间”。