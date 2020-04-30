# MYSQL日常注意点 

 一些mysql操作会影响性能
 
 
 
# 常見問題
1 s使用group by 进行分组时，GROUP BY关键字只显示每个分组的一条记录。这说明，GROUP BY关键字单独使用时，只能查询出每个分组的一条记录，这样做的意义不大。因此，一般在使用集合函数时才使用GROUP BY关键字。 SELECT sex,COUNT(sex) FROM sys_user GROUP BY sex HAVING COUNT(sex)>=0;

2 在MySQL中，还可以按照多个字段进行分组。例如，employee表按照d_id字段和sex字段进行分组。分组过程中，先按照d_id字段进行分组，遇到d_id字段的值相等的情况时，再把d_id值相等的记录按照sex字段进行分组。

实例：将employee表按照d_id字段和sex字段进行分组。 SELECT语句的代码如下： SELECT * FROM employee GROUP BY d_id,sex;

3 GROUP BY关键字与WITH ROLLUP一起使用

使用WITH ROLLUP时，将会在所有记录的最后加上一条记录。这条记录是上面所有记录的总和。 实例：将employee表的sex字段进行分组查询。使用COUNT()函数计算每组的记录数，并且加上WITH ROLLUP。 SELECT语句的代码如下： SELECT sex,COUNT(sex) FROM employee GROUP BY sex WITH ROLLUP;

4 内连接可以没有连接条件: 没有on之后的内容,这个时候系统会保留所有结果(笛卡尔积) 内连接还可以使用where代替on关键字，但效率差很多。

 
 
# MYSQL的between的边界，范围

between 的范围是包含两边的边界值
eg： id between 3 and 7 等价与 id >=3 and id<=7

not between 的范围是不包含边界值
eg：id not between 3 and 7 等价与 id < 3 or id>7

SELECT * FROM `test` where id BETWEEN 3 and 7;
等价于 SELECT * FROM \`test\` where id>=3 and id<=7;

SELECT * FROM `test` where id NOT BETWEEN 3 and 7;
等价于 SELECT * FROM `test` where id<3 or id>7;
