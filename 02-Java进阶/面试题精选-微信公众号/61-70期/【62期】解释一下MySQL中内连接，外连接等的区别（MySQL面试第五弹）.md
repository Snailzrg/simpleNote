## 【62期】解释一下MySQL中内连接，外连接等的区别（MySQL面试第五弹）

[Java面试题精选](javascript:void(0);) *3月17日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

下图展示了 LEFT JOIN、RIGHT JOIN、INNER JOIN、OUTER JOIN 相关的 7 种用法。

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExwpTtQibfXrlOZYdjwtuteH64IkRrgDrulic56ypMMWuRk5f8ZemQSxaA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

具体分解如下：

### 1.INNER JOIN（内连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExUU3Fx6DNaowhDnIGPW6cntMiaL7rQpFiazPJ0HKVhrLn4oUnxSCCibnxQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list> 
FROM Table_A A
INNER JOIN Table_B B
ON A.Key = B.Key
```

### 2.LEFT JOIN（左连接）

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)



```
SELECT <select_list>
FROM Table_A A
LEFT JOIN Table_B B
ON A.Key = B.Key
```

### 3.RIGHT JOIN（右连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExkGOyFZR3MX9icticTh4R08Dic9tHaaV1C7fmf4ZicfeLsPtXQUPFtTG8Hg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list>
FROM Table_A A
RIGHT JOIN Table_B B
ON A.Key = B.Key
```

### 4.OUTER JOIN（外连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExjh6HuicxI6bfuPJWITH6gL0G2Qfibiax2WYH5G2GKk0LAVQgCH6QicUlPA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list>
FROM Table_A A
FULL OUTER JOIN Table_B B
ON A.Key = B.Key
```

### 5.LEFT JOIN EXCLUDING INNER JOIN（左连接-内连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExib6x7rn8v34TdcaNgichnjvswLEkEalFQGdcEjz8la7pyPRickEG98fNQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list> 
FROM Table_A A
LEFT JOIN Table_B B
ON A.Key = B.Key
WHERE B.Key IS NULL
```

### 6.RIGHT JOIN EXCLUDING INNER JOIN（右连接-内连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExE0oXX6FpuKyOOsC4lxvSTWbefQK0F7RgtvP2YqAuxsibhjWW9ljfqRw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list>
FROM Table_A A
RIGHT JOIN Table_B B
ON A.Key = B.Key
WHERE A.Key IS NULL
```

### 7.OUTER JOIN EXCLUDING INNER JOIN（外连接-内连接）

![img](https://mmbiz.qpic.cn/mmbiz_png/vqlbVFl5Jn2fx4T60E8RNV6gdvX5icOExa24qEdib5Z4EElk8dRbADrfHTqE8icmBicGZibXGm4YpTvdhJuFpNgdD5Q/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



```
SELECT <select_list>
FROM Table_A A
FULL OUTER JOIN Table_B B
ON A.Key = B.Key
WHERE A.Key IS NULL OR B.Key IS NULL
```



*来源：www.codeproject.com/Articles/33052*