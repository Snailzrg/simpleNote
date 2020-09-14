## 1.DefaultListableBeanFactory

要说 XmlBeanFactory 就不得不先说它的父类 DefaultListableBeanFactory，因为 XmlBeanFactory 中的大部分功能实际上在 DefaultListableBeanFactory 中就已经提供好了，XmlBeanFactory 只是对 IO 流的读取做了一些定制而已。

DefaultListableBeanFactory 是一个完整的、功能成熟的 IoC 容器，如果你的需求很简单，甚至可以直接使用 DefaultListableBeanFactory，如果你的需求比较复杂，那么通过扩展 DefaultListableBeanFactory 的功能也可以达到，可以说 DefaultListableBeanFactory 是整个 Spring IoC 容器的始祖。

我们先来看一下 DefaultListableBeanFactory 的继承关系：

![img](https://mmbiz.qpic.cn/mmbiz_png/GvtDGKK4uYm7KW9OPxP9RXCSu57uJeDvYCYL562r96xelATNTCBwyriaicvARCgRJmBOI1P6BLzdvVv6rdLBNCkg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

从这张类的关系图中可以看出，DefaultListableBeanFactory 实际上也是一个集大成者。在 Spring 中，针对 Bean 的不同操作都有不同的接口进行规范，每个接口都有自己对应的实现，最终在 DefaultListableBeanFactory 中将所有的实现汇聚到一起。从这张类的继承关系图中我们大概就能感受到 Spring 中关于类的设计是多么厉害，代码耦合度非常低。

这些类，在本系列后面的介绍中，大部分都会涉及到，现在我先大概介绍一下每个类的作用，大家先混个脸熟：

1. BeanFactory：这个接口看名字就知道是一个 Bean 的工厂，BeanFactory 接口定义了各种获取 Bean 的方法、判断 Bean 是否存在、判断 Bean 是否单例等针对 Bean 的基础方法。
2. ListableBeanFactory：这个接口继承自 BeanFactory，在 BeanFactory 的基础上，扩展了 Bean 的查询方法，例如根据类型获取 BeanNames、根据注解获取 BeanNames、根据 Bean 获取注解等。
3. AutowireCapableBeanFactory：该接口继承自 BeanFactory，在 BeanFactory 的基础上，提供了 Bean 的创建、配置、注入、销毁等操作。有时候我们需要自己手动注入 Bean 的时候，可以考虑通过实现该接口来完成。AutowireCapableBeanFactory 在 Spring Security 中有一个重要的应用就是 ObjectPostProcessor，这个松哥将在 [👉Spring Security 系列](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzI1NDY0MTkzNQ==&action=getalbum&album_id=1319828555819286528&subscene=27&scenenote=https%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzI1NDY0MTkzNQ%3D%3D%26mid%3D2247488952%26idx%3D2%26sn%3Df5a16f45ef22ee28f37e41d08e6fecd5%26chksm%3De9c347d8deb4cecedc190b5476e35750e270754c978b818895923f9c69670ac01157d4b2181f%26scene%3D27%26key%3De9ffa206e9e5d4d764caa78c96fbb0af2b2ec333fbb15849ce59be3ff99e35264c2338acfb957131303cb8c8405e2541b4fd9212f4e5f733f79c719b68af9db0348c4d9b445173d1928e71008916f336%26ascene%3D0%26uin%3DMTQ5NzA1MzQwMw%3D%3D%26devicetype%3DiMac%2BMacBookPro15%2C1%2BOSX%2BOSX%2B10.13.6%2Bbuild(17G2208)%26version%3D12031f10%26nettype%3DWIFI%26lang%3Den%26fontScale%3D100%26exportkey%3DA7Vh2vnoyPfiNe4xJBp1Abg%3D%26pass_ticket%3DcsesYv%2BwBmhWaBHD26d%2FJ7tMkuXP0dO73h0sw2UG8l0e1hhkKGiIMjql0rJcXL0r%26winzoom%3D1.000000&uin=&key=&devicetype=iMac+MacBookPro15%2C1+OSX+OSX+10.13.6+build(17G2208)&version=12031f10&lang=en&nettype=WIFI&ascene=0&fontScale=100&winzoom=1.000000)中和大家详细介绍。
4. HierarchicalBeanFactory：该接口继承自 BeanFactory，并在 BeanFactory 基础上添加了获取 parent beanfactory 的方法。
5. SingletonBeanRegistry：这个接口定义了对单例 Bean 的定义以及获取方法。
6. ConfigurableBeanFactory：这个接口主要定了针对 BeanFactory 的各种配置以及销毁的方法。
7. ConfigurableListableBeanFactory：这是 BeanFactory 的配置清单，这里定义了忽略的类型、接口，通过 Bean 的名称获取 BeanDefinition 、冻结 BeanDefinition 等。
8. AliasRegistry：这个接口定义了对 alias 的注册、移除、判断以及查询操作。
9. SimpleAliasRegistry：这个类实现了 AliasRegistry 接口并实现了它里边的方法，SimpleAliasRegistry 使用 ConcurrentHashMap 做载体，实现了对 alias 的注册、移除判断以及查询操作。
10. DefaultSingletonBeanRegistry：这个类基于 Java 中的集合，对 SingletonBeanRegistry 接口进行了实现。
11. FactoryBeanRegistrySupport：该类继承自 DefaultSingletonBeanRegistry，并在 DefaultSingletonBeanRegistry 的基础上，增加了获取 FactoryBean 类型、移除 FactoryBean 缓存的方法等等操作。
12. AbstractBeanFactory：实现了 ConfigurableBeanFactory 接口并继承自 FactoryBeanRegistrySupport，在 AbstractBeanFactory 中对 ConfigurableBeanFactory 中定义的方法进行了实现。
13. AbstractAutowireCapableBeanFactory：该类继承自 AbstractBeanFactory 并对 AutowireCapableBeanFactory 接口中定义的方法进行了落地实现。
14. BeanDefinitionRegistry：这个接口继承自 AliasRegistry 接口，并增加了一系列针对 BeanDefinition 的注册、移除、查询、判断等方法。
15. 最后的 DefaultListableBeanFactory 自然就具备了上面所有的功能。

上面的内容可能看的大家眼花缭乱，松哥这里通过几个简单实际的例子，来带大家使用一下 DefaultListableBeanFactory 的功能，可能大家的理解就比较清晰了。

DefaultListableBeanFactory 作为一个集大成者，提供了非常多的功能，我们一个一个来看。

## 2.代码改造

首先文章中一开始的三行代码我们可以对其略加改造，因为我们已经说了 XmlBeanFactory 中的大部分功能实际上在 DefaultListableBeanFactory 中就已经提供好了，XmlBeanFactory 只是对 IO 流的读取做了一些定制而已，文件的读取主要是通过 XmlBeanDefinitionReader 来完成的（本系列前面文章已经讲过），我们可以对文章一开始的三行代码进行改造，以便更好的体现“XmlBeanFactory 中的大部分功能实际上在 DefaultListableBeanFactory 中就已经提供好了”：

```
ClassPathResource res=new ClassPathResource("beans.xml");
DefaultListableBeanFactory factory=new DefaultListableBeanFactory();
XmlBeanDefinitionReader reader=new XmlBeanDefinitionReader(factory);
reader.loadBeanDefinitions(res);
User user = factory.getBean(User.class);
System.out.println("user = " + user);
```

使用前四行代码代替 XmlBeanFactory，这样 XmlBeanFactory 的功能是不是就很明确了？就是前四行代码的功能。

## 3.动态注册 Bean

动态注册 Bean，这是 DefaultListableBeanFactory 的功能之一，不过准确来说应该是动态注册 BeanDefinition 。

我们先来看一个简单的例子：

```
DefaultListableBeanFactory defaultListableBeanFactory = new DefaultListableBeanFactory();
GenericBeanDefinition userBeanDefinition = new GenericBeanDefinition();
MutablePropertyValues pvs = new MutablePropertyValues();
pvs.add("username", "javaboy");
pvs.add("address", "www.javaboy.org");
userBeanDefinition.setPropertyValues(pvs);
userBeanDefinition.setBeanClass(User.class);
defaultListableBeanFactory.registerBeanDefinition("user", userBeanDefinition);
User user = defaultListableBeanFactory.getBean(User.class);
System.out.println("user = " + user);
```

首先我们自己手动构建一个 DefaultListableBeanFactory 对象。当然也可以使用前面的 XmlBeanFactory。

然后再手动构建一个 GenericBeanDefinition。在前面的文章中，松哥和大家讲过，现在默认使用的 BeanDefinition 就是 GenericBeanDefinition，所以这里我们自己也手动构建一个 GenericBeanDefinition。有了 GenericBeanDefinition 之后，我们设置相关的类和属性。

接下来再将 userBeanDefinition 注册到 defaultListableBeanFactory。注册完成之后，我们就可以从 defaultListableBeanFactory 中获取相应的 Bean 了。

> 这里说一句题外话，希望大家在阅读本系列每一篇文章的时候，能够将本系列前后文章联系起来一起理解，这样会有很多意料之外的收获。例如上面的，我们既可以声明一个 DefaultListableBeanFactory，也可以声明一个 XmlBeanFactory，那你大概就能据此推断出 XmlBeanFactory 的主要目的可能就是对资源文件进行读取和注册。

那么到底是怎么注册的呢？我们来看一下 defaultListableBeanFactory.registerBeanDefinition 方法的定义：

```
@Override
public void registerBeanDefinition(String beanName, BeanDefinition beanDefinition)
  throws BeanDefinitionStoreException {
 Assert.hasText(beanName, "Bean name must not be empty");
 Assert.notNull(beanDefinition, "BeanDefinition must not be null");
 if (beanDefinition instanceof AbstractBeanDefinition) {
  try {
   ((AbstractBeanDefinition) beanDefinition).validate();
  }
  catch (BeanDefinitionValidationException ex) {
   throw new BeanDefinitionStoreException(beanDefinition.getResourceDescription(), beanName,
     "Validation of bean definition failed", ex);
  }
 }
 BeanDefinition existingDefinition = this.beanDefinitionMap.get(beanName);
 if (existingDefinition != null) {
  if (!isAllowBeanDefinitionOverriding()) {
   throw new BeanDefinitionOverrideException(beanName, beanDefinition, existingDefinition);
  }
  else if (existingDefinition.getRole() < beanDefinition.getRole()) {
   // e.g. was ROLE_APPLICATION, now overriding with ROLE_SUPPORT or ROLE_INFRASTRUCTURE
   if (logger.isInfoEnabled()) {
    logger.info("Overriding user-defined bean definition for bean '" + beanName +
      "' with a framework-generated bean definition: replacing [" +
      existingDefinition + "] with [" + beanDefinition + "]");
   }
  }
  else if (!beanDefinition.equals(existingDefinition)) {
   if (logger.isDebugEnabled()) {
    logger.debug("Overriding bean definition for bean '" + beanName +
      "' with a different definition: replacing [" + existingDefinition +
      "] with [" + beanDefinition + "]");
   }
  }
  else {
   if (logger.isTraceEnabled()) {
    logger.trace("Overriding bean definition for bean '" + beanName +
      "' with an equivalent definition: replacing [" + existingDefinition +
      "] with [" + beanDefinition + "]");
   }
  }
  this.beanDefinitionMap.put(beanName, beanDefinition);
 }
 else {
  if (hasBeanCreationStarted()) {
   // Cannot modify startup-time collection elements anymore (for stable iteration)
   synchronized (this.beanDefinitionMap) {
    this.beanDefinitionMap.put(beanName, beanDefinition);
    List<String> updatedDefinitions = new ArrayList<>(this.beanDefinitionNames.size() + 1);
    updatedDefinitions.addAll(this.beanDefinitionNames);
    updatedDefinitions.add(beanName);
    this.beanDefinitionNames = updatedDefinitions;
    removeManualSingletonName(beanName);
   }
  }
  else {
   // Still in startup registration phase
   this.beanDefinitionMap.put(beanName, beanDefinition);
   this.beanDefinitionNames.add(beanName);
   removeManualSingletonName(beanName);
  }
  this.frozenBeanDefinitionNames = null;
 }
 if (existingDefinition != null || containsSingleton(beanName)) {
  resetBeanDefinition(beanName);
 }
 else if (isConfigurationFrozen()) {
  clearByTypeCache();
 }
}
```

registerBeanDefinition 方法是在 BeanDefinitionRegistry 接口中声明的，DefaultListableBeanFactory 类实现了 BeanDefinitionRegistry 接口，并实现了该方法，我们来看分析下该方法：

1. 首先对传入的 beanDefinition 对象进行校验，这也是注册前的最后一次校验，不过这个时候 BeanDefinition 对象已经到手了，所以这个校验并非 XML 文件校验，这里主要是对 methodOverrides 的校验。
2. 接下来会根据 beanName 从 beanDefinitionMap 中获取 BeanDefinition，看看当前 Bean 是否已经定义过了。beanDefinitionMap 是一个 Map 集合，这个集合中 key 是 beanName，value 是 BeanDefinition 对象。
3. 如果 BeanDefinition 已经存在了，那么接下来会判断是否允许 BeanDefinition 覆盖，如果不允许，就直接抛出异常（不知道小伙伴们有没有印象，在松哥前面的 OAuth2 系列教程中，经常需要配置允许 BeanDefinition 的覆盖，就是因为这个原因，公众号【江南一点雨】后台回复 OAuth2 获取该教程），如果允许 BeanDefinition 的覆盖，那就向 beanDefinitionMap 中再次存一次值，覆盖之前的值。
4. 如果 BeanDefinition 不存在，那就直接注册。直接注册分两种情况：项目已经运行了和项目还没运行。
5. 如果项目已经运行，由于 beanDefinitionMap 是一个全局变量，可能存在并发问题，所以要加锁处理。否则就直接注册，所谓的注册就是把对象存入 beanDefinitionMap 中，同时将 beanName 都存入 beanDefinitionNames 集合中。

这便是 registerBeanDefinition 方法的工作流程。

有小伙伴会说，这个方法从头到尾都是 BeanDefinition，跟 Bean 有什么关系呢？

咋一看确实好像和 Bean 没有直接关系。

其实这涉及到另外一个问题，就是 Bean 的懒加载。这个时候先把 BeanDefinition 定义好，等到真正调用 Bean 的时候，才会去初始化 Bean。我们可以在 User 类的构造方法中打印日志看下，如下：

```
public class User {
    private String username;
    private String address;

    public User() {
        System.out.println("--------user init--------");
    }

    @Override
    public String toString() {
        return "User{" +
                "username='" + username + '\'' +
                ", address='" + address + '\'' +
                '}';
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
```

从下图可以看到，当 BeanDefinition 注册完成后，User 并没有初始化，等到 getBean 方法被调用的时候，User 才初始化了。

![img](https://mmbiz.qpic.cn/mmbiz_png/GvtDGKK4uYm7KW9OPxP9RXCSu57uJeDvRXaFUuJ7juyFME9SwFwXG0iccjuH8Mmibp3UHLgJZTfIQZG5siaQ4eegA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

**需要注意的是，我们日常开发中使用的 ApplicationContext 并非懒加载，这个在松哥的 Spring 入门视频中可以看到效果【👉https://www.bilibili.com/video/BV1Wv41167TU】，具体原理松哥将在本系列后面的文章中和大家分享。**

那么如果不想懒加载该怎么办呢？当然有办法。

## 4.提前注册 Bean

在 DefaultListableBeanFactory 中还有一个 preInstantiateSingletons 方法可以提前注册 Bean，该方法是在 ConfigurableListableBeanFactory 接口中声明的，DefaultListableBeanFactory 类实现了 ConfigurableListableBeanFactory 接口并实现了接口中的方法：

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
 for (String beanName : beanNames) {
  RootBeanDefinition bd = getMergedLocalBeanDefinition(beanName);
  if (!bd.isAbstract() && bd.isSingleton() && !bd.isLazyInit()) {
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

preInstantiateSingletons 方法的整体逻辑比较简单，就是遍历 beanNames，对符合条件的 Bean 进行实例化，而且大家注意，这里所谓的提前初始化其实就是在我们调用 getBean 方法之前，它自己先调用了一下 getBean。

我们可以在案例中手动调用该方法：

```
DefaultListableBeanFactory defaultListableBeanFactory = new DefaultListableBeanFactory();
GenericBeanDefinition userBeanDefinition = new GenericBeanDefinition();
MutablePropertyValues pvs = new MutablePropertyValues();
pvs.add("username", "javaboy");
pvs.add("address", "www.javaboy.org");
userBeanDefinition.setPropertyValues(pvs);
userBeanDefinition.setBeanClass(User.class);
defaultListableBeanFactory.registerBeanDefinition("user", userBeanDefinition);
defaultListableBeanFactory.preInstantiateSingletons();
User user = defaultListableBeanFactory.getBean(User.class);
System.out.println("user = " + user);
```

此时在调用 getBean 方法之前，User 就已经初始化了，如下图：

![img](https://mmbiz.qpic.cn/mmbiz_png/GvtDGKK4uYm7KW9OPxP9RXCSu57uJeDvApO2BufuicVUvpPuLJp0upduNtwQyib6YRa7lia0lgAwPGlHcTs02umew/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 5.getBean

DefaultListableBeanFactory 中另外一个重量级方法就是 getBean 了。不过 getBean 方法的真正实现是在 DefaultListableBeanFactory 的父类 AbstractBeanFactory 中，具体的实现方法是 doGetBean，本来想和大家子在这里聊一聊这个问题，但是发现这是一个非常庞大的问题，BeanFactory 和 FactoryBean 都还没和大家分享，所以这个话题我们还是暂且押后，一个点一个点来。