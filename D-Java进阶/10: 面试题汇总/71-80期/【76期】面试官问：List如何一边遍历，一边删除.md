## 【76期】面试官问：List如何一边遍历，一边删除？

申城异乡人 [Java面试题精选](javascript:void(0);) *4月27日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

这是最近面试时被问到的1道面试题，本篇博客对此问题进行总结分享。

## 1. 新手常犯的错误

可能很多新手（包括当年的我，哈哈）第一时间想到的写法是下面这样的：

```
public static void main(String[] args) {
    List<String> platformList = new ArrayList<>();
    platformList.add("博客园");
    platformList.add("CSDN");
    platformList.add("掘金");

    for (String platform : platformList) {
        if (platform.equals("博客园")) {
            platformList.remove(platform);
        }
    }

    System.out.println(platformList);
}
```

然后满怀信心的去运行，结果竟然抛java.util.ConcurrentModificationException异常了，翻译成中文就是：并发修改异常。

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYznb9JVLZkjFFjvtBh4UCIiaWq8BwZy51cVVXk0tgWHYmNyTfEaxv6iaA/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

是不是很懵，心想这是为什么呢？

让我们首先看下上面这段代码生成的字节码，如下所示：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYTzewLLyNUZsP3qa6BawdODOyhWlFibZyhlLy7dkRTMpT5B62f9w0o1g/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

由此可以看出，foreach循环在实际执行时，其实使用的是Iterator，使用的核心方法是hasnext()和next()。

然后再来看下ArrayList类的Iterator是如何实现的呢？

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYDqibHfrUkicI37MtrxD9EVbeKvzO6vcx0pTPKCYYV3oak6R4GpZBl74A/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

可以看出，调用next()方法获取下一个元素时，第一行代码就是调用了checkForComodification();，而该方法的核心逻辑就是比较modCount和expectedModCount这2个变量的值。

在上面的例子中，刚开始modCount和expectedModCount的值都为3，所以第1次获取元素"博客园"是没问题的，但是当执行完下面这行代码时：

```
platformList.remove(platform);
```

modCount的值就被修改成了4。

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYfUn0U3M9trU0hxicGvVKTgibusCNEichVho4E1YPaDVvsxjjbvBEqzBsg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

所以在第2次获取元素时，modCount和expectedModCount的值就不相等了，所以抛出了java.util.ConcurrentModificationException异常。

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

既然不能使用foreach来实现，那么我们该如何实现呢？

主要有以下3种方法：

- 使用Iterator的remove()方法
- 使用for循环正序遍历
- 使用for循环倒序遍历

接下来一一讲解。

## 2. 使用Iterator的remove()方法

使用Iterator的remove()方法的实现方式如下所示：

```
public static void main(String[] args) {
    List<String> platformList = new ArrayList<>();
    platformList.add("博客园");
    platformList.add("CSDN");
    platformList.add("掘金");

    Iterator<String> iterator = platformList.iterator();
    while (iterator.hasNext()) {
        String platform = iterator.next();
        if (platform.equals("博客园")) {
            iterator.remove();
        }
    }

    System.out.println(platformList);
}
```

输出结果为：

```
[CSDN, 掘金]
```

为什么使用iterator.remove();就可以呢？

让我们看下它的源码：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYmLOCXTl1kicM7udkWibtibAE7LxIvRiaLzrzCdcl0WwfH9zQrn1lURoMhg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

可以看出，每次删除一个元素，都会将modCount的值重新赋值给expectedModCount，这样2个变量就相等了，不会触发java.util.ConcurrentModificationException异常。更多面试题，欢迎关注公众号 Java面试题精选

## 3. 使用for循环正序遍历

使用for循环正序遍历的实现方式如下所示：

```
public static void main(String[] args) {
    List<String> platformList = new ArrayList<>();
    platformList.add("博客园");
    platformList.add("CSDN");
    platformList.add("掘金");

    for (int i = 0; i < platformList.size(); i++) {
        String item = platformList.get(i);

        if (item.equals("博客园")) {
            platformList.remove(i);
            i = i - 1;
        }
    }

    System.out.println(platformList);
}
```

这种实现方式比较好理解，就是通过数组的下标来删除，不过有个注意事项就是删除元素后，要修正下下标的值：

```
i = i - 1;
```

为什么要修正下标的值呢？

因为刚开始元素的下标是这样的：

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

第1次循环将元素"博客园"删除后，元素的下标变成了下面这样：

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

第2次循环时i的值为1，也就是取到了元素”掘金“，这样就导致元素"CSDN"被跳过检查了，所以删除完元素后，我们要修正下下标，这也是上面代码中i = i - 1;的用途。

## 4. 使用for循环倒序遍历

使用for循环倒序遍历的实现方式如下所示：

```
public static void main(String[] args) {
    List<String> platformList = new ArrayList<>();
    platformList.add("博客园");
    platformList.add("CSDN");
    platformList.add("掘金");

    for (int i = platformList.size() - 1; i >= 0; i--) {
        String item = platformList.get(i);

        if (item.equals("掘金")) {
            platformList.remove(i);
        }
    }

    System.out.println(platformList);
}
```

这种实现方式和使用for循环正序遍历类似，不过不用再修正下标，因为刚开始元素的下标是这样的：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYCZfA7mMSvJg8sHPyI8lJ4iaMNeIkgtvonabMXzcjZLB87zpIazaamYg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

第1次循环将元素"掘金"删除后，元素的下标变成了下面这样：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XC50k5vlW7xAMujU8TIoqbYBo3y1SOfsC04NCmsRJKZcicAqBnia23wTJeK57XUEG77KrOZvLVH51Ug/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

第2次循环时i的值为1，也就是取到了元素”CSDN“，不会导致跳过元素，所以不需要修正下标。

## 5. 参考

> https://blog.csdn.net/zjwcdd/article/details/51513879
> https://blog.csdn.net/wangjun5159/article/details/61415358

*来源：juejin.im/post/5e93ce3be51d45470d528262*