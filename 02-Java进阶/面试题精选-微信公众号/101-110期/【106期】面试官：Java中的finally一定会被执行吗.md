## 【106期】面试官：Java中的finally一定会被执行吗？

Semineces [Java面试题精选](javascript:void(0);) *6月10日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅**

***\*阶段汇总集合：\*******\*[++小Flag实现，一百期面试题汇总++](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247484532&idx=1&sn=1c243934507d79db4f76de8ed0e5727f&chksm=e80db202df7a3b14fe7077b0fe5ec4de4088ce96a2cde16cbac21214956bd6f2e8f51193ee2b&scene=21#wechat_redirect)\****

## **一、前言** 

因为这次面试有问到一些同学finally的问题，发现自己这块好像有点记不太清楚了，有的点可能还给人家说错了，一度弄得场面有些尴尬。所以说这篇文章深入研究一下finally的执行情况和返回值的情况。

## **二、finally一定会执行吗？**

先给答案：肯定不是。

我们可以看两种情况：

##### 1.在执行try块之前直接return，我们发现finally块是不会执行的



```
public class TryCatchTest {

  private static int total() {
    int i = 11;
    if (i == 11) {
      return i;
    }
    try {
      System.out.println("执行try");
    } finally {
      System.out.println("执行finally");
    }
    return 0;
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
```



```
输出结果：
执行main：11
复制代码
```

##### 2.在执行try块之前制造一个错误，直接爆红



```
public class TryCatchTest {

  private static int total() {
    return 1 / 0;
    try {
      System.out.println("执行try");
    } finally {
      System.out.println("执行finally");
    }
    return 0;
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
```

综上我们看出，**如果程序连try块都执行不到，那么finally块自然就不会执行到了**。

不过这里有的同学就会问：如果执行了try块，finally块一定会执行吗？有的同学答案就是一定会，其实非然，看看下面的例子吧：

```
public class TryCatchTest {

  private static int total() {
    try {
      System.out.println("执行try");
      System.exit(0);
    } catch (Exception e) {
      System.out.println("执行catch");
    } finally {
      System.out.println("执行finally");
    }
    return 0;
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
执行try
```

我们在执行try块之中退出jvm，就没事了，都不执行了。当然这个情况是比较极端的，记住就行，没事不要乱整这个。最后总结一下：**不管是给try块中造了个异常，还是在try块中进行return，我们发现finally块还是会执行的。因为异常处理设计初衷就是让finally块始终执行**。这个总结在finally的执行时机得到证明。

## **三、finally执行时机探讨**

首先看常规情况：

```
public class TryCatchTest {

  private static int total() {
    try {
      System.out.println("执行try");
      return 11;
    } finally {
      System.out.println("执行finally");
    }
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
	执行try
	执行finally
	执行main：11
```

分析一下，不难得出在这个例子中**finally块执行在try块的return之前**。我们给try块中造一个异常：

```
public class TryCatchTest {

  private static int total() {
    try {
      System.out.println("执行try");
      return 1 / 0;
    } catch (Exception e) {
      System.out.println("执行catch");
      return 11;
    } finally {
      System.out.println("执行finally");
    }
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
	执行try
	执行catch
	执行finally
	执行main：11
```

同样的，**finally执行在catch块return的执行前**。

## **四、finally块中的返回值**



##### 1.finally块不含返回值，但是做改变变量值的操作

看一个例子：

```
public class TryCatchTest {

  private static int total() {
    int i = 0;
    try {
      System.out.println("执行try：" + i);
      return i;
    } finally {
      ++i;
      System.out.println("执行finally：" + i);
    }
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
执行try：0
执行finally：1
执行main：0
```

如果看完前面分析，会发现跟想象的不太一样。我们经过前面的分析，finally块的执行时机应该是return之前，那理论上我们应该先`++i`使得`i等于1`，在执行`return i;` 自然会返回1。

可是结果却返回了0，这是因为Java程序会把try或者catch块中的返回值保留，也就是暂时的确认了返回值，然后再去执行finally代码块中的语句。等到finally代码块执行完毕后，如果finally块中没有返回值的话，就把之前保留的返回值返回出去。

##### 2.finally中含有返回值

示例1：

```
public class TryCatchTest {

  private static int total() {
    try {
      System.out.println("执行try");
      return 1;
    } finally {
      System.out.println("执行finally");
      return 2;
    }
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
执行try
执行finally
执行main：2
```

------

示例2：

```
public class TryCatchTest {

  private static int total() {
    int i = 1;
    try {
      System.out.println("执行try：" + i);
      return i;
    } finally {
      ++i;
      System.out.println("执行finally：" + i);
      return i;
    }
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
输出结果：
执行try：1
执行finally：2
执行main：2
```

------

示例3：

```
public class TryCatchTest {

  private static int total() {
    int i = 1;
    try {
      System.out.println("执行try：" + i);
    } finally {
      ++i;
      System.out.println("执行finally：" + i);
    }
    return i;
  }

  public static void main(String[] args) {
    System.out.println("执行main：" + total());
  }
}
执行结果：
执行try：1
执行finally：2
执行main：2
```

这三个示例都说明了一点，在分析含有finally块的方法返回值时，要对于return出现的地方进行具体分析。**在finally块中进行return操作的话，则方法整体的返回值就是finally块中的return返回值。如果在finally块之后的方法内return，则return的值就是进行完上面的操作后的return值。**

*来源：juejin.im/post/5ec2993fe51d45209d437387*