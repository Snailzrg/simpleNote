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

## 4 docker安装redis
> docker pull redis:latest
> docker run -itd --name redis-test -p 6379:6379 redis

## 5 docker安装rabbitMQ
> docker pull rabbitmq:3.7.7-management
> docker run -d --name rabbitmq3.7.7 -p 5672:5672 -p 15672:15672 -v `pwd`/data:/var/lib/rabbitmq --hostname myRabbit -e RABBITMQ_DEFAULT_VHOST=my_vhost  -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin rabbitmq:3.7.7-management



## 6 docker安装activeMQ

>docker pull rmohr/activemq   
>
>docker run -p 61616:61616 -p 8161:8161 rmohr/activemq
>
>一般是端口映射====

