## Spring框架中Bean的生命周期

面试菌 [Java面试题精选](javascript:void(0);) *2019-09-30*

点击上方“Java面试题精选”，关注公众号

面试刷图，查缺补漏！



**首先简单说一下（以下为一个回答的参考模板）**

1、实例化一个Bean－－也就是我们常说的new；

2、按照Spring上下文对实例化的Bean进行配置－－也就是IOC注入；

3、如果这个Bean已经实现了BeanNameAware接口，会调用它实现的setBeanName(String)方法，此处传递的就是Spring配置文件中Bean的id值

4、如果这个Bean已经实现了BeanFactoryAware接口，会调用它实现的setBeanFactory(setBeanFactory(BeanFactory)传递的是Spring工厂自身（可以用这个方式来获取其它Bean，只需在Spring配置文件中配置一个普通的Bean就可以）；

5、如果这个Bean已经实现了ApplicationContextAware接口，会调用setApplicationContext(ApplicationContext)方法，传入Spring上下文（同样这个方式也可以实现步骤4的内容，但比4更好，因为ApplicationContext是BeanFactory的子接口，有更多的实现方法）；

6、如果这个Bean关联了BeanPostProcessor接口，将会调用postProcessBeforeInitialization(Object obj, String s)方法，BeanPostProcessor经常被用作是Bean内容的更改，并且由于这个是在Bean初始化结束时调用那个的方法，也可以被应用于内存或缓存技术；

7、如果Bean在Spring配置文件中配置了init-method属性会自动调用其配置的初始化方法。

8、如果这个Bean关联了BeanPostProcessor接口，将会调用postProcessAfterInitialization(Object obj, String s)方法、；

> 注：以上工作完成以后就可以应用这个Bean了，那这个Bean是一个Singleton的，所以一般情况下我们调用同一个id的Bean会是在内容地址相同的实例，当然在Spring配置文件中也可以配置非Singleton，这里我们不做赘述。

9、当Bean不再需要时，会经过清理阶段，如果Bean实现了DisposableBean这个接口，会调用那个其实现的destroy()方法；

10、最后，如果这个Bean的Spring配置中配置了destroy-method属性，会自动调用其配置的销毁方法。

**结合代码理解一下**

### **1、Bean的定义**

Spring通常通过配置文件定义Bean。如：

```
<?xml version=”1.0″ encoding=”UTF-8″?>

<beans xmlns=”http://www.springframework.org/schema/beans”
xmlns:xsi=”http://www.w3.org/2001/XMLSchema-instance”
xsi:schemaLocation=”http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd”>

<bean id=”HelloWorld” class=”com.pqf.beans.HelloWorld”>
    <property name=”msg”>
       <value>HelloWorld</value>
    </property>
</bean>

</beans>
```

这个配置文件就定义了一个标识为 HelloWorld 的Bean。在一个配置文档中可以定义多个Bean。

### **2、Bean的初始化**

有两种方式初始化Bean。

#### 1、在配置文档中通过指定init-method 属性来完成

在Bean的类中实现一个初始化Bean属性的方法，如init()，如：

```
public class HelloWorld{
   public String msg=null;
   public Date date=null;

    public void init() {
      msg=”HelloWorld”;
      date=new Date();
    }
    …… 
}
```

然后，在配置文件中设置init-mothod属性：

#### 2、实现 org.springframwork.beans.factory.InitializingBean接口

Bean实现InitializingBean接口，并且增加 afterPropertiesSet() 方法：

```
public class HelloWorld implement InitializingBean {
   public String msg=null;
   public Date date=null;

   public void afterPropertiesSet() {
       msg="向全世界问好！";
       date=new Date();
   }
    …… 
}
```

那么，当这个Bean的所有属性被Spring的BeanFactory设置完后，会自动调用afterPropertiesSet()方法对Bean进行初始化，于是，配置文件就不用指定 init-method属性了。

### **3、Bean的调用**

有三种方式可以得到Bean并进行调用：

#### 1、使用BeanWrapper

```
HelloWorld hw=new HelloWorld();
BeanWrapper bw=new BeanWrapperImpl(hw);
bw.setPropertyvalue(”msg”,”HelloWorld”);
system.out.println(bw.getPropertyCalue(”msg”));
```

#### 2、使用BeanFactory

```
InputStream is=new FileInputStream(”config.xml”);
XmlBeanFactory factory=new XmlBeanFactory(is);
HelloWorld hw=(HelloWorld) factory.getBean(”HelloWorld”);
system.out.println(hw.getMsg());
```

#### 3、使用ApplicationConttext

```
ApplicationContext actx=new FleSystemXmlApplicationContext(”config.xml”);
HelloWorld hw=(HelloWorld) actx.getBean(”HelloWorld”);
System.out.println(hw.getMsg());
```

### **4、Bean的销毁**

#### 1、使用配置文件中的 destory-method 属性

与初始化属性 init-methods类似，在Bean的类中实现一个撤销Bean的方法，然后在配置文件中通过 destory-method指定，那么当bean销毁时，Spring将自动调用指定的销毁方法。

#### 2、实现 org.springframwork.bean.factory.DisposebleBean接口

如果实现了DisposebleBean接口，那么Spring将自动调用bean中的Destory方法进行销毁，所以，Bean中必须提供Destory方法。

**图解**

**
**

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XC6XnKb0vUlqM1wlTbyuYv0ndXibbicKia9ALmO99XVs2OviaJSLSAyTvVc0GbsM9QUxQZ4aldfy8nZfQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)