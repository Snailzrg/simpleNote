## 【49期】面试官：SpringMVC的控制器是单例的吗?

[Java面试题精选](javascript:void(0);) *2月19日*

点击上方“Java面试题精选”，关注公众号

面试刷图，查缺补漏



**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

对于SpringMVC Controller单例和多例，下面举了个例子说明下.

**第一次：类是多例，一个普通属性和一个静态属性。**

**![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAvnNray0VQn02dNIFtIxLC08xfW5oUPGLl0KA9G76hubuXaJG3m8icJ3eOUUUTG3PE5gnyNXTFQ4Q/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)**

**![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAvnNray0VQn02dNIFtIxLC9spBibxGk2EvdloA7tUwUbXTasgbnGBX00ZAymWH4jbAiaVfaAuxw00g/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)**

结果：

```
普通属性：0.............静态属性：0
普通属性：0.............静态属性：1
普通属性：0.............静态属性：2
普通属性：0.............静态属性：3
```

所以说：对于多例情况普通属性是不会共用的，不会产生影响，对于静态属性会去共用这个属性。

**第二次：类改为单例**

**![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)**

结果：

```
普通属性：0.............静态属性：0
普通属性：1.............静态属性：1
普通属性：2.............静态属性：2
普通属性：3.............静态属性：3
```

所以说：对于单例情况普通属性和静态属性都会被共用。

**第三次：类去掉@Scope注解**

**![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAvnNray0VQn02dNIFtIxLCzcqUuFQvjX8IaX2llxxw7iaBbwicVNbB7r4RZqGzM6t9NUqwJaC0e1ag/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)**

结果：

```
普通属性：0.............静态属性：0
普通属性：1.............静态属性：1
普通属性：2.............静态属性：2
普通属性：3.............静态属性：3
```

所以说：springmvc默认是单例的。

另外在其他方法里面打印

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAvnNray0VQn02dNIFtIxLC1ktpx3YMgRkg1p4xPo81tKMLbEbAKaG19lKMjyDIWKIZdWC1Aic0Fug/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

输出的结果是

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAvnNray0VQn02dNIFtIxLCpgIV2vEJjibljGBk3A9o8mibBicpmunBp36RnTLVRqvgM46jt2D1wpPRg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

跳到别的方法里面也并不会去取初始值，而是再去共用这个属性。

## 总结

尽量不要在controller里面去定义属性，如果在特殊情况需要定义属性的时候，那么就在类上面加上注解@Scope("prototype")改为多例的模式.

以前struts是基于类的属性进行发的，定义属性可以整个类通用，所以默认是多例，不然多线程访问肯定是共用类里面的属性值的，肯定是不安全的，但是springmvc是基于方法的开发，都是用形参接收值，一个方法结束参数就销毁了，多线程访问都会有一块内存空间产生，里面的参数也是不会共用的，所有springmvc默认使用了单例.

所以controller里面不适合在类里面定义属性，只要controller中不定义属性，那么单例完全是安全的。springmvc这样设计主要的原因也是为了提高程序的性能和以后程序的维护只针对业务的维护就行，要是struts的属性定义多了，都不知道哪个方法用了这个属性，对以后程序的维护还是很麻烦的。

**留一个问题：****那他是线程安全的吗？****知道的欢迎留言解答**

> 来源：
>
> blog.csdn.net/qq_27026603/article/details/67953879