# start
基础：https://blog.csdn.net/u013123635/article/details/78362360/
https://www.cnblogs.com/zhuxiaojie/p/5564187.html

mq
https://blog.csdn.net/echojson/article/details/79702829


/***
*
*/

jMQ的两种消息模式

   消息列队有两种消息模式，一种是点对点的消息模式，还有一种就是订阅的模式.
       点对点的模式主要建立在一个队列上面，当连接一个列队的时候，发送端不需要知道接收端是否正在接收，可以直接向ActiveMQ发送消息，发送的消息，将会先进入队列中，如果有接收端在监听，则会发向接收端，如果没有接收端接收，则会保存在activemq服务器，直到接收端接收消息，点对点的消息模式可以有多个发送端，多个接收端，但是一条消息，只会被一个接收端给接收到，哪个接收端先连上ActiveMQ，则会先接收到，而后来的接收端则接收不到那条消息
 
**ActiveMQ主要涉及到5个方面：**
    1. 传输协议：消息之间的传递，无疑需要协议进行沟通，启动一个ActiveMQ打开了一个监听端口， ActiveMQ提供了广泛的连接模式，其中主要包括SSL、STOMP、XMPP；ActiveMQ默认的使用的协议是openWire，端口号：61616;
    2. 消息域：ActiveMQ主要包含Point-to-Point (点对点),Publish/Subscribe Model (发布/订阅者)，其中在Publich/Subscribe 模式下又有Nondurable subscription和durable subscription (持久化订阅)2种消息处理方式
    3. 消息存储：在消息传递过程中，部分重要的消息可能需要存储到数据库或文件系统中，当中介崩溃时，信息不回丢失
    4. Cluster  (集群): 最常见到 集群方式包括network of brokers和Master Slave；
    5. Monitor (监控) :ActiveMQ一般由jmx来进行监控

    默认配置下的ActiveMQ只适合学习代码而不适用于实际生产环境，ActiveMQ的性能需要通过配置挖掘，其性能提高包括代码级性能、规则性能、存储性能、网络性能以及多节点协同方法（集群方案），所以我们优化ActiveMQ的中心思路也是这样的：

1. 优化ActiveMQ单个节点的性能，包括NIO模型选择和存储选择。
2. 配置ActiveMQ的集群（ActiveMQ的高性能和高可用需要通过集群表现出来）。
四、ActiveMQ的通信方式

1. 点对点（p2p）
点对点模式下一条消息将会发送给一个消息消费者，如果当前Queue没有消息消费者，消息将进行存储。
![](_v_images/1542961822_26814.jpg)


































作者：echojson 
来源：CSDN 
原文：https://blog.csdn.net/echojson/article/details/79702829 
版权声明：本文为博主原创文章，转载请附上博文链