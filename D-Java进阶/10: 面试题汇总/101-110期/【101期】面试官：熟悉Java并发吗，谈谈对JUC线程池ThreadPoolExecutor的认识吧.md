## 【101期】面试官：熟悉Java并发吗，谈谈对JUC线程池ThreadPoolExecutor的认识吧

throwable [Java面试题精选](javascript:void(0);) *6月2日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅**

***\*阶段汇总集合：\*******\*[++小Flag实现，一百期面试题汇总++](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247484532&idx=1&sn=1c243934507d79db4f76de8ed0e5727f&chksm=e80db202df7a3b14fe7077b0fe5ec4de4088ce96a2cde16cbac21214956bd6f2e8f51193ee2b&scene=21#wechat_redirect)\****

![img](https://mmbiz.qpic.cn/mmbiz_jpg/wbiax4xEAl5ylvmQdibcicr8jgK9ibK68m1Ne1YNoTW7fpXxebebQD11cRZb5WiaVp7VCoMl6cGLaT4QZt9f1EP7UkQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 前提

很早之前就打算看一次JUC线程池`ThreadPoolExecutor`的源码实现，由于近段时间比较忙，一直没有时间整理出源码分析的文章。之前在分析扩展线程池实现可回调的`Future`时候曾经提到并发大师`Doug Lea`在设计线程池`ThreadPoolExecutor`的提交任务的顶层接口`Executor`只有一个无状态的执行方法：

```
public interface Executor {

    void execute(Runnable command);
}
```

而`ExecutorService`提供了很多扩展方法底层基本上是基于`Executor#execute()`方法进行扩展。本文着重分析`ThreadPoolExecutor#execute()`的实现，笔者会从实现原理、源码实现等角度结合简化例子进行详细的分析。`ThreadPoolExecutor`的源码从JDK8到JDK11基本没有变化，本文编写的时候使用的是JDK11。

## ThreadPoolExecutor的原理

`ThreadPoolExecutor`里面使用到JUC同步器框架`AbstractQueuedSynchronizer`（俗称`AQS`）、大量的位操作、`CAS`操作。`ThreadPoolExecutor`提供了固定活跃线程（核心线程）、额外的线程（线程池容量 - 核心线程数这部分额外创建的线程，下面称为非核心线程）、任务队列以及拒绝策略这几个重要的功能。

### JUC同步器框架

`ThreadPoolExecutor`里面使用到JUC同步器框架，主要用于四个方面：

- 全局锁`mainLock`成员属性，是可重入锁`ReentrantLock`类型，主要是用于访问工作线程`Worker`集合和进行数据统计记录时候的加锁操作。
- 条件变量`termination`，`Condition`类型，主要用于线程进行等待终结`awaitTermination()`方法时的带期限阻塞。
- 任务队列`workQueue`，`BlockingQueue`类型，任务队列，用于存放待执行的任务。
- 工作线程，内部类`Worker`类型，是线程池中真正的工作线程对象。

关于`AQS`笔者之前写过一篇相关源码分析的文章：JUC同步器框架AbstractQueuedSynchronizer源码图文分析。

### 核心线程

这里先参考`ThreadPoolExecutor`的实现并且进行简化，实现一个只有核心线程的线程池，要求如下：

- 暂时不考虑任务执行异常情况下的处理。
- 任务队列为无界队列。
- 线程池容量固定为核心线程数量。
- 暂时不考虑拒绝策略。

```
public class CoreThreadPool implements Executor {

    private BlockingQueue<Runnable> workQueue;
    private static final AtomicInteger COUNTER = new AtomicInteger();
    private int coreSize;
    private int threadCount = 0;

    public CoreThreadPool(int coreSize) {
        this.coreSize = coreSize;
        this.workQueue = new LinkedBlockingQueue<>();
    }

    @Override
    public void execute(Runnable command) {
        if (++threadCount <= coreSize) {
            new Worker(command).start();
        } else {
            try {
                workQueue.put(command);
            } catch (InterruptedException e) {
                throw new IllegalStateException(e);
            }
        }
    }

    private class Worker extends Thread {
        private Runnable firstTask;

        public Worker(Runnable runnable) {
            super(String.format("Worker-%d", COUNTER.getAndIncrement()));
            this.firstTask = runnable;
        }

        @Override
        public void run() {
            Runnable task = this.firstTask;
            while (null != task || null != (task = getTask())) {
                try {
                    task.run();
                } finally {
                    task = null;
                }
            }
        }
    }

    private Runnable getTask() {
        try {
            return workQueue.take();
        } catch (InterruptedException e) {
            throw new IllegalStateException(e);
        }
    }

    public static void main(String[] args) throws Exception {
        CoreThreadPool pool = new CoreThreadPool(5);
        IntStream.range(0, 10)
                .forEach(i -> pool.execute(() ->
                        System.out.println(String.format("Thread:%s,value:%d", Thread.currentThread().getName(), i))));
        Thread.sleep(Integer.MAX_VALUE);
    }
}
```

某次运行结果如下：

```
Thread:Worker-0,value:0
Thread:Worker-3,value:3
Thread:Worker-2,value:2
Thread:Worker-1,value:1
Thread:Worker-4,value:4
Thread:Worker-1,value:5
Thread:Worker-2,value:8
Thread:Worker-4,value:7
Thread:Worker-0,value:6
Thread:Worker-3,value:9
```

设计此线程池的时候，核心线程是懒创建的，如果线程空闲的时候则阻塞在任务队列的`take()`方法，其实对于`ThreadPoolExecutor`也是类似这样实现，只是如果使用了`keepAliveTime`并且允许核心线程超时（`allowCoreThreadTimeOut`设置为`true`）则会使用`BlockingQueue#poll(keepAliveTime)`进行轮询代替永久阻塞。

### 其他附加功能

构建`ThreadPoolExecutor`实例的时候，需要定义`maximumPoolSize`（线程池最大线程数）和`corePoolSize`（核心线程数）。当任务队列是有界的阻塞队列，核心线程满负载，任务队列已经满的情况下，会尝试创建额外的`maximumPoolSize - corePoolSize`个线程去执行新提交的任务。当`ThreadPoolExecutor`这里实现的两个主要附加功能是：

- 一定条件下会创建非核心线程去执行任务，非核心线程的回收周期（线程生命周期终结时刻）是`keepAliveTime`，线程生命周期终结的条件是：下一次通过任务队列获取任务的时候并且存活时间超过`keepAliveTime`。
- 提供拒绝策略，也就是在核心线程满负载、任务队列已满、非核心线程满负载的条件下会触发拒绝策略。

## 源码分析

先分析线程池的关键属性，接着分析其状态控制，最后重点分析`ThreadPoolExecutor#execute()`方法。

### 关键属性

```
public class ThreadPoolExecutor extends AbstractExecutorService {

    // 控制变量-存放状态和线程数
    private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));

    // 任务队列，必须是阻塞队列
    private final BlockingQueue<Runnable> workQueue;

    // 工作线程集合，存放线程池中所有的（活跃的）工作线程，只有在持有全局锁mainLock的前提下才能访问此集合
    private final HashSet<Worker> workers = new HashSet<>();
    
    // 全局锁
    private final ReentrantLock mainLock = new ReentrantLock();

    // awaitTermination方法使用的等待条件变量
    private final Condition termination = mainLock.newCondition();

    // 记录峰值线程数
    private int largestPoolSize;
    
    // 记录已经成功执行完毕的任务数
    private long completedTaskCount;
    
    // 线程工厂，用于创建新的线程实例
    private volatile ThreadFactory threadFactory;

    // 拒绝执行处理器，对应不同的拒绝策略
    private volatile RejectedExecutionHandler handler;
    
    // 空闲线程等待任务的时间周期，单位是纳秒
    private volatile long keepAliveTime;
    
    // 是否允许核心线程超时，如果为true则keepAliveTime对核心线程也生效
    private volatile boolean allowCoreThreadTimeOut;
    
    // 核心线程数
    private volatile int corePoolSize;

    // 线程池容量
    private volatile int maximumPoolSize;

    // 省略其他代码
}
```

下面看参数列表最长的构造函数：

```
public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory,
                          RejectedExecutionHandler handler) {
    if (corePoolSize < 0 ||
        maximumPoolSize <= 0 ||
        maximumPoolSize < corePoolSize ||
        keepAliveTime < 0)
        throw new IllegalArgumentException();
    if (workQueue == null || threadFactory == null || handler == null)
        throw new NullPointerException();
    this.corePoolSize = corePoolSize;
    this.maximumPoolSize = maximumPoolSize;
    this.workQueue = workQueue;
    this.keepAliveTime = unit.toNanos(keepAliveTime);
    this.threadFactory = threadFactory;
    this.handler = handler;
}
```

可以自定义核心线程数、线程池容量（最大线程数）、空闲线程等待任务周期、任务队列、线程工厂、拒绝策略。下面简单分析一下每个参数的含义和作用：

- **`corePoolSize`**：int类型，核心线程数量。

- **`maximumPoolSize`**：int类型，最大线程数量，也就是线程池的容量。

- **`keepAliveTime`**：long类型，线程空闲等待时间，也和工作线程的生命周期有关，下文会分析。

- **`unit`**：`TimeUnit`类型，`keepAliveTime`参数的时间单位，实际上`keepAliveTime`最终会转化为纳秒。

- **`workQueue`**：`BlockingQueue`类型，等待队列或者叫任务队列。

- **`threadFactory`**：`ThreadFactory`类型，线程工厂，用于创建工作线程（包括核心线程和非核心线程），默认使用`Executors.defaultThreadFactory()`作为内建线程工厂实例，一般自定义线程工厂才能更好地跟踪工作线程。

- `handler`：

- ```
  RejectedExecutionHandler
  ```

  类型，线程池的拒绝执行处理器，更多时候称为拒绝策略，拒绝策略执行的时机是当阻塞队列已满、没有空闲的线程（包括核心线程和非核心线程）并且继续提交任务。提供了4种内建的拒绝策略实现：

- - `AbortPolicy`：直接拒绝策略，也就是不会执行任务，直接抛出`RejectedExecutionException`，这是**默认的拒绝策略**。
  - `DiscardPolicy`：抛弃策略，也就是直接忽略提交的任务（通俗来说就是空实现）。
  - `DiscardOldestPolicy`：抛弃最老任务策略，也就是通过`poll()`方法取出任务队列队头的任务抛弃，然后执行当前提交的任务。
  - `CallerRunsPolicy`：调用者执行策略，也就是当前调用`Executor#execute()`的线程直接调用任务`Runnable#run()`，**一般不希望任务丢失会选用这种策略，但从实际角度来看，原来的异步调用意图会退化为同步调用**。

### 状态控制

状态控制主要围绕原子整型成员变量`ctl`：

```
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
private static final int COUNT_BITS = Integer.SIZE - 3;
private static final int COUNT_MASK = (1 << COUNT_BITS) - 1;

private static final int RUNNING    = -1 << COUNT_BITS;
private static final int SHUTDOWN   =  0 << COUNT_BITS;
private static final int STOP       =  1 << COUNT_BITS;
private static final int TIDYING    =  2 << COUNT_BITS;
private static final int TERMINATED =  3 << COUNT_BITS;

// 通过ctl值获取运行状态
private static int runStateOf(int c)     { return c & ~COUNT_MASK; }
// 通过ctl值获取工作线程数
private static int workerCountOf(int c)  { return c & COUNT_MASK; }

// 通过运行状态和工作线程数计算ctl的值，或运算
private static int ctlOf(int rs, int wc) { return rs | wc; }

private static boolean runStateLessThan(int c, int s) {
    return c < s;
}

private static boolean runStateAtLeast(int c, int s) {
    return c >= s;
}

private static boolean isRunning(int c) {
    return c < SHUTDOWN;
}

// CAS操作线程数增加1
private boolean compareAndIncrementWorkerCount(int expect) {
    return ctl.compareAndSet(expect, expect + 1);
}

// CAS操作线程数减少1
private boolean compareAndDecrementWorkerCount(int expect) {
    return ctl.compareAndSet(expect, expect - 1);
}

// 线程数直接减少1
private void decrementWorkerCount() {
    ctl.addAndGet(-1);
}
```

接下来分析一下线程池的状态变量，工作线程上限数量位的长度是`COUNT_BITS`，它的值是`Integer.SIZE - 3`，也就是正整数29：

> 我们知道，整型包装类型Integer实例的大小是4 byte，一共32 bit，也就是一共有32个位用于存放0或者1。在ThreadPoolExecutor实现中，使用32位的整型包装类型存放工作线程数和线程池状态。其中，低29位用于存放工作线程数，而高3位用于存放线程池状态，所以线程池的状态最多只能有2^3种。工作线程上限数量为2^29 - 1，超过5亿，这个数量在短时间内不用考虑会超限。

接着看工作线程上限数量掩码`COUNT_MASK`，它的值是`(1 < COUNT_BITS) - l`，也就是1左移29位，再减去1，如果补全32位，它的位视图如下：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/wbiax4xEAl5ylvmQdibcicr8jgK9ibK68m1NUPRxkg97PteQY0ibo1VqSBDUNojLic3z172z3ibAjI1gtfmxCtWKnRFwg/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

然后就是线程池的状态常量，这里只详细分析其中一个，其他类同，这里看`RUNNING`状态：

```
// -1的补码为：111-11111111111111111111111111111
// 左移29位后：111-00000000000000000000000000000
// 10进制值为：-536870912
// 高3位111的值就是表示线程池正在处于运行状态
private static final int RUNNING = -1 << COUNT_BITS;
```

控制变量`ctl`的组成就是通过线程池运行状态`rs`和工作线程数`wc`通过**或运算**得到的：

```
// rs=RUNNING值为：111-00000000000000000000000000000
// wc的值为0：000-00000000000000000000000000000
// rs | wc的结果为：111-00000000000000000000000000000
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
private static int ctlOf(int rs, int wc) {
    return rs | wc;
}
```

那么我们怎么从`ctl`中取出高3位的线程池状态？上面源码中提供的`runStateOf()`方法就是提取运行状态：

```
// 先把COUNT_MASK取反(~COUNT_MASK)，
得到：111-00000000000000000000000000000
// ctl位图特点是：xxx-yyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
// 两者做一次与运算即可得到高3位xxx
private static int runStateOf(int c){
    return c & ~COUNT_MASK;
}
```

同理，取出低29位的工作线程数量只需要把`ctl`和`COUNT_MASK`(`000-11111111111111111111111111111`)做一次**与运算**即可。

工作线程数为0的前提下，小结一下线程池的运行状态常量：

|   状态名称   |                位图                 |  十进制值  |                             描述                             |
| :----------: | :---------------------------------: | :--------: | :----------------------------------------------------------: |
|  `RUNNING`   | `111-00000000000000000000000000000` | -536870912 |      运行中状态，可以接收新的任务和执行任务队列中的任务      |
|  `SHUTDOWN`  | `000-00000000000000000000000000000` |     0      |  shutdown状态，不再接收新的任务，但是会执行任务队列中的任务  |
|    `STOP`    | `001-00000000000000000000000000000` | 536870912  | 停止状态，不再接收新的任务，也不会执行任务队列中的任务，中断所有执行中的任务 |
|  `TIDYING`   | `010-00000000000000000000000000000` | 1073741824 | 整理中状态，所有任务已经终结，工作线程数为0，过渡到此状态的工作线程会调用钩子方法`terminated()` |
| `TERMINATED` | `011-00000000000000000000000000000` | 1610612736 |           终结状态，钩子方法`terminated()`执行完毕           |

这里有一个比较特殊的技巧，由于运行状态值存放在高3位，所以可以直接通过十进制值（**甚至可以忽略低29位，直接用`ctl`进行比较，或者使用`ctl`和线程池状态常量进行比较**）来比较和判断线程池的状态：

> 工作线程数为0的前提下：RUNNING(-536870912) < SHUTDOWN(0) < STOP(536870912) < TIDYING(1073741824) < TERMINATED(1610612736)

下面这三个方法就是使用这种技巧：

```
// ctl和状态常量比较，判断是否小于
private static boolean runStateLessThan(int c, int s) {
    return c < s;
}

// ctl和状态常量比较，判断是否小于或等于
private static boolean runStateAtLeast(int c, int s) {
    return c >= s;
}

// ctl和状态常量SHUTDOWN比较，判断是否处于RUNNING状态
private static boolean isRunning(int c) {
    return c < SHUTDOWN;
}
```

最后是线程池状态的跃迁图：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/wbiax4xEAl5ylvmQdibcicr8jgK9ibK68m1Nmjrr6U17qUjttdXwYYoHR2KuvomLc38gqPspvtbuRcPnvtuUZsGCdQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)]

> PS：线程池源码中有很多中间变量用了简单的单字母表示，例如c就是表示ctl、wc就是表示worker count、rs就是表示running status。

### execute方法源码分析

线程池异步执行任务的方法实现是`ThreadPoolExecutor#execute()`，源码如下：

```
// 执行命令，其中命令（下面称任务）对象是Runnable的实例
public void execute(Runnable command) {
    // 判断命令（任务）对象非空
    if (command == null)
        throw new NullPointerException();
    // 获取ctl的值
    int c = ctl.get();
    // 判断如果当前工作线程数小于核心线程数，则创建新的核心线程并且执行传入的任务
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            // 如果创建新的核心线程成功则直接返回
            return;
        // 这里说明创建核心线程失败，需要更新ctl的临时变量c
        c = ctl.get();
    }
    // 走到这里说明创建新的核心线程失败，也就是当前工作线程数大于等于corePoolSize
    // 判断线程池是否处于运行中状态，同时尝试用非阻塞方法向任务队列放入任务（放入任务失败返回false）
    if (isRunning(c) && workQueue.offer(command)) {
        int recheck = ctl.get();
        // 这里是向任务队列投放任务成功，对线程池的运行中状态做二次检查
        // 如果线程池二次检查状态是非运行中状态，则从任务队列移除当前的任务调用拒绝策略处理之（也就是移除前面成功入队的任务实例）
        if (! isRunning(recheck) && remove(command))
            // 调用拒绝策略处理任务 - 返回
            reject(command);
        // 走到下面的else if分支，说明有以下的前提：
        // 0、待执行的任务已经成功加入任务队列
        // 1、线程池可能是RUNNING状态
        // 2、传入的任务可能从任务队列中移除失败（移除失败的唯一可能就是任务已经被执行了）
        // 如果当前工作线程数量为0，则创建一个非核心线程并且传入的任务对象为null - 返回
        // 也就是创建的非核心线程不会马上运行，而是等待获取任务队列的任务去执行
        // 如果前工作线程数量不为0，原来应该是最后的else分支，但是可以什么也不做，因为任务已经成功入队列，总会有合适的时机分配其他空闲线程去执行它
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    // 走到这里说明有以下的前提：
    // 0、线程池中的工作线程总数已经大于等于corePoolSize（简单来说就是核心线程已经全部懒创建完毕）
    // 1、线程池可能不是RUNNING状态
    // 2、线程池可能是RUNNING状态同时任务队列已经满了
    // 如果向任务队列投放任务失败，则会尝试创建非核心线程传入任务执行
    // 创建非核心线程失败，此时需要拒绝执行任务
    else if (!addWorker(command, false))
        // 调用拒绝策略处理任务 - 返回
        reject(command);
}
```

这里简单分析一下整个流程：

1. 如果当前工作线程总数小于`corePoolSize`，则直接创建核心线程执行任务（任务实例会传入直接用于构造工作线程实例）。
2. 如果当前工作线程总数大于等于`corePoolSize`，判断线程池是否处于运行中状态，同时尝试用非阻塞方法向任务队列放入任务，这里会二次检查线程池运行状态，如果当前工作线程数量为0，则创建一个非核心线程并且传入的任务对象为null。
3. 如果向任务队列投放任务失败（任务队列已经满了），则会尝试创建非核心线程传入任务实例执行。
4. 如果创建非核心线程失败，此时需要拒绝执行任务，调用拒绝策略处理任务。

**这里是一个疑惑点**：为什么需要二次检查线程池的运行状态，当前工作线程数量为0，尝试创建一个非核心线程并且传入的任务对象为null？这个可以看API注释：

> 如果一个任务成功加入任务队列，我们依然需要二次检查是否需要添加一个工作线程（因为所有存活的工作线程有可能在最后一次检查之后已经终结）或者执行当前方法的时候线程池是否已经shutdown了。所以我们需要二次检查线程池的状态，必须时把任务从任务队列中移除或者在没有可用的工作线程的前提下新建一个工作线程。

任务提交流程从调用者的角度来看如下：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/wbiax4xEAl5ylvmQdibcicr8jgK9ibK68m1Nd40icib8tiakWN7d4icDKm2bJHJw0U1B3uvFZicdGCGib3eGnHKdCRxhREiag/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

### addWorker方法源码分析

`boolean addWorker(Runnable firstTask, boolean core)`方法的第一的参数可以用于直接传入任务实例，第二个参数用于标识将要创建的工作线程是否核心线程。方法源码如下：

```
// 添加工作线程，如果返回false说明没有新创建工作线程，如果返回true说明创建和启动工作线程成功
private boolean addWorker(Runnable firstTask, boolean core) {
    retry:
    // 注意这是一个死循环 - 最外层循环
    for (int c = ctl.get();;) {
        // 这个是十分复杂的条件，这里先拆分多个与（&&）条件：
        // 1. 线程池状态至少为SHUTDOWN状态，也就是rs >= SHUTDOWN(0)
        // 2. 线程池状态至少为STOP状态，也就是rs >= STOP(1)，或者传入的任务实例firstTask不为null，或者任务队列为空
        // 其实这个判断的边界是线程池状态为shutdown状态下，不会再接受新的任务，在此前提下如果状态已经到了STOP、或者传入任务不为空、或者任务队列为空（已经没有积压任务）都不需要添加新的线程
        if (runStateAtLeast(c, SHUTDOWN)
            && (runStateAtLeast(c, STOP)
                || firstTask != null
                || workQueue.isEmpty()))
            return false;
        // 注意这也是一个死循环 - 二层循环
        for (;;) {
            // 这里每一轮循环都会重新获取工作线程数wc
            // 1. 如果传入的core为true，表示将要创建核心线程，通过wc和corePoolSize判断，如果wc >= corePoolSize，则返回false表示创建核心线程失败
            // 1. 如果传入的core为false，表示将要创非建核心线程，通过wc和maximumPoolSize判断，如果wc >= maximumPoolSize，则返回false表示创建非核心线程失败
            if (workerCountOf(c)
                >= ((core ? corePoolSize : maximumPoolSize) & COUNT_MASK))
                return false;
            // 成功通过CAS更新工作线程数wc，则break到最外层的循环
            if (compareAndIncrementWorkerCount(c))
                break retry;
            // 走到这里说明了通过CAS更新工作线程数wc失败，这个时候需要重新判断线程池的状态是否由RUNNING已经变为SHUTDOWN
            c = ctl.get();  // Re-read ctl
            // 如果线程池状态已经由RUNNING已经变为SHUTDOWN，则重新跳出到外层循环继续执行
            if (runStateAtLeast(c, SHUTDOWN))
                continue retry;
            // 如果线程池状态依然是RUNNING，CAS更新工作线程数wc失败说明有可能是并发更新导致的失败，则在内层循环重试即可
            // else CAS failed due to workerCount change; retry inner loop
        }
    }
    // 标记工作线程是否启动成功
    boolean workerStarted = false;
    // 标记工作线程是否创建成功
    boolean workerAdded = false;
    Worker w = null;
    try {
        // 传入任务实例firstTask创建Worker实例，Worker构造里面会通过线程工厂创建新的Thread对象，所以下面可以直接操作Thread t = w.thread
        // 这一步Worker实例已经创建，但是没有加入工作线程集合或者启动它持有的线程Thread实例
        w = new Worker(firstTask);
        final Thread t = w.thread;
        if (t != null) {
            // 这里需要全局加锁，因为会改变一些指标值和非线程安全的集合
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                // Recheck while holding lock.
                // Back out on ThreadFactory failure or if
                // shut down before lock acquired.
                int c = ctl.get();
                // 这里主要在加锁的前提下判断ThreadFactory创建的线程是否存活或者判断获取锁成功之后线程池状态是否已经更变为SHUTDOWN
                // 1. 如果线程池状态依然为RUNNING，则只需要判断线程实例是否存活，需要添加到工作线程集合和启动新的Worker
                // 2. 如果线程池状态小于STOP，也就是RUNNING或者SHUTDOWN状态下，同时传入的任务实例firstTask为null，则需要添加到工作线程集合和启动新的Worker
                // 对于2，换言之，如果线程池处于SHUTDOWN状态下，同时传入的任务实例firstTask不为null，则不会添加到工作线程集合和启动新的Worker
                // 这一步其实有可能创建了新的Worker实例但是并不启动（临时对象，没有任何强引用），这种Worker有可能成功下一轮GC被收集的垃圾对象
                if (isRunning(c) ||
                    (runStateLessThan(c, STOP) && firstTask == null)) {
                    if (t.isAlive()) // precheck that t is startable
                        throw new IllegalThreadStateException();
                    // 把创建的工作线程实例添加到工作线程集合
                    workers.add(w);
                    int s = workers.size();
                    // 尝试更新历史峰值工作线程数，也就是线程池峰值容量
                    if (s > largestPoolSize)
                        largestPoolSize = s;
                    // 这里更新工作线程是否启动成功标识为true，后面才会调用Thread#start()方法启动真实的线程实例
                    workerAdded = true;
                }
            } finally {
                mainLock.unlock();
            }
            // 如果成功添加工作线程，则调用Worker内部的线程实例t的Thread#start()方法启动真实的线程实例
            if (workerAdded) {
                t.start();
                // 标记线程启动成功
                workerStarted = true;
            }
        }
    } finally {
        // 线程启动失败，需要从工作线程集合移除对应的Worker
        if (! workerStarted)
            addWorkerFailed(w);
    }
    return workerStarted;
}

// 添加Worker失败
private void addWorkerFailed(Worker w) {
    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        // 从工作线程集合移除之
        if (w != null)
            workers.remove(w);
        // wc数量减1
        decrementWorkerCount();
        // 基于状态判断尝试终结线程池
        tryTerminate();
    } finally {
        mainLock.unlock();
    }
}
```

笔者发现了`Doug Lea`大神十分喜欢复杂的条件判断，而且单行复杂判断不喜欢加花括号，像下面这种代码在他编写的很多类库中都比较常见：

```
if (runStateAtLeast(c, SHUTDOWN)
    && (runStateAtLeast(c, STOP)
        || firstTask != null
        || workQueue.isEmpty()))
    return false;
// ....
//  代码拆分一下如下
boolean atLeastShutdown = runStateAtLeast(c, SHUTDOWN);     # rs >= SHUTDOWN(0)
boolean atLeastStop = runStateAtLeast(c, STOP) || firstTask != null || workQueue.isEmpty();
if (atLeastShutdown && atLeastStop){
   return false;
}
```

上面的分析逻辑中需要注意一点，`Worker`实例创建的同时，在其构造函数中会通过`ThreadFactory`创建一个Java线程`Thread`实例，后面会加锁后二次检查是否需要把`Worker`实例添加到工作线程集合`workers`中和是否需要启动`Worker`中持有的`Thread`实例，只有启动了`Thread`实例实例，`Worker`才真正开始运作，否则只是一个无用的临时对象。`Worker`本身也实现了`Runnable`接口，它可以看成是一个`Runnable`的适配器。

### 工作线程内部类Worker源码分析

线程池中的每一个具体的工作线程被包装为内部类`Worker`实例，`Worker`继承于`AbstractQueuedSynchronizer(AQS)`，实现了`Runnable`接口：

```
private final class Worker extends AbstractQueuedSynchronizer implements Runnable{
    /**
        * This class will never be serialized, but we provide a
        * serialVersionUID to suppress a javac warning.
        */
    private static final long serialVersionUID = 6138294804551838833L;

    // 保存ThreadFactory创建的线程实例，如果ThreadFactory创建线程失败则为null
    final Thread thread;
    // 保存传入的Runnable任务实例
    Runnable firstTask;
    // 记录每个线程完成的任务总数
    volatile long completedTasks;
    
    // 唯一的构造函数，传入任务实例firstTask，注意可以为null
    Worker(Runnable firstTask) {
        // 禁止线程中断，直到runWorker()方法执行
        setState(-1); // inhibit interrupts until runWorker
        this.firstTask = firstTask;
        // 通过ThreadFactory创建线程实例，注意一下Worker实例自身作为Runnable用于创建新的线程实例
        this.thread = getThreadFactory().newThread(this);
    }

    // 委托到外部的runWorker()方法，注意runWorker()方法是线程池的方法，而不是Worker的方法
    public void run() {
        runWorker(this);
    }

    // Lock methods
    //
    // The value 0 represents the unlocked state.
    // The value 1 represents the locked state.
    //  是否持有独占锁，state值为1的时候表示持有锁，state值为0的时候表示已经释放锁
    protected boolean isHeldExclusively() {
        return getState() != 0;
    }

    // 独占模式下尝试获取资源，这里没有判断传入的变量，直接CAS判断0更新为1是否成功，成功则设置独占线程为当前线程
    protected boolean tryAcquire(int unused) {
        if (compareAndSetState(0, 1)) {
            setExclusiveOwnerThread(Thread.currentThread());
            return true;
        }
        return false;
    }
    
    // 独占模式下尝试是否资源，这里没有判断传入的变量，直接把state设置为0
    protected boolean tryRelease(int unused) {
        setExclusiveOwnerThread(null);
        setState(0);
        return true;
    }
    
    // 加锁
    public void lock()        { acquire(1); }

    // 尝试加锁
    public boolean tryLock()  { return tryAcquire(1); }

    // 解锁
    public void unlock()      { release(1); }

    // 是否锁定
    public boolean isLocked() { return isHeldExclusively(); }
    
    // 启动后进行线程中断，注意这里会判断线程实例的中断标志位是否为false，只有中断标志位为false才会中断
    void interruptIfStarted() {
        Thread t;
        if (getState() >= 0 && (t = thread) != null && !t.isInterrupted()) {
            try {
                t.interrupt();
            } catch (SecurityException ignore) {
            }
        }
    }
}
```

`Worker`的构造函数里面的逻辑十分重要，通过`ThreadFactory`创建的`Thread`实例同时传入`Worker`实例，因为`Worker`本身实现了`Runnable`，所以可以作为任务提交到线程中执行。只要`Worker`持有的线程实例`w`调用`Thread#start()`方法就能在合适时机执行`Worker#run()`。简化一下逻辑如下：

```
// addWorker()方法中构造
Worker worker = createWorker();
// 通过线程池构造时候传入
ThreadFactory threadFactory = getThreadFactory();
// Worker构造函数中
Thread thread = threadFactory.newThread(worker);
// addWorker()方法中启动
thread.start();
```

`Worker`继承自`AQS`，这里使用了`AQS`的独占模式，有个技巧是构造`Worker`的时候，把`AQS`的资源（状态）通过`setState(-1)`设置为-1，这是因为`Worker`实例刚创建时`AQS`中`state`的默认值为0，此时线程尚未启动，不能在这个时候进行线程中断，见`Worker#interruptIfStarted()`方法。`Worker`中两个覆盖`AQS`的方法`tryAcquire()`和`tryRelease()`都没有判断外部传入的变量，前者直接`CAS(0,1)`，后者直接`setState(0)`。接着看核心方法`ThreadPoolExecutor#runWorker()`：

```
final void runWorker(Worker w) {
    // 获取当前线程，实际上和Worker持有的线程实例是相同的
    Thread wt = Thread.currentThread();
    // 获取Worker中持有的初始化时传入的任务对象，这里注意存放在临时变量task中
    Runnable task = w.firstTask;
    // 设置Worker中持有的初始化时传入的任务对象为null
    w.firstTask = null;
    // 由于Worker初始化时AQS中state设置为-1，这里要先做一次解锁把state更新为0，允许线程中断
    w.unlock(); // allow interrupts
    // 记录线程是否因为用户异常终结，默认是true
    boolean completedAbruptly = true;
    try {
        // 初始化任务对象不为null，或者从任务队列获取任务不为空（从任务队列获取到的任务会更新到临时变量task中）
        // getTask()由于使用了阻塞队列，这个while循环如果命中后半段会处于阻塞或者超时阻塞状态，getTask()返回为null会导致线程跳出死循环使线程终结
        while (task != null || (task = getTask()) != null) {
            // Worker加锁，本质是AQS获取资源并且尝试CAS更新state由0更变为1
            w.lock();
            // If pool is stopping, ensure thread is interrupted;
            // if not, ensure thread is not interrupted.  This
            // requires a recheck in second case to deal with
            // shutdownNow race while clearing interrupt
            // 如果线程池正在停止（也就是由RUNNING或者SHUTDOWN状态向STOP状态变更），那么要确保当前工作线程是中断状态
            // 否则，要保证当前线程不是中断状态
            if ((runStateAtLeast(ctl.get(), STOP) ||
                    (Thread.interrupted() &&
                    runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            try {
                // 钩子方法，任务执行前
                beforeExecute(wt, task);
                try {
                    task.run();
                    // 钩子方法，任务执行后 - 正常情况
                    afterExecute(task, null);
                } catch (Throwable ex) {
                    // 钩子方法，任务执行后 - 异常情况
                    afterExecute(task, ex);
                    throw ex;
                }
            } finally {
                // 清空task临时变量，这个很重要，否则while会死循环执行同一个task
                task = null;
                // 累加Worker完成的任务数
                w.completedTasks++;
                // Worker解锁，本质是AQS释放资源，设置state为0
                w.unlock();
            }
        }
        // 走到这里说明某一次getTask()返回为null，线程正常退出
        completedAbruptly = false;
    } finally {
        // 处理线程退出，completedAbruptly为true说明由于用户异常导致线程非正常退出
        processWorkerExit(w, completedAbruptly);
    }
}
```

这里重点拆解分析一下判断当前工作线程中断状态的代码：

```
if ((runStateAtLeast(ctl.get(), STOP) ||
        (Thread.interrupted() &&
        runStateAtLeast(ctl.get(), STOP))) &&
    !wt.isInterrupted())
    wt.interrupt();
// 先简化一下判断逻辑，如下
// 判断线程池状态是否至少为STOP，rs >= STOP(1)
boolean atLeastStop = runStateAtLeast(ctl.get(), STOP);
// 判断线程池状态是否至少为STOP，同时判断当前线程的中断状态并且清空当前线程的中断状态
boolean interruptedAndAtLeastStop = Thread.interrupted() && runStateAtLeast(ctl.get(), STOP);
if (atLeastStop || interruptedAndAtLeastStop && !wt.isInterrupted()){
    wt.interrupt();
}
```

`Thread.interrupted()`方法获取线程的中断状态同时会清空该中断状态，这里之所以会调用这个方法是因为在执行上面这个`if`逻辑同时外部有可能调用`shutdownNow()`方法，`shutdownNow()`方法中也存在中断所有`Worker`线程的逻辑，但是由于`shutdownNow()`方法中会遍历所有`Worker`做线程中断，有可能无法及时在任务提交到`Worker`执行之前进行中断，所以这个中断逻辑会在`Worker`内部执行，就是`if`代码块的逻辑。这里还要注意的是：`STOP`状态下会拒绝所有新提交的任务，不会再执行任务队列中的任务，同时会中断所有`Worker`线程。也就是，**即使任务Runnable已经`runWorker()`中前半段逻辑取出，只要还没走到调用其Runnable#run()，都有可能被中断**。假设刚好发生了进入`if`代码块的逻辑同时外部调用了`shutdownNow()`方法，那么`if`逻辑内会判断线程中断状态并且重置，那么`shutdownNow()`方法中调用的`interruptWorkers()`就不会因为中断状态判断出现问题导致二次中断线程（会导致异常）。

小结一下上面`runWorker()`方法的核心流程：

1. `Worker`先执行一次解锁操作，用于解除不可中断状态。
2. 通过`while`循环调用`getTask()`方法从任务队列中获取任务（当然，首轮循环也有可能是外部传入的firstTask任务实例）。
3. 如果线程池更变为`STOP`状态，则需要确保工作线程是中断状态并且进行中断处理，否则要保证工作线程必须不是中断状态。
4. 执行任务实例`Runnale#run()`方法，任务实例执行之前和之后（包括正常执行完毕和异常执行情况）分别会调用钩子方法`beforeExecute()`和`afterExecute()`。
5. `while`循环跳出意味着`runWorker()`方法结束和工作线程生命周期结束（`Worker#run()`生命周期完结），会调用`processWorkerExit()`处理工作线程退出的后续工作。

![img](https://mmbiz.qpic.cn/mmbiz_jpg/wbiax4xEAl5ylvmQdibcicr8jgK9ibK68m1NOzxXJiar4VGsAn0QHMYXeibeHgExaDmDgvWOJibjdh4UNFGxMTvOeLbibQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

接下来分析一下从任务队列中获取任务的`getTask()`方法和处理线程退出的后续工作的`processWorkerExit()`方法。



*本文来源：http://8rr.co/2348*