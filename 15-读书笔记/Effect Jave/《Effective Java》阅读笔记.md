# 《Effective Java》阅读笔记


 ：覆盖equals是请遵守通用约定
不覆盖equals方法，类的每个实例都和它本身相等，如果满足一下任何一个条件，这就正式所期望的结果。 
1. 类的每个实例本质都是唯一的 
2. 不关心类是否提供了“逻辑相等”的测试功能。 
3. 超类已经覆盖了equals，从超类继承过来的行为对于子类 也是合适的。 
4. 类是私有的或是包级私有的，可以确定它的equals方法永远不会被调用。 
以上4种不需要覆盖equals，需要覆盖equals一般作用于“值类”（value class）

在覆盖equals的时候需要遵守以下约定：
1.自反性。对于任何非null的引用值x，x.equals(x)必须返回true
2.对称性。对于任何非null的引用值x和y，当且仅当y.equals(x)返回true是，x.equals(y)必须也返回true
3.传递性。对于任何非null的引用值x和y、z，当且仅当x.equals(y)返回true，并y.equals(z)也返回true，那么x.equals(z)也必须返回true
4.一致性。对于任何非null的引用值x和y，只要equals的比较操作在对象中所用的信息没有被修改，多次调用x.equals(y)就会一致地返回true，或者一致的返回false。
5.对于任何非null的引用值x，x.equals(null)必须返回false
实现高质量equals方法的诀窍 
1. 使用==操作符检查参数是否为这个对象的引用，如果是就返回true 
2. 使用instanceof操作符检查参数是否为正确的类型，如果不是就返回false 
3. 把参数转换成正确的类型 
4. 对于该类中每个“关键”域（significant）（每一个属性），检查参数中的域是否与该对象中对应的域相匹配，如果全部检查都通过则传true，否则传false 
5. 当编写好了equals方法之后，应该为自己三个问题：它是否是对称的、传递的、一致的

需要注意的是 
1. 覆盖equals的时候总要覆盖hashCode 
2. 不要企图让equals方法过于智能 
3. 不要将equals声明中的Object对象替换为其他类型，例如： 
public boolean equals(MyClass o) {...} 
这个方法并没有覆盖Object.equals，因为此方法的参数本该是Object类型


JDK1.8中 map源码

```
 public boolean equals(Object o) {
  // 使用==操作符检查参数是否为这个对象的引用，如果是就返回true 
        if (o != this) {
  //使用instanceof操作符检查参数是否为正确的类型，如果不是就返回false
            if (!(o instanceof Map))
                return false;
  // 把参数转换成正确的类型 
            Map<?,?> m = (Map<?,?>) o;
            Node<K,V>[] t;
            int f = (t = table) == null ? 0 : t.length;
            Traverser<K,V> it = new Traverser<K,V>(t, f, 0, f);
            for (Node<K,V> p; (p = it.advance()) != null; ) {
                V val = p.val;
                Object v = m.get(p.key);
                if (v == null || (v != val && !v.equals(val)))
                    return false;
            }
            for (Map.Entry<?,?> e : m.entrySet()) {
                Object mk, mv, v;
                if ((mk = e.getKey()) == null ||
                    (mv = e.getValue()) == null ||
                    (v = get(mk)) == null ||
                    (mv != v && !mv.equals(v)))
                    return false;
            }
        }
        return true;
    }

```
hashcode
```
    public int hashCode() {
        int h = 0;
        Node<K,V>[] t;
        if ((t = table) != null) {
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
            for (Node<K,V> p; (p = it.advance()) != null; )
                h += p.key.hashCode() ^ p.val.hashCode();
        }
        return h;
    }
```

如果不这样做的话，在这些类使用基于散列的集合将会不能正常运作，比较常见的散列集合有：HashMap、HashSet、Hashtable 
在Object规范[JavaSE6]中有说明
如果两个对象根据equals(Object)方法比较是相等的，那么调用这两个对象中任意一个对象的hashCode方法都必须返回同样的整数结果。
如果我们不覆盖hashCode，会有什么问题呢？以下是一个示例，User.java
   
```
 package com.model;
    import java.util.Date;

    public class User {
    private String name;
    private int age;
    private Date reg;

    public static class Builder {
        //默认值
        private String name = "用户";
        private int age = 18;
        private Date reg = new Date(System.currentTimeMillis());

        public Builder(String name) {
            this.name = name;
        }
        public Builder age(int age) {
            this.age = age;
            return this;
        }
        public Builder reg(Date reg) {
            this.reg = reg;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }

    public User(Builder builder) {
        this.name = builder.name;
        this.age = builder.age;
        this.reg = builder.reg;
    }

    @Override
    public boolean equals(Object obj) {
        // TODO Auto-generated method stub
        if(obj == null) {
            return false;
        }
        if(obj == this) {
            return true;
        }
        if(obj instanceof User) {
            User user = (User) obj;
            if(user.age == this.age && user.name.equals(this.name) && user.reg.equals(this.reg)) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
       }
      }
```
这个类中只覆盖了equals，当我们使用User类作为HashMap的key的时候

```
        Date reg = new Date(System.currentTimeMillis());
        User user = new User.Builder("test").reg(reg).build();
        Map<User, String> map = new HashMap<>();
        map.put(user, "slience");
        System.out.println(map.get(new    User.Builder("test").reg(reg).build()));
```
我们期望的输出是slience，但是因为前后两个build的用户hashCode返回值不一样（HaseMap是以hash值作为判别是否相同的标准的），所以将会输出null，我们在User.java中添加hashCode覆盖

```
    @Override
    public int hashCode() {
        // TODO Auto-generated method stub
        int result = 17;
        result = 31 * result + name.hashCode();
        result = 31 * result + age;
        result = 31 * result + reg.hashCode();
        return result;
    }

```
这样再运行的时候HashMap就可以返回正确的数值了。（上面代码中使用31是因为31是一个奇素数，这主要在hashCode以位运算来计算的时候有好处） 
另外需要说明的是，如果散列码（hashcode）计算的代价太昂贵，可以在实体中用一个属性来缓存起来。



考虑实现 Comparable 接口
如果类实现了comparable 接口，便可以跟许多泛型算法以及依赖该接口的集合实现协作，比如可以使用 Array.sort 等集合的排序。

使类和成员的可访问性最小化
●隐藏内部实现细节，有效解耦各模块的耦合关系

●访问级别

private：类内部才可访问

package-private（缺省的）：包内部的任何类可访问

protected：声明该成员的类的子类以及包内部的类可访问

public：任何地方均可访问

