# Thread     ThreadLocal      ThreadMap 对比

>see
>
>https://juejin.im/post/6846687590444171278



#  Thread     

## 线程状态转换图



![img](https://user-gold-cdn.xitu.io/2020/5/6/171ea47b8287af73?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



- NEW 初始状态
- RUNNABLE 运行状态
- BLOCKED 阻塞状态
- WAITING 等待状态
- TIME_WAITING 超时等待状态
- TERMINATED 终止状态

> 注意： 调用obj.wait()的线程需要先获取obj的monitor，wait()会释放obj的monitor并进入等待态。所以wait()/notify()都要与synchronized联用。

### 阻塞与等待的区别

阻塞：当一个线程试图获取对象锁（非java.util.concurrent库中的锁，即synchronized），而该锁被其他线程持有，则该线程进入阻塞状态。它的特点是使用简单，由JVM调度器来决定唤醒自己，而不需要由另一个线程来显式唤醒自己，不响应中断。

阻塞 一个线程因为等待临界区的锁被阻塞产生的状态

等待：当一个线程等待另一个线程通知调度器一个条件时，该线程进入等待状态。它的特点是需要等待另一个线程显式地唤醒自己，实现灵活，语义更丰富，可响应中断。例如调用：Object.wait()、Thread.join()以及等待Lock或Condition。 等待 一个线程进入了锁，但是需要等待其他线程执行某些操作

需要强调的是虽然synchronized和JUC里的Lock都实现锁的功能，但线程进入的状态是不一样的。synchronized会让线程进入阻塞态，而JUC里的Lock是用LockSupport.park()/unpark()来实现阻塞/唤醒的，会让线程进入等待态。但话又说回来，虽然等锁时进入的状态不一样，但被唤醒后又都进入runnable态，从行为效果来看又是一样的。 一个线程进入了锁，但是需要等待其他线程执行某些操作

## 主要操作

### start()

新启一个线程执行其run()方法，一个线程只能start一次。主要是通过调用native start0()来实现。

```
public synchronized void start() {
//判断是否首次启动
        if (threadStatus != 0)
            throw new IllegalThreadStateException();

        group.add(this);

        boolean started = false;
        try {
//启动线程
            start0();
            started = true;
        } finally {
            try {
                if (!started) {
                    group.threadStartFailed(this);
                }
            } catch (Throwable ignore) {
                /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
            }
        }
    }

    private native void start0();
复制代码
```

### run()

run()方法是不需要用户来调用的，当通过start方法启动一个线程之后，当该线程获得了CPU执行时间，便进入run方法体去执行具体的任务。注意，继承Thread类必须重写run方法，在run方法中定义具体要执行的任务。

### sleep()

sleep方法有两个重载版本

```
sleep(long millis)     //参数为毫秒

sleep(long millis,int nanoseconds)    //第一参数为毫秒，第二个参数为纳秒
复制代码
```

sleep相当于让线程睡眠，交出CPU，让CPU去执行其他的任务。

但是有一点要非常注意，sleep方法不会释放锁，也就是说如果当前线程持有对某个对象的锁，则即使调用sleep方法，其他线程也无法访问这个对象。

### yield()

调用yield方法会让当前线程交出CPU权限，让CPU去执行其他的线程。它跟sleep方法类似，同样不会释放锁。但是yield不能控制具体的交出CPU的时间，另外，yield方法只能让拥有相同优先级的线程有获取CPU执行时间的机会。

注意，调用yield方法并不会让线程进入阻塞状态，而是让线程重回就绪状态，它只需要等待重新获取CPU执行时间，这一点是和sleep方法不一样的。

### join()

join方法有三个重载版本

```
1 join()
2 join(long millis)     //参数为毫秒
3 join(long millis,int nanoseconds)    //第一参数为毫秒，第二个参数为纳秒
复制代码
```

join()实际是利用了wait()，只不过它不用等待notify()/notifyAll()，且不受其影响。它结束的条件是：1）等待时间到；2）目标线程已经run完（通过isAlive()来判断）。

```
public final synchronized void join(long millis) throws InterruptedException {
    long base = System.currentTimeMillis();
    long now = 0;

    if (millis < 0) {
        throw new IllegalArgumentException("timeout value is negative");
    }
    
    //0则需要一直等到目标线程run完
    if (millis == 0) {
        while (isAlive()) {
            wait(0);
        }
    } else {
        //如果目标线程未run完且阻塞时间未到，那么调用线程会一直等待。
        while (isAlive()) {
            long delay = millis - now;
            if (delay <= 0) {
                break;
            }
            wait(delay);
            now = System.currentTimeMillis() - base;
        }
    }
}
复制代码
```

### interrupt()

此操作会将线程的中断标志位置位，至于线程作何动作那要看线程了。

- 如果线程sleep()、wait()、join()等处于阻塞状态，那么线程会定时检查中断状态位如果发现中断状态位为true，则会在这些阻塞方法调用处抛出InterruptedException异常，并且在抛出异常后立即将线程的中断状态位清除，即重- 新设置为false。抛出异常是为了线程从阻塞状态醒过来，并在结束线程前让程序员有足够的时间来处理中断请求。
- 如果线程正在运行、争用synchronized、lock()等，那么是不可中断的，他们会忽略。

可以通过以下三种方式来判断中断：

- isInterrupted()

  此方法只会读取线程的中断标志位，并不会重置。

- interrupted()

  此方法读取线程的中断标志位，并会重置。

- throw InterruptException

  抛出该异常的同时，会重置中断标志位。







# ThreadLocal工具类

> ThreadLocal是一个本地线程副本变量工具类，主要用于将私有线程和该线程存放的副本对象做一个映射，各个线程之间的变量互不干扰。

官方说的还是比较明白了，提炼关键字`工具类`，在我看来ThreadLocal就是提供给每个线程操作变量的工具类，做到了线程之间的变量隔离目的

## 内部结构图



![img](https://user-gold-cdn.xitu.io/2020/7/2/1730fbcbacc9b26c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



接下来就是看图说话：

- 每个Thread线程内部都有一个ThreadLocalMap。
- Map里面存储线程本地对象ThreadLocal（key）和线程的变量副本（value）。
- Thread内部的Map是由ThreadLocal维护，ThreadLocal负责向map获取和设置线程的变量值。
- 一个Thread可以有多个ThreadLocal。

每个线程都有其独有的Map结构，而Map中存有的是ThreadLocal为Key变量副本为Vaule的键值对，以此达到变量隔离的目的。

平时是怎么使用ThreadLocal的?

```
package threadlocal;

/**
 * @Auther: Xianglei
 * @Company: Java编程之道
 * @Date: 2020/7/2 21:44
 * @Version 1.0
 */
public class main {
    private static ThreadLocal<String> sThreadLocal = new ThreadLocal<>();
    public static void main(String args[]) {
        sThreadLocal.set("这是在主线程中");
        System.out.println("线程名字：" + Thread.currentThread().getName() + "---" + sThreadLocal.get());
        //线程a
        new Thread(new Runnable() {
            @Override
            public void run() {
                sThreadLocal.set("这是在线程a中");
                System.out.println("线程名字：" + Thread.currentThread().getName() + "---" + sThreadLocal.get());
            }
        }, "线程a").start();
        //线程b
        new Thread(new Runnable() {
            @Override
            public void run() {
                sThreadLocal.set("这是在线程b中");
                System.out.println("线程名字：" + Thread.currentThread().getName() + "---" + sThreadLocal.get());
            }
        }, "线程b").start();
        //线程c  
        new Thread(() -> {
            sThreadLocal.set("这是在线程c中");
            System.out.println("线程名字：" + Thread.currentThread().getName() + "---" + sThreadLocal.get());
        }, "线程c").start();
    }
}

复制代码
```

输出结果如下

```
线程名字：main---这是在主线程中
线程名字：线程b---这是在线程b中
线程名字：线程a---这是在线程a中
线程名字：线程c---这是在线程c中
Process finished with exit code 0
复制代码
```

可以看出每个线程各通过ThreadLocal对自己ThreadLocalMap中的数据存取并没有出现脏读的现象。就是因为每个线程内部已经存储了ThreadLocal为Key变量副本为Vaule的键值对。（隔离了）

可能你有点懵，ThreadLocal是怎么把变量复制到Thread的ThreadLocalMap中的？



当我们初始化一个线程的时候其内部干去创建了一个`ThreadLocalMap的Map容器`待用。

```
public class Thread implements Runnable {
    /* ThreadLocal values pertaining to this thread. This map is maintained
     * by the ThreadLocal class. */
    ThreadLocal.ThreadLocalMap threadLocals = null;
}
复制代码
```

当ThreadLocalMap被创建加载的时候其静态内部类Entry也随之加载，完成初始化动作。

```
 static class Entry extends WeakReference<ThreadLocal<?>> {
        /** The value associated with this ThreadLocal. */
       Object value;
        Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
}
复制代码
```

到此，线程Thread内部的Map容器初始化完毕，那么它又是如何和ThreadLocal缠上关系，ThreadLocal又是如何管理键值对的关系。



## ThreadLocal探析

我们就其核心方法分析一下内部的逻辑，同时解答上述存在的疑问：

- set()方法用于保存当前线程的副本变量值。
- get()方法用于获取当前线程的副本变量值。
- initialValue()为当前线程初始副本变量值。
- remove()方法移除当前线程的副本变量值。

### set方法

```
/**
 * Sets the current thread's copy of this thread-local variable
 * to the specified value.  Most subclasses will have no need to
 * override this method, relying solely on the {@link #initialValue}
 * method to set the values of thread-locals.
 *
 * @param value the value to be stored in the current thread's copy of
 *        this thread-local.
 */
public void set(T value) {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
}

ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}

void createMap(Thread t, T firstValue) {
    t.threadLocals = new ThreadLocalMap(this, firstValue);
}
复制代码
```

解说一下你就懂了：

当我们在Thread内部调用set方法时:

- 第一步会去获取`调用当前方法的线程Thread`。
- 然后顺其自然的拿到当前`线程内部`的`ThreadLocalMap`容器。
- 最后就把变量`副本`给丢进去。

没了...懂了吗，ThreadLocal（就认为是个维护线程内部变量的工具！）只是在Set的时候去操作了Thread内部的·`ThreadLocalMap`将变量拷贝到了Thread内部的Map容器中，Key就是当前的ThreadLocal,Value就是变量的副本。

### get方法

```
/**
 * Returns the value in the current thread's copy of this
 * thread-local variable.  If the variable has no value for the
 * current thread, it is first initialized to the value returned
 * by an invocation of the {@link #initialValue} method.
 *
 * @return the current thread's value of this thread-local
 */
public T get() {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null)
            return (T)e.value;
    }
    return setInitialValue();
}

ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}

private T setInitialValue() {
    T value = initialValue();
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
    return value;
}

protected T initialValue() {
    return null;
}
复制代码
```

- 获取当前线程的ThreadLocalMap对象
- 从map中根据this（当前的threadlocal对象）获取线程存储的Entry节点。
- 从Entry节点获取存储的对应Value副本值返回。
- map为空的话返回初始值null，即线程变量副本为null。

### remove方法

清除Map中的KV

```
/**
 * Removes the current thread's value for this thread-local
 * variable.  If this thread-local variable is subsequently
 * {@linkplain #get read} by the current thread, its value will be
 * reinitialized by invoking its {@link #initialValue} method,
 * unless its value is {@linkplain #set set} by the current thread
 * in the interim.  This may result in multiple invocations of the
 * <tt>initialValue</tt> method in the current thread.
 *
 * @since 1.5
 */
public void remove() {
 ThreadLocalMap m = getMap(Thread.currentThread());
 if (m != null)
     m.remove(this);
}

ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}

 /**
  * Remove the entry for key.
  */
    private void remove(ThreadLocal<?> key) {
    Entry[] tab = table;
    int len = tab.length;
    int i = key.threadLocalHashCode & (len-1);
       for (Entry e = tab[i];
            e != null;
            e = tab[i = nextIndex(i, len)]) {
              if (e.get() == key) {
                  e.clear();
                  expungeStaleEntry(i);
                  return;
              }
          }
    }
复制代码
```

下面再认识一下`ThreadLocalMap`，一个真正存储（隔离）数据的东西。







## ThreadLocalMap

ThreadLocalMap是ThreadLocal的`内部类`，实现了一套自己的Map结构，咱们看一下内部的继承关系就一目了然。



![img](https://user-gold-cdn.xitu.io/2020/7/2/1730fec13ae2d54d?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



其Entry使用的是K-V方式来组织数据，Entry中key是ThreadLocal对象，且是一个弱引用（弱引用，生命周期只能存活到`下次GC前`）。

对于`弱引用`引发的问题我们`最后再说`。

```
static class Entry extends WeakReference<ThreadLocal<?>> {
        /** The value associated with this ThreadLocal. */
         Object value;

         Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
 }
复制代码
```

ThreadLocalMap的成员变量

```
static class ThreadLocalMap {
    /**
     * The initial capacity -- MUST be a power of two.
     */
    private static final int INITIAL_CAPACITY = 16;

    /**
     * The table, resized as necessary.
     * table.length MUST always be a power of two.
     */
    private Entry[] table;

    /**
     * The number of entries in the table.
     */
    private int size = 0;

    /**
     * The next size value at which to resize.
     */
    private int threshold; // Default to 0
}
复制代码
```

### HashCode 计算

ThreaLocalMap中没有采用传统的调用ThreadLocal的hashcode方法（继承自object的hashcode），而是调用`nexthashcode`，源码如下：

```
private final int threadLocalHashCode = nextHashCode();
private static AtomicInteger nextHashCode = new AtomicInteger();
 //1640531527 能够让hash槽位分布相当均匀
private static final int HASH_INCREMENT = 0x61c88647; 
private static int nextHashCode() {
      return nextHashCode.getAndAdd(HASH_INCREMENT);
}
复制代码
```

### Hash冲突

和HashMap的最大的不同在于，ThreadLocalMap解决Hash冲突的方式就是简单的步长加1或减1及线性探测，寻找下一个相邻的位置。

```
/**
 * Increment i modulo len.
 */
private static int nextIndex(int i, int len) {
    return ((i + 1 < len) ? i + 1 : 0);
}

/**
 * Decrement i modulo len.
 */
private static int prevIndex(int i, int len) {
    return ((i - 1 >= 0) ? i - 1 : len - 1);
}
复制代码
```

ThreadLocalMap采用线性探测的方式解决Hash冲突的效率很低，如有大量不同的ThreadLocal对象放入map中时发送冲突。所以建议每个线程只存一个变量（一个ThreadLocal）就不存在Hash冲突的问题，如果一个线程要保存set多个变量，就需要创建多个ThreadLocal，多个ThreadLocal放入Map中时会极大的增加Hash冲突的可能。

清楚意思吗？当你在一个线程需要保存多个变量时，你以为是多次set？你错了你得创建多个ThreadLocal，多次set的达不到存储多个变量的目的。

```
sThreadLocal.set("这是在线程a中");
复制代码
```

## Key的弱引用问题

看看官话，为什么要用弱引用。

> To help deal with very large and long-lived usages, the hash table entries use WeakReferences for keys.
>  为了处理`非常大`和`生命周期`非常长的线程，哈希表使用弱引用作为 key。

- 生命周期长：暂时可以想到线程池中的线程

ThreadLocal在没有外部对象强引用时如Thread，发生GC时弱引用Key会被回收，而Value是强引用不会回收，如果创建ThreadLocal的线程一直持续运行如线程池中的线程，那么这个Entry对象中的value就有可能一直得不到回收，发生内存泄露。

- key 如果使用强引用：引用的ThreadLocal的对象被回收了，但是ThreadLocalMap还持有ThreadLocal的强引用，如果没有手动删除，ThreadLocal不会被回收，导致Entry内存泄漏。
- key 使用弱引用：引用的ThreadLocal的对象被回收了，由于ThreadLocalMap持有ThreadLocal的弱引用，即使没有手动删除，ThreadLocal也会被回收。value在下一次ThreadLocalMap调用set,get，remove的时候会被清除。

Java8中已经做了一些优化如，在ThreadLocal的get()、set()、remove()方法调用的时候会清除掉线程ThreadLocalMap中所有Entry中Key为null的Value，并将整个Entry设置为null，利于下次内存回收。

Java8中for循环遍历整个Entry数组，遇到key=null的就会替换从而避免内存泄露的问题。

```
       private int expungeStaleEntry(int staleSlot) {
            Entry[] tab = table;
            int len = tab.length;

            // expunge entry at staleSlot
            tab[staleSlot].value = null;
            tab[staleSlot] = null;
            size--;

            // Rehash until we encounter null
            Entry e;
            int i;
            for (i = nextIndex(staleSlot, len);
                 (e = tab[i]) != null;
                 i = nextIndex(i, len)) {
                ThreadLocal<?> k = e.get();
                if (k == null) {
                    e.value = null;
                    tab[i] = null;
                    size--;
                } else {
                    int h = k.threadLocalHashCode & (len - 1);
                    if (h != i) {
                        tab[i] = null;
                        while (tab[h] != null)
                            h = nextIndex(h, len);
                        tab[h] = e;
                    }
                }
            }
            return i;
        }
复制代码
```

通常ThreadLocalMap的生命周期跟Thread（注意线程池中的Thread）一样长，如果没有手动删除对应key（线程使用结束归还给线程池了，其中的KV不再被使用但又不会GC回收，可认为是内存泄漏），一定会导致内存泄漏，但是使用弱引用可以多一层保障：弱引用ThreadLocal会被GC回收，不会内存泄漏，对应的value在下一次ThreadLocalMap`调用set,get,remove的时候会被清除`，Java8已经做了上面的代码优化。



## 总结

- 每个ThreadLocal只能保存一个变量副本，如果想要一个线程能够保存多个副本以上，就需要创建多个ThreadLocal。
- ThreadLocal内部的ThreadLocalMap键为弱引用，会有内存泄漏的风险。
- 每次使用完ThreadLocal，都调用它的remove()方法，清除数据。


