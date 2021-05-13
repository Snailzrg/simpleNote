## 【164期】围绕 Spring AOP 能提出哪些面试问题？

### AOP是什么？

与OOP对比，面向切面，传统的OOP开发中的代码逻辑是至上而下的过程中会长生一些横切性问题，这些横切性的问题和我们的主业务逻辑关系不会散落在代码的各个地方，造成难以维护，AOP的编程思想就是把业务逻辑和横切的问题进行分离，从而达到解耦的目的，使代码的重用性和开发效率高（目的是重用代码，把公共的代码抽取出来）

### 二、面试官问：AOP的应用场景有哪些呢？

1、日志记录

2、权限验证

3、效率检查（个人在代码上，喜欢用注解+切面，实现校验，redis分布式锁等功能）

4、事务管理（spring 的事务就是用AOP实现的）

### 三、面试官问：springAop的底层是怎样实现的？

（这个时候，条件反射地想起这两点）

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBMfEq6iboepWuozjUzaib1ptSJfropkDZMAJn5pu2vqiag4qY7JtsQxm27VSDC1o4KHAyAAlXAjMjLg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

1、JDK动态代理

2、CGLIB代理

面试官一问：是编译时期进行织入，还是运行期进行织入？

- 运行期，生成字节码，再加载到虚拟机中，JDK是利用反射原理，CGLIB使用了ASM原理。

面试官再问：初始化时期织入还是获取对象时织入？

- 初始化的时候，已经将目标对象进行代理，放入到spring 容器中

面试官再再问：spring AOP 默认使用jdk动态代理还是cglib？

- 要看条件，如果实现了接口的类，是使用jdk。如果没实现接口，就使用cglib。

(来一个尴尬的笑容，有点忘记了，内心，直接泪目)

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

### 四、面试官问：spring AOP 和 AspectJ的关系？

1、两者都是为了实现AOP这个目的，而出现的技术，spring aop 参考 AspectJ编程风格

- 这里有个故事就是，原本spring aop 初期的时候所用的编程风格，让人用起来，很不方便，而且让人看不懂。后来，spring aop 就开始取用了Aspectj的编程风格去进行编程

这里有一个小彩蛋（如果知道，请跳过）,搭建一个用上spring，但是不使用xml文件，而且将bean注入到容器中，而且能从容器中拿出来的项目。

第一步骤：加入spring-context依赖

```
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-context</artifactId>
      <version>5.0.8.RELEASE</version>
    </dependency>
```

第二步骤：加入三个类，一个测试类

```
@Configuration
@ComponentScan("com.ving")
public class AopConfig {
}
 
////////////////////////////////////////////////
 
 
@Component
public class IndexDao {
 
    public void query(){
        System.out.println("dao----query");
    }
}
 
////////////////////////////////////////////////
 
public class Test {
    public static void main(String[] args) {
        AnnotationConfigApplicationContext annotationConfigApplicationContext = new AnnotationConfigApplicationContext(AopConfig.class);
        annotationConfigApplicationContext.start();
         IndexDao bean = annotationConfigApplicationContext.getBean(IndexDao.class);
        bean.query();
 
    }
}
```

打印的结果为：

```
dao----query
```

我们继续往下看

### 面试官最后一问：能不能简单说下AOP中的切面、切点、连接点、通知，四者的关系？

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBMfEq6iboepWuozjUzaib1ptTHsntqTfCmIJWvdCh7ib1icOZBgeobAWSp3Q7cwMht233S022HQEic37Q/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

aspect 切面

Point cut （如果理解了这个切点的概念，就在应用方面完全是可以的了）表示连接点的集合（类似一个表）

Join point 目标对象中的方法（每一条记录）

weaving 把代理逻辑加入到目标对象上的过程叫做织入

advice 通知类型，请下下图官网说明

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XBMfEq6iboepWuozjUzaib1ptodk7JEvzwXzOrQCUOibjeDBf5tG4FcW36a5TV3kkIRNgN0HO9yFp6Rw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

下面代码是说明切面，切点，连接点，通知，四者的关系！

```
/**
 *
 * 切面
 * 一定要给spring 管理
 */
@Component
@Aspect
public class VingAspectJ {

    /**
     * 切点
     * 为什么切点要声明在一个方法上?目的是为了将注解写在上面而已
     * pointcut是连接点的集合（就是方法的集合）
     */
    @Pointcut("execution(* com.ving.dao.*.*(..))")
    public void pointCut(){

    }

    /**
     * 通知---》配置切点
     */
    @After("com.ving.config.VingAspectJ.pointCut()")
    public void after(){
        System.out.println("after");
    }

    @Before("com.ving.config.VingAspectJ.pointCut()")
    public void before(){
        System.out.println("before");
    }
}
```

*来源：cnblogs.com/vingLiu/p/12052096.html*