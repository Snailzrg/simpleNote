## 【79期】别找了，回答Spring中Bean的生命周期，这里帮你总结好了！

我又不是架构师 [Java面试题精选](javascript:void(0);) *5月1日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

这一节准备给大家讲解Spring 容器中的Bean的生命周期。这一节我个人觉得还是比较实用的，在实际工作当中经常会用到这些知识来解决一些非常棘手的问题。

## ApplicationContext中Bean的生命周期

先来张图:

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XBeia8Jy0mAuU4icQXVB1Y1waUadJlpmVO6AI4VHqRxsYjGn76Qv3kae3R1PE8WuiaLJQjMhjcVz8Acg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

大家看到这张图肯定是一脸蒙蔽。不要着急，我来慢慢解释:从getBean(…)为触发点，Spring容器的Bean生命周期就经历了图中的生命周期，先分个类:

- 图中绿色箭头的三个步骤(InstantiationAwareBeanPostProcessor)和粉红色箭头的两个步骤(BeanPostProcessor)为容器级的生命周期接口,当Spring每加载任何一个Bean到容器中时，这些接口都会起到如图中的几次调用。这两个处理器叫做"容器级后处理器",他们的影响是全局的，能够影响所有的Bean.
- 图中大红色圆圈圈住的接口叫做"工厂级后处理器",类似的接口还有CustomEditorConfigurer,PropertyPlaceholderConfigurer等，这类接口只在上下文初始化的时候调用一次，其目的是完成一些配置文件的加工处理工作。
- 剩下的就简单了，属于Bean级别的接口，专属于某个Bean所有，每个Bean实例化的时候调用自己特有的。

值得一提的是，无论是"容器级后处理器"还是"工厂级后处理器"，他们都是可以配置多个的(如，配置两个BeanPostProcessor)，如果想控制他们的调用顺序，实现一个org.springframework.core.Ordered接口即可。当然了，一般不用，一般一类后处理器只有一个即可。

重点强调！:

> 这些接口的调用顺序并不是一尘不变的，会随便Spring的版本变动而变动，大家要做的是万变不离其宗，知道能够通过这些接口在Bean初始化的时做一些属性上的操作。调用顺序要根据具体的版本来自己测试。下面我会给大家来列一个例子:

```
public class Student implements BeanFactoryAware, BeanNameAware,
        InitializingBean, DisposableBean,ApplicationContextAware {
    private String name;

    public Student(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
        System.out.println("BeanFactoryAware......");
    }

    @Override
    public void setBeanName(String s) {
        System.out.println("BeanNameAware......");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("DisposableBean......");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("InitializingBean......");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("ApplicationContextAware......");
    }
}
```

BeanFactoryPostProcessor:

```
public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {

    public MyBeanFactoryPostProcessor() {
        super();
        System.out.println("这是BeanFactoryPostProcessor实现类构造器！！");
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory arg0)
            throws BeansException {
        System.out.println("BeanFactoryPostProcessor调用postProcessBeanFactory方法");
        BeanDefinition bd = arg0.getBeanDefinition("student");
        MutablePropertyValues propertyValues = bd.getPropertyValues();
        //配置文件中的信息在加载到Spring中后以BeanDefinition的形式存在.在这里又可以更改BeanDefinition,所以可以理解为更改配置文件里面的内容
//        propertyValues.add("zdy","123");
    }

}
```

BeanPostProcessor:

```
public class MyBeanPostProcessor implements BeanPostProcessor {

    public MyBeanPostProcessor() {
        super();
        System.out.println("这是BeanPostProcessor实现类构造器！！");
    }

    @Override
    public Object postProcessAfterInitialization(Object arg0, String arg1)
            throws BeansException {
        System.out.println("BeanPostProcessor接口方法After对属性进行更改！");
        return arg0;
    }

    @Override
    public Object postProcessBeforeInitialization(Object arg0, String arg1)
            throws BeansException {
        System.out.println("BeanPostProcessor接口方法Before对属性进行更改！");
        return arg0;
    }
}
```

InstantiationAwareBeanPostProcessorAdapter:

```
public class MyInstantiationAwareBeanPostProcessor extends
        InstantiationAwareBeanPostProcessorAdapter {

    public MyInstantiationAwareBeanPostProcessor() {
        super();
        System.out.println("这是InstantiationAwareBeanPostProcessorAdapter实现类构造器！！");
    }

    // 接口方法、实例化Bean之前调用
    @Override
    public Object postProcessBeforeInstantiation(Class beanClass,
                                                 String beanName) throws BeansException {
        System.out.println("InstantiationAwareBeanPostProcessor调用Before方法");
        return null;
    }

    // 接口方法、实例化Bean之后调用
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName)
            throws BeansException {
        System.out.println("InstantiationAwareBeanPostProcessor调用Ater方法");
        return bean;
    }

    // 接口方法、设置某个属性时调用
    @Override
    public PropertyValues postProcessPropertyValues(PropertyValues pvs,
                                                    PropertyDescriptor[] pds, Object bean, String beanName)
            throws BeansException {
        System.out.println("InstantiationAwareBeanPostProcessor调用postProcessPropertyValues方法");
        return pvs;
    }
}
```

然后我们的Main方法:

```
public class App 
{
    public static void main( String[] args )
    {

        ApplicationContext ac =new ClassPathXmlApplicationContext("applicationContext.xml");
        Student stu = (Student) ac.getBean("student");
        stu.setName("wangwu");
    }
}
```

Spring文件最简单:（注意要把我们自己定义的处理器全部加到容器里去）

```
<?xml version="1.0" encoding="UTF-8"?>
<beans
    <bean id="student" class="com.zdy.Student">
        <constructor-arg value="zhangsan"/>
    </bean>
    <bean id="myBeanFactoryPostProcessor" class="com.zdy.MyBeanFactoryPostProcessor"></bean>
    <bean id="myInstantiationAwareBeanPostProcessor" class="com.zdy.MyInstantiationAwareBeanPostProcessor"></bean>
    <bean id="myBeanPostProcessor" class="com.zdy.MyBeanPostProcessor"></bean>
</beans>
```

然后run一下子，看结果:

```
这是BeanFactoryPostProcessor实现类构造器！！
BeanFactoryPostProcessor调用postProcessBeanFactory方法
这是InstantiationAwareBeanPostProcessorAdapter实现类构造器！！
这是BeanPostProcessor实现类构造器！！
InstantiationAwareBeanPostProcessor调用Before方法
InstantiationAwareBeanPostProcessor调用postProcessPropertyValues方法
BeanNameAware......
BeanFactoryAware......
ApplicationContextAware......
BeanPostProcessor接口方法Before对属性进行更改！
InitializingBean......
InstantiationAwareBeanPostProcessor调用Ater方法
BeanPostProcessor接口方法After对属性进行更改！
```

好了，其实大致流程就说完了，我大致针对Bean的生命周期说一下:Spring为了尽可能的把自己内部的东西机制暴露出来给用户使用，所以在Bean创建的过程中加了很多机制，通过所谓的"处理器"Processor暴露出来,然后处理器都有自己的顺序，我们需要做的就是定义好处理器的逻辑，然后注册到Sprinhg容器中，Spring就会调用了。

其次，还有一种方式，就是让我们的Bean实现一些接口(类似于ApplicationContextAware)，通过这种方式，在Bean初始化的某个步骤调用接口定义好的方法来传入一些信息进来，像ApplicationContextAware就把ApplicationContext给传给我们了。

然后我给大家说几个实用点的知识点，大家记着，用到时回来翻一翻就可以了:

1. 上面的生命周期流程图，时候的时候注意调用先后顺序，避免属性被覆盖的现象。
2. BeanFactoryPostProcessor 主要是在Spring刚加载完配置文件，还没来得及初始化Bean的时候做一些操作。比如篡改某个Bean在配置文件中配置的内容。
3. InstantiationAwareBeanPostProcessorAdapter 基本没什么鸟用，Bean初始化后，还没有设置属性值时调用，和BeanFactoryPostProcessor一样，可以篡改配置文件加载到内存中的信息。
4. ApplicationContextAware:用处很大，注入了ApplicationContext到Bean中。
5. InitializingBean:有用处，可以在Bean属性全部改完之后，再做一些定制化操作。
6. BeanPostProcessor：没什么用，Spring框架内部使用的比较猛，像什么AOP，动态代理，都是在这搞事。后期有时间和大家分析。
7. 其他的像什么init-method，destroy方法，基本都是个摆设。。我是没怎么用过，只知道有这么回事。

## 结语

好了，Bean的生命周期算上和大家分享完了，其实没什么东西，大家知道有这么回事，能用到"后处理器"搞事的时候回来大致看下顺序即可。其次就是一些Bean实现的接口，最常用的就是(ApplicationContextAware和InitializingBean)了。还有就是BeanPostProcessor，因为这个接口的方法里会把Bean实体以Object传进去。

所以可以进行一些属性上的操作。其实说实在的，程序员用的比较少。框架内部用的多。OK，这篇讲的其实比较糙，主要是因为没什么东西可讲，Over，Have a good day !

> 来源：juejin.im/post/5a4ee1f6518825733e603fcb