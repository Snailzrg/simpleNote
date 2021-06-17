# 	1:远程调试

> 部署远程服务机器
> a) 新增jvm启动参数：-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4001
> 参数说明：transport=dt_socket 表示使用socket通信协议
> server=y 表示该JVM用于调试
> suspend=n 表示JVM 立即执行，不要等待调试者连接
> address=1601 连接的端口（PS：此端口不要与tomcat启动端口重复）
>
> `java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4001 demo-0.0.1-SNAPSHOT.jar `

![image-20210324165350126](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210324165350126.png)

 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005  

几点说明：

-agentlib:jdwp 这个是jdk自带的调试工具是jti,位于$JAVA_HOME/jre/lib/amd64/libjdwp.so,后面的均是它的参数

suspend=n 表示程序启动时不挂起，直接运行，与之相反的就是程序启动后需要远程断点调试也启动后程序才会运行。

address=5005 表示程序的远程调试监听端口




nohup java -jar /root/data/snailwork/eureka-server-0.0.1-SNAPSHOT.jar  >/root/data/snailwork/logs/eureka-server.log &

nohup java -jar  -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005  

eureka-user-0.0.1-SNAPSHOT.jar  >/root/data/snailwork/logs/eureka-user.log &
