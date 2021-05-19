[toc]

# AQS基础——多图详解CLH锁的原理与实现

> 源码笔记，专注于Java后端系列框架的源码分析。关注【源码笔记】公众号，第一时间接收最新源码分析文章更新。

# 1 什么是自旋锁和互斥锁？

由于CLH锁是一种自旋锁，那么我们先来看看自旋锁是什么？

**自旋锁**说白了也是一种互斥锁，只不过没有抢到锁的线程会一直自旋等待锁的释放，处于**busy-waiting**的状态，此时等待锁的线程不会进入休眠状态，而是一直忙等待浪费CPU周期。**因此自旋锁适用于锁占用时间短的场合。**

这里谈到了自旋锁，那么我们也顺便说下互斥锁。这里的**互斥锁**说的是传统意义的互斥锁，就是多个线程并发竞争锁的时候，没有抢到锁的线程会进入休眠状态即**sleep-waiting**，当锁被释放的时候，处于休眠状态的一个线程会再次获取到锁。缺点就是这一些列过程需要线程切换，需要执行很多CPU指令，同样需要时间。如果CPU执行线程切换的时间比锁占用的时间还长，那么可能还不如使用自旋锁。**因此互斥锁适用于锁占用时间长的场合。**

# 2 什么是CLH锁？

**CLH锁**其实就是一种是基于逻辑队列非线程饥饿的一种自旋公平锁，由于是 Craig、Landin 和 Hagersten三位大佬的发明，因此命名为CLH锁。

**CLH锁原理如下：**

1. 首先有一个尾节点指针，通过这个尾结点指针来构建等待线程的逻辑队列，因此能确保线程线程先到先服务的公平性，因此尾指针可以说是构建逻辑队列的桥梁；此外这个尾节点指针是原子引用类型，避免了多线程并发操作的线程安全性问题；
2. 通过等待锁的每个线程在自己的某个变量上自旋等待，这个变量将由前一个线程写入。由于某个线程获取锁操作时总是通过尾节点指针获取到前一线程写入的变量，而尾节点指针又是原子引用类型，因此确保了这个变量获取出来总是线程安全的。

这么说肯定很抽象，有些小伙伴可能不理解，没关系，我们心中可以有个概念即可，后面我们会一步一图来彻彻底底把CLH锁弄明白。

# 3 为什么要学习CLH锁？

好了，前面我们对CLH锁有了一个概念后，那么我们为什么要学习CLH锁呢？

研究过AQS源码的小伙伴们应该知道，AQS是JUC的核心，而CLH锁又是AQS的基础，说核心也不为过，因为AQS就是用了变种的CLH锁。如果要学好Java并发编程，那么必定要学好JUC；学好JUC，必定要先学好AQS；学好AQS，那么必定先学好CLH。因此，这就是我们为什么要学习CLH锁的原因。

# 4 CLH锁详解

那么，下面我们先来看CLH锁实现代码，然后通过一步一图来详解CLH锁。

```java
// CLHLock.java

public class CLHLock {
    /**
     * CLH锁节点
     */
    private static class CLHNode {
        // 锁状态：默认为false，表示线程没有获取到锁；true表示线程获取到锁或正在等待
        // 为了保证locked状态是线程间可见的，因此用volatile关键字修饰
        volatile boolean locked = false;
    }
    // 尾结点，总是指向最后一个CLHNode节点
    // 【注意】这里用了java的原子系列之AtomicReference，能保证原子更新
    private final AtomicReference<CLHNode> tailNode;
    // 当前节点的前继节点
    private final ThreadLocal<CLHNode> predNode;
    // 当前节点
    private final ThreadLocal<CLHNode> curNode;

    // CLHLock构造函数，用于新建CLH锁节点时做一些初始化逻辑
    public CLHLock() {
        // 初始化时尾结点指向一个空的CLH节点
        tailNode = new AtomicReference<>(new CLHNode());
        // 初始化当前的CLH节点
        curNode = new ThreadLocal() {
            @Override
            protected CLHNode initialValue() {
                return new CLHNode();
            }
        };
        // 初始化前继节点，注意此时前继节点没有存储CLHNode对象，存储的是null
        predNode = new ThreadLocal();
    }

    /**
     * 获取锁
     */
    public void lock() {
        // 取出当前线程ThreadLocal存储的当前节点，初始化值总是一个新建的CLHNode，locked状态为false。
        CLHNode currNode = curNode.get();
        // 此时把lock状态置为true，表示一个有效状态，
        // 即获取到了锁或正在等待锁的状态
        currNode.locked = true;
        // 当一个线程到来时，总是将尾结点取出来赋值给当前线程的前继节点；
        // 然后再把当前线程的当前节点赋值给尾节点
        // 【注意】在多线程并发情况下，这里通过AtomicReference类能防止并发问题
        // 【注意】哪个线程先执行到这里就会先执行predNode.set(preNode);语句，因此构建了一条逻辑线程等待链
        // 这条链避免了线程饥饿现象发生
        CLHNode preNode = tailNode.getAndSet(currNode);
        // 将刚获取的尾结点（前一线程的当前节点）付给当前线程的前继节点ThreadLocal
        // 【思考】这句代码也可以去掉吗，如果去掉有影响吗？
        predNode.set(preNode);
        // 【1】若前继节点的locked状态为false，则表示获取到了锁，不用自旋等待；
        // 【2】若前继节点的locked状态为true，则表示前一线程获取到了锁或者正在等待，自旋等待
        while (preNode.locked) {
            System.out.println("线程" + Thread.currentThread().getName() + "没能获取到锁，进行自旋等待。。。");
        }
        // 能执行到这里，说明当前线程获取到了锁
        System.out.println("线程" + Thread.currentThread().getName() + "获取到了锁！！！");
    }

    /**
     * 释放锁
     */
    public void unLock() {
        // 获取当前线程的当前节点
        CLHNode node = curNode.get();
        // 进行解锁操作
        // 这里将locked至为false，此时执行了lock方法正在自旋等待的后继节点将会获取到锁
        // 【注意】而不是所有正在自旋等待的线程去并发竞争锁
        node.locked = false;
        System.out.println("线程" + Thread.currentThread().getName() + "释放了锁！！！");
        // 小伙伴们可以思考下，下面两句代码的作用是什么？？
        CLHNode newCurNode = new CLHNode();
        curNode.set(newCurNode);

        // 【优化】能提高GC效率和节省内存空间，请思考：这是为什么？
        // curNode.set(predNode.get());
    }
}
复制代码
```

# 4.1 CLH锁的初始化逻辑

通过上面代码，我们缕一缕CLH锁的初始化逻辑先：

1. 定义了一个

   ```
   CLHNode
   ```

   节点，里面有一个

   ```
   locked
   ```

   属性，表示线程线程是否获得锁，默认为

   ```
   false
   ```

   。

   ```
   false
   ```

   表示线程没有获取到锁或已经释放锁；

   ```
   true
   ```

   表示线程获取到了锁或者正在自旋等待。

   > 注意，为了保证`locked`属性线程间可见，该属性被`volatile`修饰。

2. `CLHLock`有三个重要的成员变量尾节点指针`tailNode`,当前线程的前继节点`preNode`和当前节点`curNode`。其中`tailNode`是`AtomicReference`类型，目的是为了保证尾节点的线程安全性；此外，`preNode`和`curNode`都是`ThreadLocal`类型即线程本地变量类型，用来保存每个线程的前继`CLHNode`和当前`CLHNode`节点。

3. 最重要的是我们新建一把`CLHLock`对象时，此时会执行构造函数里面的初始化逻辑。此时给尾指针`tailNode`和当前节点`curNode`初始化一个`locked`状态为`false`的`CLHNode`节点，此时前继节点`preNode`存储的是`null`。

# 4.2 CLH锁的加锁过程

我们再来看看CLH锁的加锁过程，下面再贴一遍加锁`lock`方法的代码：

```java
// CLHLock.java

/**
 * 获取锁
 */
public void lock() {
    // 取出当前线程ThreadLocal存储的当前节点，初始化值总是一个新建的CLHNode，locked状态为false。
    CLHNode currNode = curNode.get();
    // 此时把lock状态置为true，表示一个有效状态，
    // 即获取到了锁或正在等待锁的状态
    currNode.locked = true;
    // 当一个线程到来时，总是将尾结点取出来赋值给当前线程的前继节点；
    // 然后再把当前线程的当前节点赋值给尾节点
    // 【注意】在多线程并发情况下，这里通过AtomicReference类能防止并发问题
    // 【注意】哪个线程先执行到这里就会先执行predNode.set(preNode);语句，因此构建了一条逻辑线程等待链
    // 这条链避免了线程饥饿现象发生
    CLHNode preNode = tailNode.getAndSet(currNode);
    // 将刚获取的尾结点（前一线程的当前节点）付给当前线程的前继节点ThreadLocal
    // 【思考】这句代码也可以去掉吗，如果去掉有影响吗？
    predNode.set(preNode);
    // 【1】若前继节点的locked状态为false，则表示获取到了锁，不用自旋等待；
    // 【2】若前继节点的locked状态为true，则表示前一线程获取到了锁或者正在等待，自旋等待
    while (preNode.locked) {
        try {
            Thread.sleep(1000);
        } catch (Exception e) {

        }
        System.out.println("线程" + Thread.currentThread().getName() + "没能获取到锁，进行自旋等待。。。");
    }
    // 能执行到这里，说明当前线程获取到了锁
    System.out.println("线程" + Thread.currentThread().getName() + "获取到了锁！！！");
}
复制代码
```

虽然代码的注释已经很详细，我们还是缕一缕线程加锁的过程：

1. 首先获得当前线程的当前节点`curNode`，这里每次获取的`CLHNode`节点的`locked`状态都为`false`；
2. 然后将当前`CLHNode`节点的`locked`状态赋值为`true`，表示当前线程的一种有效状态，即获取到了锁或正在等待锁的状态；
3. 因为尾指针`tailNode`的总是指向了前一个线程的`CLHNode`节点，因此这里利用尾指针`tailNode`取出前一个线程的`CLHNode`节点，然后赋值给当前线程的前继节点`predNode`，并且将尾指针重新指向最后一个节点即当前线程的当前`CLHNode`节点，以便下一个线程到来时使用；
4. 根据前继节点（前一个线程）的`locked`状态判断，若`locked`为`false`，则说明前一个线程释放了锁，当前线程即可获得锁，不用自旋等待；若前继节点的locked状态为true，则表示前一线程获取到了锁或者正在等待，自旋等待。

为了更通俗易懂，我们用一个图里来说明。

**假如有这么一个场景：**有四个并发线程同时启动执行lock操作，假如四个线程的实际执行顺序为：threadA<--threadB<--threadC<--threadD

**第一步**，线程A过来，执行了lock操作，获得了锁，此时`locked`状态为`true`，如下图：



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



**第二步**，线程B过来，执行了lock操作，由于线程A还未释放锁，此时自旋等待，`locked`状态也为`true`，如下图：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/83fc46bdb44d428db15187a6f63e1203~tplv-k3u1fbpfcp-zoom-1.image)

**第三步**，线程C过来，执行了lock操作，由于线程B处于自旋等待，此时线程C也自旋等待（因此CLH锁是公平锁），`locked`状态也为`true`，如下图：

![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/38f87749cf5245a0aaab2656bbef487b~tplv-k3u1fbpfcp-zoom-1.image)

**第四步**，线程D过来，执行了lock操作，由于线程C处于自旋等待，此时线程D也自旋等待，`locked`状态也为`true`，如下图：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/79573b02617c44f18d9c7000b11e91a2~tplv-k3u1fbpfcp-zoom-1.image)



这就是多个线程并发加锁的一个过程图解，当前线程只要判断前一线程的`locked`状态如果是`true`，那么则说明前一线程要么拿到了锁，要么也处于自旋等待状态，所以自己也要自旋等待。而尾指针`tailNode`总是指向最后一个线程的`CLHNode`节点。

# 4.3 CLH锁的释放锁过程

前面用图解结合代码说明了CLH锁的加锁过程，那么，CLH锁的释放锁的过程又是怎样的呢？ 同样，我们先贴下释放锁的代码：

```java
// CLHLock.java

/**
 * 释放锁
 */
public void unLock() {
    // 获取当前线程的当前节点
    CLHNode node = curNode.get();
    // 进行解锁操作
    // 这里将locked至为false，此时执行了lock方法正在自旋等待的后继节点将会获取到锁
    // 【注意】而不是所有正在自旋等待的线程去并发竞争锁
    node.locked = false;
    System.out.println("线程" + Thread.currentThread().getName() + "释放了锁！！！");
    // 小伙伴们可以思考下，下面两句代码的作用是什么？？？
    CLHNode newCurNode = new CLHNode();
    curNode.set(newCurNode);

    // 【优化】能提高GC效率和节省内存空间，请思考：这是为什么？
    // curNode.set(predNode.get());
}
复制代码
```

可以看到释放CLH锁的过程代码比加锁简单多了，下面同样缕一缕：

1. 首先从当前线程的线程本地变量中获取出当前`CLHNode`节点，同时这个`CLHNode`节点被后面一个线程的`preNode`变量指向着；

2. 然后将

   ```
   locked
   ```

   状态置为

   ```
   false
   ```

   即释放了锁；

   > **注意：**`locked`因为被`volitile`关键字修饰，此时后面自旋等待的线程的局部变量`preNode.locked`也为`false`，因此后面自旋等待的线程结束`while`循环即结束自旋等待，此时也获取到了锁。这一步骤也在异步进行着。

3. 然后给当前线程的表示当前节点的线程本地变量重新赋值为一个新的

   ```
   CLHNode
   ```

   。

   > **思考**：这一步看上去是多余的，其实并不是。请思考下为什么这么做？我们后续会继续深入讲解。

我们还是用一个图来说说明CLH锁释放锁的场景，接着前面四个线程加锁的场景，假如这四个线程加锁后，线程A开始释放锁，此时线程B获取到锁，结束自旋等待，然后线程C和线程D仍然自旋等待，如下图：

![img](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95aed735469547dbb8dbf4552c1e5963~tplv-k3u1fbpfcp-zoom-1.image)

以此类推，线程B释放锁的过程也跟上图类似，这里不再赘述。



# 4.4 考虑同个线程加锁释放锁再次正常获取锁的情况

在前面**4.3小节**讲到释放锁`unLock`方法中有下面两句代码：

```java
  CLHNode newCurNode = new CLHNode();
  curNode.set(newCurNode);
复制代码
```

这两句代码的作用是什么？这里先直接说结果：若没有这两句代码，若同个线程加锁释放锁后，然后再次执行加锁操作，这个线程就会陷入自旋等待的状态。这是为啥，可能有些下伙伴也没明白，劲越也是搞了蛮久才搞明白，嘿嘿。

下面我们同样通过一步一图的形式来分析这两句代码的作用。 假如有下面这样一个场景：线程A获取到了锁，然后释放锁，然后再次获取锁。

**第一步：** 线程A执行了lock操作，获取到了锁，如下图：

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



上图的加锁操作中，线程A的当前`CLHNode`节点的`locked`状态被置为`true`；然后`tailNode`指针指向了当前线程的当前节点；最后因为前继节点的`locked`状态为`false`，不用自旋等待，因此获得了锁。

**第二步：** 线程A执行了unLock操作，释放了锁，如下图：

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



上图的释放锁操作中，线程A的当前`CLHNode`节点的`locked`状态被置为`false`，表示释放了锁；然后新建了一个新的`CLHNode`节点`newCurNode`，线程A的当前节点线程本地变量值重新指向了`newCurNode`节点对象。

**第三步：** 线程A再次执行lock操作，重新获得锁，如下图：



![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4885911ba0284edead37d94f00e6973f~tplv-k3u1fbpfcp-zoom-1.image)



上图的再次获取锁操作中，首先将线程A的当前`CLHNode`节点的`locked`状态置为`true`；然后首先通过`tailNode`尾指针获取到前继节点即第一，二步中的`curNode`对象，然后线程A的前继节点线程本地变量的值重新指向了重新指向了`curNode`对象；然后`tailNode`尾指针重新指向了新创建的`CLHNode`节点`newCurNode`对象。最后因为前继节点的`locked`状态为`false`，不用自旋等待，因此获得了锁。

> **扩展：** 注意到以上图片的`preNode`对象此时没有任何引用，所以当下一次会被GC掉。前面是通过每次执行`unLock`操作都新建一个新的`CLHNode`节点对象`newCurNode`，然后让线程A的当前节点线程本地变量值重新指向`newCurNode`。因此这里完全不用重新创建新的`CLHNode`节点对象，可以通过`curNode.set(predNode.get());`这句代码进行优化，提高GC效率和节省内存空间。

# 4.5 考虑同个线程加锁释放锁再次获取锁异常的情况

现在我们把`unLock`方法的`CLHNode newCurNode = new CLHNode();`和`curNode.set(newCurNode);`这两句代码注释掉，变成了下面这样：

```java
// CLHLock.java

public void unLock() {
    CLHNode node = curNode.get();
    node.locked = false;
    System.out.println("线程" + Thread.currentThread().getName() + "释放了锁！！！");
    /*CLHNode newCurNode = new CLHNode();
    curNode.set(newCurNode);*/
}
复制代码
```

那么结果就是线程A通过加锁，释放锁后，再次获取锁时就会陷入自旋等待的状态，这又是为什么呢？我们下面来详细分析。

**第一步：** 线程A执行了lock操作，获取到了锁，如下图：

![img](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87ff8e6e9e06439abd61461b82392bff~tplv-k3u1fbpfcp-zoom-1.image)



上图的加锁操作中，线程A的当前`CLHNode`节点的`locked`状态被置为`true`；然后`tailNode`指针指向了当前线程的当前节点；最后因为前继节点的`locked`状态为`false`，不用自旋等待，因此获得了锁。这一步没有什么异常。

**第二步：** 线程A执行了unLock操作，释放了锁，如下图：



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)

现在已经把`unLock`方法的`CLHNode newCurNode = new CLHNode();`和`curNode.set(newCurNode);`这两句代码注释掉了，因此上图的变化就是线程A的当前`CLHNode`节点的`locked`状态置为`false`即!可。



**第三步:** 线程A再次执行lock操作，此时会陷入一直自旋等待的状态，如下图：

![img](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0a5b76b5f6342eea6d22dce78e5658d~tplv-k3u1fbpfcp-zoom-1.image)

通过上图对线程A再次获取锁的`lock`方法的每一句代码进行分析，得知虽然第二步中将线程A的当前`CLHNode`的`locked`状态置为`false`了，但是在第三步线程A再次获取锁的过程中，将当前`CLHNode`的`locked`状态又置为`true`了，且尾指针`tailNode`指向的依然还是线程A的当前当前`CLHNode`节点。又因为每次都是将尾指针`tailNode`指向的`CLHNode`节点取出来给当前线程的前继`CLHNode`节点，之后执行`while(predNode.locked) {}`语句时，此时因为`predNode.locked = true`，因此线程A就永远自旋等待了。



# 5 测试CLH锁

下面我们通过一个Demo来测试前面代码实现的CLH锁是否能正常工作，直接上测试代码：

```java
// CLHLockTest.java

/**
 * 用来测试CLHLocke生不生效
 *
 * 定义一个静态成员变量cnt，然后开10个线程跑起来，看能是否会有线程安全问题
 */
public class CLHLockTest {
    private static int cnt = 0;

    public static void main(String[] args) throws Exception {
        final CLHLock lock = new CLHLock();

        for (int i = 0; i < 100; i++) {
            new Thread(() -> {
                lock.lock();

                cnt++;

                lock.unLock();
            }).start();
        }
        // 让main线程休眠10秒，确保其他线程全部执行完
        Thread.sleep(10000);
        System.out.println();
        System.out.println("cnt----------->>>" + cnt);

    }
}
复制代码
```

下面附运行结果截图：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7d9c992951ed432bac65d80384b8bc98~tplv-k3u1fbpfcp-zoom-1.image)



> **PS：** 这里为了截图全面，因此只开了10个线程。经过劲越测试，开100个线程，1000个线程也不会存在线程安全问题。

# 6 小结

好了，前面我们通过多图详细说明了CLH锁的原理与实现，那么我们再对前面的知识进行一次小结：

1. 首先我们学习了自旋锁和互斥锁的概念与区别；
2. 然后我们学习了什么是CLH锁以及为什么要学习CLH锁；
3. 最后我们通过图示+代码实现的方式来学习CLH锁的原理，从而为学习后面的AQS打好坚实的基础。