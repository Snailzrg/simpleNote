# Decode函数
https://www.cnblogs.com/xunyi/p/8932794.html

Oracle中decode函数的使用
decode 的几种用法

1.使用decode判断字符串是否一样

DECODE(value,if 条件1，then 值1，if 条件2，then 值2，...，else 其他值)

Sql测试：

select aac001,decode(aac001,'0000000001','林海燕','0000000002','陈德财','others') as name from ac01 where rownum<=5;

输出结果：

 

使用decode判比较大小
Select decode(sign(var1-var2),1,var1,var2) from dual

Sign()函数根据某个值是0、正数、负数，分别返回0、1、-1；

Sql测试：

Select decode(sign(100-90),1,100,90) from dual

输出结果 ：100

100-90=10>0则sign()返回1，decode()函数取值var1=100

Select decode(sign(100-90),-1,100,90) from dual

输出结果：90

100-90=10>0则sign()返回1,decode()函数取值var2=100

 

使用decode函数分段
工资大于10000为高薪，工资介于5000到10000为中等，工资小于5000位低薪

 

 

Sql测试：

SELECT

ename,sal,

DECODE(SIGN(sal-10000),1,’高薪’,0,’高薪’,

-1,DECODE(SIGN(sal-5000),1’中等’,0,’中等’,

-1,’低薪’))) from ac01

 

输出结果:

李明 12000 高薪

张三 5000 中等

王五 3000 低薪