# Spring 源码解读第七弹！bean 标签的解析

Spring 源码解读继续。

本文是 Spring 系列第八篇，如果小伙伴们还没阅读过本系列前面的文章，建议先看看，这有助于更好的理解本文。

1. [Spring 源码解读计划](https://mp.weixin.qq.com/s/1ImVkjdmcllArzPOSksNoA)
2. [Spring 源码第一篇开整！配置文件是怎么加载的？](https://mp.weixin.qq.com/s/OVcBCs7rluNXdKI2bNshQw)
3. [Spring 源码第二弹！XML 文件解析流程](https://mp.weixin.qq.com/s/Rr7FBgau8hT0t4X9XtXdGQ)
4. [Spring 源码第三弹！EntityResolver 是个什么鬼？](https://mp.weixin.qq.com/s/vXD79ucsRjbQWbogrzdq9g)
5. [Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A)
6. [手把手教你搭建 Spring 源码分析环境](https://mp.weixin.qq.com/s/8WnRZtHmstum23Ut5EXAug)
7. [Spring 源码第六弹！松哥和大家聊聊容器的始祖 DefaultListableBeanFactory](https://mp.weixin.qq.com/s/vQatn3w9BvdSdOY05yQa0Q)

## 1.前文回顾

不知道小伙伴们是否还记得，在前面我们讲 Spring 文档加载的时候，涉及到如下一段源码：

```java
protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource)
        throws BeanDefinitionStoreException {
    try {
        Document doc = doLoadDocument(inputSource, resource);
        int count = registerBeanDefinitions(doc, resource);
        if (logger.isDebugEnabled()) {
            logger.debug("Loaded " + count + " bean definitions from " + resource);
        }
        return count;
    }
    catch (BeanDefinitionStoreException ex) {
        throw ex;
    }
    catch (SAXParseException ex) {
        throw new XmlBeanDefinitionStoreException(resource.getDescription(),
                "Line " + ex.getLineNumber() + " in XML document from " + resource + " is invalid", ex);
    }
    catch (SAXException ex) {
        throw new XmlBeanDefinitionStoreException(resource.getDescription(),
                "XML document from " + resource + " is invalid", ex);
    }
    catch (ParserConfigurationException ex) {
        throw new BeanDefinitionStoreException(resource.getDescription(),
                "Parser configuration exception parsing XML from " + resource, ex);
    }
    catch (IOException ex) {
        throw new BeanDefinitionStoreException(resource.getDescription(),
                "IOException parsing XML document from " + resource, ex);
    }
    catch (Throwable ex) {
        throw new BeanDefinitionStoreException(resource.getDescription(),
                "Unexpected exception parsing XML document from " + resource, ex);
    }
}

```

这段代码就两个核心方法：

1. 首先调用 doLoadDocument 方法获取 Spring 的 XML 配置文件加载出来的 Document 文档对象，这个方法的执行流程我们在前面已经介绍过了，这里就不再赘述。
2. 接下来就是调用 registerBeanDefinitions 方法，讲加载出来的文档对象进行解析，定义出相应的 BeanDefinition 对象出来。

BeanDefinition 是什么，有什么作用，松哥在之前的 [Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A) 一文中已经做过介绍，这里就不再赘述。

本文我们就来看看 Document 对象是如何一步一步加载成 BeanDefinition 的。

## 2.parseDefaultElement

我们就从 registerBeanDefinitions 方法开始看起：

```java
public int registerBeanDefinitions(Document doc, Resource resource) throws BeanDefinitionStoreException {
    BeanDefinitionDocumentReader documentReader = createBeanDefinitionDocumentReader();
    int countBefore = getRegistry().getBeanDefinitionCount();
    documentReader.registerBeanDefinitions(doc, createReaderContext(resource));
    return getRegistry().getBeanDefinitionCount() - countBefore;
}

```

这里通过调用 createBeanDefinitionDocumentReader 方法获取到一个 BeanDefinitionDocumentReader 的实例，具体的对象则是 DefaultBeanDefinitionDocumentReader，也就是说接下来调用 DefaultBeanDefinitionDocumentReader#registerBeanDefinitions 进行解析。继续来看该方法的定义：

```java
@Override
public void registerBeanDefinitions(Document doc, XmlReaderContext readerContext) {
    this.readerContext = readerContext;
    doRegisterBeanDefinitions(doc.getDocumentElement());
}

```

这里又调用到了 doRegisterBeanDefinitions 方法继续完成注册：

```java
protected void doRegisterBeanDefinitions(Element root) {
    // Any nested <beans> elements will cause recursion in this method. In
    // order to propagate and preserve <beans> default-* attributes correctly,
    // keep track of the current (parent) delegate, which may be null. Create
    // the new (child) delegate with a reference to the parent for fallback purposes,
    // then ultimately reset this.delegate back to its original (parent) reference.
    // this behavior emulates a stack of delegates without actually necessitating one.
    BeanDefinitionParserDelegate parent = this.delegate;
    this.delegate = createDelegate(getReaderContext(), root, parent);
    if (this.delegate.isDefaultNamespace(root)) {
        String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
        if (StringUtils.hasText(profileSpec)) {
            String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
                    profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
            // We cannot use Profiles.of(...) since profile expressions are not supported
            // in XML config. See SPR-12458 for details.
            if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Skipped XML bean definition file due to specified profiles [" + profileSpec +
                            "] not matching: " + getReaderContext().getResource());
                }
                return;
            }
        }
    }
    preProcessXml(root);
    parseBeanDefinitions(root, this.delegate);
    postProcessXml(root);
    this.delegate = parent;
}

```

这个方法流程比较简单，首先检查了一下有没有 profile 需要处理（如果有人不清楚 Spring 中的 profile，可以在公众号后台回复 spring5 获取松哥录制的免费的 Spring 入门教程）。处理完 profile 之后，接下来就是解析了，解析有一个前置处理方法 preProcessXml 和后置处理方法 postProcessXml，不过这两个方法默认都是空方法，真正的解析方法是 parseBeanDefinitions：

```java
protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
    if (delegate.isDefaultNamespace(root)) {
        NodeList nl = root.getChildNodes();
        for (int i = 0; i < nl.getLength(); i++) {
            Node node = nl.item(i);
            if (node instanceof Element) {
                Element ele = (Element) node;
                if (delegate.isDefaultNamespace(ele)) {
                    parseDefaultElement(ele, delegate);
                }
                else {
                    delegate.parseCustomElement(ele);
                }
            }
        }
    }
    else {
        delegate.parseCustomElement(root);
    }
}

```

在该方法中进行节点的解析，最终会来到 parseDefaultElement 方法中。我们一起来看下该方法：

```java
private void parseDefaultElement(Element ele, BeanDefinitionParserDelegate delegate) {
    if (delegate.nodeNameEquals(ele, IMPORT_ELEMENT)) {
        importBeanDefinitionResource(ele);
    }
    else if (delegate.nodeNameEquals(ele, ALIAS_ELEMENT)) {
        processAliasRegistration(ele);
    }
    else if (delegate.nodeNameEquals(ele, BEAN_ELEMENT)) {
        processBeanDefinition(ele, delegate);
    }
    else if (delegate.nodeNameEquals(ele, NESTED_BEANS_ELEMENT)) {
        // recurse
        doRegisterBeanDefinitions(ele);
    }
}

```

终于来到期盼已久的 parseDefaultElement 方法中了。

在该方法中，我们可以看到，节点一共被分为了四大类：

- import
- alias
- bean
- beans

每一个节点都好理解，因为我们在开发中可能多多少少都有用过，需要注意的是，如果是 beans 节点，又会再次调用 doRegisterBeanDefinitions 方法进行递归解析，源码上面还给了一个注释 recurse，意思就是递归。

四种类型的节点解析，我们就从 bean 的解析看起吧，因为 beans 节点是我们最常用的节点，这个搞清楚了，另外三个节点就可以举一反三了。

我们来看 processBeanDefinition 方法：

```java
protected void processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) {
    BeanDefinitionHolder bdHolder = delegate.parseBeanDefinitionElement(ele);
    if (bdHolder != null) {
        bdHolder = delegate.decorateBeanDefinitionIfRequired(ele, bdHolder);
        try {
            // Register the final decorated instance.
            BeanDefinitionReaderUtils.registerBeanDefinition(bdHolder, getReaderContext().getRegistry());
        }
        catch (BeanDefinitionStoreException ex) {
            getReaderContext().error("Failed to register bean definition with name '" +
                    bdHolder.getBeanName() + "'", ele, ex);
        }
        // Send registration event.
        getReaderContext().fireComponentRegistered(new BeanComponentDefinition(bdHolder));
    }
}

```

在这段代码中，首先调用代理类 BeanDefinitionParserDelegate 对元素进行解析，解析的结果会保存在 bdHolder 中，也就是 bean 节点中配置的元素 class、id、name 等属性，在经过这一步的解析之后，都会保存到 bdHolder 中。

如果 bdHolder 不为空，那么接下来对子节点的属性继续解析，同时对 bdHolder 进行注册，最终发出事件，通知这个 bean 节点已经加载完了。

如此看来，整个解析的核心过程应该在 delegate.parseBeanDefinitionElement(ele) 方法中，追踪该方法的执行，我们最终来到这里：

```java
@Nullable
public BeanDefinitionHolder parseBeanDefinitionElement(Element ele, @Nullable BeanDefinition containingBean) {
    String id = ele.getAttribute(ID_ATTRIBUTE);
    String nameAttr = ele.getAttribute(NAME_ATTRIBUTE);
    List<String> aliases = new ArrayList<>();
    if (StringUtils.hasLength(nameAttr)) {
        String[] nameArr = StringUtils.tokenizeToStringArray(nameAttr, MULTI_VALUE_ATTRIBUTE_DELIMITERS);
        aliases.addAll(Arrays.asList(nameArr));
    }
    String beanName = id;
    if (!StringUtils.hasText(beanName) && !aliases.isEmpty()) {
        beanName = aliases.remove(0);
        if (logger.isTraceEnabled()) {
            logger.trace("No XML 'id' specified - using '" + beanName +
                    "' as bean name and " + aliases + " as aliases");
        }
    }
    if (containingBean == null) {
        checkNameUniqueness(beanName, aliases, ele);
    }
    AbstractBeanDefinition beanDefinition = parseBeanDefinitionElement(ele, beanName, containingBean);
    if (beanDefinition != null) {
        if (!StringUtils.hasText(beanName)) {
            try {
                if (containingBean != null) {
                    beanName = BeanDefinitionReaderUtils.generateBeanName(
                            beanDefinition, this.readerContext.getRegistry(), true);
                }
                else {
                    beanName = this.readerContext.generateBeanName(beanDefinition);
                    // Register an alias for the plain bean class name, if still possible,
                    // if the generator returned the class name plus a suffix.
                    // This is expected for Spring 1.2/2.0 backwards compatibility.
                    String beanClassName = beanDefinition.getBeanClassName();
                    if (beanClassName != null &&
                            beanName.startsWith(beanClassName) && beanName.length() > beanClassName.length() &&
                            !this.readerContext.getRegistry().isBeanNameInUse(beanClassName)) {
                        aliases.add(beanClassName);
                    }
                }
                if (logger.isTraceEnabled()) {
                    logger.trace("Neither XML 'id' nor 'name' specified - " +
                            "using generated bean name [" + beanName + "]");
                }
            }
            catch (Exception ex) {
                error(ex.getMessage(), ele);
                return null;
            }
        }
        String[] aliasesArray = StringUtils.toStringArray(aliases);
        return new BeanDefinitionHolder(beanDefinition, beanName, aliasesArray);
    }
    return null;
}

```

这个方法中所作的事情我们可以大致分为 5 个步骤：

1. 提取出 id 和 name 属性值。
2. 检查 beanName 是否唯一。
3. 对节点做进一步的解析，解析出 beanDefinition 对象，真是的类型是 GenericBeanDefinition。
4. 如果 beanName 属性没有值，则使用默认的规则生成 beanName（默认规则是类名全路径）。
5. 最终将获取到的信息封装成一个 BeanDefinitionHolder 返回。

在这一层面主要完成了对 id 和 name 的处理，如果用户没有给 bean 定义名称的话，则生成一个默认的名称，至于其他属性的解析，则主要是在 parseBeanDefinitionElement 方法中完成的。

```java
@Nullable
public AbstractBeanDefinition parseBeanDefinitionElement(
        Element ele, String beanName, @Nullable BeanDefinition containingBean) {
    this.parseState.push(new BeanEntry(beanName));
    String className = null;
    if (ele.hasAttribute(CLASS_ATTRIBUTE)) {
        className = ele.getAttribute(CLASS_ATTRIBUTE).trim();
    }
    String parent = null;
    if (ele.hasAttribute(PARENT_ATTRIBUTE)) {
        parent = ele.getAttribute(PARENT_ATTRIBUTE);
    }
    try {
        AbstractBeanDefinition bd = createBeanDefinition(className, parent);
        parseBeanDefinitionAttributes(ele, beanName, containingBean, bd);
        bd.setDescription(DomUtils.getChildElementValueByTagName(ele, DESCRIPTION_ELEMENT));
        parseMetaElements(ele, bd);
        parseLookupOverrideSubElements(ele, bd.getMethodOverrides());
        parseReplacedMethodSubElements(ele, bd.getMethodOverrides());
        parseConstructorArgElements(ele, bd);
        parsePropertyElements(ele, bd);
        parseQualifierElements(ele, bd);
        bd.setResource(this.readerContext.getResource());
        bd.setSource(extractSource(ele));
        return bd;
    }
    catch (ClassNotFoundException ex) {
        error("Bean class [" + className + "] not found", ele, ex);
    }
    catch (NoClassDefFoundError err) {
        error("Class that bean class [" + className + "] depends on not found", ele, err);
    }
    catch (Throwable ex) {
        error("Unexpected failure during bean definition parsing", ele, ex);
    }
    finally {
        this.parseState.pop();
    }
    return null;
}

```

1. 首先解析出 className 属性。
2. 解析出 parent 属性。
3. 调用 createBeanDefinition 方法创建出用于保存对象的 BeanDefinition，既 GenericBeanDefinition。
4. parseBeanDefinitionAttributes 用来解析出各种各样的节点属性。
5. parseMetaElements 用来解析 Meta 数据。
6. parseLookupOverrideSubElements 解析 lookup-method 属性。
7. parseReplacedMethodSubElements 解析 replace-method 属性。
8. parseConstructorArgElements 解析构造函数参数。
9. parsePropertyElements 解析 property 子元素。
10. parseQualifierElements 解析 qualifier 子元素。
11. 最终返回 bd。

可以看到，bean 节点中所有的属性都解析了，有的是我们日常常见的属性，有的是我们不常见的甚至从来都没见到过的，无论哪种情况，现在全部都解析了。解析完成后，将获得的 GenericBeanDefinition 返回。

## 3. 常规属性解析

这里有一些属性的解析可能比较冷门，这个我一会说，还有一些比较常规，例如 parseBeanDefinitionAttributes 方法用来解析各种各样的节点属性，这些节点属性可能大家都比较熟悉，我们一起来看下：

```java
public AbstractBeanDefinition parseBeanDefinitionAttributes(Element ele, String beanName,
        @Nullable BeanDefinition containingBean, AbstractBeanDefinition bd) {
    if (ele.hasAttribute(SINGLETON_ATTRIBUTE)) {
        error("Old 1.x 'singleton' attribute in use - upgrade to 'scope' declaration", ele);
    }
    else if (ele.hasAttribute(SCOPE_ATTRIBUTE)) {
        bd.setScope(ele.getAttribute(SCOPE_ATTRIBUTE));
    }
    else if (containingBean != null) {
        // Take default from containing bean in case of an inner bean definition.
        bd.setScope(containingBean.getScope());
    }
    if (ele.hasAttribute(ABSTRACT_ATTRIBUTE)) {
        bd.setAbstract(TRUE_VALUE.equals(ele.getAttribute(ABSTRACT_ATTRIBUTE)));
    }
    String lazyInit = ele.getAttribute(LAZY_INIT_ATTRIBUTE);
    if (isDefaultValue(lazyInit)) {
        lazyInit = this.defaults.getLazyInit();
    }
    bd.setLazyInit(TRUE_VALUE.equals(lazyInit));
    String autowire = ele.getAttribute(AUTOWIRE_ATTRIBUTE);
    bd.setAutowireMode(getAutowireMode(autowire));
    if (ele.hasAttribute(DEPENDS_ON_ATTRIBUTE)) {
        String dependsOn = ele.getAttribute(DEPENDS_ON_ATTRIBUTE);
        bd.setDependsOn(StringUtils.tokenizeToStringArray(dependsOn, MULTI_VALUE_ATTRIBUTE_DELIMITERS));
    }
    String autowireCandidate = ele.getAttribute(AUTOWIRE_CANDIDATE_ATTRIBUTE);
    if (isDefaultValue(autowireCandidate)) {
        String candidatePattern = this.defaults.getAutowireCandidates();
        if (candidatePattern != null) {
            String[] patterns = StringUtils.commaDelimitedListToStringArray(candidatePattern);
            bd.setAutowireCandidate(PatternMatchUtils.simpleMatch(patterns, beanName));
        }
    }
    else {
        bd.setAutowireCandidate(TRUE_VALUE.equals(autowireCandidate));
    }
    if (ele.hasAttribute(PRIMARY_ATTRIBUTE)) {
        bd.setPrimary(TRUE_VALUE.equals(ele.getAttribute(PRIMARY_ATTRIBUTE)));
    }
    if (ele.hasAttribute(INIT_METHOD_ATTRIBUTE)) {
        String initMethodName = ele.getAttribute(INIT_METHOD_ATTRIBUTE);
        bd.setInitMethodName(initMethodName);
    }
    else if (this.defaults.getInitMethod() != null) {
        bd.setInitMethodName(this.defaults.getInitMethod());
        bd.setEnforceInitMethod(false);
    }
    if (ele.hasAttribute(DESTROY_METHOD_ATTRIBUTE)) {
        String destroyMethodName = ele.getAttribute(DESTROY_METHOD_ATTRIBUTE);
        bd.setDestroyMethodName(destroyMethodName);
    }
    else if (this.defaults.getDestroyMethod() != null) {
        bd.setDestroyMethodName(this.defaults.getDestroyMethod());
        bd.setEnforceDestroyMethod(false);
    }
    if (ele.hasAttribute(FACTORY_METHOD_ATTRIBUTE)) {
        bd.setFactoryMethodName(ele.getAttribute(FACTORY_METHOD_ATTRIBUTE));
    }
    if (ele.hasAttribute(FACTORY_BEAN_ATTRIBUTE)) {
        bd.setFactoryBeanName(ele.getAttribute(FACTORY_BEAN_ATTRIBUTE));
    }
    return bd;
}

```

可以看到，这里解析的节点属性，从上往下，依次是：

1. 解析 singleton 属性（该属性已废弃，使用 scope 替代）。
2. 解析 scope 属性，如果未指定 scope 属性，但是存在 containingBean，则使用 containingBean 的 scope 属性值。
3. 解析 abstract 属性。
4. 解析 lazy-init 属性。
5. 解析 autowire 属性。
6. 解析 depends-on 属性。
7. 解析 autowire-candidate 属性。
8. 解析 primary 属性。
9. 解析 init-method 属性。
10. 解析 destroy-method 属性。
11. 解析 factory-method 属性。
12. 解析 factory-bean 属性。

这些属性作用大家都比较熟悉。因为日常用的多一些。

**前面提到的解析中，lookup-method、replace-method、以及 qualifier 等属性可能大家日常都很少用到，甚至没有听说过，如果用都没用过，那源码肯定不好理解，所以接下来松哥会录制一个视频，来和大家讲一讲这些冷门属性的使用，然后我们再继续深入解析这里的 parseMetaElements、parseLookupOverrideSubElements 等方法。**

## 4. Bean 的生成

有了 BeanDefinitionHolder 之后，接下来 Bean 的生成就很容易了。

大家回顾如下两篇文章来理解有了 BeanDefinition 之后，如何转化为具体的 Bean：

- [Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A)
- [Spring 源码第六弹！松哥和大家聊聊容器的始祖 DefaultListableBeanFactory](https://mp.weixin.qq.com/s/vQatn3w9BvdSdOY05yQa0Q)

好啦，今天的文章就先说这么多~