# MySQL时间、字符串、时间戳互相转换

Mysql取系统函数：
- Select curtime();
- Select curdate():
- Select sysdate():
- select now();


```
1 时间转字符串
select date_format(now(), ‘%Y-%m-%d %H:%i:%s’); 
结果：2018-05-02 20:24:10
 
2 时间转时间戳
select unix_timestamp(now()); 
结果：1525263383
 
3 字符串转时间
select str_to_date(‘2018-05-02’, ‘%Y-%m-%d %H’); 
结果：2018-05-02 00:00:00

4 字符串转时间戳
select unix_timestamp(‘2018-05-02’); 
结果：1525263383

5 时间戳转时间
select from_unixtime(1525263383); 
结果：2018-05-02 20:16:23

6 时间戳转字符串
select from_unixtime(1525263383, ‘%Y-%m’); 
结果：2018-05
```

-------------------------------------------

 涉及日期比较

```
主要使用到DATE_SUB()函数
作用：从DATE或DATETIME值中减去时间值(或间隔)。 
语法：DATE_SUB(start_date, INTERVAL expr unit); 
参数详解： 
start_date是DATE或DATETIME的起始值。 
expr是一个字符串，用于确定从起始日期减去的间隔值（可以为负数）。 
unit是expr可解析的间隔单位，例如DAY，HOUR等

重点敲黑板，来看下例子

1、获取当前日期（yyyy-MM-dd）
select curdate();
select DATE_SUB(curdate(), interval 0 DAY) ;//当前日期减去0天，等效select curdate();

2、获取当前日期+时间（yyyy-MM-dd HH:mm:ss）
select now();
select DATE_SUB(now(), interval 0 DAY) ;//原理同上

3、获取明天日期
 select DATE_SUB(curdate(), interval -1 DAY) ;

4、获取昨天日期
 select DATE_SUB(curdate(), interval 1 DAY) ;

5、 前一个小时时间
 select DATE_SUB(now(), interval 1 hour);

6、 后一个小时时间
 select DATE_SUB(now(), interval -1 hour);

7、 前30分钟时间
select DATE_SUB(now(), interval 30 minute);

8、 后30分钟时间
select DATE_SUB(now(), interval -30 minute);

9、 获得前一年时间
select DATE_SUB(now(), interval 1 year);

10、 获得后一年时间
 select DATE_SUB(now(), interval -1 year);

如果要算月或年，将unit参数改成对应的值：day、month、year即可 
如果要统计前几天就将expr参数修改为相应的天数。 
具体使用，自行发挥。

另外有一个函数DATE_ADD()，语法与date_sub()相近，
不过date_add()是从起始日期加上的间隔值。 
eg：获得前一个小时时间 
select DATE_ADD(now(), interval -1 minute); //add 
等效于：select DATE_SUB(now(), interval 1 hour); //sub
```






