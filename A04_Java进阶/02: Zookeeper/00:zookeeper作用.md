[toc]



# zookeeper机制

zookeeper=文件系统+通知机制

一、Zookeeper提供了什么

1、文件系统

Zookeeper维护一个类似文件系统的数据结构

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/20141108213344_45-20210513151914510.png)

每个子目录项如NameService都被称为znoed,和文件系统一样，我们能够自由的增加、删除znode,在znode下增加、删除子znode,唯一不同的在于znode是可以存储数据的。

有4种类型的znode

1、PERSISTENT--持久化目录节点

客户端与zookeeper断开连接后，该节点依旧存在

2、PERSISTENT_SEQUENTIAL-持久化顺序编号目录节点

客户端与zookeeper断开连接后，该节点依旧存在，只是Zookeeper给该节点名称进行顺序编号

3、EPHEMERAL-临时目录节点

客户端与zookeeper断开连接后，该节点被删除

4、EPHEMERAL_SEQUENTIAL-临时顺序编号目录节点

客户端与zookeeper断开连接后，该节点被删除，只是Zookeeper给该节点名称进行顺序编号

2、通知机制

客户端注册监听它关心的目录节点，当目录节点发生变化（数据改变、被删除、子目录节点增加删除）等，zookeeper会通知客户端。

二、zookeeper可以做什么

1、命名服务

在zookeeper的文件系统里创建一个目录，即有唯一的path,在我们使用tborg无法确定上游程序的部署机器时即可与下游程序约定好path,通过path即能互相探索发现。

2、配置管理

 程序总是需要配置的，如果程序分散部署在多台机器上，要逐个改变配置就变得困难。好吧，现在把这些配置全部放到zookeeper上去，保存在 Zookeeper 的某个目录节点中，然后所有相关应用程序对这个目录节点进行监听，一旦配置信息发生变化，每个应用程序就会收到 Zookeeper 的通知，然后从 Zookeeper 获取新的配置信息应用到系统中就好。

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/20141108213345_625-20210513151921154.png)、

3、集群管理

所谓集群管理无在乎两点：是否有机器退出和加入、选举master。

​    对于第一点，所有机器约定在父目录GroupMembers下创建临时目录节点，然后监听父目录节点的子节点变化消息。一旦有机器挂掉，该机器与 zookeeper的连接断开，其所创建的临时目录节点被删除，所有其他机器都收到通知：某个兄弟目录被删除，于是，所有人都知道：它上船了。新机器加入 也是类似，所有机器收到通知：新兄弟目录加入，highcount又有了。

​    对于第二点，我们稍微改变一下，所有机器创建临时顺序编号目录节点，每次选取编号最小的机器作为master就好。

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/20141108213345_947-20210513151923643.png)

4、分布式锁

有了zookeeper的一致性文件系统，锁的问题变得容易。锁服务可以分为两类，一个是保持独占，另一个是控制时序。

​    对于第一类，我们将zookeeper上的一个znode看作是一把锁，通过createznode的方式来实现。所有客户端都去创建 /distribute_lock 节点，最终成功创建的那个客户端也即拥有了这把锁。厕所有言：来也冲冲，去也冲冲，用完删除掉自己创建的distribute_lock 节点就释放出锁。

​    对于第二类， /distribute_lock 已经预先存在，所有客户端在它下面创建临时顺序编号目录节点，和选master一样，编号最小的获得锁，用完删除，依次方便。

![img](https://gitee.com/snailzrg/snail_img/raw/master/picgo_snail_img/20141108213345_5-20210513151929512.png)

5、队列管理

两种类型的队列：

1、 同步队列，当一个队列的成员都聚齐时，这个队列才可用，否则一直等待所有成员到达。

2、队列按照 FIFO 方式进行入队和出队操作。

第一类，在约定目录下创建临时目录节点，监听节点数目是否是我们要求的数目。

第二类，和分布式锁服务中的控制时序场景基本原理一致，入列有编号，出列按编号。         

​     终于了解完我们能用zookeeper做什么了，可是作为一个程序员，我们总是想狂热了解zookeeper是如何做到这一点的，单点维护一个文件系统没有什么难度，可是如果是一个集群维护一个文件系统保持数据的一致性就非常困难了。





### docker 使用zookeeper

##  3、使用 docker run 启动

```bash
# docker run 新建并启动容器
docker run --name zookeeper2181 -it -p 2181:2181 -p 2888:2888 -p 3888:3888 zookeeper

# 2181 端口号时 zookeeper client 端口
# 2888端口号是zookeeper服务之间通信的端口
# 3888端口是zookeeper与其他应用程序通信的端口


# 使用 ZK 命令行客户端连接 ZK
docker run -it --rm --link zookeeper2181:zookeeper zookeeper zkCli.sh -server zookeeper
# 启动一个 zookeeper 镜像, 并运行这个镜像内的 zkCli.sh 命令, 命令参数是 "-server zookeeper"
# 将我们先前启动的名为 zookeeper2181 的容器连接(link) 到我们新建的这个容器上, 并将其主机名命名为 zookeeper
# 当我们执行了这个命令后, 就可以像正常使用 ZK 命令行客户端一样操作 ZK 服务了.
```
