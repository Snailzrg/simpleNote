# base
-w3c-
https://www.w3cschool.cn/oraclejc/oraclejc-xzfk2qv3.html



note：
    1: DISTINCT不是SQL标准的UNIQUE的同义词。总是使用DISTINCT而不使用UNIQUE是一个好的习惯。
    2: DISTINCT将NULL值视为重复值。如果使用SELECT DISTINCT语句从具有多个NULL值的列中查询数据，则结果集只包含一个NULL值。
    3: WHERE子句出现在FROM子句之后但在ORDER BY子句之前。在WHERE关键字之后是search_condition - 它定义了返回行记录必须满足的条件。除了SELECT语句之外，还可以使用DELETE或UPDATE语句中的WHERE子句来指定要更新或删除的行记录。
    4:要查找具有两个值之间的值的行，请在WHERE子句中使用BETWEEN运算符。例如，要获取标价在650到680之间(650 <= list_price <= 680)的产品，请使用以下语句： ```  eg: order_date BETWEEN DATE '2016-12-01' AND DATE '2016-12-31' ``` 
    5: 可以使用其内置函數 TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date  ;  UPPER( first_name ) LIKE 'CH%'
    6：FETCH子句在Oracle中可以用来限制查询返回的行数，本教程将教大家如何使用FETCH子句。 
```
                                 -- 以下查询语句仅能在Oracle 12c以上版本执行
                                        SELECT
                                            product_name,
                                            quantity
                                        FROM
                                            inventories
                                        INNER JOIN products
                                                USING(product_id)
                                        ORDER BY
                                            quantity DESC 
                                        FETCH NEXT 5 ROWS ONLY;
```
    7

