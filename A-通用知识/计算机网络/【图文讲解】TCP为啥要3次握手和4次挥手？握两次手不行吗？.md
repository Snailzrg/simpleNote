## 【图文讲解】TCP为啥要3次握手和4次挥手？握两次手不行吗？

点击关注 👉 [Java基基](javascript:void(0);) *今天*

点击上方“Java基基”，选择“设为星标”

做积极的人，而不是积极废人！

源码精品专栏

- [原创 | Java 2020 超神之路，很肝~](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&chksm=fa496f8ecd3ee698f4954c00efb80fe955ec9198fff3ef4011e331aa37f55a6a17bc8c0335a8&scene=21#wechat_redirect)
- [中文详细注释的开源项目](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486264&idx=1&sn=475ac3f1ef253a33daacf50477203c80&chksm=fa497489cd3efd9f7298f5da6aad0c443ae15f398436aff57cb2b734d6689e62ab43ae7857ac&scene=21#wechat_redirect)
- [RPC 框架 Dubbo 源码解析](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247484647&idx=1&sn=9eb7e47d06faca20d530c70eec3b8d5c&chksm=fa497b56cd3ef2408f807e66e0903a5d16fbed149ef7374021302901d6e0260ad717d903e8d4&scene=21#wechat_redirect)
- [网络应用框架 Netty 源码解析](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247485054&idx=2&sn=9f3b85f7b8454634da6c5c2ded9b4dba&chksm=fa4979cfcd3ef0d9d2dd92d8d1bd8f1553abc6e2095a5d743e0b2c2afe4955ea2bbbd7a4b79d&token=55862109&lang=zh_CN&scene=21#wechat_redirect)
- [消息中间件 RocketMQ 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486256&idx=1&sn=81daccd3fcd2953456c917630636fb26&chksm=fa497481cd3efd97d9239f5eab060e49dea9876a6046eadba0effb878d2fb51f3ba5733e4c0b&scene=21#wechat_redirect)
- [数据库中间件 Sharding-JDBC 和 MyCAT 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486257&idx=1&sn=4d3c9c675f8833157641a2e0b48e498c&chksm=fa497480cd3efd96fe17975b0b8b141e87fd0a62673e6a30b501460de80b3eb997056f09de08&scene=21#wechat_redirect)
- [作业调度中间件 Elastic-Job 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486258&idx=1&sn=ae5665ae9c3002b53f87cab44948a096&chksm=fa497483cd3efd950514da5a37160e7fd07f0a96f39265cf7ba3721985e5aadbdcbe7aafc34a&scene=21#wechat_redirect)
- [分布式事务中间件 TCC-Transaction 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486259&idx=1&sn=b023cf3dbf97e5da59db2f4ee632f5a6&chksm=fa497482cd3efd9402d71469f71863f71a6998b27e12ca2e00446b8178d79dcef0721d8e570a&scene=21#wechat_redirect)
- [Eureka 和 Hystrix 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486260&idx=1&sn=8f14c0c191d6f8df6eb34202f4ad9708&chksm=fa497485cd3efd93937143a648bc1b530bc7d1f6f8ad4bf2ec112ffe34dee80b474605c22db0&scene=21#wechat_redirect)
- [Java 并发源码](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486261&idx=1&sn=bd69f26aadfc826f6313ffbb95e44ee5&chksm=fa497484cd3efd92352d6fb3d05ccbaebca2fafed6f18edbe5be70c99ba088db5c8a7a8080c1&scene=21#wechat_redirect)

来源：cnblogs.com/qdhxhz/p/8470997.html

- 一、TCP三次握手
- 二、TCP数据的传输过程
- 三、TCP的四次挥手
- 四、SYN（洪水）攻击
- 五、TCP和UDP的区别

------

TCP有6种标示:SYN(建立联机) ACK(确认) PSH(传送) FIN(结束) RST(重置) URG(紧急)

# 一、TCP三次握手

## 第一次握手

![img](https://mmbiz.qpic.cn/mmbiz_png/6mychickmupVXzx3HZYW1iaq6ibviabsHJX99NULzqCNp5NFzwibIHulMVGZK9Nd0DttrMZ7mNhoPoXOnYtwMVYNqoQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

客户端向服务器发出连接请求报文，这时报文首部中的同部位SYN=1，同时随机生成初始序列号 seq=x

此时，TCP客户端进程进入了 SYN-SENT（同步已发送状态）状态。TCP规定，SYN报文段（SYN=1的报文段）不能携带数据，但需要消耗掉一个序号。

这个三次握手中的开始。表示客户端想要和服务端建立连接。

## 第二次握手

TCP服务器收到请求报文后，如果同意连接，则发出确认报文。确认报文中应该 ACK=1，SYN=1，确认号是ack=x+1，同时也要为自己随机初始化一个序列号 seq=y

此时，TCP服务器进程进入了SYN-RCVD（同步收到）状态。这个报文也不能携带数据，但是同样要消耗一个序号。这个报文带有SYN(建立连接)和ACK(确认)标志，询问客户端是否准备好。

## 第三次握手

TCP客户进程收到确认后，还要向服务器给出确认。确认报文的ACK=1，ack=y+1，此时，TCP连接建立，客户端进入ESTABLISHED（已建立连接）状态。

TCP规定，ACK报文段可以携带数据，但是如果不携带数据则不消耗序号。这里客户端表示我已经准备好。

> 思考：为什么要三次握手呢，有人说两次握手就好了

**举例：已失效的连接请求报文段。**

client发送了第一个连接的请求报文，但是由于网络不好，这个请求没有立即到达服务端，而是在某个网络节点中滞留了，直到某个时间才到达server

本来这已经是一个失效的报文，但是server端接收到这个请求报文后，还是会想client发出确认的报文，表示同意连接。

假如不采用三次握手，那么只要server发出确认，新的建立就连接了，但其实这个请求是失效的请求，client是不会理睬server的确认信息，也不会向服务端发送确认的请求

但是server认为新的连接已经建立起来了，并一直等待client发来数据，这样，server的很多资源就没白白浪费掉了

**采用三次握手就是为了防止这种情况的发生，server会因为收不到确认的报文，就知道client并没有建立连接。这就是三次握手的作用。**

# 二、TCP数据的传输过程

建立连接后，两台主机就可以相互传输数据了。如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/6mychickmupVXzx3HZYW1iaq6ibviabsHJX93ehic6Xq3CUE0toJ0x9MO6kn9C5B5tbtoJMOSoFMoZyUH1Yrndbq7Xg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

**1）** 主机A初始seq为1200,滑动窗体为100,向主机B传递数据的过程。

**2）** 假设主机B在完全成功接收数据的基础上,那么主机B为了确认这一点，向主机A发送 ACK 包，并将 Ack 号设置为 1301。因此按如下的公式确认 Ack 号：

`Ack号 = Seq号 + 传递的字节数 + 1`（这是在完全接受成功的情况下）

**3）** 主机A获得B传来的ack(1301)后,开始发送seq为1301,滑动窗体为100的数据。……

与三次握手协议相同，最后加 1 是为了告诉对方要传递的 Seq 号。上面说了，主机B完全成功接收A发来的数据才是这样的,如果存在丢包该如何。

下面分析传输过程中数据包丢失的情况，如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/6mychickmupVXzx3HZYW1iaq6ibviabsHJX9kCaoAPbOM3uvpo2qTOY7f0kTsEwj7VH87b5ibSibO31ltos82sEC0neQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上图表示通过 Seq 1301 数据包向主机B传递100字节的数据，但中间发生了错误，主机B未收到。

经过一段时间后，主机A仍未收到对于 Seq 1301 的ACK确认，因此尝试重传数据。

为了完成数据包的重传，TCP套接字每次发送数据包时都会启动定时器，如果在一定时间内没有收到目标机器传回的 ACK 包，那么定时器超时，数据包会重传。

上面也只是一种可能,比如数据1250丢失,那么Ack返回的就是1250,具体的可以详细看下博客：

> https://www.cnblogs.com/qdhxhz/p/10267932.html

# 三、TCP的四次挥手

![img](https://mmbiz.qpic.cn/mmbiz_jpg/6mychickmupVXzx3HZYW1iaq6ibviabsHJX9ccSndt5z8vkxwLzSvqZImExlTK8LiaapOQeRXzfK7fdJXH9rsMkCzPA/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 第一次挥手

TCP发送一个FIN(结束)，用来关闭客户到服务端的连接。客户端进程发出连接释放报文，并且停止发送数据。

释放数据报文首部，FIN=1，其序列号为seq=u（等于前面已经传送过来的数据的最后一个字节的序号加1），此时，客户端进入FIN-WAIT-1（终止等待1）状态。TCP规定，FIN报文段即使不携带数据，也要消耗一个序号。

## 第二次挥手

服务端收到这个FIN，他发回一个ACK(确认)，确认收到序号为收到序号+1，和SYN一样，一个FIN将占用一个序号。

服务器收到连接释放报文，发出确认报文，ACK=1，ack=u+1，并且带上自己的序列号seq=v，此时，服务端就进入了CLOSE-WAIT（关闭等待）状态。

TCP服务器通知高层的应用进程，客户端向服务器的方向就释放了，这时候处于半关闭状态，即客户端已经没有数据要发送了，但是服务器若发送数据，客户端依然要接受。

这个状态还要持续一段时间，也就是整个CLOSE-WAIT状态持续的时间。

客户端收到服务器的确认请求后，此时，客户端就进入FIN-WAIT-2（终止等待2）状态，等待服务器发送连接释放报文（在这之前还需要接受服务器发送的最后的数据）。

## 第三次挥手

服务端发送一个FIN(结束)到客户端，服务端关闭客户端的连接。

服务器将最后的数据发送完毕后，就向客户端发送连接释放报文，FIN=1，ack=u+1，由于在半关闭状态，服务器很可能又发送了一些数据

假定此时的序列号为seq=w，此时，服务器就进入了LAST-ACK（最后确认）状态，等待客户端的确认。

## 第四次挥手

客户端发送ACK(确认)报文确认，并将确认的序号+1，这样关闭完成。

客户端收到服务器的连接释放报文后，必须发出确认，ACK=1，ack=w+1，而自己的序列号是seq=u+1，此时，客户端就进入了TIME-WAIT（时间等待）状态。

注意此时TCP连接还没有释放，必须经过2∗∗MSL（最长报文段寿命）的时间后，当客户端撤销相应的TCB后，才进入CLOSED状态。

服务器只要收到了客户端发出的确认，立即进入CLOSED状态。同样，撤销TCB后，就结束了这次的TCP连接。可以看到，服务器结束TCP连接的时间要比客户端早一些。

> 思考：那么为什么是4次挥手呢？

**为了确保数据能够完成传输。**

关闭连接时，当收到对方的FIN报文通知时，它仅仅表示对方没有数据发送给你了；但未必你所有的数据都全部发送给对方了

所以你未必会马上关闭SOCKET,也即你可能还需要发送一些数据给对方之后，再发送FIN报文给对方来表示你同意现在可以关闭连接了，所以它这里的ACK报文和FIN报文多数情况下都是分开发送的。

可能有人会有疑问，**tcp我握手的时候为何ACK(确认)和SYN(建立连接)是一起发送。挥手的时候为什么是分开的时候发送呢？**

因为当Server端收到Client端的SYN连接请求报文后，可以直接发送SYN+ACK报文。其中ACK报文是用来应答的，SYN报文是用来同步的。

但是关闭连接时，当Server端收到FIN报文时，很可能并不会立即关闭 SOCKET，所以只能先回复一个ACK报文，告诉Client端，"你发的FIN报文我收到了"。只有等到我Server端所有的报文都发送完了，我才能发送FIN报文，因此不能一起发送。故需要四步挥手。

> 思考:客户端突然挂掉了怎么办？

正常连接时，客户端突然挂掉了，如果没有措施处理这种情况，那么就会出现客户端和服务器端出现长时期的空闲。

解决办法是在服务器端设置保活计时器，每当服务器收到客户端的消息，就将计时器复位。超时时间通常设置为2小时。

若服务器超过2小时没收到客户的信息，他就发送探测报文段。若发送了10个探测报文段，每一个相隔75秒，还没有响应就认为客户端出了故障，因而终止该连接。

# 四、SYN（洪水）攻击

## 背景

初始化连接的 SYN 超时问题Client发送SYN包给Server后挂了，Server回给Client的SYN-ACK一直没收到Client的ACK确认，这个时候这个连接既没建立起来，也不能算失败。

这就需要一个超时时间让Server将这个连接断开，否则这个连接就会一直占用Server的SYN连接队列中的一个位置，大量这样的连接就会将Server的SYN连接队列耗尽，让正常的连接无法得到处理。

目前，Linux下默认会进行5次重发SYN-ACK包，重试的间隔时间从1s开始，下次的重试间隔时间是前一次的双倍，5次的重试时间间隔为1s, 2s, 4s, 8s, 16s，总共31s，第5次发出后还要等32s都知道第5次也超时了

所以，总共需要 1s + 2s + 4s+ 8s+ 16s + 32s = 63s，TCP才会把断开这个连接。

由于，SYN超时需要63秒，那么就给攻击者一个攻击服务器的机会，攻击者在短时间内发送大量的SYN包给Server(俗称SYN flood攻击)，用于耗尽Server的SYN队列。

## 什么是 SYN 攻击

SYN 攻击指的是，攻击客户端在短时间内伪造大量不存在的IP地址，向服务器不断地发送SYN包，服务器回复确认包，并等待客户的确认。

由于源地址是不存在的，服务器需要不断的重发直至超时，这些伪造的SYN包将长时间占用未连接队列，正常的SYN请求被丢弃，导致目标系统运行缓慢，严重者会引起网络堵塞甚至系统瘫痪。SYN 攻击是一种典型的 DoS攻击。

## 如何检测 SYN 攻击？

检测 SYN 攻击非常的方便，当你在服务器上看到大量的半连接状态时，特别是源IP地址是随机的，基本上可以断定这是一次SYN攻击。在 Linux/Unix 上可以使用系统自带的netstats 命令来检测 SYN 攻击。

## 如何防御 SYN 攻击？

SYN攻击不能完全被阻止，除非将TCP协议重新设计。我们所做的是尽可能的减轻SYN攻击的危害，常见的防御 SYN 攻击的方法有如下几种：

- 缩短超时（SYN Timeout）
- 时间增加最大半连接数
- 过滤网关防护SYN
- cookies技术

# 五、TCP和UDP的区别

我这里简单列举几个，因为我还没有研究UDP这个协议。

**1、** 基于连接与无连接;UDP是无连接的，即发送数据之前不需要建立连接

**2、** TCP保证数据正确性，UDP可能丢包，TCP保证数据顺序，UDP不保证。

也就是说，通过TCP连接传送的数据，无差错，不丢失，不重复，且按序到达;UDP尽最大努力交付，即不保证可靠交付Tcp通过校验和，重传控制，序号标识，滑动窗口、确认应答实现可靠传输。如丢包时的重发控制，还可以对次序乱掉的分包进行顺序控制。

**3、** UDP具有较好的实时性，工作效率比TCP高，适用于对高速传输和实时性有较高的通信或广播通信。

**4、** 每一条TCP连接只能是点到点的;UDP支持一对一，一对多，多对一和多对多的交互通信。

**5、** TCP对系统资源要求较多，UDP对系统资源要求较少。