# 一 ：JS 对象(Object)和字符串(String)互转方法

## 利用原生JSON对象，将对象转为字符串

```
var jsObj = {};
jsObj.testArray = [1,2,3,4,5];
jsObj.name = 'CSS3';
jsObj.date = '8 May, 2011';
var str = JSON.stringify(jsObj);
alert(str);
```

## 从JSON字符串转为对象

```
var jsObj = {};
jsObj.testArray = [1,2,3,4,5];
jsObj.name = 'CSS3';
jsObj.date = '8 May, 2011';
var str = JSON.stringify(jsObj);
var str1 = JSON.parse(str);
alert(str1);
```

