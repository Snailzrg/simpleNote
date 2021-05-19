[toc]

# 从源码的角度再学「Thread」



## 前言

`Java`中的线程是使用`Thread`类实现对`Thread`的实践更加得心应手。

## 从注释开始

相信阅读过`JDK`源码的同学都能感受到`JDK`源码中有非常详尽的注释，阅读某个类的源码应当先看看注释对它的介绍，注释原文就不贴了，以下是我对它的总结：

- `Thread`是程序中执行的线程，`Java`虚拟机允许应用程序同时允许多个执行线程

- 每个线程都有优先级的概念，具有较高优先级的线程优先于优先级较低的线程执行

- 每个线程都可以被设置为守护线程

- 当在某个线程中运行的代码创建一个新的`Thread`对象时，新的线程优先级跟创建线程一致

- 当`Java`虚拟机启动的时候都会启动一个叫做`main`的线程，它没有守护线程，`main`线程会继续执行，直到以下情况发送

  - `Runtime` 类的退出方法`exit`被调用并且安全管理器允许进行退出操作
  - 所有非守护线程均已死亡，或者`run`方法执行结束正常返回结果，或者`run`方法抛出异常

- 创建线程第一种方式：继承`Thread`类，重写`run`方法

  ```
  //定义线程类
  class PrimeThread extends Thread {
        long minPrime;
        PrimeThread(long minPrime) {
            this.minPrime = minPrime;
        }
        public void run() {
            // compute primes larger than minPrime
            &nbsp;.&nbsp;.&nbsp;.
        }
    }
  //启动线程
  PrimeThread p = new PrimeThread(143);
  p.start();
  复制代码
  ```

- 创建线程第二种方式：实现`Runnable`接口，重写`run`方法，因为`Java`的单继承限制，通常使用这种方式创建线程更加灵活

  ```
  //定义线程
   class PrimeRun implements Runnable {
        long minPrime;
        PrimeRun(long minPrime) {
            this.minPrime = minPrime;
        }
        public void run() {
            // compute primes larger than minPrime
            &nbsp;.&nbsp;.&nbsp;.
        }
    }
  //启动线程
  PrimeRun p = new PrimeRun(143);
  new Thread(p).start();
  复制代码
  ```

- 创建线程时可以给线程指定名字，如果没有指定，会自动为它生成名字

- 除非另有说明，否则将`null`参数传递给`Thread`类中的构造函数或方法将导致抛出 `NullPointerException`

## Thread 常用属性

阅读一个`Java`类，先从它拥有哪些属性入手：

```
//线程名称，创建线程时可以指定线程的名称
private volatile String name;

//线程优先级，可以设置线程的优先级
private int priority;

//可以配置线程是否为守护线程，默认为false
private boolean daemon = false;

//最终执行线程任务的`Runnable`
private Runnable target;

//描述线程组的类
private ThreadGroup group;

//此线程的上下文ClassLoader
private ClassLoader contextClassLoader;

//所有初始化线程的数目，用于自动编号匿名线程，当没有指定线程名称时，会自动为其编号
private static int threadInitNumber;

//此线程请求的堆栈大小，如果创建者没有指定堆栈大小，则为0。, 虚拟机可以用这个数字做任何喜欢的事情。, 一些虚拟机会忽略它。
private long stackSize;

//线程id
private long tid;

//用于生成线程ID
private static long threadSeqNumber;

//线程状态
private volatile int threadStatus = 0;

//线程可以拥有的最低优先级
public final static int MIN_PRIORITY = 1;

//分配给线程的默认优先级。
public final static int NORM_PRIORITY = 5;

//线程可以拥有的最大优先级
public final static int MAX_PRIORITY = 10;
复制代码
```

所有的属性命名都很语义化，其实已看名称基本就猜到它是干嘛的了，难度不大～～

## Thread 构造方法

了解了属性之后，看看`Thread`实例是怎么构造的？先预览下它大致有多少个构造方法：



![img](https://user-gold-cdn.xitu.io/2019/1/17/1685a93318677187?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



查看每个构造方法内部源码，发现均调用的是名为`init`的私有方法，再看`init`方法有两个重载，而其核心方法如下：

```
   /**
     * Initializes a Thread.
     *
     * @param g                   线程组
     * @param target              最终执行任务的 `run()` 方法的对象
     * @param name                新线程的名称
     * @param stackSize           新线程所需的堆栈大小，或者 0 表示要忽略此参数
     * @param acc                 要继承的AccessControlContext，如果为null，则为 AccessController.getContext()
     * @param inheritThreadLocals 如果为 true，从构造线程继承可继承的线程局部的初始值
     */
    private void init(ThreadGroup g, Runnable target, String name,
                      long stackSize, AccessControlContext acc,
                      boolean inheritThreadLocals) {
        //线程名称为空，直接抛出空指针异常
        if (name == null) {
            throw new NullPointerException("name cannot be null");
        }
        //初始化当前线程对象的线程名称
        this.name = name;
        //获取当前正在执行的线程为父线程
        Thread parent = currentThread();
        //获取系统安全管理器
        SecurityManager security = System.getSecurityManager();
        //如果线程组为空
        if (g == null) {
            //如果安全管理器不为空
            if (security != null) {
                //获取SecurityManager中的线程组
                g = security.getThreadGroup();
            }
            //如果获取的线程组还是为空
            if (g == null) {
                //则使用父线程的线程组
                g = parent.getThreadGroup();
            }
        }
        
        //检查安全权限
        g.checkAccess();

        //使用安全管理器检查是否有权限
        if (security != null) {
            if (isCCLOverridden(getClass())) {
                security.checkPermission(SUBCLASS_IMPLEMENTATION_PERMISSION);
            }
        }
        
        //线程组中标记未启动的线程数+1，这里方法是同步的，防止出现线程安全问题
        g.addUnstarted();
        
        //初始化当前线程对象的线程组
        this.group = g;
        //初始化当前线程对象的是否守护线程属性，注意到这里初始化时跟父线程一致
        this.daemon = parent.isDaemon();
        //初始化当前线程对象的线程优先级属性，注意到这里初始化时跟父线程一致
        this.priority = parent.getPriority();
        //这里初始化类加载器
        if (security == null || isCCLOverridden(parent.getClass()))
            this.contextClassLoader = parent.getContextClassLoader();
        else
            this.contextClassLoader = parent.contextClassLoader;
        this.inheritedAccessControlContext =
                acc != null ? acc : AccessController.getContext();
        //初始化当前线程对象的最终执行任务对象
        this.target = target;
        //这里再对线程的优先级字段进行处理
        setPriority(priority);
        if (inheritThreadLocals && parent.inheritableThreadLocals != null)
            this.inheritableThreadLocals =
                ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
        //初始化当前线程对象的堆栈大小
        this.stackSize = stackSize;

        //初始化当前线程对象的线程ID，该方法是同步的，内部实际上是threadSeqNumber++
        tid = nextThreadID();
    }
复制代码
```

另一个重载`init`私有方法如下，实际上内部调用的是上述`init`方法：

```
private void init(ThreadGroup g, Runnable target, String name,
                      long stackSize) {
        init(g, target, name, stackSize, null, true);
    }
复制代码
```

接下来看看所有构造方法：

1. 空构造方法

   ```
    public Thread() {
           init(null, null, "Thread-" + nextThreadNum(), 0);
       }
   复制代码
   ```

   内部调用的是`init`第二个重载方法，参数基本都是默认值，线程名称写死为`"Thread-" + nextThreadNum()`格式，`nextThreadNum()`为一个同步方法，内部维护一个静态属性表示线程的初始化数量+1：

   ```
    private static int threadInitNumber;
       private static synchronized int nextThreadNum() {
           return threadInitNumber++;
       }
   复制代码
   ```

2. 自定义执行任务`Runnable`对象的构造方法

   ```
   public Thread(Runnable target) {
       init(null, target, "Thread-" + nextThreadNum(), 0);
   }
   复制代码
   ```

   与第一个构造方法区别在于可以自定义`Runnable`对象

3. 自定义执行任务`Runnable`对象和`AccessControlContext`对象的构造方法

   ```
    Thread(Runnable target, AccessControlContext acc) {
       init(null, target, "Thread-" + nextThreadNum(), 0, acc, false);
   }
   复制代码
   ```

4. 自定义线程组`ThreadGroup`和执行任务`Runnable`对象的构造方法

   ```
   public Thread(ThreadGroup group, Runnable target) {
       init(group, target, "Thread-" + nextThreadNum(), 0);
   }
   复制代码
   ```

5. 自定义线程名称`name`的构造方法

   ```
    public Thread(String name) {
       init(null, null, name, 0);
   }
   复制代码
   ```

6. 自定义线程组`ThreadGroup`和线程名称`name`的构造方法

   ```
    public Thread(ThreadGroup group, String name) {
       init(group, null, name, 0);
   }
   复制代码
   ```

7. 自定义执行任务`Runnable`对象和线程名称`name`的构造方法

   ```
    public Thread(Runnable target, String name) {
       init(null, target, name, 0);
   }
   复制代码
   ```

8. 自定义线程组`ThreadGroup`和线程名称`name`和执行任务`Runnable`对象的构造方法

   ```
     public Thread(ThreadGroup group, Runnable target, String name) {
       init(group, target, name, 0);
   }
   复制代码
   ```

9. 全部属性都是自定义的构造方法

   ```
     public Thread(ThreadGroup group, Runnable target, String name,
                 long stackSize) {
       init(group, target, name, stackSize);
   }
   复制代码
   ```

`Thread`提供了非常灵活的重载构造方法，方便开发者自定义各种参数的`Thread`对象。

## 常用方法

这里记录一些比较常见的方法吧，对于`Thread`中存在的一些本地方法，我们暂且不用管它～

#### 设置线程名称

设置线程名称，该方法为同步方法，为了防止出现线程安全问题，可以手动调用`Thread`的实例方法设置名称，也可以在构造`Thread`时在构造方法中传入线程名称，我们通常都是在构造参数时设置

```
   public final synchronized void setName(String name) {
       &emsp;&emsp;//检查安全权限
          checkAccess();
       &emsp;&emsp;//如果形参为空，抛出空指针异常
          if (name == null) {
              throw new NullPointerException("name cannot be null");
          }
  	  //给当前线程对象设置名称
          this.name = name;
          if (threadStatus != 0) {
              setNativeName(name);
          }
      }
复制代码
```

#### 获取线程名称

内部直接返回当前线程对象的名称属性

```
  public final String getName() {
        return name;
    }
复制代码
```

#### 启动线程

```
public synchronized void start() {
        //如果不是刚创建的线程，抛出异常
        if (threadStatus != 0)
            throw new IllegalThreadStateException();

        //通知线程组，当前线程即将启动，线程组当前启动线程数+1，未启动线程数-1
        group.add(this);
        
        //启动标识
        boolean started = false;
        try {
            //直接调用本地方法启动线程
            start0();
            //设置启动标识为启动成功
            started = true;
        } finally {
            try {
                //如果启动呢失败
                if (!started) {
                    //线程组内部移除当前启动的线程数量-1，同时启动失败的线程数量+1
                    group.threadStartFailed(this);
                }
            } catch (Throwable ignore) {
                /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
            }
        }
    }
复制代码
```

我们正常的启动线程都是调用`Thread`的`start()`方法，然后`Java`虚拟机内部会去调用`Thred`的`run`方法，可以看到`Thread`类也是实现`Runnable`接口，重写了`run`方法的：

```
 @Override
    public void run() {
        //当前执行任务的Runnable对象不为空，则调用其run方法
        if (target != null) {
            target.run();
        }
    }
复制代码
```

`Thread`的两种使用方式：

- 继承`Thread`类，重写`run`方法，那么此时是直接执行`run`方法的逻辑，不会使用`target.run();`
- 实现`Runnable`接口，重写`run`方法，因为`Java`的单继承限制，通常使用这种方式创建线程更加灵活，这里真正的执行逻辑就会交给自定义`Runnable`去实现

#### 设置守护线程

本质操作是设置`daemon`属性

```
public final void setDaemon(boolean on) {
        //检查是否有安全权限
        checkAccess();
        //本地方法，测试此线程是否存活。, 如果一个线程已经启动并且尚未死亡，则该线程处于活动状态
        if (isAlive()) {
            //如果线程先启动后再设置守护线程，将抛出异常
            throw new IllegalThreadStateException();
        }
        //设置当前守护线程属性
        daemon = on;
    }
复制代码
```

#### 判断线程是否为守护线程

```
 public final boolean isDaemon() {
        //直接返回当前对象的守护线程属性
        return daemon;
    }
复制代码
```

#### 线程状态

先来个线程状态图：



![img](https://user-gold-cdn.xitu.io/2019/1/20/1686a3f7ad48fb61?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



获取线程状态：

```
 public State getState() {
        //由虚拟机实现，获取当前线程的状态
        return sun.misc.VM.toThreadState(threadStatus);
    }
复制代码
```

线程状态主要由内部枚举类`State`组成：

```
  public enum State {
      
        NEW,

      
        RUNNABLE,

      
        BLOCKED,

       
        WAITING,

       
        TIMED_WAITING,

       
        TERMINATED;
    }
复制代码
```

- NEW：刚刚创建，尚未启动的线程处于此状态
- RUNNABLE：在Java虚拟机中执行的线程处于此状态
- BLOCKED：被阻塞等待监视器锁的线程处于此状态，比如线程在执行过程中遇到`synchronized`同步块，就会进入此状态，此时线程暂停执行，直到获得请求的锁
- WAITING：无限期等待另一个线程执行特定操作的线程处于此状态
  - 通过 wait() 方法等待的线程在等待 notify() 方法
  - 通过 join() 方法等待的线程则会等待目标线程的终止
- TIMED_WAITING：正在等待另一个线程执行动作，直到指定等待时间的线程处于此状态
  - 通过 wait() 方法，携带超时时间，等待的线程在等待 notify() 方法
  - 通过 join() 方法，携带超时时间，等待的线程则会等待目标线程的终止
- TERMINATED：已退出的线程处于此状态，此时线程无法再回到 RUNNABLE 状态

#### 线程休眠

这是一个静态的本地方法，使当前执行的线程休眠暂停执行 `millis` 毫秒，当休眠被中断时会抛出`InterruptedException`中断异常

```
    /**
     * Causes the currently executing thread to sleep (temporarily cease
     * execution) for the specified number of milliseconds, subject to
     * the precision and accuracy of system timers and schedulers. The thread
     * does not lose ownership of any monitors.
     *
     * @param  millis
     *         the length of time to sleep in milliseconds
     *
     * @throws  IllegalArgumentException
     *          if the value of {@code millis} is negative
     *
     * @throws  InterruptedException
     *          if any thread has interrupted the current thread. The
     *          <i>interrupted status</i> of the current thread is
     *          cleared when this exception is thrown.
     */
    public static native void sleep(long millis) throws InterruptedException;
复制代码
```

#### 检查线程是否存活

本地方法，测试此线程是否存活。 如果一个线程已经启动并且尚未死亡，则该线程处于活动状态。

```
    /**
     * Tests if this thread is alive. A thread is alive if it has
     * been started and has not yet died.
     *
     * @return  <code>true</code> if this thread is alive;
     *          <code>false</code> otherwise.
     */
    public final native boolean isAlive();
复制代码
```

#### 线程优先级

- 设置线程优先级

```
    /**
     * Changes the priority of this thread.
     * <p>
     * First the <code>checkAccess</code> method of this thread is called
     * with no arguments. This may result in throwing a
     * <code>SecurityException</code>.
     * <p>
     * Otherwise, the priority of this thread is set to the smaller of
     * the specified <code>newPriority</code> and the maximum permitted
     * priority of the thread's thread group.
     *
     * @param newPriority priority to set this thread to
     * @exception  IllegalArgumentException  If the priority is not in the
     *               range <code>MIN_PRIORITY</code> to
     *               <code>MAX_PRIORITY</code>.
     * @exception  SecurityException  if the current thread cannot modify
     *               this thread.
     * @see        #getPriority
     * @see        #checkAccess()
     * @see        #getThreadGroup()
     * @see        #MAX_PRIORITY
     * @see        #MIN_PRIORITY
     * @see        ThreadGroup#getMaxPriority()
     */
    public final void setPriority(int newPriority) {
        //线程组
        ThreadGroup g;
        //检查安全权限
        checkAccess();
        //检查优先级形参范围
        if (newPriority > MAX_PRIORITY || newPriority < MIN_PRIORITY) {
            throw new IllegalArgumentException();
        }
        if((g = getThreadGroup()) != null) {
            //如果优先级形参大于线程组最大线程最大优先级
            if (newPriority > g.getMaxPriority()) {
                //则使用线程组的优先级数据
                newPriority = g.getMaxPriority();
            }
            //调用本地设置线程优先级方法
            setPriority0(priority = newPriority);
        }
    }
复制代码
```

#### 线程中断

有一个`stop()`实例方法可以强制终止线程，不过这个方法因为太过于暴力，已经被标记为过时方法，不建议程序员再使用，因为**强制终止线程**会导致数据不一致的问题。

这里关于线程中断的方法涉及三个：

```
//实例方法，通知线程中断，设置标志位
 public void interrupt(){}
 //静态方法，检查当前线程的中断状态，同时会清除当前线程的中断标志位状态
 public static boolean interrupted(){}
 //实例方法，检查当前线程是否被中断，其实是检查中断标志位
 public boolean isInterrupted(){}
复制代码
```

**interrupt() 方法解析**

```
/**
     * Interrupts this thread.
     *
     * <p> Unless the current thread is interrupting itself, which is
     * always permitted, the {@link #checkAccess() checkAccess} method
     * of this thread is invoked, which may cause a {@link
     * SecurityException} to be thrown.
     *
     * <p> If this thread is blocked in an invocation of the {@link
     * Object#wait() wait()}, {@link Object#wait(long) wait(long)}, or {@link
     * Object#wait(long, int) wait(long, int)} methods of the {@link Object}
     * class, or of the {@link #join()}, {@link #join(long)}, {@link
     * #join(long, int)}, {@link #sleep(long)}, or {@link #sleep(long, int)},
     * methods of this class, then its interrupt status will be cleared and it
     * will receive an {@link InterruptedException}.
     *
     * <p> If this thread is blocked in an I/O operation upon an {@link
     * java.nio.channels.InterruptibleChannel InterruptibleChannel}
     * then the channel will be closed, the thread's interrupt
     * status will be set, and the thread will receive a {@link
     * java.nio.channels.ClosedByInterruptException}.
     *
     * <p> If this thread is blocked in a {@link java.nio.channels.Selector}
     * then the thread's interrupt status will be set and it will return
     * immediately from the selection operation, possibly with a non-zero
     * value, just as if the selector's {@link
     * java.nio.channels.Selector#wakeup wakeup} method were invoked.
     *
     * <p> If none of the previous conditions hold then this thread's interrupt
     * status will be set. </p>
     *
     * <p> Interrupting a thread that is not alive need not have any effect.
     *
     * @throws  SecurityException
     *          if the current thread cannot modify this thread
     *
     * @revised 6.0
     * @spec JSR-51
     */
    public void interrupt() {
        //检查是否是自身调用
        if (this != Thread.currentThread())
            //检查安全权限,这可能导致抛出{@link * SecurityException}。
            checkAccess();
        
        //同步代码块
        synchronized (blockerLock) {
            Interruptible b = blocker;
            //检查是否是阻塞线程调用
            if (b != null) {
                //设置线程中断标志位
                interrupt0(); 
                //此时抛出异常，将中断标志位设置为false,此时我们正常会捕获该异常，重新设置中断标志位
                b.interrupt(this);
                return;
            }
        }
        //如无意外，则正常设置中断标志位
        interrupt0();
    }
复制代码
```

- 线程中断方法不会使线程立即退出，而是给线程发送一个通知，告知目标线程，有人希望你退出啦～
- 只能由自身调用，否则可能会抛出 `SecurityException`
- 调用中断方法是由目标线程自己决定是否中断，而如果同时调用了`wait`,`join`,`sleep`等方法，会使当前线程进入阻塞状态，此时有可能发生`InterruptedException`异常
- 被阻塞的线程再调用中断方法是不合理的
- 中断不活动的线程不会产生任何影响

检查线程是否被中断:

```
    /**
     * Tests whether this thread has been interrupted.  The <i>interrupted
     * status</i> of the thread is unaffected by this method.
     
     测试此线程是否已被中断。, 线程的<i>中断*状态</ i>不受此方法的影响。
     *
     * <p>A thread interruption ignored because a thread was not alive
     * at the time of the interrupt will be reflected by this method
     * returning false.
     *
     * @return  <code>true</code> if this thread has been interrupted;
     *          <code>false</code> otherwise.
     * @see     #interrupted()
     * @revised 6.0
     */
    public boolean isInterrupted() {
        return isInterrupted(false);
    }
复制代码
```

静态方法,会清空当前线程的中断标志位：

```
   /**
     *测试当前线程是否已被中断。, 此方法清除线程的* <i>中断状态</ i>。, 换句话说，如果要连续两次调用此方法，则* second调用将返回false（除非当前线程再次被中断，在第一次调用已清除其中断的*状态   之后且在第二次调用已检查之前）, 它）
     *
     * <p>A thread interruption ignored because a thread was not alive
     * at the time of the interrupt will be reflected by this method
     * returning false.
     *
     * @return  <code>true</code> if the current thread has been interrupted;
     *          <code>false</code> otherwise.
     * @see #isInterrupted()
     * @revised 6.0
     */
    public static boolean interrupted() {
        return currentThread().isInterrupted(true);
    }

复制代码
```

## 总结

记录自己阅读`Thread`类源码的一些思考，不过对于其中用到的很多本地方法只能望而却步，还有一些代码没有看明白，暂且先这样吧，如果有不足之处，请留言告知我，谢谢！后续会在实践中对`Thread`做出更多总结记录。