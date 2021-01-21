## 【171期】面试官：小伙汁，Spring是怎么解决循环依赖的呢？

## 前言

Spring大家族功能强大，模块复杂繁多。就Spring Framework模块而言，核心功能只有两个：`IoC`和`AOP`。

本篇主要从源码的角度讲解Spring容器中一些重要的接口、Spring如何解决循环依赖等

> 本篇使用的Spring版本为`5.2.2.RELEASE`。

Spring的源码错综复杂，并且类名一般都比较长，并且调用层次较深。因此阅读起来有一定的难度，所以阅读的时候可以先从大体上理解整个流程，而不需要逐行的阅读。不然很容易陷入细节而无法自拔，导致事倍功半。

在深入Spring源码之前，需要先了解几个非常重要的接口，理解他们，是理解Spring容器启动的关键。

## 核心接口

### BeanDefinition

`BeanDefinition`是Spring中非常重要的一个接口，定义于`spring-beans`模块中，其定义如下：

```
/**
 * A BeanDefinition describes a bean instance, which has property values,
 * constructor argument values, and further information supplied by
 * concrete implementations.
 *
 * <p>This is just a minimal interface: The main intention is to allow a
 * {@link BeanFactoryPostProcessor} to introspect and modify property values
 * and other bean metadata.
 *
 */
public interface BeanDefinition extends AttributeAccessor, BeanMetadataElement {
}
```

根据接口描述，我们可以知道

> BeanDefinition描述了一个bean实例，它具有属性值，构造函数参数值以及具体实现提供的更多信息。

看完类的描述，我们似乎依然不知道这个接口是用来干嘛的。

就博主自己的理解，`BeanDefinition`主要做用是定义了一个`Spring Bean`的元信息（metadata）的抽象。使得不管是XML文件配置的`Spring Bean`、注解扫描的`Spring Bean`，还是`Java Config`类配置`Spring Bean`，都能一个统一的抽象来表示，这个抽象就是`BeanDefinition`。

接下来看一下这个接口里面的（部分）内容，可以帮助理解这个接口的作用

```
/** 返回当前bean实例是否是单例 */
boolean isSingleton();

/** 返回当前bean是否应该被懒加载 */
boolean isLazyInit();

/** 返回bean的类名称 */
@Nullable
String getBeanClassName();
```

从这个几个接口方法的描述就可以看出`BeanDefinition`可以描述`Spring Bean`的元信息。

在我们学习Java的时候其实已经接触过这样的类，那就是`java.lang.Class`类，`Class`就是用来描述JDK中各个类的元信息的抽象，我们可以从`Class`类获取类的名称、构造函数、字段等信息。

### BeanFactory

`BeanFactory`是Spring中非常重要的一个接口，定义于`spring-beans`模块中，其定义如下：

```
/**
 * The root interface for accessing a Spring bean container.
 * This is the basic client view of a bean container;
 * further interfaces such as {@link ListableBeanFactory} and
 * {@link org.springframework.beans.factory.config.ConfigurableBeanFactory}
 * are available for specific purposes.
 *
 * <p>Bean factory implementations should support the standard bean lifecycle interfaces
 * as far as possible. The full set of initialization methods and their standard order is:
 * <ol>
 * <li>BeanNameAware's {@code setBeanName}
 * <li>BeanClassLoaderAware's {@code setBeanClassLoader}
 * <li>BeanFactoryAware's {@code setBeanFactory}
 * <li>EnvironmentAware's {@code setEnvironment}
 * <li>EmbeddedValueResolverAware's {@code setEmbeddedValueResolver}
 * <li>ResourceLoaderAware's {@code setResourceLoader} (only applicable when running in an application context)
 * <li>ApplicationEventPublisherAware's {@code setApplicationEventPublisher} (only applicable when running in an application context)
 * <li>MessageSourceAware's {@code setMessageSource} (only applicable when running in an application context)
 * <li>ApplicationContextAware's {@code setApplicationContext} (only applicable when running in an application context)
 * <li>ServletContextAware's {@code setServletContext} (only applicable when running in a web application context)
 * <li>{@code postProcessBeforeInitialization} methods of BeanPostProcessors
 * <li>InitializingBean's {@code afterPropertiesSet}
 * <li>a custom init-method definition
 * <li>{@code postProcessAfterInitialization} methods of BeanPostProcessors
 * </ol>
 *
 * <p>On shutdown of a bean factory, the following lifecycle methods apply:
 * <ol>
 * <li>{@code postProcessBeforeDestruction} methods of DestructionAwareBeanPostProcessors
 * <li>DisposableBean's {@code destroy}
 * <li>a custom destroy-method definition
 * </ol>
 *
 */
public interface BeanFactory {
}
```

从接口注释和接口定义就可以知道，`BeanFactory`是Spring容器的顶级接口。并且注释中也给出了全套初始化方法及其标准顺序。

由于是顶层接口，所以定义的方法比较少，最核心的方法当属`getBean`

```
/** 从Spring容器中获取bean实例 */
<T> T getBean(Class<T> requiredType) throws BeansException;

/** 从Spring容器中获取bean实例 */
Object getBean(String name) throws BeansException;
```

### ApplicationContext

`BeanFactory`是Spring的顶级接口，从`BeanFactory`中已经能够获取`Spring Bean`实例了，但是Spring依然提供了一个用来扩展`BeanFactory`的接口，那就是`ApplicationContext`，该接口是`BeanFactory`的超集。定义在`spring-context`模块中。

```
/**
 * Central interface to provide configuration for an application.
 * This is read-only while the application is running, but may be
 * reloaded if the implementation supports this.
 *
 * <p>An ApplicationContext provides:
 * <ul>
 * <li>Bean factory methods for accessing application components.
 * Inherited from {@link org.springframework.beans.factory.ListableBeanFactory}.
 * <li>The ability to load file resources in a generic fashion.
 * Inherited from the {@link org.springframework.core.io.ResourceLoader} interface.
 * <li>The ability to publish events to registered listeners.
 * Inherited from the {@link ApplicationEventPublisher} interface.
 * <li>The ability to resolve messages, supporting internationalization.
 * Inherited from the {@link MessageSource} interface.
 * <li>Inheritance from a parent context. Definitions in a descendant context
 * will always take priority. This means, for example, that a single parent
 * context can be used by an entire web application, while each servlet has
 * its own child context that is independent of that of any other servlet.
 * </ul>
 *
 * <p>In addition to standard {@link org.springframework.beans.factory.BeanFactory}
 * lifecycle capabilities, ApplicationContext implementations detect and invoke
 * {@link ApplicationContextAware} beans as well as {@link ResourceLoaderAware},
 * {@link ApplicationEventPublisherAware} and {@link MessageSourceAware} beans.
 *
 */
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory,
  MessageSource, ApplicationEventPublisher, ResourcePatternResolver {
}
```

根据类的描述可以知道这是一个中央接口，为应用程序提供配置。这个接口主要用来扩展`BeanFactory`的功能。`ApplicationContext`接口提供了如下功能

- 用于访问应用程序组件的Bean工厂方法
- 以通用方式加载文件资源的能力
- 将事件发布给注册的侦听器的能力
- 处理消息的能力，支持国际化

### BeanPostProcessor

`BeanPostProcessor`是Spring中非常重要的一个接口，定义于`spring-beans`模块中，其定义如下：

```
/**
 * Factory hook that allows for custom modification of new bean instances &mdash;
 * for example, checking for marker interfaces or wrapping beans with proxies.
 *
 * <p>Typically, post-processors that populate beans via marker interfaces
 * or the like will implement {@link #postProcessBeforeInitialization},
 * while post-processors that wrap beans with proxies will normally
 * implement {@link #postProcessAfterInitialization}.
 *
 * <h3>Registration</h3>
 * <p>An {@code ApplicationContext} can autodetect {@code BeanPostProcessor} beans
 * in its bean definitions and apply those post-processors to any beans subsequently
 * created. A plain {@code BeanFactory} allows for programmatic registration of
 * post-processors, applying them to all beans created through the bean factory.
 *
 * <h3>Ordering</h3>
 * <p>{@code BeanPostProcessor} beans that are autodetected in an
 * {@code ApplicationContext} will be ordered according to
 * {@link org.springframework.core.PriorityOrdered} and
 * {@link org.springframework.core.Ordered} semantics. In contrast,
 * {@code BeanPostProcessor} beans that are registered programmatically with a
 * {@code BeanFactory} will be applied in the order of registration; any ordering
 * semantics expressed through implementing the
 * {@code PriorityOrdered} or {@code Ordered} interface will be ignored for
 * programmatically registered post-processors. Furthermore, the
 * {@link org.springframework.core.annotation.Order @Order} annotation is not
 * taken into account for {@code BeanPostProcessor} beans.
 * 
 */
public interface BeanPostProcessor {
}
```

在Spring的源码中可以看到很多`PostProcessor`相关的接口和类，比如`BeanPostProcessor`、`BeanFactoryPostProcessor`。`*PostProcessor`是后置处理器，用来对已经被创建，但是尚未初始化完成的对象进行一些增强操作。

往期：[001期~150期汇总，方便阅读，不断更新中.....](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247485351&idx=2&sn=214225ab4345f4d9c562900cb42a52ba&chksm=e80db1d1df7a38c741137246bf020a5f8970f74cd03530ccc4cb2258c1ced68e66e600e9e059&scene=21#wechat_redirect)

## 启动Spring

想要启动一个Spring容器很简单，只需要几行代码。

```
public class SpringBeanLifecycle {

    public static void main(String[] args) {
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
        applicationContext.getBean(Student.class);
    }
}
```

其中`applicationContext.xml`是Spring的配置文件

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="student" class="com.sicimike.bean.lifecycle.Student"></bean>
</beans>
```

而`Student`类仅仅是为了注入Spring容器，无实际内容。

其实仅仅一行代码，就已经启动了Spring，那就是`new ClassPathXmlApplicationContext("applicationContext.xml")`。所以我们需要深入连接这个构造方法执行了哪些内容

```
/**
 * Create a new ClassPathXmlApplicationContext, loading the definitions
 * from the given XML file and automatically refreshing the context.
 * @param configLocation resource location
 * @throws BeansException if context creation failed
 */
public ClassPathXmlApplicationContext(String configLocation) throws BeansException {
 this(new String[] {configLocation}, true, null);
}
/**
 * Create a new ClassPathXmlApplicationContext with the given parent,
 * loading the definitions from the given XML files.
 * @param configLocations array of resource locations
 * @param refresh whether to automatically refresh the context,
 * loading all bean definitions and creating all singletons.
 * Alternatively, call refresh manually after further configuring the context.
 * @param parent the parent context
 * @throws BeansException if context creation failed
 * @see #refresh()
 */
public ClassPathXmlApplicationContext(
  String[] configLocations, boolean refresh, @Nullable ApplicationContext parent)
  throws BeansException {

 super(parent);
 // configLocations是加载的配置文件的名称数字，因此该方法主要的作用就是设置配置文件
 setConfigLocations(configLocations);
 if (refresh) {
  // 该方法就是启动Spring容器的核心方法
  refresh();
 }
}
```

### refresh

`refresh`方法执行的逻辑就是Spring容器启动的完整过程，其定义如下

```
@Override
public void refresh() throws BeansException, IllegalStateException {
 synchronized (this.startupShutdownMonitor) {
  // Prepare this context for refreshing.
  prepareRefresh();

  // Tell the subclass to refresh the internal bean factory.
  ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

  // Prepare the bean factory for use in this context.
  prepareBeanFactory(beanFactory);

  try {
   // Allows post-processing of the bean factory in context subclasses.
   postProcessBeanFactory(beanFactory);

   // Invoke factory processors registered as beans in the context.
   // 完成包（类）的扫描
   invokeBeanFactoryPostProcessors(beanFactory);

   // Register bean processors that intercept bean creation.
   // 注册后置处理器
   registerBeanPostProcessors(beanFactory);

   // Initialize message source for this context.
   // 国际化
   initMessageSource();

   // Initialize event multicaster for this context.
   初始化事件多播
   initApplicationEventMulticaster();

   // Initialize other special beans in specific context subclasses.
   onRefresh();

   // Check for listener beans and register them.
   registerListeners();

   // Instantiate all remaining (non-lazy-init) singletons.
   // 初始化所有的非懒加载的单例bean，核心方法
   finishBeanFactoryInitialization(beanFactory);

   // Last step: publish corresponding event.
   finishRefresh();
  }

  catch (BeansException ex) {
   if (logger.isWarnEnabled()) {
    logger.warn("Exception encountered during context initialization - " +
      "cancelling refresh attempt: " + ex);
   }

   // Destroy already created singletons to avoid dangling resources.
   destroyBeans();

   // Reset 'active' flag.
   cancelRefresh(ex);

   // Propagate exception to caller.
   throw ex;
  }

  finally {
   // Reset common introspection caches in Spring's core, since we
   // might not ever need metadata for singleton beans anymore...
   resetCommonCaches();
  }
 }
}
```

该方法虽然调用了很多其他方法，但是真正创建`Spring Bean`的逻辑是`finishBeanFactoryInitialization`方法。

### finishBeanFactoryInitialization

```
/**
 * Finish the initialization of this context's bean factory,
 * initializing all remaining singleton beans.
 */
protected void finishBeanFactoryInitialization(ConfigurableListableBeanFactory beanFactory) {
 // Initialize conversion service for this context.
 if (beanFactory.containsBean(CONVERSION_SERVICE_BEAN_NAME) &&
   beanFactory.isTypeMatch(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class)) {
  beanFactory.setConversionService(
    beanFactory.getBean(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class));
 }

 // Register a default embedded value resolver if no bean post-processor
 // (such as a PropertyPlaceholderConfigurer bean) registered any before:
 // at this point, primarily for resolution in annotation attribute values.
 if (!beanFactory.hasEmbeddedValueResolver()) {
  beanFactory.addEmbeddedValueResolver(strVal -> getEnvironment().resolvePlaceholders(strVal));
 }

 // Initialize LoadTimeWeaverAware beans early to allow for registering their transformers early.
 String[] weaverAwareNames = beanFactory.getBeanNamesForType(LoadTimeWeaverAware.class, false, false);
 for (String weaverAwareName : weaverAwareNames) {
  getBean(weaverAwareName);
 }

 // Stop using the temporary ClassLoader for type matching.
 beanFactory.setTempClassLoader(null);

 // Allow for caching all bean definition metadata, not expecting further changes.
 beanFactory.freezeConfiguration();

 // Instantiate all remaining (non-lazy-init) singletons.
 // 初始化所有的非懒加载的单例bean，核心方法
 beanFactory.preInstantiateSingletons();
}
```

### preInstantiateSingletons

```
@Override
public void preInstantiateSingletons() throws BeansException {
 if (logger.isTraceEnabled()) {
  logger.trace("Pre-instantiating singletons in " + this);
 }

 // Iterate over a copy to allow for init methods which in turn register new bean definitions.
 // While this may not be part of the regular factory bootstrap, it does otherwise work fine.
 List<String> beanNames = new ArrayList<>(this.beanDefinitionNames);

 // Trigger initialization of all non-lazy singleton beans...
 // 触发所有非懒加载的单例bean
 for (String beanName : beanNames) {
  // RootBeanDefinition是BeanDefinition的子类
  // 也就是spring bean的元信息的抽象，用来判断该bean是不是应该被初始化
  RootBeanDefinition bd = getMergedLocalBeanDefinition(beanName);
  if (!bd.isAbstract() && bd.isSingleton() && !bd.isLazyInit()) {
   // 如果是非抽象、非懒加载的单例bean，就应该被初始化
   if (isFactoryBean(beanName)) {
    Object bean = getBean(FACTORY_BEAN_PREFIX + beanName);
    if (bean instanceof FactoryBean) {
     final FactoryBean<?> factory = (FactoryBean<?>) bean;
     boolean isEagerInit;
     if (System.getSecurityManager() != null && factory instanceof SmartFactoryBean) {
      isEagerInit = AccessController.doPrivileged((PrivilegedAction<Boolean>)
          ((SmartFactoryBean<?>) factory)::isEagerInit,
        getAccessControlContext());
     }
     else {
      isEagerInit = (factory instanceof SmartFactoryBean &&
        ((SmartFactoryBean<?>) factory).isEagerInit());
     }
     if (isEagerInit) {
      getBean(beanName);
     }
    }
   }
   else {
    // 该方法才是真正的实例化spring bean
    getBean(beanName);
   }
  }
 }

 // Trigger post-initialization callback for all applicable beans...
 for (String beanName : beanNames) {
  Object singletonInstance = getSingleton(beanName);
  if (singletonInstance instanceof SmartInitializingSingleton) {
   final SmartInitializingSingleton smartSingleton = (SmartInitializingSingleton) singletonInstance;
   if (System.getSecurityManager() != null) {
    AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
     smartSingleton.afterSingletonsInstantiated();
     return null;
    }, getAccessControlContext());
   }
   else {
    smartSingleton.afterSingletonsInstantiated();
   }
  }
 }
}
```

![img](https://mmbiz.qpic.cn/mmbiz_png/8KKrHK5ic6XAj0Me94TRv5xlkRXpbbMiavZBkJxC3jbnwp9C8Lg18wzlpkow5dybw8eH0p63G1XjqTg1a4P59Qjw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)preInstantiateSingletons@row.1

从调试信息可以看到，`bd`是`RootBeanDefinition`，也就是`BeanDefinition`，它定义了Bean的元信息。

### getBean

```
@Override
public Object getBean(String name) throws BeansException {
 return doGetBean(name, null, null, false);
}
```

### doGetBean

该方法用于创建或者查询bean

```
/**
 * Return an instance, which may be shared or independent, of the specified bean.
 */
@SuppressWarnings("unchecked")
protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
  @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {

 // 校验bean的名称
 final String beanName = transformedBeanName(name);
 Object bean;

 // Eagerly check singleton cache for manually registered singletons.
 // 从单例池中获取对象，该方法非常重要，后文详解
 // 由于容器在这里第一次尝试创建或者获取bean，所以返回值为null
 Object sharedInstance = getSingleton(beanName);
 if (sharedInstance != null && args == null) {
  if (logger.isTraceEnabled()) {
   if (isSingletonCurrentlyInCreation(beanName)) {
    logger.trace("Returning eagerly cached instance of singleton bean '" + beanName +
      "' that is not fully initialized yet - a consequence of a circular reference");
   }
   else {
    logger.trace("Returning cached instance of singleton bean '" + beanName + "'");
   }
  }
  bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
 }

 else {
  // Fail if we're already creating this bean instance:
  // We're assumably within a circular reference.
  if (isPrototypeCurrentlyInCreation(beanName)) {
   // 判断该单例对象是否正在被创建
   throw new BeanCurrentlyInCreationException(beanName);
  }

  // Check if bean definition exists in this factory.
  BeanFactory parentBeanFactory = getParentBeanFactory();
  if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
   // Not found -> check parent.
   String nameToLookup = originalBeanName(name);
   if (parentBeanFactory instanceof AbstractBeanFactory) {
    return ((AbstractBeanFactory) parentBeanFactory).doGetBean(
      nameToLookup, requiredType, args, typeCheckOnly);
   }
   else if (args != null) {
    // Delegation to parent with explicit args.
    return (T) parentBeanFactory.getBean(nameToLookup, args);
   }
   else if (requiredType != null) {
    // No args -> delegate to standard getBean method.
    return parentBeanFactory.getBean(nameToLookup, requiredType);
   }
   else {
    return (T) parentBeanFactory.getBean(nameToLookup);
   }
  }

  if (!typeCheckOnly) {
   markBeanAsCreated(beanName);
  }

  try {
   final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
   checkMergedBeanDefinition(mbd, beanName, args);

   // Guarantee initialization of beans that the current bean depends on.
   String[] dependsOn = mbd.getDependsOn();
   if (dependsOn != null) {
    for (String dep : dependsOn) {
     if (isDependent(beanName, dep)) {
      throw new BeanCreationException(mbd.getResourceDescription(), beanName,
        "Circular depends-on relationship between '" + beanName + "' and '" + dep + "'");
     }
     registerDependentBean(dep, beanName);
     try {
      getBean(dep);
     }
     catch (NoSuchBeanDefinitionException ex) {
      throw new BeanCreationException(mbd.getResourceDescription(), beanName,
        "'" + beanName + "' depends on missing bean '" + dep + "'", ex);
     }
    }
   }

   // Create bean instance.
   if (mbd.isSingleton()) {
    // student对象是单例，所以执行该逻辑，此处再次调用getSingleton方法
    // 不过与上面不同的是，此处调用的是重载的方法
    sharedInstance = getSingleton(beanName, () -> {
     try {
      // 真正创建对象的方法
      return createBean(beanName, mbd, args);
     }
     catch (BeansException ex) {
      // Explicitly remove instance from singleton cache: It might have been put there
      // eagerly by the creation process, to allow for circular reference resolution.
      // Also remove any beans that received a temporary reference to the bean.
      destroySingleton(beanName);
      throw ex;
     }
    });
    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
   }

   else if (mbd.isPrototype()) {
    // It's a prototype -> create a new instance.
    Object prototypeInstance = null;
    try {
     beforePrototypeCreation(beanName);
     prototypeInstance = createBean(beanName, mbd, args);
    }
    finally {
     afterPrototypeCreation(beanName);
    }
    bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
   }

   else {
    String scopeName = mbd.getScope();
    final Scope scope = this.scopes.get(scopeName);
    if (scope == null) {
     throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
    }
    try {
     Object scopedInstance = scope.get(beanName, () -> {
      beforePrototypeCreation(beanName);
      try {
       return createBean(beanName, mbd, args);
      }
      finally {
       afterPrototypeCreation(beanName);
      }
     });
     bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
    }
    catch (IllegalStateException ex) {
     throw new BeanCreationException(beanName,
       "Scope '" + scopeName + "' is not active for the current thread; consider " +
       "defining a scoped proxy for this bean if you intend to refer to it from a singleton",
       ex);
    }
   }
  }
  catch (BeansException ex) {
   cleanupAfterBeanCreationFailure(beanName);
   throw ex;
  }
 }

 // Check if required type matches the type of the actual bean instance.
 if (requiredType != null && !requiredType.isInstance(bean)) {
  try {
   T convertedBean = getTypeConverter().convertIfNecessary(bean, requiredType);
   if (convertedBean == null) {
    throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
   }
   return convertedBean;
  }
  catch (TypeMismatchException ex) {
   if (logger.isTraceEnabled()) {
    logger.trace("Failed to convert bean '" + name + "' to required type '" +
      ClassUtils.getQualifiedName(requiredType) + "'", ex);
   }
   throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
  }
 }
 return (T) bean;
}
```

该方法中调用了三个非常重要的方法，分别是两个重载的`getSingleton`方法和`createBean`方法。

### getSingleton

该方法定义如下

```
@Nullable
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
 // 从单例缓存池中获取单例对象
 Object singletonObject = this.singletonObjects.get(beanName);
 if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
  // 获取的对象为null，且该单例对象正在被创建
  // 但是它的调用时间是在getSingleton方法（也就是当前方法）之后
  // 所以此处的isSingletonCurrentlyInCreation方法返回的是false
  // 两个条件只满足了第一个，所以不会进入下面的逻辑
  // 后面的逻辑会调用一个方法标识单例bean正在被创建，之后再调用isSingletonCurrentlyInCreation()方法会返回true
  synchronized (this.singletonObjects) {
   // 从缓存中获取
   singletonObject = this.earlySingletonObjects.get(beanName);
   if (singletonObject == null && allowEarlyReference) {
    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
    if (singletonFactory != null) {
     singletonObject = singletonFactory.getObject();
     // 如果没有就加入缓存
     this.earlySingletonObjects.put(beanName, singletonObject);
     this.singletonFactories.remove(beanName);
    }
   }
  }
 }
 // 直接返回null
 return singletonObject;
}
```

从方法的实现可以看到，Spring取单例对象是从`singletonObjects`对象中取的，该对象定义如下

```
/** Cache of singleton objects: bean name to bean instance. */
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);
```

实际上`singletonObjects`就是Spring Bean的单例对象缓存池，里面存放的就是所有已经被Spring创建的单例bean实例（经历了完整的Spring Bean初始化生命周期）。有的地方也叫做Spring的一级缓存，本质上就是一个`Map`。

除此之外，还在`earlySingletonObjects`中根据`beanName`查找，如果没有就加入。`earlySingletonObjects`对象定义如下

```
/** Cache of early singleton objects: bean name to bean instance. */
private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);
```

可以看到，`earlySingletonObjects`也是一个缓存，存放的是尚未初始完成（已经被创建，但是尚未完成Spring初始化生命周期，也就是半成品）bean。有的地方也叫做二级缓存，本质也是个`Map`。

除此之外，还有一个缓存叫`singletonFactories`，其定义如下

```
/** Cache of singleton factories: bean name to ObjectFactory. */
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
```

该对象也是一个缓存，用于缓存尚未完成初始化对象的Bean工厂，也叫做三级缓存，本质也是个`Map`。至此，关于Spring解决循环依赖的三个缓存都已经出现了

```
/**
 * 一级缓存，用于存放已经初始化完成的Spring Bean（经历了完整的Spring Bean初始化生命周期 ）
 */
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

/**
 * 二级缓存，用于存放已经被创建，但是尚未初始化完成的Bean（尚未经历了完整的Spring Bean初始化生命周期 ）
 * 这种对象提前暴露出来，就是为了解决循环引用，避免“鸡生蛋，蛋生鸡”的问题
 */
private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);


/**
 * 三级缓存，用于存放二级缓存中Bean的工厂
 */
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
```

这个方法在整个Spring Bean初始化的过程中被调用了很多次，应该算是最重要的方法之一了。想要读懂Spring解决循环依赖，务必反复阅读此方法。

第二个`getSingleton`方法定义如下

```
public Object getSingleton(String beanName, ObjectFactory<?> singletonFactory) {
 Assert.notNull(beanName, "Bean name must not be null");
 synchronized (this.singletonObjects) {
  Object singletonObject = this.singletonObjects.get(beanName);
  if (singletonObject == null) {
   if (this.singletonsCurrentlyInDestruction) {
    throw new BeanCreationNotAllowedException(beanName,
      "Singleton bean creation not allowed while singletons of this factory are in destruction " +
      "(Do not request a bean from a BeanFactory in a destroy method implementation!)");
   }
   if (logger.isDebugEnabled()) {
    logger.debug("Creating shared instance of singleton bean '" + beanName + "'");
   }
   // 该方法标记单例bean正在被创建
   beforeSingletonCreation(beanName);
   boolean newSingleton = false;
   boolean recordSuppressedExceptions = (this.suppressedExceptions == null);
   if (recordSuppressedExceptions) {
    this.suppressedExceptions = new LinkedHashSet<>();
   }
   try {
    singletonObject = singletonFactory.getObject();
    newSingleton = true;
   }
   catch (IllegalStateException ex) {
    // Has the singleton object implicitly appeared in the meantime ->
    // if yes, proceed with it since the exception indicates that state.
    singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null) {
     throw ex;
    }
   }
   catch (BeanCreationException ex) {
    if (recordSuppressedExceptions) {
     for (Exception suppressedException : this.suppressedExceptions) {
      ex.addRelatedCause(suppressedException);
     }
    }
    throw ex;
   }
   finally {
    if (recordSuppressedExceptions) {
     this.suppressedExceptions = null;
    }
    afterSingletonCreation(beanName);
   }
   if (newSingleton) {
    addSingleton(beanName, singletonObject);
   }
  }
  return singletonObject;
 }
}
```

这个方法里调用了`beforeSingletonCreation`方法，作用是标记此单例bean正在被创建。是Spring解决循环依赖的关键操作之一

往期：[001期~150期汇总，方便阅读，不断更新中.....](http://mp.weixin.qq.com/s?__biz=MzIyNDU2ODA4OQ==&mid=2247485351&idx=2&sn=214225ab4345f4d9c562900cb42a52ba&chksm=e80db1d1df7a38c741137246bf020a5f8970f74cd03530ccc4cb2258c1ced68e66e600e9e059&scene=21#wechat_redirect)

### createBean

`createBean`方法是Spring真正创建Bean的方法，也是Spring Bean的生命周期的开始。方法定义如下

```
@Override
protected Object createBean(String beanName, RootBeanDefinition mbd, @Nullable Object[] args)
  throws BeanCreationException {

 if (logger.isTraceEnabled()) {
  logger.trace("Creating instance of bean '" + beanName + "'");
 }
 RootBeanDefinition mbdToUse = mbd;

 // Make sure bean class is actually resolved at this point, and
 // clone the bean definition in case of a dynamically resolved Class
 // which cannot be stored in the shared merged bean definition.
 Class<?> resolvedClass = resolveBeanClass(mbd, beanName);
 if (resolvedClass != null && !mbd.hasBeanClass() && mbd.getBeanClassName() != null) {
  mbdToUse = new RootBeanDefinition(mbd);
  mbdToUse.setBeanClass(resolvedClass);
 }

 // Prepare method overrides.
 try {
  mbdToUse.prepareMethodOverrides();
 }
 catch (BeanDefinitionValidationException ex) {
  throw new BeanDefinitionStoreException(mbdToUse.getResourceDescription(),
    beanName, "Validation of method overrides failed", ex);
 }

 try {
  // Give BeanPostProcessors a chance to return a proxy instead of the target bean instance.
  Object bean = resolveBeforeInstantiation(beanName, mbdToUse);
  if (bean != null) {
   return bean;
  }
 }
 catch (Throwable ex) {
  throw new BeanCreationException(mbdToUse.getResourceDescription(), beanName,
    "BeanPostProcessor before instantiation of bean failed", ex);
 }

 try {
  // 真正创建Spring Bean
  Object beanInstance = doCreateBean(beanName, mbdToUse, args);
  if (logger.isTraceEnabled()) {
   logger.trace("Finished creating instance of bean '" + beanName + "'");
  }
  return beanInstance;
 }
 catch (BeanCreationException | ImplicitlyAppearedSingletonException ex) {
  // A previously detected exception with proper bean creation context already,
  // or illegal singleton state to be communicated up to DefaultSingletonBeanRegistry.
  throw ex;
 }
 catch (Throwable ex) {
  throw new BeanCreationException(
    mbdToUse.getResourceDescription(), beanName, "Unexpected exception during bean creation", ex);
 }
}
```

### doCreateBean

该方法用于创建Spring Bean，经过层层套娃，终于来到了重点，该方法定义如下

```
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
  throws BeanCreationException {

 // Instantiate the bean.
 BeanWrapper instanceWrapper = null;
 if (mbd.isSingleton()) {
  // 调用构造方法创建对象
  instanceWrapper = this.factoryBeanInstanceCache.remove(beanName);
 }
 if (instanceWrapper == null) {
  instanceWrapper = createBeanInstance(beanName, mbd, args);
 }
 final Object bean = instanceWrapper.getWrappedInstance();
 Class<?> beanType = instanceWrapper.getWrappedClass();
 if (beanType != NullBean.class) {
  mbd.resolvedTargetType = beanType;
 }

 // Allow post-processors to modify the merged bean definition.
 synchronized (mbd.postProcessingLock) {
  if (!mbd.postProcessed) {
   try {
    applyMergedBeanDefinitionPostProcessors(mbd, beanType, beanName);
   }
   catch (Throwable ex) {
    throw new BeanCreationException(mbd.getResourceDescription(), beanName,
      "Post-processing of merged bean definition failed", ex);
   }
   mbd.postProcessed = true;
  }
 }

 // Eagerly cache singletons to be able to resolve circular references
 // even when triggered by lifecycle interfaces like BeanFactoryAware.
 // 此处是Spring解决循环引用的关键
 // 第一个条件判断当前bean是否是单例，也就说明Spring只支持单例Bean的循环引用
 // 第二个条件默认是true，也就说Spring默认是支持循环引用的，如果想要关闭循环引用，把这个值设置成false即可
 // 第三个条件就是判断当前bean是否正在被创建，由于之前已经调用过beforeSingletonCreation方法，所以这个条件为true
 boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
   isSingletonCurrentlyInCreation(beanName));
 if (earlySingletonExposure) {
  if (logger.isTraceEnabled()) {
   logger.trace("Eagerly caching bean '" + beanName +
     "' to allow for resolving potential circular references");
  }
  // 如果支持循环引用，就加入到一个集合，也就是【提前暴露出来】
  addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
 }

 // Initialize the bean instance.
 // 初始化bean实例
 Object exposedObject = bean;
 try {
  // 填充属性，也就是自动注入
  populateBean(beanName, mbd, instanceWrapper);
  // 真正的初始Spring Bean
  exposedObject = initializeBean(beanName, exposedObject, mbd);
 }
 catch (Throwable ex) {
  if (ex instanceof BeanCreationException && beanName.equals(((BeanCreationException) ex).getBeanName())) {
   throw (BeanCreationException) ex;
  }
  else {
   throw new BeanCreationException(
     mbd.getResourceDescription(), beanName, "Initialization of bean failed", ex);
  }
 }

 if (earlySingletonExposure) {
  Object earlySingletonReference = getSingleton(beanName, false);
  if (earlySingletonReference != null) {
   if (exposedObject == bean) {
    exposedObject = earlySingletonReference;
   }
   else if (!this.allowRawInjectionDespiteWrapping && hasDependentBean(beanName)) {
    String[] dependentBeans = getDependentBeans(beanName);
    Set<String> actualDependentBeans = new LinkedHashSet<>(dependentBeans.length);
    for (String dependentBean : dependentBeans) {
     if (!removeSingletonIfCreatedForTypeCheckOnly(dependentBean)) {
      actualDependentBeans.add(dependentBean);
     }
    }
    if (!actualDependentBeans.isEmpty()) {
     throw new BeanCurrentlyInCreationException(beanName,
       "Bean with name '" + beanName + "' has been injected into other beans [" +
       StringUtils.collectionToCommaDelimitedString(actualDependentBeans) +
       "] in its raw version as part of a circular reference, but has eventually been " +
       "wrapped. This means that said other beans do not use the final version of the " +
       "bean. This is often the result of over-eager type matching - consider using " +
       "'getBeanNamesOfType' with the 'allowEagerInit' flag turned off, for example.");
    }
   }
  }
 }

 // Register bean as disposable.
 try {
  registerDisposableBeanIfNecessary(beanName, bean, mbd);
 }
 catch (BeanDefinitionValidationException ex) {
  throw new BeanCreationException(
    mbd.getResourceDescription(), beanName, "Invalid destruction signature", ex);
 }

 return exposedObject;
}
```

在这个方法中，最重要的调用方法有三个`createBeanInstance`、`populateBean`和`initializeBean`。

- `createBeanInstance`：调用构造方法创建对象
- `populateBean`：填充属性
- `initializeBean`：初始化给定的bean实例，应用工厂回调以及init方法和bean后置处理器

解决循环依赖的关键就是在第一步和第二步之间，判断当前bean是否需要支持循环引用，如果需要，就提前暴露出去，这时候暴露出去的bean是尚未完成初始化的bean，也就是所谓的半成品。

理解了这三个步骤，再结合`getSingleton`方法的逻辑，相信Spring解决循环依赖的思路已经非常明确了。

## 总结

Spring源码庞大且繁杂，想要在短时间内读懂不太可能，不如先带着问题去读某个部分。

*来源：blog.csdn.net/Baisitao_/article/details/107349302*

