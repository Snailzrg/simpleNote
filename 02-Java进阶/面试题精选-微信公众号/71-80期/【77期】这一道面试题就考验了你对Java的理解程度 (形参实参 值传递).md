## 【77期】这一道面试题就考验了你对Java的理解程度

JavaDoop [Java面试题精选](javascript:void(0);) *4月29日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

## 简介

最近看到一篇文章，关于一道面试题，先看一下题目，如下：

```
public static void main(String[] args) {
        Integer a = 1;
        Integer b = 2;
        System.out.printf("a = %s, b = %s\n", a, b);
        swap(a, b);
        System.out.printf("a = %s, b = %s\n", a, b);
    }

public static void swap(Integer a, Integer b) {
    // TODO 实现
}
```

有人可能在没经过仔细考虑的情况下，给出以下的答案

```
// 特别提醒，这是错误的方式
// 特别提醒，这是错误的方式
// 特别提醒，这是错误的方式
public static void swap(Integer a, Integer b) {
    // TODO 实现
    Integer temp = a;
    a = b;
    b = temp;
}
```

很遗憾，这是错误的。重要的事注释三遍

那么为什么错误，原因是什么？

想要搞清楚具体的原因，在这里你需要搞清楚以下几个概念，如果这个概念搞清楚了，你也不会把上面的实现方法写错

- 形参和实参
- 参数值传递
- 自动装箱

所以，上面的问题先放一边，先看一下这几个概念

### 形参和实参

什么是形参？什么是实参？

概念上的东西，参考教科书或者google去吧，下面直接代码说明更加明显

```
public void test() {
    int shi_can = 0;

    testA(shi_can);
}

public void testA(int xing_can) {

}
```

> 注：为了清楚的表达意思，我命名的时候并没有按照java的驼峰规则命名，这里只是为了演示

通过上面的代码很清楚的表达形参和实参的概念，在调用testA时，传递的就是实参，而在testA方法签名中的参数为形参

从作用域上看，形参只会在方法内部生效，方法结束后，形参也会被释放掉，所以形参是不会影响方法外的

### 值传递和引用传递

- 值传递：传递的是实际值，像基本数据类型
- 引用传递：将对象的引用作为实参进行传递

java基本类型数据作为参数是值传递，对象类型是引用传递

实参是可以传递给形参的，但是形参却不能影响实参，所以，当进行值传递的情况下，改变的是形参的值，并没有改变实参，所以无论是引用传递还是值传递，只要更改的是形参本身，那么都无法影响到实参的。对于引用传递而言，不同的引用可以指向相同的地址，通过形参的引用地址，找到了实际对象分配的空间，然后进行更改就会对实参指向的对象产生影响

额，上面表述，可能有点绕，看代码

```
// 仅仅是一个java对象
public class IntType {

    private int value;

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }
}

// main方法
public class IntTypeSwap {
    public static void main(String[] args) {

        // CODE_1
        IntType type1 = new IntType();
        type1.setValue(1);

        IntType type2 = new IntType();
        type2.setValue(2);
      // CODE_1

        swap1(type1, type2);
        System.out.printf("type1.value = %s, type2.value = %s", type1.getValue(), type2.getValue());
        swap2(type1, type2);
        System.out.println();
        System.out.printf("type1.value = %s, type2.value = %s", type1.getValue(), type2.getValue());
    }

    public static void swap2(IntType type1, IntType type2) {
        int temp = type1.getValue();
        type1.setValue(type2.getValue());
        type2.setValue(temp);
    }

    public static void swap1(IntType type1, IntType type2) {
        IntType type = type1;
        type1 = type2;
        type2 = type;
    }
}
```

在main方法中，CODE_1中间的代码为声明了两个对象，分别设置value为1和2，而swap1和swap2两个方法的目的是为了交互这两个对象的value值

先思考一下，应该输出的结果是什么
…
…

```
type1.value = 1, type2.value = 2
type1.value = 2, type2.value = 1
```

从输出结果来看swap1并没有达到目的，回头看一下swap1

```
public static void swap1(IntType type1, IntType type2) {
        IntType type = type1;
        type1 = type2;
        type2 = type;
    }
```

从值传递的角度来看，对象参数传递采用的是引用传递，那么type1和type2传递过来的是指向对象的引用，在方法内部，直接操作形参，交换了形参的内容，这样形参改变，都是并没有对实参产生任何影响，也没有改变对象实际的值，所以，结果是无法交换

而对于swap2，对象引用作为形参传递过来后，并没有对形参做任何的改变，而是直接操作了形参所指向的对象实际地址，那这样，无论是实参还是其他地方，只要是指向该对象的所有的引用地址对应的值都会改变。更多面试题，欢迎关注公众号Java面试题精选

### 自动装箱

看我上面的那个例子的swap1，是不是顿时觉得与上面的面试题的错误做法非常相似了，是的，错误的原因是一模一样的，就是稍微有一点区别，就是Integer不是new出来的，而是自动装箱的一个对象，那么什么是自动装箱呢？jdk到底做了什么事？

如果你不想知道为什么，只想知道结果，那么我就直说，自动装箱就是jdk调用了Integer的valueOf(int)的方法，很简单，看源码

```
public static Integer valueOf(int i) {
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
    }
```

上面那些如果不想深究可以忽略，就看最后一句，是不是明白了什么呢。没错，也是new出来一个对象。

好了，有人可能会问，为什么会知道自动装箱调用的是valueOf方法，这里其他人怎么知道的我不清楚，我是通过查看反编译的字节码指令知道的

```
public static void main(String[] args) {
        Integer a = 1;
        Integer b = 2;
        System.out.printf("a = %s, b = %s\n", a, b);
        swap(a, b);
        System.out.printf("a = %s, b = %s\n", a, b);
    }

    public static void swap(Integer a, Integer b) {
        Integer temp = a;
        a = b;
        b = temp;
    }
```

反编译出来的结果为

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XBicJSrPzIb5WZcB0co7HiaEefFW5sx2AMTOUOC5ricF6MByQU2ctxmry6gIrRCpico7EicYs26Q59o6vw/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

对比一下可以很清楚的看到valueOf(int)方法被调用

## 回归

好，现在回归正题了，直接操作形参无法改变实际值，而Integer又没有提供set方法，那是不是无解了呢？我很好奇如果有人以下这样写，面试官会有什么反应

```
public static void swap(Integer a, Integer b) {
        // TODO 实现
        // 无解，
    }
```

既然出了肯定是有解的，可以实现，回头看看，在上面swap2的那个例子中是通过set方法来改变值的，那么Integer有没有提供呢？答案没有（我没找到）

那就先看看源码

```
private final int value;
...
public Integer(int value) {
        this.value = value;
    }
```

这是Integer的构造函数，可以看到Integer对象实际值是用value属性来存储的，但是这个value是被final修饰的，没办法继续找，value没有提供任何的set方法。既然在万法皆不通的情况下，那就只能动用反射来解决问题

```
public static void swap(Integer a, Integer b) {
        int temp = a.intValue();
        try {
            Field value = Integer.class.getDeclaredField("value");
            value.setAccessible(true);
            value.set(a, b);
            value.set(b, temp);

        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }
```

现在感觉很开心，终于找到解决方案，可是当你执行的时候，从输出结果你会发现，jdk在跟我开玩笑吗

```
a = 1, b = 2
a = 2, b = 2
```

为什么会出现这种情况，无奈，调试会发现是在value.set的时候将Integer的缓存值改变了，因为value.set(Object v1, Object v2)两个参数都是对象类型，所以temp会进行自动装箱操作，会调用valueOf方法，这样会获取到错误的缓存值，所以，为了避免这种情况，就只能不需要调用缓存值，直接new Integer就可以跳过缓存，所以代码改成如下即可

```
public static void swap(Integer a, Integer b) {
        int temp = a.intValue();
        try {
            Field value = Integer.class.getDeclaredField("value");
            value.setAccessible(true);
            value.set(a, b);
            value.set(b, new Integer(temp));

        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }
```

至此，这道题完美结束