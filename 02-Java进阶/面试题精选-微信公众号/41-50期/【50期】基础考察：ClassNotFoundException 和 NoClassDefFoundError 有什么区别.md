## 【50期】基础考察：ClassNotFoundException 和 NoClassDefFoundError 有什么区别

[Java面试题精选](javascript:void(0);) *2月21日*

点击上方“Java面试题精选”，关注公众号

面试刷图，查缺补漏



**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

在写Java程序的时候，当一个类找不到的时候，JVM有时候会抛出ClassNotFoundException异常，而有时候又会抛出NoClassDefFoundError。看两个异常的字面意思，好像都是类找不到，但是JVM为什么要用两个异常去区分类找不到的情况呢？这个两个异常有什么不同的地方呢？

## ClassNotFoundException

ClassNotFoundException是一个运行时异常。从类继承层次上来看，ClassNotFoundException是从Exception继承的，所以ClassNotFoundException是一个检查异常。

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBT6ianAutqaGVHGoI6DPlicWibics96zMxPO9I9EHj4YWiacpNQy2chuRia2EIUHz9xEibPqLoAwaAmaL4A/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

当应用程序运行的过程中尝试使用类加载器去加载Class文件的时候，如果没有在classpath中查找到指定的类，就会抛出ClassNotFoundException。一般情况下，当我们使用Class.forName()或者ClassLoader.loadClass以及使用ClassLoader.findSystemClass()在运行时加载类的时候，如果类没有被找到，那么就会导致JVM抛出ClassNotFoundException。

最简单的，当我们使用JDBC去连接数据库的时候，我们一般会使用Class.forName()的方式去加载JDBC的驱动，如果我们没有将驱动放到应用的classpath下，那么会导致运行时找不到类，所以运行Class.forName()会抛出ClassNotFoundException。

```
public class MainClass {
    public static void main(String[] args) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

输出：

```
java.lang.ClassNotFoundException: oracle.jdbc.driver.OracleDriver
    at java.net.URLClassLoader.findClass(URLClassLoader.java:381)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
    at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:331)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
    at java.lang.Class.forName0(Native Method)
    at java.lang.Class.forName(Class.java:264)
    at MainClass.main(MainClass.java:7)
```

## NoClassDefFoundError

NoClassDefFoundError异常，看命名后缀是一个Error。从类继承层次上看，NoClassDefFoundError是从Error继承的。和ClassNotFoundException相比，明显的一个区别是，NoClassDefFoundError并不需要应用程序去关心catch的问题。

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBT6ianAutqaGVHGoI6DPlicW9AWaedaFiaeLt0U0q4jxuRWXoicZzSQh0BmtqWEgxdsXv1zWnedSSYSQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

当JVM在加载一个类的时候，如果这个类在编译时是可用的，但是在运行时找不到这个类的定义的时候，JVM就会抛出一个NoClassDefFoundError错误。比如当我们在new一个类的实例的时候，如果在运行是类找不到，则会抛出一个NoClassDefFoundError的错误。

```
public class TempClass {
}

public class MainClass {
    public static void main(String[] args) {
        TempClass t = new TempClass();
    }
}
```

首先这里我们先创建一个TempClass，然后编译以后，将TempClass生产的TempClass.class文件删除，然后执行程序，输出：

```
Exception in thread "main" java.lang.NoClassDefFoundError: TempClass
    at MainClass.main(MainClass.java:6)
Caused by: java.lang.ClassNotFoundException: TempClass
    at java.net.URLClassLoader.findClass(URLClassLoader.java:381)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
    at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:331)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
    ... 1 more
```

## 总结

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBT6ianAutqaGVHGoI6DPlicWicaxPyIMBzcNakPvwDtkPPnC1EGbibWwW2z9WqfxsgjPlia3rZb2OXAIA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

> 来源：cnblogs.com/duke2016/p/9153241.html