[toc]



主讲：鲁班
时间：2019/08/28
**概要：**

1. Nginx 简介
2. Nginx 架构说明 
3. Nginx 基础配置与使用
## 一、Nginx 简介与安装

---
### 知识点：
1. Nginx 简介

Nginx是一个高性能WEB服务器，除它之外Apache、Tomcat、Jetty、IIS，它们都是Web服务器，或者叫做WWW（World Wide Web）服务器，相应地也都具备Web服务器的基本功能。Nginx  相对基它WEB服务有什么优势呢？
1. Tomcat、Jetty 面向java语言，先天就是重量级的WEB服务器，其性能与Nginx没有可比性。
2. IIS只能在Windows操作系统上运行。Windows作为服务器在稳定性与其他一些性能上都不如类UNIX操作系统，因此，在需要高性能Web服务器的场合下IIS并不占优。
3. Apache的发展时期很长，而且是目前毫无争议的世界第一大Web服务器，其有许多优点，如稳定、开源、跨平台等，但它出现的时间太长了，在它兴起的年代，互联网的产业规模远远比不上今天，所以它被设计成了一个重量级的、不支持高并发的Web服务器。在Apache服务器上，如果有数以万计的并发HTTP请求同时访问，就会导致服务器上消耗大量内存，操作系统内核对成百上千的Apache进程做进程间切换也会消耗大量CPU资源，并导致HTTP请求的平均响应速度降低，这些都决定了Apache不可能成为高性能Web服务器，这也促使了Lighttpd和Nginx的出现。 下图可以看出07年到17 年强劲增长势头。

![图片](https://images-cdn.shimo.im/6A4GSirFCTcUX0WC/服务器排名.png!thumbnail)

### **2、编译与安装**
**安装环境准备：**
**（1）linux 内核2.6及以上版本:**
只有2.6之后才支持epool ，在此之前使用select或pool多路复用的IO模型，无法解决高并发压力的问题。通过命令uname -a 即可查看。
```
#查看 linux 内核
uname -a  
```
**（2）GCC编译器**
GCC（GNU Compiler Collection）可用来编译C语言程序。Nginx不会直接提供二进制可执行程序,只能下载源码进行编译。
**（3）PCRE库**
PCRE（Perl Compatible Regular Expressions，Perl兼容正则表达式）是由Philip Hazel开发的函数库，目前为很多软件所使用，该库支持正则表达式。
**（4）zlib库**
zlib库用于对HTTP包的内容做gzip格式的压缩，如果我们在nginx.conf里配置了gzip on，并指定对于某些类型（content-type）的HTTP响应使用gzip来进行压缩以减少网络传输量。
**（5）OpenSSL开发库**
如果我们的服务器不只是要支持HTTP，还需要在更安全的SSL协议上传输HTTP，那么就需要拥有OpenSSL了。另外，如果我们想使用MD5、SHA1等散列函数，那么也需要安装它。
上面几个库都是Nginx 基础功能所必需的，为简单起见我们可以通过yum 命令统一安装。
```
#yum 安装nginx 环境
yum -y install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre pcre-devel
```

**源码获取：**
nginx 下载页：http://nginx.org/en/download.html 。
```
# 下载nginx 最新稳定版本
wget http://nginx.org/download/nginx-1.19.9.tar.gz
#解压
tar -zxvf /opt/nginx-1.19.9.tar.gz  -C ./
```
最简单的安装：
```
# 全部采用默认安装
./configure & make & make install  
make   & make install 

## 解压
tar -zxvf nginx-1.9.9.tar.gz
##进入nginx目录
cd nginx-1.9.9
## 配置./configure --prefix=/usr/local/nginx
# make
make &&make install
```
执行完成之后 nginx 运行文件 就会被安装在 /usr/local/nginx 下。

基于参数构建
```
./configure    
```

**模块更新：**
```
# 添加状态查查看模块
./configure --with-http_stub_status_module 
# 重新创建主文件
make
# 将新生成的nginx 文件覆盖 旧文件。
cp objs/nginx /usr/local/nginx/sbin/
# 查看是否更新成功 显示了 configure 构建参数表示成功
/usr/local/nginx/sbin/nginx -V
```


**控制命令：**
```
#查看命令帮助
./sbin/nginx -?
#默认方式启动：
./sbin/nginx 
#指定配置文件启动 
./sbing/nginx -c /tmp/nginx.conf 
#指定nginx程序目录启动
./sbin/nginx -p /usr/local/nginx/

#快速停止
./sbin/nginx -s stop
#优雅停止
./sbin/nginx -s quit

# 热装载配置文件 
./sbin/nginx -s reload
# 重新打开日志文件
./sbin/nginx -s reopen
# 设置全局命令，如下表示设置启动用户为root
./sbin/nginx -g "user root;"

```

**模块更新：**
## 二、Nginx 架构说明

---
**Nginx 架构图:**
![图片](https://images-cdn.shimo.im/mgBtXOyOrjkUmSrZ/nginx_架构图.png!thumbnail)

**架构说明：**
1）nginx启动时，会生  不处理网络请求，主要负责调度工作进程，也就是图示的三项：加载配置、启动工作进程及非停升级。所以，nginx启动以后，查看操作系统的进程列表，我们就能看到至少有两个nginx进程。
2）服务器实际处理网络请求及响应的是工作进程（worker），在类unix系统上，nginx可以配置多个worker，而每个worker进程都可以同时处理数以千计的网络请求。
3）模块化设计。nginx的worker，包括核心和功能性模块，核心模块负责维持一个运行循环（run-loop），执行网络请求处理的不同阶段的模块功能，如网络读写、存储读写、内容传输、外出过滤，以及将请求发往上游服务器等。而其代码的模块化设计，也使得我们可以根据需要对功能模块进行适当的选择和修改，编译成具有特定功能的服务器。
4）事件驱动、异步及非阻塞，可以说是nginx得以获得高并发、高性能的关键因素，同时也得益于对Linux、Solaris及类BSD等操作系统内核中事件通知及I/O性能增强功能的采用，如kqueue、epoll及event ports。


**Nginx 核心模块：**
![图片](https://images-cdn.shimo.im/pV2dAuFXkaodJB4i/image.png!thumbnail)

## 三、Nginx 配置与使用

---
### **知识点**
1. 配置文件语法格式
2. 配置第一个静态WEB服务
3. 配置案例
  1. 动静分离实现
  2. 防盗链
  3. 多域名站点
  4. 下载限速
  5. IP 黑名单
  6. 基于user-agent分流
4. 日志配置
### **1、配置文件的语法格式：**
先来看一个简单的nginx 配置
```
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
        location /nginx_status {
    	   stub_status on;
    	   access_log   off;
  	    }
    }
}
```
上述配置中的events、http、server、location、upstream等属于配置项块。而worker_processes 、worker_connections、include、listen  属于配置项块中的属性。   /nginx_status   属于配置块的特定参数参数。其中server块嵌套于http块，其可以直接继承访问Http块当中的参数。
| **配置块**   | 名称开头用大口号包裹其对应属性   |
|:----|:----|:----:|
| **属性**   | 基于空格切分属性名与属性值，属性值可能有多个项 都以空格进行切分 如：  access_log  logs/host.access.log  main   |
| **参数**   | 其配置在 块名称与大括号间，其值如果有多个也是通过空格进行拆   |

注意 如果配置项值中包括语法符号，比如空格符，那么需要使用单引号或双引号括住配置项值，否则Nginx会报语法错误。例如：
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                     '$status $body_bytes_sent "$http_referer" '
                     '"$http_user_agent" "$http_x_forwarded_for"';
### 2、配置第一个静态WEB服务
**基础站点演示：**
- [ ] 创建站点目录 mkdir -p /usr/www/luban 
- [ ] 编写静态文件
- [ ] 配置 nginx.conf
    - [ ] 配置server
    - [ ] 配置location

基本配置介绍说明：
（1）监听端口
语法：listen address：
默认：listen 80;
配置块：server

（2）主机名称
语法：server_name name[……];
默认：server_name "";
配置块：server
server_name后可以跟多个主机名称，如server_name [www.testweb.com](http://www.testweb.com)、download.testweb.com;。 支持通配符与正则

**（3）location**
语法：location[=|～|～*|^～|@]/uri/{……}
配置块：server
1. =表示把URI作为字符串，以便与参数中的uri做完全匹配。
2. / 基于uri目录匹配
3. ～表示正则匹配URI时是字母大小写敏感的。
4. ～*表示正则匹配URI时忽略字母大小写问题。
5. ^～表示正则匹配URI时只需要其前半部分与uri参数匹配即可。

**匹配优先规则：**
1.     精确匹配优先 =
2.     正则匹配优先 ^~
3.     前缀最大匹配优先。
4.     配置靠前优化

（4）root 指定站点根目录
可配置在 server与location中，基于ROOT路径+URL中路径去寻找指定文件。
（5）alias 指定站点别名
只能配置location 中。基于alias 路径+ URL移除location  前缀后的路径来寻找文件。
如下示例：
```
location /V1 {
      alias  /www/old_site;
      index  index.html index.htm;
}
#防问规则如下
URL：http://xxx:xx/V1/a.html
最终寻址：/www/old_site/a.thml
```



**动静分离演示：**
- [ ] 创建静态站点
- [ ] 配置 location /static
- [ ] 配置 ~* \.(gif|png|css|js)$ 

**基于目录动静分离**
```
   server {
        listen 80;
        server_name *.luban.com;
        root /usr/www/luban;
        location / {
                index luban.html;
        }
        location /static {
         alias /usr/www/static;
        }
 }
```
**基于正则动静分离**
```
location ~* \.(gif|jpg|png|css|js)$ {
      root /usr/www/static;
}
```

**防盗链配置演示：**
```
# 加入至指定location 即可实现
valid_referers none blocked *.luban.com;
 if ($invalid_referer) {
       return 403;
}
```

**下载限速：**
```
location /download {
    limit_rate 1m; //限制每S下载速度
    limit_rate_after 30m; // 超过30 之 后在下载
}

```
**创建IP黑名单**
```
#封禁指定IP
deny 192.168.0.1;
allow 192.168.0.1;
#开放指定IP 段
allow 192.168.0.0/24;
#封禁所有
deny    all;
#开放所有
allow    all;
# 创建黑名单文件
echo 'deny 192.168.0.132;' >> balck.ip
#http 配置块中引入 黑名单文件
include       black.ip;
```


### 3、日志配置：
**日志格式：**
```
log_format  main  '$remote_addr - $remote_user [$time_local]   "$request" '
                     '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';
access_log  logs/access.log  main;
#基于域名打印日志
access_log logs/$host.access.log main;
```

**error日志的设置**
语法：error_log /path/file level;
默认：error_log logs/error.log error;
level是日志的输出级别，取值范围是debug、info、notice、warn、error、crit、alert、emerg，
**针对指定的客户端输出debug级别的日志**
语法：debug_connection[IP|CIDR]
events {
debug_connection 192.168.0.147; 
debug_connection 10.224.57.0/200;
}
注意：debug 日志开启 必须在安装时 添加  --with-debug (允许debug)
[nginx.conf](https://attachments-cdn.shimo.im/uhMsgcdhudg2yAND/nginx.conf)





##  四：配置文件例子

## Nginx常用功能

1、Http代理，反向代理：作为web服务器最常用的功能之一，尤其是反向代理。

这里我给来2张图，对正向代理与反响代理做个诠释，具体细节，大家可以翻阅下资料。

![img](https://www.runoob.com/wp-content/uploads/2018/08/1535725078-5993-20160202133724350-1807373891.jpg)

Nginx在做反向代理时，提供性能稳定，并且能够提供配置灵活的转发功能。Nginx可以根据不同的正则匹配，采取不同的转发策略，比如图片文件结尾的走文件服务器，动态页面走web服务器，只要你正则写的没问题，又有相对应的服务器解决方案，你就可以随心所欲的玩。并且Nginx对返回结果进行错误页跳转，异常判断等。如果被分发的服务器存在异常，他可以将请求重新转发给另外一台服务器，然后自动去除异常服务器。

------

## 2、负载均衡

Nginx提供的负载均衡策略有2种：内置策略和扩展策略。内置策略为轮询，加权轮询，Ip hash。扩展策略，就天马行空，只有你想不到的没有他做不到的啦，你可以参照所有的负载均衡算法，给他一一找出来做下实现。

上3个图，理解这三种负载均衡算法的实现

![img](https://www.runoob.com/wp-content/uploads/2018/08/1535725078-8303-20160202133753382-1863657242.jpg)

Ip hash算法，对客户端请求的ip进行hash操作，然后根据hash结果将同一个客户端ip的请求分发给同一台服务器进行处理，可以解决session不共享的问题。 

![img](https://www.runoob.com/wp-content/uploads/2018/08/1535725078-1224-20160201162405944-676557632.jpg)

------

## 3、web缓存

Nginx可以对不同的文件做不同的缓存处理，配置灵活，并且支持FastCGI_Cache，主要用于对FastCGI的动态程序进行缓存。配合着第三方的ngx_cache_purge，对制定的URL缓存内容可以的进行增删管理。

------

## 4、Nginx相关地址

源码：https://trac.nginx.org/nginx/browser

官网：http://www.nginx.org/

**nginx 文件结构**

```
...              #全局块

events {         #events块
   ...
}

http      #http块
{
    ...   #http全局块
    server        #server块
    { 
        ...       #server全局块
        location [PATTERN]   #location块
        {
            ...
        }
        location [PATTERN] 
        {
            ...
        }
    }
    server
    {
      ...
    }
    ...     #http全局块
}
```

- 1、**全局块**：配置影响nginx全局的指令。一般有运行nginx服务器的用户组，nginx进程pid存放路径，日志存放路径，配置文件引入，允许生成worker process数等。
- 2、**events块**：配置影响nginx服务器或与用户的网络连接。有每个进程的最大连接数，选取哪种事件驱动模型处理连接请求，是否允许同时接受多个网路连接，开启多个网络连接序列化等。
- 3、**http块**：可以嵌套多个serv er，配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置。如文件引入，mime-type定义，日志自定义，是否使用sendfile传输文件，连接超时时间，单连接请求数等。
- 4、**server块**：配置虚拟主机的相关参数，一个http中可以有多个server。
- 5、**location块**：配置请求的路由，以及各种页面的处理情况。

下面给大家上一个配置文件，作为理解。 

```
########### 每个指令必须有分号结束。#################
#user administrator administrators;  #配置用户或者组，默认为nobody nobody。
#worker_processes 2;  #允许生成的进程数，默认为1
#pid /nginx/pid/nginx.pid;   #指定nginx进程运行文件存放地址
error_log log/error.log debug;  #制定日志路径，级别。这个设置可以放入全局块，http块，server块，级别以此为：debug|info|notice|warn|error|crit|alert|emerg
events {
    accept_mutex on;   #设置网路连接序列化，防止惊群现象发生，默认为on
    multi_accept on;  #设置一个进程是否同时接受多个网络连接，默认为off
    #use epoll;      #事件驱动模型，select|poll|kqueue|epoll|resig|/dev/poll|eventport
    worker_connections  1024;    #最大连接数，默认为512
}
http {
    include       mime.types;   #文件扩展名与文件类型映射表
    default_type  application/octet-stream; #默认文件类型，默认为text/plain
    #access_log off; #取消服务日志    
    log_format myFormat '$remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer      $http_user_agent $http_x_forwarded_for'; #自定义格式
    access_log log/access.log myFormat;  #combined为日志格式的默认值
    sendfile on;   #允许sendfile方式传输文件，默认为off，可以在http块，server块，location块。
    sendfile_max_chunk 100k;  #每个进程每次调用传输数量不能大于设定的值，默认为0，即不设上限。
    keepalive_timeout 65;  #连接超时时间，默认为75s，可以在http，server，location块。

    upstream mysvr {   
      server 127.0.0.1:7878;
      server 192.168.10.121:3333 backup;  #热备
    }
    error_page 404 https://www.baidu.com; #错误页
    server {
        keepalive_requests 120; #单连接请求上限次数。
        listen       4545;   #监听端口
        server_name  127.0.0.1;   #监听地址       
        location  ~*^.+$ {       #请求的url过滤，正则匹配，~为区分大小写，~*为不区分大小写。
           #root path;  #根目录
           #index vv.txt;  #设置默认页
           proxy_pass  http://mysvr;  #请求转向mysvr 定义的服务器列表
           deny 127.0.0.1;  #拒绝的ip
           allow 172.18.5.54; #允许的ip           
        } 
    }
}
```

上面是nginx的基本配置，需要注意的有以下几点：

1、几个常见配置项：

- 1.$remote_addr 与 $http_x_forwarded_for 用以记录客户端的ip地址； 
- 2.$remote_user ：用来记录客户端用户名称； 
- 3.$time_local ： 用来记录访问时间与时区；
- 4.$request ： 用来记录请求的url与http协议；
- 5.$status ： 用来记录请求状态；成功是200；
-   6.$body_bytes_s ent ：记录发送给客户端文件主体内容大小；
- 7.$http_referer ：用来记录从那个页面链接访问过来的；
- 8.$http_user_agent ：记录客户端浏览器的相关信息；

2、惊群现象：一个网路连接到来，多个睡眠的进程被同时叫醒，但只有一个进程能获得链接，这样会影响系统性能。

3、每个指令必须有分号结束。





## Nginx中Location配置详解

首先精确匹配 =-》其次以xx开头匹配^~-》然后是按文件中顺序的正则匹配-》最后是交给 / 通用匹配。

当有匹配成功时候，停止匹配，按当前匹配规则处理请求。

例子，有如下匹配规则：

```json
location = / {
   #规则A
}
location = /login {
   #规则B
}
location ^~ /static/ {
   #规则C
}
location ~ \.(gif|jpg|png|js|css)$ {
   #规则D，注意：是根据括号内的大小写进行匹配。括号内全是小写，只匹配小写
}
location ~* \.png$ {
   #规则E
}
location !~ \.xhtml$ {
   #规则F
}
location !~* \.xhtml$ {
   #规则G
}
location / {
   #规则H
}
```

> 那么产生的效果如下：

- 访问根目录/， 比如http://localhost/ 将匹配规则A

- 访问 http://localhost/login 将匹配规则B，http://localhost/register 则匹配规则H

- 访问 http://localhost/static/a.html 将匹配规则C

- 访问 http://localhost/a.gif, http://localhost/b.jpg 将匹配规则D和规则E，但是规则D顺序优先，规则E不起作用， 而 http://localhost/static/c.png 则优先匹配到 规则C

- 访问 http://localhost/a.PNG 则匹配规则E， 而不会匹配规则D，因为规则E不区分大小写。

- 访问 http://localhost/a.xhtml 不会匹配规则F和规则G，

- http://localhost/a.XHTML不会匹配规则G，（因为!）。规则F，规则G属于排除法，符合匹配规则也不会匹配到，所以想想看实际应用中哪里会用到。

- 访问 http://localhost/category/id/1111 则最终匹配到规则H，因为以上规则都不匹配，这个时候nginx转发请求给后端应用服务器，比如FastCGI（php），tomcat（jsp），nginx作为方向代理服务器存在。

所以实际使用中，个人觉得至少有三个匹配规则定义，如下：

```
#直接匹配网站根，通过域名访问网站首页比较频繁，使用这个会加速处理，官网如是说。
#这里是直接转发给后端应用服务器了，也可以是一个静态首页
# 第一个必选规则
location = / {
    proxy_pass http://tomcat:8080/index
}
 
# 第二个必选规则是处理静态文件请求，这是nginx作为http服务器的强项
# 有两种配置模式，目录匹配或后缀匹配,任选其一或搭配使用
location ^~ /static/ {                              //以xx开头
    root /webroot/static/;
}
location ~* \.(gif|jpg|jpeg|png|css|js|ico)$ {     //以xx结尾
    root /webroot/res/;
}
 
#第三个规则就是通用规则，用来转发动态请求到后端应用服务器
#非静态文件请求就默认是动态请求，自己根据实际把握
location / {
    proxy_pass http://tomcat:8080/
}
```





#### 配置的路径会自动加载后面问题

```javascript
 location /www/ {
           root   /data/zrgdata/;        
#           proxy_pass http://127.0.0.1:8080;
           index  index.html index.htm;
       }
访问地址：http://192.168.225.236:8001/www/index.html
```

> 在nginx中配置proxy_pass时，如果是按照 ^~ 正则匹配路径时,要注意proxy_pass后的url最后的 /
> 如果加上了/，则会把匹配的路径部分也给代理走；
> 如果没有/，相当于是绝对根路径，则nginx不会把location中匹配的路径部分代理走。
> （注意：这里说的是proxy_pass的url后面的"/"，不是指location 后面的"/"）

```javascript
假如已有站点：http://js.test.com/test.html
location  /static_js/   { 
    proxy_pass http://js.test.com/; （这里的最后面的"/"）
}

如上面的配置，如果请求的url是http://servername/static_js/test.html，会被代理成http://js.test.com/test.html
而如果这么配置
location  /static_js/  { 
    proxy_pass http://js.test.com; 
}
则会被代理到http://js.test.com/static_js/test.htm，产生无法访问从而报错

如果换成下面这样，也会报错：
location ^~ /static_js/ {
    proxy_pass http://js.test.com; 
}
但是，这样就没问题了：
location ^~ /static_js/ {
    proxy_pass http://js.test.com/; 
}

当然，我们可以用如下的rewrite来实现/的功能
location ^~ /static_js/ { 
    rewrite /static_js/(.+)$ /$1 break; 
    proxy_pass http://js.test.com; 
} 
```



### 高可用

1)使用 yum 命令进行安装

yum install keepalived –y

(2)安装之后，在 etc 里面生成目录 keepalived，有文件 keepalived.conf

4、完成高可用配置(主从配置)

