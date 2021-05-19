[toc]

本篇文章是[《Java内存故障？只是因为你不够帅！》](https://mp.weixin.qq.com/s/MAebo8x356IMlASocxPqRw) 这篇文章的续篇。上篇侧重于理论，本篇侧重于实践。对于内存问题排查来说，搞理论的痛苦，搞实践的也痛苦，没有一片清净之地。

why？因为内存溢出是Java码农永远的伤。

溢出有很多种解释，有精满自溢，有缓冲区溢出攻击，还有另外一种叫做领导的溢出。不知道什么叫作**溢出理论**，xjjdog在此普及一下。 

[《领导看了会炸毛的溢出理论》](http://mp.weixin.qq.com/s?__biz=MzA4MTc4NTUxNQ==&mid=2650520353&idx=1&sn=2fd5f0eee8eaf5e2025f7b2e57609b49&chksm=8780bce5b0f735f314775b17895ebe3429c26b1197573450cdd8032bccab70428d3cca061120&scene=21#wechat_redirect)  

## 内存溢出什么最重要？

其实，内存溢出就像是一场交通事故。事故的发生方，就是具体的服务；事故的处理方，就是相关的程序员。其中有一个最重要的环节，就是在事故现场需要拍照取证。

如果没有照片没有行车记录仪没有证据，就只能靠那张嘴，怎么说都是不可信的。

**这句话很重要很重要：内存问题排查什么最重要？当然是信息收集，留下一些为我们的排查提供支持的依据。**千万不要舍本逐末，对内存问题排查本身感兴趣，那是自虐行为。

有很多工具可以帮助我们定位问题，但前提是你得把它留下来。下面这篇文章是xjjdog很久之前留下来的，由于标题的缘故，你可能忽略了，但这些工具能够快速帮我们定位问题。

[《将java进程转移到“解剖台”之前，法医都干了什么？》](http://mp.weixin.qq.com/s?__biz=MzA4MTc4NTUxNQ==&mid=2650520084&idx=1&sn=b2ca0a4355f83b304715f24113e155a1&chksm=8780bdd0b0f734c6cdf898f9c11e024d3c141e58fa45ddfb36aa3f320eb38b22674aabbe9432&scene=21#wechat_redirect)

 

![img](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc6e35f37c9643508358511f04654ef1~tplv-k3u1fbpfcp-zoom-1.image)



```bash
ss -antp > $DUMP_DIR/ss.dump 2>&1
netstat -s > $DUMP_DIR/netstat-s.dump 2>&1
top -Hp $PID -b -n 1 -c >  $DUMP_DIR/top-$PID.dump 2>&1
sar -n DEV 1 2 > $DUMP_DIR/sar-traffic.dump 2>&1
lsof -p $PID > $DUMP_DIR/lsof-$PID.dump
iostat -x > $DUMP_DIR/iostat.dump 2>&1
free -h > $DUMP_DIR/free.dump 2>&1
jstat -gcutil $PID > $DUMP_DIR/jstat-gcutil.dump 2>&1
jstack $PID > $DUMP_DIR/jstack.dump 2>&1
jmap -histo $PID > $DUMP_DIR/jmap-histo.dump 2>&1
jmap -dump:format=b,file=$DUMP_DIR/heap.bin $PID > /dev/null  2>&1
复制代码
```

## GC日志配置

但并不是每次出现故障，你都在机器的身边。靠人工也不能保证实时性。所以，强烈建议你把GC日志输出的详细一些，那么出现问题的时候就舒坦一些。

**实际上，这个要求在我看来是强制的。**

很多同学上来就说，**我的内存溢出了**。但你和它要一些日志信息，要堆栈，要现场保存的快照。都没有。这就是纯粹来搞笑的。

下面是JDK8或者以下的GC日志参数，可以看到还是很长的。

```bash
#!/bin/sh
LOG_DIR="/tmp/logs"
JAVA_OPT_LOG=" -verbose:gc"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -XX:+PrintGCDetails"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -XX:+PrintGCDateStamps"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -XX:+PrintGCApplicationStoppedTime"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -XX:+PrintTenuringDistribution"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -Xloggc:${LOG_DIR}/gc_%p.log"

JAVA_OPT_OOM=" -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_DIR} -XX:ErrorFile=${LOG_DIR}/hs_error_pid%p.log "

JAVA_OPT="${JAVA_OPT_LOG} ${JAVA_OPT_OOM}"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"
复制代码
```

下面是JDK9及其以上的日志配置。可以看到它的配置方式全变了，而且不向下兼容。Java搞的这个变化还是挺蛋疼的。

```bash
#!/bin/sh

LOG_DIR="/tmp/logs"
JAVA_OPT_LOG=" -verbose:gc"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -Xlog:gc,gc+ref=debug,gc+heap=debug,gc+age=trace:file=${LOG_DIR}/gc_%p.log:tags,uptime,time,level"
JAVA_OPT_LOG="${JAVA_OPT_LOG} -Xlog:safepoint:file=${LOG_DIR}/safepoint_%p.log:tags,uptime,time,level"

JAVA_OPT_OOM=" -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_DIR} -XX:ErrorFile=${LOG_DIR}/hs_error_pid%p.log "

JAVA_OPT="${JAVA_OPT_LOG} ${JAVA_OPT_OOM}"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"

echo $JAVA_OPT
复制代码
```

一旦发现了问题，就可以拿GC日志来快速定位堆内问题。但是并不是让你一行行去看，那太低效了。因为日志可能会很长很长，而且也不一定看得懂。这个时候，就可以使用一些在线工具辅助解决。我经常使用的是gceasy，下面是它的一张截图。

```java
http://gceasy.io
复制代码
```



![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bbcdde51705b45139ad798f2d9e6824a~tplv-k3u1fbpfcp-zoom-1.image)



有了GC日志还不行，因为它仅仅是记录了堆空间的一些变化，至于操作系统的一些资源变动，它是无从知晓的。所以，如果你有一个监控系统的话，在寻找问题的时候也能帮到忙。从下图可以看到系统资源的一些变动。



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



## 溢出示例

### 堆溢出

代码。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



日志。

```bash
java -Xmx20m -Xmn4m -XX:+HeapDumpOnOutOfMemoryError - OOMTest
[18.386s][info][gc] GC(10) Concurrent Mark 5.435ms
[18.395s][info][gc] GC(12) Pause Full (Allocation Failure) 18M->18M(19M) 10.572ms
[18.400s][info][gc] GC(13) Pause Full (Allocation Failure) 18M->18M(19M) 5.348ms
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
    at OldOOM.main(OldOOM.java:20)
复制代码
```

jvisualvm的反应。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



### 元空间溢出

代码。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



日志。

```bash
java -Xmx20m -Xmn4m -XX:+HeapDumpOnOutOfMemoryError -XX:MetaspaceSize=16M -XX:MaxMetaspaceSize=16M MetaspaceOOMTest
6.556s][info][gc] GC(30) Concurrent Cycle 46.668ms
java.lang.OutOfMemoryError: Metaspace
Dumping heap to /tmp/logs/java_pid36723.hprof ..
复制代码
```

jvisualvm的反应。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



### 直接内存溢出

代码。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



日志。

```bash
java -XX:MaxDirectMemorySize=10M -Xmx10M OffHeapOOMTest
Exception in thread "Thread-2" java.lang.OutOfMemoryError: Direct buffer memory
    at java.nio.Bits.reserveMemory(Bits.java:694)
    at java.nio.DirectByteBuffer.<init>(DirectByteBuffer.java:123)
    at java.nio.ByteBuffer.allocateDirect(ByteBuffer.java:311)
    at OffHeapOOMTest.oom(OffHeapOOMTest.java:27)...
复制代码
```

### 栈溢出

代码。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



日志。

```bash
java -Xss128K StackOverflowTest
Exception in thread "main" java.lang.StackOverflowError
    at java.io.PrintStream.write(PrintStream.java:526)
    at java.io.PrintStream.print(PrintStream.java:597)
    at java.io.PrintStream.println(PrintStream.java:736)
    at StackOverflowTest.a(StackOverflowTest.java:5)
复制代码
```

## 哪些代码容易出现问题

### 忘记重写hashCode和equals

看下面的代码。由于没有重写Key类的hashCode和equals方法。造成了放入HashMap的所有对象，都无法被取出来。它们和外界失联了。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



下面这篇文章详细的描述了它的原理。 [架构师写的BUG，非比寻常](https://mp.weixin.qq.com/s/BBJKJXE7dFaGn5n7BAwHTQ)

### 结果集失控



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)

不要觉得这段代码可笑。在实际工作中的review中，xjjdog不止一次发现这种蛋疼的代码。这有可能是赶工期，也有可能是刚学会写Java。这行代码有很大的可能性踩坑。



### 条件失控

代码。与之类似的就是条件失控，当某个条件不满足的时候，将会造成结果集的失控。大家可以看下面的代码，fullname 和 other为空的时候，会出现什么后果？

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



### 万能参数

还有的同学使用各种Object和HashMap来进行信息交换。这种代码正常运行的时候没什么问题，但一旦出错，几乎无法排查。排查参数、排查堆栈、排查调用链，全部失效。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



### 一些预防的措施

- 减少创建大对象的频率：比如byte数组的传递
- 不要缓存太多的堆内数据：使用guava的weak引用模式
- 查询的范围一定要可控：如分库分表中间件；ES等有同样问题
- 用完的资源一定要close掉：可以使用新的 try-with-resources语法
- 少用intern：字符串太长，且无法复用，就会造成内存泄漏
- 合理的Session超时时间
- 少用第三方本地代码，使用Java方案替代
- 合理的池大小
- XML（SAX/DOM）、JSON解析要注意对象大小

## 案例分析一

这是最常见的一种情况。了解了这种方式，能够应对大多数内存溢出和内存泄漏问题。

### 现象

- 环境：CentOS7，JDK1.8，SpringBoot
- G1垃圾回收器
- 刚启动没什么问题，慢慢放量后，发生了OOM
- 系统自动生成了heapdump文件
- 临时解决方式：重启，但问题依然发现

### 信息收集

- 日志：GC的日志信息： 内存突增突降，变动迅速
- 堆栈：Thread Dump文件：大部分阻塞在某个方法上
- 压测：使用wrk进行压测，发现20个用户并发，内存溢出

```bash
wrk -t20 -c20 -d300s http://127.0.0.1:8084/api/test
复制代码
```

### MAT分析

堆栈文件获取：

```bash
jmap -dump:format=b,file=heap.bin 37340
jhsdb jmap  --binaryheap --pid  37340
复制代码
```

MAT工具是基于eclipse平台开发的，本身是一个Java程序。分析Heap Dump文件：发现内存创建了大量的报表对象。

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



通过菜单Find Leaks，一键找出黑李逵。



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)

根据提示向下挖就可以。



### 解决

分析结果：

- 系统存在大数据量查询服务，并在内存做合并
- 当并发量达到一定程度，会有大量数据堆积到内存进行运算

解决方式：

- 重构查询服务，减少查询的字段
- 使用SQL查询代替内存拼接，避免对结果集的操作
- 举例：查找两个列表的交集

## 案例分析二

### 现象

- 环境：CentOS7，JDK1.8，JBoss
- CMS垃圾回收器
- 操作系统CPU资源耗尽
- 访问任何接口，响应都非常的慢

### 分析

- 发现每次GC的效果都特别好，但是非常频繁
- 了解到使用了堆内缓存，而且设置的容量比较大
- 缓存填充的速度特别快！

结论：

- 开了非常大的缓存，GC之后迅速占满，造成GC频繁

## 案例分析三

### 现象

- java进程异常退出
- java进程直接消失
- 没有留下dump文件
- GC日志正常
- 监控发现死亡时，堆内内存占用很少，堆内仍有大量剩余空间

### 分析

- XX:+HeapDumpOnOutOfMemoryError不起作用
- 监控发现操作系统内存持续增加

下面这些情况都会造成程序退出而没什么响应。

- 被操作系统杀死 dmesg oom-killer
- System.exit()
- java  com.cn.AA & 后终端关闭
- kill -9

### 解决

发现：

- 在dmesg命令中发现确实被oom-kill

解决：

- 给JVM少分配一些内存，腾出空间给其他进程

## 案例分析四

请参见堆外内存排查这篇文章。 [《Java堆外内存排查小结》](https://mp.weixin.qq.com/s/p0cQeDLm3A-C0gGQ3aBp1Q) 

## End



![img](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e98d5708e0d452dbf0d6ae757cc02e9~tplv-k3u1fbpfcp-zoom-1.image)



最后，还是以下面这张图作为小结。实践知识永远逃不出理论的支持，没有了实践的巩固理论也就变成没有灵魂的躯体。Java内存问题永远都逃不出下面这张图，就像计算机永远都逃不出0和1。


作者：小姐姐味道
链接：https://juejin.im/post/6859522939302346766
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。