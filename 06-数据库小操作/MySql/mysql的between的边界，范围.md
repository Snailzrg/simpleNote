# mysql的between的边界，范围

between 的范围是包含两边的边界值
eg： id between 3 and 7 等价与 id >=3 and id<=7

not between 的范围是不包含边界值
eg：id not between 3 and 7 等价与 id < 3 or id>7

SELECT * FROM `test` where id BETWEEN 3 and 7;
等价于 SELECT * FROM \`test\` where id>=3 and id<=7;

SELECT * FROM `test` where id NOT BETWEEN 3 and 7;
等价于 SELECT * FROM `test` where id<3 or id>7;
