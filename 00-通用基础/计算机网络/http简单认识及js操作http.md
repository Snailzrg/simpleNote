# http简单认识及js操作http
CSDN:-->https://blog.csdn.net/qq_34178990/article/details/81033293

前言

这篇是我在看了《图解http》， 并查阅了关于ajax相关知识之后， 感觉有所收获， 所写。 主要叫讲述简单http认识， js如何操作。， 关于CORS跨域等问题。

一、http基础篇

简介

http（超文本传输文本协议）， 用于web应用传输数据的协议， 只能由客户端发起， 由服务端响应。 具有无状态等特点。

结构

http协议的传输单位是http报文（请求报文、响应报文）。 报文的结构可分为：请求/响应行、 首部字段、实体部分。

get请求报文

GET /index.html HTTP/1.1     //请求行
Host: test.com  //首部字段
get响应报文

HTTP/1.1 200 OK                 //响应行
Date: Tue, 10 Jul 2012 06;50:15 GMT     //首部字段
Content-Length: 362                     //首部字段
Content-Type: text/html                //首部字段

<html>                                  //实体
...
请求行用于说明请求方法 ， 请求地址， http版本号 
响应行用于说明服务器http版本号， 响应状态码， 状态码的原因短句

首部字段分为： 通用首部字段、 请求首部字段、 响应首部字段、 实体首部字段

对于实体内的内容， 可以用实体首部字段加以说明。 最常使用的是content-type: xxxx， 说明实体内容的类型。

二、javaScript操作http

浏览器中， http请求可以由浏览器中的如下内容发送： 
1. 浏览器中的url地址栏 
2. 页面有src属性的标签（img、script、 link等） 
3. 带有action属性的form表单 
4. XMLHttpRequest对象

1. XMLHttpRequest的基本用法

在这些方法中， XMLHttpRequest对象提供了接口让我们操作http.基本用法如下：

var xhr = new XMLHttpRequest();//此时readyState属性值为0
xhr.open('post', 'http://www.test.com', false)//此时readyState属性值为1
xhr.send("name=yang&psd=123")//readyState属性值为2

xhr.onreadyStatechange = function(){
    if(xhr.readState === 4 && xhr.status === 200 ){
        console.log(xhr.responseText)
    }else{
        console.log('Request was unsuccessfull:' + xhr.status)
    }
}
以上是XMLHttpRequest的基本使用方法。

1). 发送数据， 使用send方法

这里的发送数据指的是post方法发送数据

xhr.send("name=yang&psd=123")//post方法发送了一个form表单数据
1
如果是get方法则数据拼接到url后面（使用encodeURIComponent()将名和值进行编码之后）， send方法参数必须是null

xhr.open('get', 'http://www.test.com?name='yang'&psd=123, false)//将name和value进行encodeURIComponent编码， （同cookie的value一样）， 其中open方法最后一个参数代表是否异步
xhr.send(null)//不能不写
2). 使用readyState可以查看当前xhr对象的状态， 状态有：

0– 没调用open方法
1– 没调用send方法
2– 调用send方法， 未接受到响应
3– 正在接受响应， 未接受完成
4– 响应全部接受
3). 获得响应的状态， 使用status属性， 当属性的值为200表示请求成功

var httpStatus = xhr.status
if(httpStatus === 200){
    //请求成功，可以做接下来的事情了
}

4). 获得响应的数据，使用responseText属性
var result = xhr.responseText
5). 添加首部字段, 使用setRequestHeader方法
xhr.setRequestHeader('myHeader', 'myValue')//这里必须放在open方法， 和send方法中间， 否则不能成功添加首部字段
6). 获得首部字段， 使用getResponseHeader或getAllResponseHeaders方法

var header = xhr.getResponseHeader('myHeader')//传入首部字段名
var headers = xhr.getAllResponseHeader()//获得全部的首部字段，返回多行文本内容

//这是headers的结果
Date: Sun, 14 Nov 2004 18:04:03 GMT
Server: Apache/1.3.29(Unix)
Vary: Accept
X-Powered-By: PHP/4.3.8
Connection: close
Content-Type: text/html;charset=ios-8859-1

2. XMLHttpRequest跨域用法

使用XHR对象通信，有一个限制就是跨域安全策略。 默认情况下， XHR对下只能访问包含它的页面位于同一个域中的资源。 但是有时我们开发不能不进行跨域请求。

1). CORS跨域源资源共享
基本思想： 使用自定义的首部字段让给浏览器与服务器沟通， 从而决定请求或响应是否应该成功。
整个CORS通信过程，都是浏览器自动完成，不需要用户参与。对于开发者来说，CORS通信与同源的AJAX通信没有差别，代码完全一样。浏览器一旦发现AJAX请求跨源，就会自动添加一些附加的头信息（Origin首部字段），有时还会多出一次附加的请求，但用户不会有感觉。

2). 原理

客户端
浏览器一旦发现AJAX请求跨源，就会自动添加一些附加的头信息（Origin首部字段），有时还会多出一次附加的请求（分简单请求），但用户不会有感觉。

服务端
服务器读取Origin首部字段的值， 判断是否应该成功， 如果成功返回的响应报文中首部字段包含Access-control-allow-Origin:xxxxxx。 如果xxxxx为*或与自己发送的Origin的值相同， 浏览器就会判断请求成功。

3). CORS的简单请求与非简单请求

局限
CORS跨域请求， 存在以下限制， 例如：

求方法为post/get/head，
首部字段只设置Content-Type
不能访问响应头部
cookie不随请求发送
简单情求

请求方法为post/get/head， 首部字段只设置content-type（只限于三个值application/x-www-form-urlencoded、multipart/form-data、text/plain等 
）， 这样的请求为简单请求。 这是浏览器将会在请求报文中添加Origin的首部字段，完成情趣。

GET /cors HTTP/1.1
Origin: http://api.bob.com
Host: api.alice.com
Accept-Language: en-US
Connection: keep-alive
User-Agent: Mozilla/5.0...

非简单请求

如果不是简单请求， 浏览器将不会想处理简单请求一样处理， 例如我们希望添加其他的首部字段。 这浏览器将会发送一个预检请求（Preflighted Requests）

Preflighted Requests,如下

OPTIONS /cors HTTP/1.1                       //请求的方法， 地址， http版本
Origin: http://api.bob.com                // 客户端的域名
Access-Control-Request-Method: PUT          //即将发起非简单请求的方法， 用于服务器判断是否支持该方法
Access-Control-Request-Headers: X-Custom-Header //即将发起非简单请求携带的首部字段， 用于服务器判断是否支持该字段
Host: api.alice.com   
Accept-Language: en-US
Connection: keep-alive
User-Agent: Mozilla/5.0...

这种请求的方法是options方法， 用于服务器询问。 如果服务都满足， 将会如下

HTTP/1.1 200 OK
Date: Mon, 01 Dec 2008 01:15:39 GMT
Server: Apache/2.0.61 (Unix)
Access-Control-Allow-Origin: http://api.bob.com        //允许跨域的域
Access-Control-Allow-Methods: GET, POST, PUT           //支持的请求方法
Access-Control-Allow-Headers: X-Custom-Header         //支持的头部
Content-Type: text/html; charset=utf-8
Content-Encoding: gzip
Content-Length: 0
Keep-Alive: timeout=2, max=100
Connection: Keep-Alive
Content-Type: text/plain

浏览器将会用响应报文的首部字段中以Access-control开头的字段与即将发送的请求比对， 如果服务将会如同简单请求一样发送请求。 故，非简单请求会有一个预检请求。

同时， 浏览器会将响应按照这个时间：（Access-Control-Max-Age: 1728000）保存， 在该时间未过期期间， 就不必发送预检请求， 而直接发起请求。

携带cookie

默认情况下， 跨域请求不会携带cookie。 需要我们设置一个属性值–withCredentials

xhr.withCredentials = true

当然跨域携带cookie也需要服务器支持才行， 如果服务愿意接受携带cookie的跨域信息， 就会在预检请求响应头部添加如下首部字段：

Access-Control-Allow-Credentials: true

3. 跨浏览器的CORS

function createCORSRequest(method, url){
    var xhr = new XMLHttpRequest()
    if("withCredentials" in xhr){
        xhr.open(method, url, true);
    }else if (typeof XDomainRequest() != 'undefined') {
        xhr = new XDomainRequest()
        xhr.open(method, url)
    }else{
        xhr = null
    }
    return xhr
}

var request = createCORSRequest('get', 'http://test.com')
if(request){
    request.onload = function(){//XMLHttpRequest 2级增加的事件
        //对request.responseText进行处理
    }
    request.send(null)
}

总结

详细了解http呢是有必要的， 对于我们理解很多东西都有非常大的好处。 比如这篇文章， 关于操作http部分， 其重点就是添加实体， 添加首部字段的操作。 而关于添加首部字段呢， 就有必要明白各个首部字段的意义了。
