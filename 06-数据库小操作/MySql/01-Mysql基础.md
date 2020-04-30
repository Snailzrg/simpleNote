# 1. MySQL 数据类型

MySQL中定义数据字段的类型对你数据库的优化是非常重要的。

MySQL支持多种类型，大致可以分为三类：数值、日期/时间和字符串(字符)类型。

***

## 1.1. 数值类型

MySQL支持所有标准SQL数值数据类型。

这些类型包括严格数值数据类型(INTEGER、SMALLINT、DECIMAL和NUMERIC)，以及近似数值数据类型(FLOAT、REAL和DOUBLE PRECISION)。

关键字INT是INTEGER的同义词，关键字DEC是DECIMAL的同义词。

BIT数据类型保存位字段值，并且支持MyISAM、MEMORY、InnoDB和BDB表。

作为SQL标准的扩展，MySQL也支持整数类型TINYINT、MEDIUMINT和BIGINT。下面的表显示了需要的每个整数类型的存储和范围。


| 类型 | 大小 | 范围（有符号） | 范围（无符号） | 用途 |
| --- | --| --- | --- | --- |
| TINYINT | 1 字节 | (-128，127) | (0，255) | 小整数值 |
| SMALLINT | 2 字节 | (-32 768，32 767) | (0，65 535) | 大整数值 |
| MEDIUMINT | 3 字节 | (-8 388 608，8 388 607) | (0，16 777 215) | 大整数值 |
| INT或INTEGER | 4 字节 | (-2 147 483 648，2 147 483 647) | (0，4 294 967 295) | 大整数值 |
| BIGINT| 8 字节 | (-9 233 372 036 854 775 808，9 223 372 036 854 775 807) | (0，18 446 744 073 709 551 615) | 极大整数值 |
| FLOAT | 4 字节 | (-3.402 823 466 E+38，-1.175 494 351 E-38)，0，(1.175 494 351 E-38，3.402 823 466 351 E+38) | 0，(1.175 494 351 E-38，3.402 823 466 E+38) | 单精度  
| DOUBLE| 8 字节 | (-1.797 693 134 862 315 7 E+308，-2.225 073 858 507 201 4 E-308)，0，(2.225 073 858 507 201 4 E-308，1.797 693 134 862 315 7 E+308) | 0，(2.225 073 858 507 201 4 E-308，1.797 693 134 862 315 7 E+308) | 双精度  
| DECIMAL | 对DECIMAL(M,D) ，如果M>D，为M+2否则为D+2 | 依赖于M和D的值 | 依赖于M和D的值 | 小数值 |
浮点数值 |

***

## 1.2. 日期和时间类型

表示时间值的日期和时间类型为DATETIME、DATE、TIMESTAMP、TIME和YEAR。

每个时间类型有一个有效值范围和一个"零"值，当指定不合法的MySQL不能表示的值时使用"零"值。

TIMESTAMP类型有专有的自动更新特性，将在后面描述。

| 类型 | 大小  (字节) | 范围 | 格式 | 用途 |
| --- | --- | --- | --- | --- |
| DATE | 3 | 1000-01-01/9999-12-31 | YYYY-MM-DD | 日期值 |
| TIME | 3 | '-838:59:59'/'838:59:59' | HH:MM:SS | 时间值或持续时间 |
| YEAR | 1 | 1901/2155 | YYYY | 年份值 |
| DATETIME | 8 | 1000-01-01 00:00:00/9999-12-31 23:59:59 | YYYY-MM-DD HH:MM:SS | 混合日期和时间值 |
| TIMESTAMP | 4 | 1970-01-01 00:00:00/2038 | YYYYMMDD HHMMSS | 混合日期和时间值，时间戳 |

结束时间是第 **2147483647** 秒，北京时间 **2038-1-19 11:14:07**，格林尼治时间 2038年1月19日 凌晨 03:14:07


***

## 1.3. 字符串类型

字符串类型指CHAR、VARCHAR、BINARY、VARBINARY、BLOB、TEXT、ENUM和SET。该节描述了这些类型如何工作以及如何在查询中使用这些类型。

| 类型 | 大小 | 用途 |
| --- | --- | --- |
| CHAR | 0-255字节 | 定长字符串 |
| VARCHAR | 0-65535 字节 | 变长字符串 |
| TINYBLOB | 0-255字节 | 不超过 255 个字符的二进制字符串 |
| TINYTEXT | 0-255字节 | 短文本字符串 |
| BLOB | 0-65 535字节 | 二进制形式的长文本数据 |
| TEXT | 0-65 535字节 | 长文本数据 |
| MEDIUMBLOB | 0-16 777 215字节 | 二进制形式的中等长度文本数据 |
| MEDIUMTEXT | 0-16 777 215字节 | 中等长度文本数据 |
| LONGBLOB | 0-4 294 967 295字节 | 二进制形式的极大文本数据 |
| LONGTEXT | 0-4 294 967 295字节 | 极大文本数据 |

CHAR 和 VARCHAR 类型类似，但它们保存和检索的方式不同。它们的最大长度和是否尾部空格被保留等方面也不同。在存储或检索过程中不进行大小写转换。

BINARY 和 VARBINARY 类似于 CHAR 和 VARCHAR，不同的是它们包含二进制字符串而不要非二进制字符串。也就是说，它们包含字节字符串而不是字符字符串。这说明它们没有字符集，并且排序和比较基于列值字节的数值值。

BLOB 是一个二进制大对象，可以容纳可变数量的数据。有 4 种 BLOB 类型：TINYBLOB、BLOB、MEDIUMBLOB 和 LONGBLOB。它们区别在于可容纳存储范围不同。

有 4 种 TEXT 类型：TINYTEXT、TEXT、MEDIUMTEXT 和 LONGTEXT。对应的这 4 种 BLOB 类型，可存储的最大长度不同，可根据实际情况选择。



# Mysql函数
对于针对字符串位置的操作，第一个位置被标记为1。 
ASCII(str) 
返回字符串str的最左面字符的ASCII代码值。如果str是空字符串，返回0。如果str是NULL，返回NULL。 
mysql> select ASCII('2');
    -> 50
mysql> select ASCII(2);
    -> 50
mysql> select ASCII('dx');
    -> 100
也可参见ORD()函数。 
ORD(str) 
如果字符串str最左面字符是一个多字节字符，通过以格式((first byte ASCII code)*256+(second byte ASCII code))[*256+third byte ASCII code...]返回字符的ASCII代码值来返回多字节字符代码。如果最左面的字符不是一个多字节字符。返回与ASCII()函数返回的相同值。
mysql> select ORD('2');
    -> 50
CONV(N,from_base,to_base) 
在不同的数字基之间变换数字。返回数字N的字符串数字，从from_base基变换为to_base基，如果任何参数是NULL，返回NULL。参数N解释为一个整数，但是可以指定为一个整数或一个字符串。最小基是2且最大的基是36。如果to_base是一个负数，N被认为是一个有符号数，否则，N被当作无符号数。 CONV以64位点精度工作。 
mysql> select CONV("a",16,2);
    -> '1010'
mysql> select CONV("6E",18,8);
    -> '172'
mysql> select CONV(-17,10,-18);
    -> '-H'
mysql> select CONV(10+"10"+'10'+0xa,10,10);
    -> '40'
BIN(N) 
返回二进制值N的一个字符串表示，在此N是一个长整数(BIGINT)数字，这等价于CONV(N,10,2)。如果N是NULL，返回NULL。 
mysql> select BIN(12);
    -> '1100'
OCT(N) 
返回八进制值N的一个字符串的表示，在此N是一个长整型数字，这等价于CONV(N,10,8)。如果N是NULL，返回NULL。 
mysql> select OCT(12);
    -> '14'
HEX(N) 
返回十六进制值N一个字符串的表示，在此N是一个长整型(BIGINT)数字，这等价于CONV(N,10,16)。如果N是NULL，返回NULL。 
mysql> select HEX(255);
    -> 'FF'
CHAR(N,...) 
CHAR()将参数解释为整数并且返回由这些整数的ASCII代码字符组成的一个字符串。NULL值被跳过。 
mysql> select CHAR(77,121,83,81,'76');
    -> 'MySQL'
mysql> select CHAR(77,77.3,'77.3');
    -> 'MMM'
CONCAT(str1,str2,...) 
返回来自于参数连结的字符串。如果任何参数是NULL，返回NULL。可以有超过2个的参数。一个数字参数被变换为等价的字符串形式。 
mysql> select CONCAT('My', 'S', 'QL');
    -> 'MySQL'
mysql> select CONCAT('My', NULL, 'QL');
    -> NULL
mysql> select CONCAT(14.3);
    -> '14.3'
LENGTH(str) 
　 
OCTET_LENGTH(str) 
　 
CHAR_LENGTH(str) 
　 
CHARACTER_LENGTH(str) 
返回字符串str的长度。 
mysql> select LENGTH('text');
    -> 4
mysql> select OCTET_LENGTH('text');
    -> 4
注意，对于多字节字符，其CHAR_LENGTH()仅计算一次。 
LOCATE(substr,str) 
　 
POSITION(substr IN str) 
返回子串substr在字符串str第一个出现的位置，如果substr不是在str里面，返回0. 
mysql> select LOCATE('bar', 'foobarbar');
    -> 4
mysql> select LOCATE('xbar', 'foobar');
    -> 0
该函数是多字节可靠的。 
LOCATE(substr,str,pos) 
返回子串substr在字符串str第一个出现的位置，从位置pos开始。如果substr不是在str里面，返回0。
mysql> select LOCATE('bar', 'foobarbar',5);
    -> 7
这函数是多字节可靠的。 
INSTR(str,substr) 
返回子串substr在字符串str中的第一个出现的位置。这与有2个参数形式的LOCATE()相同，除了参数被颠倒。 
mysql> select INSTR('foobarbar', 'bar');
    -> 4
mysql> select INSTR('xbar', 'foobar');
    -> 0
这函数是多字节可靠的。 
LPAD(str,len,padstr) 
返回字符串str，左面用字符串padstr填补直到str是len个字符长。 
mysql> select LPAD('hi',4,'??');
    -> '??hi'
RPAD(str,len,padstr) 
返回字符串str，右面用字符串padstr填补直到str是len个字符长。 
mysql> select RPAD('hi',5,'?');
    -> 'hi???'
LEFT(str,len) 
返回字符串str的最左面len个字符。
mysql> select LEFT('foobarbar', 5);
    -> 'fooba'
该函数是多字节可靠的。 
RIGHT(str,len) 
返回字符串str的最右面len个字符。 
mysql> select RIGHT('foobarbar', 4);
    -> 'rbar'
该函数是多字节可靠的。 
SUBSTRING(str,pos,len) 
　 
SUBSTRING(str FROM pos FOR len) 
　 
MID(str,pos,len) 
从字符串str返回一个len个字符的子串，从位置pos开始。使用FROM的变种形式是ANSI SQL92语法。 
mysql> select SUBSTRING('Quadratically',5,6);
    -> 'ratica'
该函数是多字节可靠的。 
SUBSTRING(str,pos) 
　 
SUBSTRING(str FROM pos) 
从字符串str的起始位置pos返回一个子串。 
mysql> select SUBSTRING('Quadratically',5);
    -> 'ratically'
mysql> select SUBSTRING('foobarbar' FROM 4);
    -> 'barbar'
该函数是多字节可靠的。 
SUBSTRING_INDEX(str,delim,count) 
返回从字符串str的第count个出现的分隔符delim之后的子串。如果count是正数，返回最后的分隔符到左边(从左边数) 的所有字符。如果count是负数，返回最后的分隔符到右边的所有字符(从右边数)。 
mysql> select SUBSTRING_INDEX('www.mysql.com', '.', 2);
    -> 'www.mysql'
mysql> select SUBSTRING_INDEX('www.mysql.com', '.', -2);
    -> 'mysql.com'
该函数对多字节是可靠的。 
LTRIM(str) 
返回删除了其前置空格字符的字符串str。 
mysql> select LTRIM(' barbar');
    -> 'barbar'
RTRIM(str) 
返回删除了其拖后空格字符的字符串str。 
mysql> select RTRIM('barbar   ');
    -> 'barbar'
该函数对多字节是可靠的。 
TRIM([[BOTH | LEA
DING | TRAILING] [remstr] FROM] str) 
返回字符串str，其所有remstr前缀或后缀被删除了。如果没有修饰符BOTH、LEADING或TRAILING给出，BOTH被假定。如果remstr没被指定，空格被删除。 
mysql> select TRIM(' bar   ');
    -> 'bar'
mysql> select TRIM(LEADING 'x' FROM 'xxxbarxxx');
    -> 'barxxx'
mysql> select TRIM(BOTH 'x' FROM 'xxxbarxxx');
    -> 'bar'
mysql> select TRIM(TRAILING 'xyz' FROM 'barxxyz');
    -> 'barx'
该函数对多字节是可靠的。 
SOUNDEX(str) 
返回str的一个同音字符串。听起来“大致相同”的2个字符串应该有相同的同音字符串。一个“标准”的同音字符串长是4个字符，但是SOUNDEX()函数返回一个任意长的字符串。你可以在结果上使用SUBSTRING()得到一个“标准”的 同音串。所有非数字字母字符在给定的字符串中被忽略。所有在A-Z之外的字符国际字母被当作元音。 
mysql> select SOUNDEX('Hello');
    -> 'H400'
mysql> select SOUNDEX('Quadratically');
    -> 'Q36324'
SPACE(N) 
返回由N个空格字符组成的一个字符串。 
mysql> select SPACE(6);
    -> '     '
REPLACE(str,from_str,to_str) 
返回字符串str，其字符串from_str的所有出现由字符串to_str代替。 
mysql> select REPLACE('www.mysql.com', 'w', 'Ww');
    -> 'WwWwWw.mysql.com'
该函数对多字节是可靠的。 
REPEAT(str,count) 
返回由重复countTimes次的字符串str组成的一个字符串。如果count <= 0，返回一个空字符串。如果str或count是NULL，返回NULL。 
mysql> select REPEAT('MySQL', 3);
    -> 'MySQLMySQLMySQL'
REVERSE(str) 
返回颠倒字符顺序的字符串str。 
mysql> select REVERSE('abc');
    -> 'cba'
该函数对多字节可靠的。 
INSERT(str,pos,len,newstr) 
返回字符串str，在位置pos起始的子串且len个字符长得子串由字符串newstr代替。 
mysql> select INSERT('Quadratic', 3, 4, 'What');
    -> 'QuWhattic'
该函数对多字节是可靠的。 
ELT(N,str1,str2,str3,...) 
如果N= 1，返回str1，如果N= 2，返回str2，等等。如果N小于1或大于参数个数，返回NULL。ELT()是FIELD()反运算。 
mysql> select ELT(1, 'ej', 'Heja', 'hej', 'foo');
    -> 'ej'
mysql> select ELT(4, 'ej', 'Heja', 'hej', 'foo');
    -> 'foo'
FIELD(str,str1,str2,str3,...) 
返回str在str1, str2, str3, ...清单的索引。如果str没找到，返回0。FIELD()是ELT()反运算。 
mysql> select FIELD('ej', 'Hej', 'ej', 'Heja', 'hej', 'foo');
    -> 2
mysql> select FIELD('fo', 'Hej', 'ej', 'Heja', 'hej', 'foo');
    -> 0
FIND_IN_SET(str,strlist) 
如果字符串str在由N子串组成的表strlist之中，返回一个1到N的值。一个字符串表是被“,”分隔的子串组成的一个字符串。如果第一个参数是一个常数字符串并且第二个参数是一种类型为SET的列，FIND_IN_SET()函数被优化而使用位运算！如果str不是在strlist里面或如果strlist是空字符串，返回0。如果任何一个参数是NULL，返回NULL。如果第一个参数包含一个“,”，该函数将工作不正常。 
mysql> SELECT FIND_IN_SET('b','a,b,c,d');
    -> 2
MAKE_SET(bits,str1,str2,...) 
返回一个集合 (包含由“,”字符分隔的子串组成的一个字符串)，由相应的位在bits集合中的的字符串组成。str1对应于位0，str2对应位1，等等。在str1, str2, ...中的NULL串不添加到结果中。 
mysql> SELECT MAKE_SET(1,'a','b','c');
    -> 'a'
mysql> SELECT MAKE_SET(1 | 4,'hello','nice','world');
    -> 'hello,world'
mysql> SELECT MAKE_SET(0,'a','b','c');
    -> ''
EXPORT_SET(bits,on,off,[separator,[number_of_bits]]) 
返回一个字符串，在这里对于在“bits”中设定每一位，你得到一个“on”字符串，并且对于每个复位(reset)的位，你得到一个“off”字符串。每个字符串用“separator”分隔(缺省“,”)，并且只有“bits”的“number_of_bits” (缺省64)位被使用。 
mysql> select EXPORT_SET(5,'Y','N',',',4)
    -> Y,N,Y,N 
LCASE(str) 
　 
LOWER(str) 
返回字符串str，根据当前字符集映射(缺省是ISO-8859-1 Latin1)把所有的字符改变成小写。该函数对多字节是可靠的。 
mysql> select LCASE('QUADRATICALLY');
    -> 'quadratically'
UCASE(str) 
　 
UPPER(str) 
返回字符串str，根据当前字符集映射(缺省是ISO-8859-1 Latin1)把所有的字符改变成大写。该函数对多字节是可靠的。 
mysql> select UCASE('Hej');
    -> 'HEJ'
该函数对多字节是可靠的。 
LOAD_FILE(file_name) 
读入文件并且作为一个字符串返回文件内容。文件必须在服务器上，你必须指定到文件的完整路径名，而且你必须有file权限。文件必须所有内容都是可读的并且小于max_allowed_packet。如果文件不存在或由于上面原因之一不能被读出，函数返回NULL。 
mysql> UPDATE table_name
      SET blob_column=LOAD_FILE("/tmp/picture")
      WHERE id=1;
MySQL必要时自动变换数字为字符串，并且反过来也如此： 
mysql> SELECT 1+"1";
    -> 2
mysql> SELECT CONCAT(2,' test');
    -> '2 test'
如果你想要明确地变换一个数字到一个字符串，把它作为参数传递到CONCAT()。 
如果字符串函数提供一个二进制字符串作为参数，结果字符串也是一个二进制字符串。被变换到一个字符串的数字被当作是一个二进制字符串。这仅影响比较



# 3. MySql日志

**MySQL开启通用查询日志general log 
mysql打开general log之后，所有的查询语句都可以在general log文件中以可读的方式得到，但是这样general log文件会非常大，所以默认都是关闭的。有的时候为了查错等原因，还是需要暂时打开general log的（本次测试只修改在内存中的参数值，不设置参数文件）。
general_log支持动态修改：

mysql> select version();
+-----------+
| version() |
+-----------+
| 5.6.16  |
+-----------+
1 row in set (0.00 sec)

mysql> set global general_log=1;

Query OK, 0 rows affected (0.03 sec)
general_log支持输出到table：
mysql> set global log_output='TABLE';
Query OK, 0 rows affected (0.00 sec)

mysql> select * from mysql.general_log\G;

*************************** 1. row ***************************
 event_time: 2014-08-14 10:53:18
  user_host: root[root] @ localhost []
  thread_id: 3
  server_id: 0
command_type: Query
  argument: select * from mysql.general_log
*************************** 2. row ***************************
 event_time: 2014-08-14 10:54:25
  user_host: root[root] @ localhost []
  thread_id: 3
  server_id: 0
command_type: Query
  argument: select * from mysql.general_log
2 rows in set (0.00 sec)
ERROR: 
No query specified
输出到file：
mysql> set global log_output='FILE';
Query OK, 0 rows affected (0.00 sec)

mysql> set global general_log_file='/tmp/general.log'; 
Query OK, 0 rows affected (0.01 sec)

[root@mysql-db101 tmp]# more /tmp/general.log 
/home/mysql/mysql/bin/mysqld, Version: 5.6.16 (Source distribution). started with:
Tcp port: 3306 Unix socket: /home/mysql/logs/mysql.sock
Time         Id Command  Argument
140814 10:56:44   3 Query   select * from mysql.general_log

**查询次数最多的SQL语句**
analysis-general-log.py general.log | sort | uniq -c | sort -nr

```
1032 SELECT * FROM wp_comments WHERE ( comment_approved = 'x' OR comment_approved = 'x' ) AND comment_post_ID = x ORDER BY comment_date_gmt DESC
653 SELECT post_id, meta_key, meta_value FROM wp_postmeta WHERE post_id in (x) ORDER BY meta_id ASC
527 SELECT FOUND_ROWS()
438 SELECT t.*, tt.* FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt ON t.term_id = tt.term_id WHERE tt.taxonomy = 'x' AND t.term_id = x limit
341 SELECT option_value FROM wp_options WHERE option_name = 'x' limit
329 SELECT t.*, tt.*, tr.object_id FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt ON tt.term_id = t.term_id INNER JOIN wp_term_relationships AS tr ON tr.term_taxonomy_id = tt.term_taxonomy_id WHERE tt.taxonomy in (x) AND tr.object_id in (x) ORDER BY t.name ASC
311 SELECT wp_posts.* FROM wp_posts WHERE 1= x AND wp_posts.ID in (x) AND wp_posts.post_type = 'x' AND ((wp_posts.post_status = 'x')) ORDER BY wp_posts.post_date DESC
219 SELECT wp_posts.* FROM wp_posts WHERE ID in (x)
218 SELECT tr.object_id FROM wp_term_relationships AS tr INNER JOIN wp_term_taxonomy AS tt ON tr.term_taxonomy_id = tt.term_taxonomy_id WHERE tt.taxonomy in (x) AND tt.term_id in (x) ORDER BY tr.object_id ASC
217 SELECT wp_posts.* FROM wp_posts WHERE 1= x AND wp_posts.ID in (x) AND wp_posts.post_type = 'x' AND ((wp_posts.post_status = 'x')) ORDER BY wp_posts.menu_order ASC
202 SELECT SQL_CALC_FOUND_ROWS wp_posts.ID FROM wp_posts WHERE 1= x AND wp_posts.post_type = 'x' AND (wp_posts.post_status = 'x') ORDER BY wp_posts.post_date DESC limit
118 SET NAMES utf8
115 SET SESSION sql_mode= 'x'
115 SELECT @@SESSION.sql_mode
112 SELECT option_name, option_value FROM wp_options WHERE autoload = 'x'
111 SELECT user_id, meta_key, meta_value FROM wp_usermeta WHERE user_id in (x) ORDER BY umeta_id ASC
108 SELECT YEAR(min(post_date_gmt)) AS firstdate, YEAR(max(post_date_gmt)) AS lastdate FROM wp_posts WHERE post_status = 'x'
108 SELECT t.*, tt.* FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt ON t.term_id = tt.term_id WHERE tt.taxonomy in (x) AND tt.count > x ORDER BY tt.count DESC limit
107 SELECT t.*, tt.* FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt ON t.term_id = tt.term_id WHERE tt.taxonomy in (x) AND t.term_id in (x) ORDER BY t.name ASC
107 SELECT * FROM wp_users WHERE ID = 'x'
106 SELECT SQL_CALC_FOUND_ROWS wp_posts.ID FROM wp_posts WHERE 1= x AND wp_posts.post_type = 'x' AND (wp_posts.post_status = 'x') AND post_date > 'x' ORDER BY wp_posts.post_date DESC limit
106 SELECT SQL_CALC_FOUND_ROWS wp_posts.ID FROM wp_posts WHERE 1= x AND wp_posts.post_type = 'x' AND (wp_posts.post_status = 'x') AND post_date > 'x' ORDER BY RAND() DESC limit
105 SELECT SQL_CALC_FOUND_ROWS wp_posts.ID FROM wp_posts WHERE 1= x AND wp_posts.post_type = 'x' AND (wp_posts.post_status = 'x') AND post_date > 'x' ORDER BY wp_posts.comment_count DESC limit
```





