# Http的Connect方法
链接：https://www.jianshu.com/p/54357cdd4736
在HTTP中常用的方法有get，post，head。但也有很多不常用的method，其中就包括connect

1、HTTP代理使用的就是connect这个方法，connect在网页开发中不会使用到。
2、connect的作用就是将服务器作为代理，让服务器代替用户去访问其他网页（说白了，就是翻墙），之后将数据返回给用户。
3、connect是通过TCP连接代理服务器的。加入我想告诉代理服务器向访问https://www.jianshu.com/u/f67233ce6c0c网站，就需要首先建立起一条从我的客户端到代理服务器的TCP连接，然后给代理服务器发送一个HTTP报文：

![Connnect](_v_images/connnect_1558080273_29146.jpg)

其中Proxy-Authorization中，为验证用户名和密码部分。
在发送完这个请求之后，代理服务器会响应请求，返回一个200的信息，但这个200并不同于我们平时见到的OK，而是Connection Established。
HTTP/1.1 200 Connection Established

如果用户名密码部分验证失败，则会返回：
HTTP/1.1 407 Unauthorized

通过验证之后，就可以做HTTP操作了，发送的HTTP请求报文会通过代理服务器请求Internet服务器。然后返回给客户端。




