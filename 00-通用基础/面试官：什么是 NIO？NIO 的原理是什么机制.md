## 面试官：什么是 NIO？NIO 的原理是什么机制？

点击关注 👉 [Java基基](javascript:void(0);) *3天前*

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

来源：blog.csdn.net/qq_36520235/

- NIO和IO到底有什么区别？有什么关系？
- 先了解一下什么是通道，什么是缓冲区的概念
- NIO的底层工作原理
- NIO 工作代码示例
- NIO和Netty的工作模型对比？

------

# NIO和IO到底有什么区别？有什么关系？

首先说一下核心区别：

1. NIO是以块的方式处理数据，但是IO是以最基础的字节流的形式去写入和读出的。所以在效率上的话，肯定是NIO效率比IO效率会高出很多。
2. NIO不在是和IO一样用OutputStream和InputStream 输入流的形式来进行处理数据的，但是又是基于这种流的形式，而是采用了通道和缓冲区的形式来进行处理数据的。
3. 还有一点就是NIO的通道是可以双向的，但是IO中的流只能是单向的。
4. 还有就是NIO的缓冲区（其实也就是一个字节数组）还可以进行分片，可以建立只读缓冲区、直接缓冲区和间接缓冲区，只读缓冲区很明显就是字面意思，直接缓冲区是为加快 I/O 速度，而以一种特殊的方式分配其内存的缓冲区。
5. 补充一点：NIO比传统的BIO核心区别就是，NIO采用的是多路复用的IO模型，普通的IO用的是阻塞的IO模型，两个之间的效率肯定是多路复用效率更高

# 先了解一下什么是通道，什么是缓冲区的概念

## 通道是个什么意思？

- 通道是对原 I/O 包中的流的模拟。到任何目的地(或来自任何地方)的所有数据都必须通过一个 Channel 对象（通道）。一个 Buffer 实质上是一个容器对象。发送给一个通道的所有对象都必须首先放到缓冲区中；同样地，从通道中读取的任何数据都要读到缓冲区中。Channel是一个对象，可以通过它读取和写入数据。拿 NIO 与原来的 I/O 做个比较，通道就像是流。
- 正如前面提到的，所有数据都通过 Buffer 对象来处理。您永远不会将字节直接写入通道中，相反，您是将数据写入包含一个或者多个字节的缓冲区。同样，您不会直接从通道中读取字节，而是将数据从通道读入缓冲区，再从缓冲区获取这个字节。

## 缓冲区是什么意思：

- Buffer 是一个对象， 它包含一些要写入或者刚读出的数据。在 NIO 中加入 Buffer 对象，体现了新库与原 I/O 的一个重要区别。在面向流的 I/O 中，您将数据直接写入或者将数据直接读到 Stream 对象中
- 在 NIO 库中，所有数据都是用缓冲区处理的。在读取数据时，它是直接读到缓冲区中的。在写入数据时，它是写入到缓冲区中的。任何时候访问 NIO 中的数据，您都是将它放到缓冲区中。
- 缓冲区实质上是一个数组。通常它是一个字节数组，但是也可以使用其他种类的数组。但是一个缓冲区不 仅仅 是一个数组。缓冲区提供了对数据的结构化访问，而且还可以跟踪系统的读/写进程

## 缓冲区的类型：

> ByteBuffer
>
> CharBuffer
>
> ShortBuffer
>
> IntBuffer
>
> LongBuffer
>
> FloatBuffer
>
> DoubleBuffer

# NIO的底层工作原理

## 先来了解一下buffer的工作机制：

- capacity 缓冲区数组的总长度
- position 下一个要操作的数据元素的位置
- limit 缓冲区数组中不可操作的下一个元素的位置，limit<=capacity
- mark 用于记录当前 position 的前一个位置或者默认是 0

1.这一步其实是当我们刚开始初始化这个buffer数组的时候，开始默认是这样的

2、但是当你往buffer数组中开始写入的时候几个字节的时候就会变成下面的图，position会移动你数据的结束的下一个位置，这个时候你需要把buffer中的数据写到channel管道中，所以此时我们就需要用这个`buffer.flip();`方法，

3、当你调用完2中的方法时，这个时候就会变成下面的图了，这样的话其实就可以知道你刚刚写到buffer中的数据是在position---->limit之间，然后下一步调用`clear（）；`

4、这时底层操作系统就可以从缓冲区中正确读取这 5 个字节数据发送出去了。在下一次写数据之前我们在调一下 clear() 方法。缓冲区的索引状态又回到初始位置。（其实这一步有点像IO中的把转运字节数组 `char[] buf = new char[1024];` 不足1024字节的部分给强制刷新出去的意思）

## 补充：

1、这里还要说明一下 mark，当我们调用 `mark()` 时，它将记录当前 position 的前一个位置，当我们调用 reset 时，position 将恢复 mark 记录下来的值

2.clear()方法会：清空整个缓冲区。position将被设回0，limit被设置成 capacity的值（这个个人的理解就是当你在flip（）方法的基础上已经记住你写入了多少字节数据，直接把position到limit之间的也就是你写入已经记住的数据给“复制”到管道中）

3.当你把缓冲区的数局写入到管道中的时候，你需要调用flip()方法将Buffer从写模式切换到读模式，调用flip()方法会将position设回0，并将limit设置成之前position的值。buf.flip();（其实我个人理解的就相当于先记住缓冲区缓冲了多少数据）

# NIO 工作代码示例

```
public void selector() throws IOException {
//先给缓冲区申请内存空间
        ByteBuffer buffer = ByteBuffer.allocate(1024);
     //打开Selector为了它可以轮询每个 Channel 的状态
        Selector selector = Selector.open();
        ServerSocketChannel ssc = ServerSocketChannel.open();
        ssc.configureBlocking(false);//设置为非阻塞方式
        ssc.socket().bind(new InetSocketAddress(8080));
        ssc.register(selector, SelectionKey.OP_ACCEPT);//注册监听的事件
        while (true) {
            Set selectedKeys = selector.selectedKeys();//取得所有key集合
            Iterator it = selectedKeys.iterator();
            while (it.hasNext()) {
                SelectionKey key = (SelectionKey) it.next();
                if ((key.readyOps() & SelectionKey.OP_ACCEPT) == SelectionKey.OP_ACCEPT) {
                    ServerSocketChannel ssChannel = (ServerSocketChannel) key.channel();
                 SocketChannel sc = ssChannel.accept();//接受到服务端的请求
                    sc.configureBlocking(false);
                    sc.register(selector, SelectionKey.OP_READ);
                    it.remove();
                } else if
                ((key.readyOps() & SelectionKey.OP_READ) == SelectionKey.OP_READ) {
                    SocketChannel sc = (SocketChannel) key.channel();
                    while (true) {
                        buffer.clear();
                        int n = sc.read(buffer);//读取数据
                        if (n <= 0) {
                            break;
                        }
                        buffer.flip();
                    }
                    it.remove();
                }
            }
        }
}
```

## 最后给大家看一下整体的NIO的示意图

# NIO和Netty的工作模型对比？

## （1）NIO的工作流程步骤：

1. 首先是先创建ServerSocketChannel 对象，和真正处理业务的线程池
2. 然后给刚刚创建的ServerSocketChannel 对象进行绑定一个对应的端口，然后设置为非阻塞
3. 然后创建Selector对象并打开，然后把这Selector对象注册到ServerSocketChannel 中，并设置好监听的事件，监听 SelectionKey.OP_ACCEPT
4. 接着就是Selector对象进行死循环监听每一个Channel通道的事件，循环执行 Selector.select() 方法，轮询就绪的 Channel
5. 从Selector中获取所有的SelectorKey（这个就可以看成是不同的事件），如果SelectorKey是处于 OP_ACCEPT 状态，说明是新的客户端接入，调用 ServerSocketChannel.accept 接收新的客户端。
6. 然后对这个把这个接受的新客户端的Channel通道注册到ServerSocketChannel上，并且把之前的OP_ACCEPT 状态改为SelectionKey.OP_READ读取事件状态，并且设置为非阻塞的，然后把当前的这个SelectorKey给移除掉，说明这个事件完成了
7. 如果第5步的时候过来的事件不是OP_ACCEPT 状态，那就是OP_READ读取数据的事件状态，然后调用本文章的上面的那个读取数据的机制就可以了

## （2）Netty的工作流程步骤：

1. 创建 NIO 线程组 EventLoopGroup 和 ServerBootstrap。
2. 设置 ServerBootstrap 的属性：线程组、SO_BACKLOG 选项，设置 NioServerSocketChannel 为 Channel，设置业务处理 Handler
3. 绑定端口，启动服务器程序。
4. 在业务处理 TimeServerHandler 中，读取客户端发送的数据，并给出响应

## （3）两者之间的区别：

1. OP_ACCEPT 的处理被简化，因为对于 accept 操作的处理在不同业务上都是一致的。
2. 在 NIO 中需要自己构建 ByteBuffer 从 Channel 中读取数据，而 Netty 中数据是直接读取完成存放在 ByteBuf 中的。相当于省略了用户进程从内核中复制数据的过程。
3. 在 Netty 中，我们看到有使用一个解码器 FixedLengthFrameDecoder，可以用于处理定长消息的问题，能够解决 TCP 粘包读半包问题，十分方便。