## 【51期】一道阿里面试题：说说你知道的关于BeanFactory和FactoryBean的区别

至尊宝 [Java面试题精选](javascript:void(0);) *2月24日*

点击上方“Java面试题精选”，关注公众号

面试刷图，查缺补漏

**BeanFacotry是spring中比较原始的Factory。**如XMLBeanFactory就是一种典型的BeanFactory。原始的BeanFactory无法支持spring的许多插件，如AOP功能、Web应用等。

**ApplicationContext接口，它由BeanFactory接口派生而来。**ApplicationContext包含BeanFactory的所有功能，通常建议比BeanFactory优先。

## BeanFactory和FactoryBean的区别

BeanFactory是接口，提供了OC容器最基本的形式，给具体的IOC容器的实现提供了规范，

FactoryBean也是接口，为IOC容器中Bean的实现提供了更加灵活的方式，FactoryBean在IOC容器的基础上给Bean的实现加上了一个简单工厂模式和装饰模式(如果想了解装饰模式参考：修饰者模式(装饰者模式，Decoration) 我们可以在getObject()方法中灵活配置。其实在Spring源码中有很多FactoryBean的实现类.

**区别：**BeanFactory是个Factory，也就是IOC容器或对象工厂，FactoryBean是个Bean。在Spring中，**所有的Bean都是由BeanFactory(也就是IOC容器)来进行管理的。**

但**对FactoryBean而言，这个Bean不是简单的Bean，而是一个能生产或者修饰对象生成的工厂Bean,它的实现与设计模式中的工厂模式和修饰器模式类似**

### 1、BeanFactory

BeanFactory，以Factory结尾，表示它是一个工厂类(接口)， 它负责生产和管理bean的一个工厂。**在Spring中，BeanFactory是IOC容器的核心接口，它的职责包括：****实例化、定位、配置应用程序中的对象及建立这些对象间的依赖。**

BeanFactory只是个接口，并不是IOC容器的具体实现，但是Spring容器给出了很多种实现，如 DefaultListableBeanFactory、XmlBeanFactory、ApplicationContext等，其中XmlBeanFactory就是常用的一个，该实现将以XML方式描述组成应用的对象及对象间的依赖关系。XmlBeanFactory类将持有此XML配置元数据，并用它来构建一个完全可配置的系统或应用。

都是附加了某种功能的实现。它为其他具体的IOC容器提供了最基本的规范，例如DefaultListableBeanFactory,XmlBeanFactory,ApplicationContext 等具体的容器都是实现了BeanFactory，再在其基础之上附加了其他的功能。

**BeanFactory和ApplicationContext就是spring框架的两个IOC容器，现在一般使用ApplicationnContext，其不但包含了BeanFactory的作用，同时还进行更多的扩展。**

BeanFacotry是spring中比较原始的Factory。如XMLBeanFactory就是一种典型的BeanFactory。

原始的BeanFactory无法支持spring的许多插件，如AOP功能、Web应用等。ApplicationContext接口,它由BeanFactory接口派生而来，

ApplicationContext包含BeanFactory的所有功能，通常建议比BeanFactory优先

ApplicationContext以一种更向面向框架的方式工作以及对上下文进行分层和实现继承，ApplicationContext包还提供了以下的功能：

- MessageSource, 提供国际化的消息访问
- 资源访问，如URL和文件
- 事件传播
- 载入多个（有继承关系）上下文 ，使得每一个上下文都专注于一个特定的层次，比如应用的web层;

在不使用spring框架之前，我们的service层中要使用dao层的对象，不得不在service层中new一个对象。存在的问题：层与层之间的依赖。

service层要用dao层对象需要配置到xml配置文件中，至于对象是怎么创建的，关系是怎么组合的都交给了spring框架去实现。

方式1、

```
Resource resource = new FileSystemResource("beans.xml");
BeanFactory factory = new XmlBeanFactory(resource);
```

方式2、

```
ClassPathResource resource = new ClassPathResource("beans.xml");
BeanFactory factory = new XmlBeanFactory(resource);
```

方式3、

```
ApplicationContext context = new ClassPathXmlApplicationContext(new String[] {"applicationContext.xml", "applicationContext-part2.xml"});
BeanFactory factory = (BeanFactory) context;
```

基本就是这些了，接着使用getBean(String beanName)方法就可以取得bean的实例；BeanFactory提供的方法及其简单，仅提供了六种方法供客户调用：

- **boolean containsBean(String beanName)** 判断工厂中是否包含给定名称的bean定义，若有则返回true

- **Object getBean(String)** 返回给定名称注册的bean实例。根据bean的配置情况，如果是singleton模式将返回一个共享实例，否则将返回一个新建的实例，如果没有找到指定bean,该方法可能会抛出异常

- **Object getBean(String, Class)** 返回以给定名称注册的bean实例，并转换为给定class类型

- **Class getType(String name)** 返回给定名称的bean的Class,如果没有找到指定的bean实例，则排除NoSuchBeanDefinitionException异常

- **boolean isSingleton(String)** 判断给定名称的bean定义是否为单例模式

- **String[] getAliases(String name)** 返回给定bean名称的所有别名

  

```
package org.springframework.beans.factory;  
import org.springframework.beans.BeansException;  
public interface BeanFactory {  
    String FACTORY_BEAN_PREFIX = "&";  
    Object getBean(String name) throws BeansException;  
    <T> T getBean(String name, Class<T> requiredType) throws BeansException;  
    <T> T getBean(Class<T> requiredType) throws BeansException;  
    Object getBean(String name, Object... args) throws BeansException;  
    boolean containsBean(String name);  
    boolean isSingleton(String name) throws NoSuchBeanDefinitionException;  
    boolean isPrototype(String name) throws NoSuchBeanDefinitionException;  
    boolean isTypeMatch(String name, Class<?> targetType) throws NoSuchBeanDefinitionException;  
    Class<?> getType(String name) throws NoSuchBeanDefinitionException;  
    String[] getAliases(String name);  
}
```

### 2、FactoryBean

**一般情况下，Spring通过反射机制利用`<bean>`的class属性指定实现类实例化Bean，在某些情况下，实例化Bean过程比较复杂，如果按照传统的方式，则需要在`<bean>`中提供大量的配置信息。****配置方式的灵活性是受限的，这时采用编码的方式可能会得到一个简单的方案。**

Spring为此提供了一个org.springframework.bean.factory.FactoryBean的工厂类接口，用户可以通过实现该接口定制实例化Bean的逻辑。FactoryBean接口对于Spring框架来说占用重要的地位，Spring自身就提供了70多个FactoryBean的实现。**它们隐藏了实例化一些复杂Bean的细节，给上层应用带来了便利。****从Spring3.0开始，FactoryBean开始支持泛型，即接口声明改为`FactoryBean<T>`的形式**

以Bean结尾，表示它是一个Bean，不同于普通Bean的是：它是实现了`FactoryBean<T>`接口的Bean，根据该Bean的ID从BeanFactory中获取的实际上是FactoryBean的getObject()返回的对象，而不是FactoryBean本身，如果要获取FactoryBean对象，请在id前面加一个&符号来获取。

例如自己实现一个FactoryBean，功能：用来代理一个对象，对该对象的所有方法做一个拦截，在调用前后都输出一行LOG，模仿ProxyFactoryBean的功能。

```
/**
 * my factory bean<p>
 * 代理一个类，拦截该类的所有方法，在方法的调用前后进行日志的输出
 * @author daniel.zhao
 *
 */
public class MyFactoryBean implements FactoryBean<Object>, InitializingBean, DisposableBean {

    private static final Logger logger = LoggerFactory.getLogger(MyFactoryBean.class);    
    private String interfaceName;    
    private Object target;    
    private Object proxyObj;    
    @Override
    public void destroy() throws Exception {
        logger.debug("destroy......");
    }
    @Override
    public void afterPropertiesSet() throws Exception {
        proxyObj = Proxy.newProxyInstance(
                this.getClass().getClassLoader(), 
                new Class[] { Class.forName(interfaceName) }, 
                new InvocationHandler() {                    
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                logger.debug("invoke method......" + method.getName());
                logger.debug("invoke method before......" + System.currentTimeMillis());
                Object result = method.invoke(target, args);
                logger.debug("invoke method after......" + System.currentTimeMillis());
                return result;            }            
        });
        logger.debug("afterPropertiesSet......");
    }

    @Override
    public Object getObject() throws Exception {
        logger.debug("getObject......");
        return proxyObj;
    }

    @Override
    public Class<?> getObjectType() {
        return proxyObj == null ? Object.class : proxyObj.getClass();
    }

    @Override
    public boolean isSingleton() {
        return true;
    }

    public String getInterfaceName() {
        return interfaceName;
    }

    public void setInterfaceName(String interfaceName) {
        this.interfaceName = interfaceName;
    }

    public Object getTarget() {
        return target;
    }

    public void setTarget(Object target) {
        this.target = target;
    }

    public Object getProxyObj() {
        return proxyObj;
    }

    public void setProxyObj(Object proxyObj) {
        this.proxyObj = proxyObj;
    }

}
```

XML-Bean配置如下

```
<bean id="fbHelloWorldService" class="com.ebao.xxx.MyFactoryBean">
   <property name="interfaceName" value="com.ebao.xxx.HelloWorldService" />
   <property name="target" ref="helloWorldService" />
</bean>
```

Junit Test class

```
@RunWith(JUnit4ClassRunner.class)
@ContextConfiguration(classes = { MyFactoryBeanConfig.class })
public class MyFactoryBeanTest {
    @Autowired
    private ApplicationContext context;    
    /**
     * 测试验证FactoryBean原理，代理一个servcie在调用其方法的前后，打印日志亦可作其他处理
     * 从ApplicationContext中获取自定义的FactoryBean
     * context.getBean(String beanName) ---> 最终获取到的Object是FactoryBean.getObejct(), 
     * 使用Proxy.newInstance生成service的代理类
     */
    @Test
    public void testFactoryBean() {
        HelloWorldService helloWorldService = (HelloWorldService) context.getBean("fbHelloWorldService");
        helloWorldService.getBeanName();
        helloWorldService.sayHello();
    }
}
```

FactoryBean是一个接口，当在IOC容器中的Bean实现了FactoryBean后，通过getBean(String BeanName)获取到的Bean对象并不是FactoryBean的实现类对象，而是这个实现类中的getObject()方法返回的对象。要想获取FactoryBean的实现类，就要getBean(&BeanName)，在BeanName之前加上&。

Java代码

```
package org.springframework.beans.factory;  
public interface FactoryBean<T> {  
    T getObject() throws Exception;  
    Class<?> getObjectType();  
    boolean isSingleton();  
}
```

在该接口中还定义了以下3个方法：

- **TgetObject()：**返回由FactoryBean创建的Bean实例，如果isSingleton()返回true，则该实例会放到Spring容器中单实例缓存池中；
- **booleanisSingleton()：**返回由FactoryBean创建的Bean实例的作用域是singleton还是prototype；
- **Class<T>getObjectType()：**返回FactoryBean创建的Bean类型。

当配置文件中`<bean>`的class属性配置的实现类是FactoryBean时，通过getBean()方法返回的不是FactoryBean本身，而是FactoryBean#getObject()方法所返回的对象，相当于FactoryBean#getObject()代理了getBean()方法。

例：如果使用传统方式配置下面Car的`<bean>`时，Car的每个属性分别对应一个`<property>`元素标签。

```
package  com.baobaotao.factorybean;  
    public   class  Car  {  
        private   int maxSpeed ;  
        private  String brand ;  
        private   double price ;  
        public   int  getMaxSpeed ()   {  
            return   this . maxSpeed ;  
        }  
        public   void  setMaxSpeed ( int  maxSpeed )   {  
            this . maxSpeed  = maxSpeed;  
        }  
        public  String getBrand ()   {  
            return   this . brand ;  
        }  
        public   void  setBrand ( String brand )   {  
            this . brand  = brand;  
        }  
        public   double  getPrice ()   {  
            return   this . price ;  
        }  
        public   void  setPrice ( double  price )   {  
            this . price  = price;  
       }  
}
```

如果用FactoryBean的方式实现就灵活点，下例通过逗号分割符的方式一次性的为Car的所有属性指定配置值：

```
package  com.baobaotao.factorybean;  
import  org.springframework.beans.factory.FactoryBean;  
public   class  CarFactoryBean  implements  FactoryBean<Car>  {  
    private  String carInfo ;  
    public  Car getObject ()   throws  Exception  {  
        Car car =  new  Car () ;  
        String []  infos =  carInfo .split ( "," ) ;  
        car.setBrand ( infos [ 0 ]) ;  
        car.setMaxSpeed ( Integer. valueOf ( infos [ 1 ])) ;  
        car.setPrice ( Double. valueOf ( infos [ 2 ])) ;  
        return  car;  
    }  
    public  Class<Car> getObjectType ()   {  
        return  Car. class ;  
    }  
    public   boolean  isSingleton ()   {  
        return   false ;  
    }  
    public  String getCarInfo ()   {  
        return   this . carInfo ;  
    }  

    // 接受逗号分割符设置属性信息  
    public   void  setCarInfo ( String carInfo )   {  
        this . carInfo  = carInfo;  
    }  
}
```

有了这个CarFactoryBean后，就可以在配置文件中使用下面这种自定义的配置方式配置CarBean了：

```
<bean d="car"class="com.baobaotao.factorybean.CarFactoryBean"
P:carInfo="法拉利,400,2000000"/>
```

当调用getBean("car")时，Spring通过反射机制发现CarFactoryBean实现了FactoryBean的接口，这时Spring容器就调用接口方法CarFactoryBean#getObject()方法返回。如果希望获取CarFactoryBean的实例，则需要在使用getBean(beanName)方法时在beanName前显示的加上"&"前缀：如getBean("&car");

下面是一个应用FactoryBean的例子

```
<beans xmlns="http://www.springframework.org/schema/beans"  
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
             xmlns:context="http://www.springframework.org/schema/context"  
             xmlns:aop="http://www.springframework.org/schema/aop"  
             xmlns:tx="http://www.springframework.org/schema/tx"  
             xsi:schemaLocation="http://www.springframework.org/schema/beans  
                     http://www.springframework.org/schema/beans/spring-beans-3.0.xsd  
                     http://www.springframework.org/schema/context  
                     http://www.springframework.org/schema/context/spring-context-3.0.xsd  
                     http://www.springframework.org/schema/aop  
                     http://www.springframework.org/schema/aop/spring-aop-3.0.xsd  
                     http://www.springframework.org/schema/tx  
                     http://www.springframework.org/schema/tx/spring-tx-3.0.xsd">  

 <bean id="student" class="com.spring.bean.Student">    
  <property name="name" value="zhangsan" />    
 </bean>    

 <bean id="school" class="com.spring.bean.School">    
 </bean>   

 <bean id="factoryBeanPojo" class="com.spring.bean.FactoryBeanPojo">    
    <property name="type" value="student" />  
 </bean>   
</beans>
```

FactoryBean的实现类

```
import org.springframework.beans.factory.FactoryBean;  

/**  
 * @author  作者 wangbiao 
 * @parameter  
 * @return  
 */  
public class FactoryBeanPojo implements FactoryBean{  
    private String type;  

    @Override  
    public Object getObject() throws Exception {  
        if("student".equals(type)){  
            return new Student();             
        }else{  
            return new School();  
        }  

    }  

    @Override  
    public Class getObjectType() {  
        return School.class;  
    }  

    @Override  
    public boolean isSingleton() {  
        return true;  
    }  

    public String getType() {  
        return type;  
    }  

    public void setType(String type) {  
        this.type = type;  
    }  

}
```

普通的bean

```
/**  
 * @author  作者 wangbiao 
 * @parameter  
 * @return  
 */  
public class School {  
    private String schoolName;  
    private String address;  
    private int studentNumber;  
    public String getSchoolName() {  
        return schoolName;  
    }  
    public void setSchoolName(String schoolName) {  
        this.schoolName = schoolName;  
    }  
    public String getAddress() {  
        return address;  
    }  
    public void setAddress(String address) {  
        this.address = address;  
    }  
    public int getStudentNumber() {  
        return studentNumber;  
    }  
    public void setStudentNumber(int studentNumber) {  
        this.studentNumber = studentNumber;  
    }  
    @Override  
    public String toString() {  
        return "School [schoolName=" + schoolName + ", address=" + address  
                + ", studentNumber=" + studentNumber + "]";  
    }  
}
```

测试类

```
import org.springframework.context.support.ClassPathXmlApplicationContext;  

import com.spring.bean.FactoryBeanPojo;  

/**  
 * @author  作者 wangbiao 
 * @parameter  
 * @return  
 */  
public class FactoryBeanTest {  
    public static void main(String[] args){  
        String url = "com/spring/config/BeanConfig.xml";  
        ClassPathXmlApplicationContext cpxa = new ClassPathXmlApplicationContext(url);  
        Object school=  cpxa.getBean("factoryBeanPojo");  
        FactoryBeanPojo factoryBeanPojo= (FactoryBeanPojo) cpxa.getBean("&factoryBeanPojo");  
        System.out.println(school.getClass().getName());  
        System.out.println(factoryBeanPojo.getClass().getName());  
    }  
}
```

输出的结果：

```
十一月 16, 2016 10:28:24 上午 org.springframework.context.support.AbstractApplicationContext prepareRefresh  
INFO: Refreshing org.springframework.context.support.ClassPathXmlApplicationContext@1e8ee5c0: startup date [Wed Nov 16 10:28:24 CST 2016]; root of context hierarchy  
十一月 16, 2016 10:28:24 上午 org.springframework.beans.factory.xml.XmlBeanDefinitionReader loadBeanDefinitions  
INFO: Loading XML bean definitions from class path resource [com/spring/config/BeanConfig.xml]  
十一月 16, 2016 10:28:24 上午 org.springframework.beans.factory.support.DefaultListableBeanFactory preInstantiateSingletons  
INFO: Pre-instantiating singletons in org.springframework.beans.factory.support.DefaultListableBeanFactory@35b793ee: defining beans [student,school,factoryBeanPojo]; root of factory hierarchy  
com.spring.bean.Student  
com.spring.bean.FactoryBeanPojo
```

从结果上可以看到当从IOC容器中获取FactoryBeanPojo对象的时候，用getBean(String BeanName)获取的确是Student对象，可以看到在FactoryBeanPojo中的type属性设置为student的时候，会在getObject()方法中返回Student对象。

所以说从IOC容器获取实现了FactoryBean的实现类时，返回的却是实现类中的getObject方法返回的对象，要想获取FactoryBean的实现类，得在getBean(String BeanName)中的BeanName之前加上&,写成getBean(String &BeanName)。

## 参考

> https://blog.csdn.net/wangbiao007/article/details/53183764
> https://blog.csdn.net/qiesheng/article/details/72875315
> https://www.cnblogs.com/redcool/p/6413461.html

> 来源：cnblogs.com/aspirant/p/9082858.html