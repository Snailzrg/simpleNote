# 	1:远程调试

> 部署远程服务机器
> a) 新增jvm启动参数：-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4001
> 参数说明：transport=dt_socket 表示使用socket通信协议
> server=y 表示该JVM用于调试
> suspend=n 表示JVM 立即执行，不要等待调试者连接
> address=1601 连接的端口（PS：此端口不要与tomcat启动端口重复）

`java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4001 demo-0.0.1-SNAPSHOT.jar `

![image-20210324165350126](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/image-20210324165350126.png)

