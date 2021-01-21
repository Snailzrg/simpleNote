# Springboot项目java -jar 启动jar包参数详解



# 命令实例：

```
nohup java -Xms500m -Xmx500m -Xmn250m -Xss256k -server -XX:+HeapDumpOnOutOfMemoryError -jar $JAR_PATH/test-0.0.1-SNAPSHOT.jar --spring.profiles.active=daily -verbose:class &
```

### **说明：**

1. --spring.profiles.active=daily， 这个可以在spring-boot启动中指定系统变量，多环境(测试、预发、线上配置)的区分
2. 在排查jar包冲突时，可以指定启动的-verbose:class  打印出启动的应用实际加载类的路径，来排查来源。
3. jvm堆设值： -Xms500m -Xmx500m -Xmn250m -Xss256k
4. nohup 不挂断地运行命令；& 在后台运行 ，一般两个一起用。 eg：nohup command &
5. -server:服务器模式，在多个CPU时性能佳，启动慢但性能好，能合理管理内存。
6. -XX:+HeapDumpOnOutOfMemoryError：在堆溢出时保存快照

### **可以用 java -X命令在终端查询所有的java堆参数**：

```
-Xmixed           混合模式执行 (默认)



    -Xint             仅解释模式执行



    -Xbootclasspath:<用 : 分隔的目录和 zip/jar 文件>



                      设置搜索路径以引导类和资源



    -Xbootclasspath/a:<用 : 分隔的目录和 zip/jar 文件>



                      附加在引导类路径末尾



    -Xbootclasspath/p:<用 : 分隔的目录和 zip/jar 文件>



                      置于引导类路径之前



    -Xdiag            显示附加诊断消息



    -Xnoclassgc       禁用类垃圾收集



    -Xincgc           启用增量垃圾收集



    -Xloggc:<file>    将 GC 状态记录在文件中 (带时间戳)



    -Xbatch           禁用后台编译



    -Xms<size>        设置初始 Java 堆大小



    -Xmx<size>        设置最大 Java 堆大小



    -Xss<size>        设置 Java 线程堆栈大小



    -Xprof            输出 cpu 配置文件数据



    -Xfuture          启用最严格的检查, 预期将来的默认值



    -Xrs              减少 Java/VM 对操作系统信号的使用 (请参阅文档)



    -Xcheck:jni       对 JNI 函数执行其他检查



    -Xshare:off       不尝试使用共享类数据



    -Xshare:auto      在可能的情况下使用共享类数据 (默认)



    -Xshare:on        要求使用共享类数据, 否则将失败。



    -XshowSettings    显示所有设置并继续



    -XshowSettings:all



                      显示所有设置并继续



    -XshowSettings:vm 显示所有与 vm 相关的设置并继续



    -XshowSettings:properties



                      显示所有属性设置并继续



    -XshowSettings:locale



                      显示所有与区域设置相关的设置并继续



 



-X 选项是非标准选项, 如有更改, 恕不另行通知。



 



 



以下选项为 Mac OS X 特定的选项:



    -XstartOnFirstThread



                      在第一个 (AppKit) 线程上运行 main() 方法



    -Xdock:name=<应用程序名称>"



                      覆盖停靠栏中显示的默认应用程序名称



    -Xdock:icon=<图标文件的路径>



                      覆盖停靠栏中显示的默认图标
```

 

### **-server和-client具体说明：**

>    -server：一定要作为第一个参数，在多个 CPU 时性能佳，还有一种叫 -client 的模式，特点是启动速度比较快，但运行时性能和内存管理效率不高，通常用于客户端应用程序或开发调试，在 32 位环境下直接运行 Java 程序默认启用该模式。Server 模式的特点是启动速度比较慢，但运行时性能和内存管理效率很高，适用于生产环境，在具有 64 位能力的 JDK 环境下默认启用该模式，可以不配置该参数。 

###  

### -XX:+HeapDumpOnOutOfMemoryError：

>   该配置会把快照保存在user.dir中，比如你用tomcat启动，那应该是在tomcat的bin目录下
>
> 当然，也可以通过XX:HeapDumpPath=./java_pid.hprof来显示指定路径
>
>  此外，OnOutOfMemoryError参数允许用户指定当出现oom时，指定某个脚本来完成一些动作，比如邮件知会。。。
>
> ```
> $ java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof -XX:OnOutOfMemoryError ="sh ~/cleanup.sh" MyApp
> ```

 

# 其他补充说明：

### shell命令重定向绑定：

```
nohup command >/dev/null 2>&1 &
```

`>/dev/null 2>&1`。这条命令其实分为两命令，一个是`>/dev/null`，另一个是`2>&1`。

\1. >/dev/null

这条命令的作用是将标准输出1重定向到/dev/null中。/dev/null代表linux的空设备文件，所有往这个文件里面写入的内容都会丢失，俗称“黑洞”。那么执行了`>/dev/null`之后，标准输出就会不再存在，没有任何地方能够找到输出的内容。

\2. 2>&1

这条命令用到了重定向绑定，采用&可以将两个输出绑定在一起。这条命令的作用是错误输出将和标准输出同用一个文件描述符，说人话就是错误输出将会和标准输出输出到同一个地方。

linux在执行shell命令之前，就会确定好所有的输入输出位置，并且从左到右依次执行重定向的命令，所以`>/dev/null 2>&1`的作用就是让标准输出重定向到/dev/null中（丢弃标准输出），然后错误输出由于重用了标准输出的描述符，所以错误输出也被定向到了/dev/null中，错误输出同样也被丢弃了。执行了这条命令之后，**该条shell命令将不会输出任何信息到控制台，也不会有任何信息输出到文件中**。

**>/dev/null 2>&1   VS   2>&1 >/dev/null**

乍眼看这两条命令貌似是等同的，但其实大为不同。刚才提到了，linux在执行shell命令之前，就会确定好所有的输入输出位置，并且从左到右依次执行重定向的命令。那么我们同样从左到右地来分析`2>&1 >/dev/null`：

1. 2>&1，将错误输出绑定到标准输出上。由于此时的标准输出是默认值，也就是输出到屏幕，所以错误输出会输出到屏幕。
2. \>/dev/null，将标准输出1重定向到/dev/null中。

我们用一个表格来更好地说明这两条命令的区别：

| 命令            | 标准输出 | 错误输出 |
| :-------------- | :------- | :------- |
| >/dev/null 2>&1 | 丢弃     | 丢弃     |
| 2>&1 >/dev/null | 丢弃     | 屏幕     |

**>/dev/null 2>&1     VS    >/dev/null 2>/dev/null**

那么可能会有些同学会疑问，为什么要用重定向绑定，而不是像`>/dev/null 2>/dev/null`这样子重复一遍呢。

为了回答这个问题，我们回到刚才介绍输出重定向的场景。我们尝试将标准输出和错误输出都定向到out文件中：

| ` `1234 | ` `# ls a.txt b.txt >out 2>out# cat outa.txt�法访问b.txt: 没有那个文件或目录 |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

WTF？竟然出现了乱码，这是为啥呢？这是因为采用这种写法，标准输出和错误输出会抢占往out文件的管道，所以可能会导致输出内容的时候出现缺失、覆盖等情况。现在是出现了乱码，有时候也有可能出现只有error信息或者只有正常信息的情况。不管怎么说，采用这种写法，最后的情况是无法预估的。

而且，由于out文件被打开了两次，两个文件描述符会抢占性的往文件中输出内容，所以整体IO效率不如`>/dev/null 2>&1`来得高。

### nohup结合

> 1.nohup
>
> 用途：不挂断地运行命令。
>
> 语法：nohup Command [ Arg … ] [　& ]
>
> 　　无论是否将 nohup 命令的输出重定向到终端，输出都将附加到当前目录的 nohup.out 文件中。
>
> 　　如果当前目录的 nohup.out 文件不可写，输出重定向到 $HOME/nohup.out 文件中。
>
> 　　如果没有文件能创建或打开以用于追加，那么 Command 参数指定的命令不可调用。
>
> 退出状态：该命令返回下列出口值： 　
>
> 　　126 可以查找但不能调用 Command 参数指定的命令。 　
>
> 　　127 nohup 命令发生错误或不能查找由 Command 参数指定的命令。 　
>
> 　　否则，nohup 命令的退出状态是 Command 参数指定命令的退出状态。
>
> 2.&
>
> 用途：在后台运行
>
> 一般两个一起用

我们经常使用`nohup command &`命令形式来启动一些后台程序，比如一些java服务：

| ` `1 | ` `# nohup java -jar xxxx.jar & |
| ---- | ------------------------------- |
|      |                                 |

为了不让一些执行信息输出到前台（控制台），我们还会加上刚才提到的`>/dev/null 2>&1`命令来丢弃所有的输出：

| ` `1 | ` `# nohup java -jar xxxx.jar >/dev/null 2>&1 & |
| ---- | ----------------------------------------------- |
|      |                                                 |

## 

 

参考链接：https://blog.csdn.net/ldx891113/article/details/51735171。Tomcat 调优及 JVM 参数优化