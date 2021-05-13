# mysql复制表数据和结构

一、LIKE方法
like方法复制生成一个新表，包括其备注、索引、主键外键、存储引擎等

CREATE TABLE IF NOT EXISTS like_table2 (LIKE table2); 

二、SELECT方法
select方法只复制字段属性，原表的主键、索引、表备注、存储引擎都没有复制

CREATE TABLE IF NOT EXISTS like_table2 SELECT * FROM table2; //复制数据
CREATE TABLE IF NOT EXISTS like_table2 SELECT * FROM table2 where 1=0; //不复制数据

三、两种方法的区别
like方法是专门复制表结构的方法，它复制表的结构和相关属性，并不复制数据。 
select方法可复制表的结构但不复制相关属性，是否要复制数据可在select语句中添加“1=0”条件进行控制。
