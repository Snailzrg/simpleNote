[toc]

# 常见docker镜像

> 常见docker镜像映射本机器端口 映射文件等
>
> https://blog.csdn.net/qq_37740841/article/details/105255791
>
> https://zhuanlan.zhihu.com/p/112360774
>
> https://www.sqlsec.com/2020/11/docker4.html

## 2 docker安装jenkins
> docker pull jenkins/jenkins:lts;
> mkdir /home/jenkins_home;
> docker run -d --name jenkins_01 -p 8080:8080 -v /home/jenkins_01:/home/jenkins_01 jenkins/jenkins:lts ;
> docker exec -it jenkins_01 bash；
> cat /var/jenkins_home/secrets/initialAdminPassword

## 3 docker安装nginx
> docker pull nginx:latest
> docker run --name nginx-test -p 8080:80 -d nginx

### 3.1:ngnix配置主从

- vi /root/data/docker/nginx/nginx01.conf

  >user  nginx;
  >worker_processes  1;
  >
  >error_log  /var/log/nginx/error.log warn;
  >pid        /var/run/nginx.pid;
  >
  >events {
  >    worker_connections  1024;
  >}
  >
  >http {
  >    include       /etc/nginx/mime.types;
  >    default_type  application/octet-stream;
  >
  >    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  >                      '$status $body_bytes_sent "$http_referer" '
  >                      '"$http_user_agent" "$http_x_forwarded_for"';
  >    
  >    access_log  /var/log/nginx/access.log  main;
  >    
  >    sendfile        on;
  >    #tcp_nopush     on;
  >    
  >    keepalive_timeout  65;
  >    
  >    #gzip  on;
  >    
  >    proxy_redirect          off;
  >    proxy_set_header        Host $host;
  >    proxy_set_header        X-Real-IP $remote_addr;
  >    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
  >    client_max_body_size    10m;
  >    client_body_buffer_size   128k;
  >    proxy_connect_timeout   5s;
  >    proxy_send_timeout      5s;
  >    proxy_read_timeout      5s;
  >    proxy_buffer_size        4k;
  >    proxy_buffers           4 32k;
  >    proxy_busy_buffers_size  64k;
  >    proxy_temp_file_write_size 64k;
  >    
  >    upstream tomcat {
  >    	server 192.168.225.161:8080;
  >    	server 1192.168.225.161:8081;
  >    	server 192.168.225.161:8082;
  >    }
  >    server {
  >        listen       5050;
  >        server_name  192.168.225.161;
  >        location / {
  >            proxy_pass   http://tomcat;
  >            index  index.html index.htm;
  >        }
  >    }
  >}

docker run -d --net=host -v /root/data/docker/nginx/nginx01.conf:/etc/nginx/nginx.conf --name=n1 --privileged nginx 



- vi /root/data/docker/nginx/nginx02.conf

> user  nginx;
> worker_processes  1;
>
> error_log  /var/log/nginx/error.log warn;
> pid        /var/run/nginx.pid;
>
> events {
>     worker_connections  1024;
> }
>
> http {
>     include       /etc/nginx/mime.types;
>     default_type  application/octet-stream;
>
>     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
>                       '$status $body_bytes_sent "$http_referer" '
>                       '"$http_user_agent" "$http_x_forwarded_for"';
>     
>     access_log  /var/log/nginx/access.log  main;
>     
>     sendfile        on;
>     #tcp_nopush     on;
>     
>     keepalive_timeout  65;
>     
>     #gzip  on;
>     
>     proxy_redirect          off;
>     proxy_set_header        Host $host;
>     proxy_set_header        X-Real-IP $remote_addr;
>     proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
>     client_max_body_size    10m;
>     client_body_buffer_size   128k;
>     proxy_connect_timeout   5s;
>     proxy_send_timeout      5s;
>     proxy_read_timeout      5s;
>     proxy_buffer_size        4k;
>     proxy_buffers           4 32k;
>     proxy_busy_buffers_size  64k;
>     proxy_temp_file_write_size 64k;
>     
>     upstream tomcat {
>     	server 192.168.225.161:8080;
>     	server 192.168.225.161:8081;
>     	server 192.168.225.161:8082;
>     }
>     server {
>         listen       5051;
>         server_name  192.168.225.161;
>         location / {
>             proxy_pass   http://tomcat;
>             index  index.html index.htm;
>         }
>     }
> }

docker run -d --net=host -v /root/data/docker/nginx/nginx02.conf:/etc/nginx/nginx.conf --name=n2 --privileged nginx 

- 虚拟ip: `192.168.225.161`
- nginx主机ip: `192.168.225.161:5050`
- nginx备机ip: `192.168.225.161:5051`



- 配置主机
进入 docker 容器虚拟机
docker exec -it n1 bash

更新下apt
apt update

下载 keepalived
apt-get install keepalived -y

下载 vim
apt-get install vim -y

修改keepalived配置
vi /etc/keepalived/keepalived.conf

写入配置

>global_defs {
>
>#路由id：当前安装keepalived的节点主机标识符，保证全局唯一
>
>   router_id keep_104
>}
>
>vrrp_instance VI_1 {
>
>#表示状态是MASTER主机还是备用机BACKUP
>
>​    state MASTER
>
>#该实例绑定的网卡名称
>
>​    interface ens33
>
>#保证主备节点一致即可
>
>​    virtual_router_id 51
>
>#权重，master权重一般高于backup，如果有多个，那就是选举，谁的权重高，谁就当选
>
>​    priority 100
>
>主备之间同步检查时间间隔，单位秒#
>
>​    advert_int 2
>
>#认证权限密码，防止非法节点进入
>
>​    authentication {
>​        auth_type PASS
>​        auth_pass 123456
>​    }
>
>#虚拟出来的ip，可以有多个（vip）
>
>​    virtual_ipaddress {
>​        192.168.225.198
>​    }
>}
>
>virtual_server 192.168.225.198 5000 {
>    delay_loop 3
>    lb_algo rr
>    lb_kind NAT
>    persistence_timeout 50
>    protocol TCP
>    real_server 192.168.225.161 5050 {
>        weight 1
>    }
>}

- 启动`keepalived`

```shell
root@centOS:/# service keepalived start
[ ok ] Starting keepalived: keepalived.

12
```



配置备机
进入 docker 容器虚拟机
docker exec -it n2 bash

更新下apt
apt update

下载 keepalived
apt-get install keepalived -y

下载 vim
apt-get install vim -y

修改keepalived配置
vi /etc/keepalived/keepalived.conf

> global_defs {
>    router_id keep_105
> }
>
> vrrp_instance VI_1 {
> #备用机设置为BACKUP
>     state BACKUP
>     interface ens33
>     virtual_router_id 51
>
> #权重低于MASTER
>
> ​    priority 80
> ​    advert_int 2
> ​    authentication {
> ​        auth_type PASS
> ​        auth_pass 123456
> ​    }
> ​    virtual_ipaddress {
>
> #注意：主备两台的vip都是一样的，绑定到同一个vip
>
> ​        192.168.225.198
> ​    }
> }
>
> virtual_server 192.168.225.198 5000 {
>     delay_loop 3
>     lb_algo rr
>     lb_kind NAT
>     persistence_timeout 50
>     protocol TCP
>     real_server 192.168.225.161 5051 {
>         weight 1
>     }
> }


启动keepalived
root@centOS:/# service keepalived start
[ ok ] Starting keepalived: keepalived.
记得退出
exit

## 4 docker安装redis

> docker pull redis:latest
> docker run -itd --name redis-test -p 6379:6379 redis
>
> ```text
> docker run --name redis-single -p 6379:6379 -d redis --requirepass "123456"
> docker exec -it redis-single /bin/bash
> ```

![image-20210413095652420](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210413095652420.png)



## 5 docker安装rabbitMQ

> docker pull rabbitmq:3.7.7-management
> docker run -d --name rabbitmq3.7.7 -p 5672:5672 -p 15672:15672 -v `pwd`/data:/var/lib/rabbitmq --hostname myRabbit -e RABBITMQ_DEFAULT_VHOST=my_vhost  -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin rabbitmq:3.7.7-management



## 6 docker安装activeMQ

>docker pull rmohr/activemq   
>
>docker run -p 61616:61616 -p 8161:8161 rmohr/activemq
>
>一般是端口映射====

