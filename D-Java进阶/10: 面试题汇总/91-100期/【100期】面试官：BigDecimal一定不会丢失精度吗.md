## 【100期】面试官：BigDecimal一定不会丢失精度吗？

HikariCP [Java面试题精选](javascript:void(0);) *5月30日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅**

我们基本已经形成了常识，需要用到金钱的地方要用BigDecimal而不是其他，而我们也都知道浮点型变量在进行计算的时候会出现丢失精度的问题。

那么，你知道其实BigDecimal也会丢失精度吗？而使用BigDecimal的背后又有什么值得去探究的地方吗？今天，告诉你，知其然，也知其所以然。

如下一段代码：

```
System.out.println(0.05 + 0.01);  
System.out.println(1.0 - 0.42);  
System.out.println(4.015 * 100);  
System.out.println(123.3 / 100);  
```

输出：
0.060000000000000005
0.5800000000000001
401.49999999999994
1.2329999999999999

可以看到在Java中进行浮点数运算的时候，会出现丢失精度的问题。那么我们如果在进行商品价格计算的时候，就会出现问题。

很有可能造成我们手中有0.06元，却无法购买一个0.05元和一个0.01元的商品。

因为如上所示，他们两个的总和为0.060000000000000005。

这无疑是一个很严重的问题，尤其是当电商网站的并发量上去的时候，出现的问题将是巨大的。可能会导致无法下单，或者对账出现问题。所以接下来我们就可以使用Java中的BigDecimal类来解决这类问题。

**普及一下：**

Java中float的精度为6-7位有效数字。double的精度为15-16位。

#### API

构造器：

```
构造器                   描述
BigDecimal(int)       创建一个具有参数所指定整数值的对象。
BigDecimal(double)    创建一个具有参数所指定双精度值的对象。
BigDecimal(long)      创建一个具有参数所指定长整数值的对象。
BigDecimal(String)    创建一个具有参数所指定以字符串表示的数值的对象。
```

函数：

```
方法                    描述
add(BigDecimal)       BigDecimal对象中的值相加，然后返回这个对象。
subtract(BigDecimal)  BigDecimal对象中的值相减，然后返回这个对象。
multiply(BigDecimal)  BigDecimal对象中的值相乘，然后返回这个对象。
divide(BigDecimal)    BigDecimal对象中的值相除，然后返回这个对象。
toString()            将BigDecimal对象的数值转换成字符串。
doubleValue()         将BigDecimal对象中的值以双精度数返回。
floatValue()          将BigDecimal对象中的值以单精度数返回。
longValue()           将BigDecimal对象中的值以长整数返回。
intValue()            将BigDecimal对象中的值以整数返回。
```

由于一般的数值类型，例如double不能准确的表示16位以上的数字。

### BigDecimal精度也丢失

我们在使用BigDecimal时，使用它的BigDecimal(String)构造器创建对象才有意义。其他的如BigDecimal b = new BigDecimal(1)这种，还是会发生精度丢失的问题。如下代码：

```
BigDecimal a = new BigDecimal(1.01);
BigDecimal b = new BigDecimal(1.02);
BigDecimal c = new BigDecimal("1.01");
BigDecimal d = new BigDecimal("1.02");
System.out.println(a.add(b));
System.out.println(c.add(d));
```

输出：
2.0300000000000000266453525910037569701671600341796875
2.03

可见论丢失精度BigDecimal显的更为过分。但是使用Bigdecimal的BigDecimal(String)构造器的变量在进行运算的时候却没有出现这种问题。

究其原因计算机组成原理里面都有，它们的编码决定了这样的结果。

long可以准确存储19位数字，而double只能准备存储16位数字。

double由于有exp位，可以存16位以上的数字，但是需要以低位的不精确作为代价。如果需要高于19位数字的精确存储，则必须用BigInteger来保存，当然会牺牲一些性能。

所以我们一般使用BigDecimal来解决商业运算上丢失精度的问题的时候，声明BigDecimal对象的时候一定要使用它构造参数为String的类型的构造器。

同时这个原则Effective Java和MySQL 必知必会中也都有提及。float和double只能用来做科学计算和工程计算。商业运算中我们要使用BigDecimal。

而且我们从源码的注释中官方也给出了说明，如下是BigDecimal类的double类型参数的构造器上的一部分注释说明：

```
* The results of this constructor can be somewhat unpredictable.  
     * One might assume that writing {@codenew BigDecimal(0.1)} in  
     * Java creates a {@code BigDecimal} which is exactly equal to  
     * 0.1 (an unscaled value of 1, with a scale of 1), but it is  
     * actually equal to  
     * 0.1000000000000000055511151231257827021181583404541015625.  
     * This is because 0.1 cannot be represented exactly as a  
     * {@codedouble} (or, for that matter, as a binary fraction of  
     * any finite length).  Thus, the value that is being passed  
     * <i>in</i> to the constructor is not exactly equal to 0.1,  
     * appearances notwithstanding.  
       ……  
        * When a {@codedouble} must be used as a source for a  
     * {@code BigDecimal}, note that this constructor provides an  
     * exact conversion; it does not give the same result as  
     * converting the {@codedouble} to a {@code String} using the  
     * {@link Double#toString(double)} method and then using the  
     * {@link #BigDecimal(String)} constructor.  To get that result,  
     * use the {@codestatic} {@link #valueOf(double)} method.  
     * </ol>  
public BigDecimal(double val) {  
    this(val,MathContext.UNLIMITED);  
}  
```

第一段也说的很清楚它只能计算的无限接近这个数，但是无法精确到这个数。

第二段则说，如果要想准确计算这个值，那么需要把double类型的参数转化为String类型的。并且使用BigDecimal(String)这个构造方法进行构造。去获取结果。

### 正确运用BigDecimal

另外，BigDecimal所创建的是对象，我们不能使用传统的+、-、*、/等算术运算符直接对其对象进行数学运算，而必须调用其相对应的方法。方法中的参数也必须是BigDecimal的对象，由刚才我们所罗列的API也可看出。

在一般开发过程中，我们数据库中存储的数据都是float和double类型的。在进行拿来拿去运算的时候还需要不断的转化，这样十分的不方便。这里我写了一个工具类：

```
/**  
 * @author: Ji YongGuang.  
 * @date: 19:50 2017/12/14.  
 */  
publicclass BigDecimalUtil {  

    private BigDecimalUtil() {  

    }  

    public static BigDecimal add(double v1, double v2) {// v1 + v2  
        BigDecimal b1 = new BigDecimal(Double.toString(v1));  
        BigDecimal b2 = new BigDecimal(Double.toString(v2));  
        return b1.add(b2);  
    }  

    public static BigDecimal sub(double v1, double v2) {  
        BigDecimal b1 = new BigDecimal(Double.toString(v1));  
        BigDecimal b2 = new BigDecimal(Double.toString(v2));  
        return b1.subtract(b2);  
    }  

    public static BigDecimal mul(double v1, double v2) {  
        BigDecimal b1 = new BigDecimal(Double.toString(v1));  
        BigDecimal b2 = new BigDecimal(Double.toString(v2));  
        return b1.multiply(b2);  
    }  

    public static BigDecimal div(double v1, double v2) {  
        BigDecimal b1 = new BigDecimal(Double.toString(v1));  
        BigDecimal b2 = new BigDecimal(Double.toString(v2));  
        // 2 = 保留小数点后两位   ROUND_HALF_UP = 四舍五入  
        return b1.divide(b2, 2, BigDecimal.ROUND_HALF_UP);// 应对除不尽的情况  
    }  
}  
```

该工具类提供了double类型的基本的加减乘除运算。直接调用即可。

*来源：www.jianshu.com/p/c81edc59546c*