## Nginx使用详解 

## 文档所需的安装文件全部已经打包，下载地址：
链接：https://pan.baidu.com/s/1yWUDj3lXK9nm-huyzSwu8g
提取码：u7dl
复制这段内容后打开百度网盘手机App，操作更方便哦–来自百度网盘超级会员V3的分享

Nginx可以完成、负载均衡、动静分离

有一部分由于违规无法上传，建议观看此视频补全未提及的知识点尚硅谷Nginx讲解传送门

1. 负载均衡
增加服务器的数量，将请求分发到各个服务器上，而非将请求集中到单个服务器

2. 动静分离
将动态资源和静态资源由不同的服务器解析，降低只使用单个服务器时的压力


二、Nginx安装 (Linux)
将pcre依赖文件上传到Linux的/usr/src目录下


进入上述目录，cd /usr/src

将pcre压缩文件解压，tar -zxvf pcre-8.37.tar.gz

进入解压后的目录中，cd pcre-8.37/

依次执行./configure，make && make install，完成安装

查看是否安装成功，pcre-config --version



安装openssl、zlib、gcc依赖
yum -y install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel
1
将Nginx安装包上传到Linux的/usr/src目录


进入上述目录，cd /usr/src

将Nginx安装文件解压，tar -zxvf nginx-1.12.2.tar.gz

进入解压后的目录中，cd nginx-1.12.2/

依次执行./configure，make && make install，完成安装

开放80端口：

(1) firewall-cmd --permanent --add-port=80/tcp，显示success表示成功

(2) firewall-cmd --reload，重启防火墙生效，显示success表示成功

(3) firewall-cmd --query-port=80/tcp，显示yes表示80端口开放成功

启动Nginx，cd /usr/local/nginx/sbin，后执行./nginx


浏览器地址栏输入 http://[Linux的IP地址]:80 (Nginx默认使用80端口)


三、Nginx常用指令
1. 启动Nginx
先cd /usr/local/nginx/sbin，后./nginx，或者直接 /usr/local/nginx/sbin/nginx

2. 关闭Nginx
先cd /usr/local/nginx/sbin，后./nginx -s stop，或者直接 /usr/local/nginx/sbin/nginx -s stop

3. 热部署Nginx
(无需重启Nginx也可重新加载修改过后的配置文件)

先cd /usr/local/nginx/sbin，后./nginx -s reload，或者直接 /usr/local/nginx/sbin/nginx -s reload

四、Nginx配置文件
Nginx的配置文件都放在/usr/local/nginx/conf/目录下



将nginx.conf文件打开后的内容：

# 第一部分：全局块
worker_processes  1;  # worker进程数，值越大，支持的并发数量越大，尽量与cpu数相同

# 第二部分：events块
`events {`
    `worker_connections  1024;  # 每个worker进程支持的最大连接数默认为1024`
`}`

# 第三部分：http块
	http {
		# http全局块
	    include       mime.types;
	    default_type  application/octet-stream;
	    sendfile        on;
	    keepalive_timeout  65;
	# server块，一般都是对此部分进行配置 (可以有多个server块)
	server {
	    listen       80;
	    server_name  localhost;
	    location / {
	        root   html;
	        index  index.html index.htm;
	    }
	    error_page   500 502 503 504  /50x.html;
	    location = /50x.html {
	        root   html;
	    }
	 }
	}

五、Nginx配置实例 (一)

1. 实现效果
在浏览器输入地址www.123.com，跳转到Linux系统的tomcat服务器主页

2. 步骤分析
(1) 在Linux中安装tomcat，使用默认端口8080

(2) 访问过程解析

(3) 在windows的host文件中进行域名和ip地址的对应关系的设置

(4) 在Nginx的配置文件中，vim /usr/local/nginx/conf/nginx.conf

(5) 启动Nginx，打开浏览器运行，效果如图



六、Nginx配置实例(二)
1. 实现效果
修改Nginx的监听端口为9001，根据浏览器地址的不同跳转到不同的服务器页面

访问 http://[Linux的ip地址]:9001/edu/ 跳转到 127.0.0.1:8080
访问 http://[Linux的ip地址]:9001/vod/ 跳转到 127.0.0.1:8081

2. 步骤分析
(1) 创建两个Tomcat服务器，一个8080端口，一个8081端口 (并开放这两个端口)

(2) 在两个Tomcat服务器的webapps目录下分别创建edu、vod文件夹和a.html文件

(3) 在Nginx的配置文件中进行配置，vim /usr/local/nginx/conf/nginx.conf

(4) 打开浏览器进行测试

3. Nginx配置文件中location指令的说明
(1) 简介：用于匹配请求地址

(2) 语法

(3) 通配符

=：用于不含正则表达式的 uri 前，要求请求字符串与 uri 严格匹配，如果匹配成功，就停
止继续向下搜索并立即处理该请求

~：匹配包含uri的请求地址，区分大小写

~*：匹配包含uri的请求地址，不区分大小写

^~：用于不含正则表达式的 uri 前，要求 Nginx 服务器找到标识 uri 和请求字符串匹配度 最高的 location 后，立即使用此 location 处理请求，而不再使用 location 块中的正则 uri 和请求字符串做匹配

七、Nginx配置实例 - 负载均衡
1. 实现效果
浏览器地址栏输入http://[Linux的ip地址]/edu/a.html，将此请求分配到两台Tomcat服务器中

2. 步骤分析
(1) 创建两个Tomcat服务器，一个8080端口，一个8081端口 (并开放这两个端口)

(2) 在两个Tomcat服务器的webapps目录下分别创建edu文件夹和a.html文件

(3) 在Nginx的配置文件中进行负载均衡配置，vim /usr/local/nginx/conf/nginx.conf

upstream myserver {
# 列出所要负载均衡的tomcat服务器
    server 192.168.206.128:8080;
    server 192.168.206.128:8081;
}

    server {
        listen       80;
        server_name  192.168.206.128;
    
        #charset koi8-r;
    
        #access_log  logs/host.access.log  main;
    
        location / {
            proxy_pass http://myserver;
        }
    (4) 运行结果：地址栏输入地址，每次刷新都会去另一个Tomcat服务器中
3. 负载均衡的分配策略
(1) 轮询 (默认)

按照请求的时间先后顺序逐一分配到不同的服务器，如果某个服务器宕机，会自动将此服 务器剔除

(2) weight

weight表示权重，默认为1，权重越高被分配的请求越多，用法：



(3) ip_hash

每个请求按照访问的ip地址的hash进行分配，即某个地址第一次访问到了哪个服务器，之 后此请求会固定访问此服务器，可以解决session的问题，用法：



(4) fair

按照服务器的响应时间进行请求的分配，服务器响应时间短的优先分配，用法：



## 八、Nginx配置实例 - 动静分离

1. 概述
Nginx动静分离简单来说就是把动态跟静态请求分开，不能理解成只是单纯的把动态页面和静 态页面物理分离。严格意义上说应该是动态请求跟静态请求分开，可以理解成使用Nginx处理 静态页面，Tomcat处理动态页面。动静分离从目前实现角度来讲大致分为两种，一种是纯粹把 静态文件独立成单独的域名，放在独立的服务器上，也是目前主流推崇的方案；另外一种方法 就是动态跟静态文件混合在一起发布，通过Nginx来分开

2. 实现效果
    在Linux的根目录下创建一个/data/www/文件夹，其中存放静态资源a.html，在8080的那台 Tomcat服务器的webapps下也创建一个/data/www/文件夹，其中存放静态资源a.html，当输入 此静态资源的请求时，访问到的是根目录中的静态资源，而不是Tomcat服务器中的静态资源
3. 步骤分析
    (1) 创建上述文件夹及文件

(2) 在Nginx的配置文件中进行动静分离配置，vim /usr/local/nginx/conf/nginx.conf

```
server {
    listen       80;
    server_name  192.168.206.128;
    #charset koi8-r;
    #access_log  logs/host.access.log  main;
    location /www/ {
        root /data/;
        index index.html index.htm;
  }
}
```


## 九、Nginx配置实例 - 高可用集群

1. 概述
当Nginx主服务器宕机之后使用备用服务器，保证服务的高可用性，思想如图：

2. 步骤分析
(1) 需要两台Nginx服务器 (即两台Linux虚拟机)，地址分别为192.168.17.129和192.168.17.131

(2) 在两台虚拟机中安装Nginx

(3) 在主服务器中安装keepalived

i. 进入usr目录，cd /usr/

ii. 安装需要的环境

1. wget http://www.percona.com/redir/downloads/Percona-XtraDB-Cluster/5.5.37-25.10/RPM/rhel6/x86_64/Percona-XtraDB-Cluster-shared-55-5.5.37-25.10.756.el6.x86_64.rpm

2. rpm -ivh Percona-XtraDB-Cluster-shared-55-5.5.37-25.10.756.el6.x86_64.rpm
iii. 使用yum指令进行安装，yum install keepalived -y

iv. 安装之后在/etc中生成目录keepalived，其中有配置文件keepalived.conf

(4) 删除原本的配置文件，rm -rf /etc/keepalived/keepalived.conf

(5) 使用新的配置文件keepalived.conf替换，内容如下：

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   #邮件服务器通知地址（暂不配置，默认即可，默认是当前虚拟机的ip地址）
   smtp_server 192.168.17.129
   #邮件服务器超时时间（暂不配置，默认即可）
   smtp_connect_timeout 30
   #当前虚拟机的IP地址
   router_id 192.168.17.129
}

vrrp_script Monitor_Nginx {
 script "/etc/keepalived/nginx_check.sh"    #检测脚本执行的路径
 interval 2                             #检测脚本执行的间隔
 weight 2                              #检测脚本执行的权重
}

vrrp_instance VI_1 {
    state MASTER       # 标识这个机器是MASTER(主服务器)还是BACKUP(备服务器)
    interface ens33      # 当前机器的网卡名称  
    virtual_router_id 51  # 虚拟路由的编号，主备必须一致
    priority 100         # 主、备机取不同的优先级，主机值较大，备份机值较小
    advert_int 1         # VRRP Multicast广播周期秒数，即每隔一秒检测是否宕机
    authentication {
        auth_type PASS   #(VRRP认证方式)
        auth_pass 1111   #(密码)
    }
    track_script {
		Monitor_Nginx # 调用nginx进程检测脚本
	}
    virtual_ipaddress {
        192.168.17.50  # 给两台Nginx服务器绑定的虚拟ip地址
    }
}

(6) 新增keepalived的检测脚本，vim /etc/keepalived/nginx_check.sh

#!/bin/bash
if [ "$(ps -ef | grep "nginx: master process" | grep -v grep )" == "" ]
 then
 killall keepalived
fi
(7) 启动keepalived服务，service keepalived start

(8) 在另一台Linux系统中安装Nginx备服务器和keepalived，步骤如上所述，但在keepalived 的配置文件中需要对上述内容的红色部分进行修改

3. 运行结果
浏览器输入虚拟ip地址192.168.17.50，可访问到主服务器中，kill主服务器的Nginx进程，此 虚拟ip地址会访问到备服务器中

十、Nginx原理分析
查看Nginx的进程会发现有worker和master两种进程

工作的线程模型如图所示：

工作原理如图所示：

使用一个master和多个worker的好处：

利于热部署：抢到请求的worker会执行任务，其余空闲worker会更新配置文件，当执行任 务的worker任务结束之后也会自动的更新配置文件信息

每个worker是独立的进程，如果其中一个worker出现问题，不会影响到其他worker

三个常见问题：

设置多少个worker合适？
答：worker数和服务器的cpu数相同最为适宜，在Nginx的配置文件的全局块中修改

一个请求会占用某个worker的几个连接数？
答：
(1) 如果只是静态资源，会占用2个连接数 (接收和返回两个连接数)

(2) 如果Nginx作为代理服务器使用Tomcat处理动态资源，会占用4个连接数

如何计算Nginx最大的并发数？
答：
(1) 如果只是静态资源，最大并发数 = worker个数 * 每个worker的最大连接数 / 2

(2) 如果Nginx作为代理服务器使用Tomcat处理动态资源，
最大并发数 = worker个数 * 每个worker的最大连接数 / 4
————————————————
版权声明：本文为CSDN博主「[Arcadian]」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/weixin_49343190/article/details/112006564