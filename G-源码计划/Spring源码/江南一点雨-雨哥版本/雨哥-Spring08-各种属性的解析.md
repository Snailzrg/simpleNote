# Spring 源码第 8 篇，各种属性的解析

Spring 源码解析第 8 篇，继续。

上篇文章我们分析了 bean 标签的解析过程，但是主要是涉及到一些简单的属性，一些冷门属性如 lookup-method 等没有和大家分析，主要是考虑到这些属性大家可能用得少，因此我上周录制了一个简单的视频，先带领小伙伴们复习了一下这些冷门属性的用法：

[Spring 中四个冷门属性，你可能没用过，挑战看一下！](https://mp.weixin.qq.com/s/JB1U28-oVZKTuOqFT1L_tg)

现在关于 bean 节点的配置大家都了解了，我们接下来就来看下完整的解析过程。

阅读本系列前面文章，有助于更好的理解本文：

1. [Spring 源码解读计划](https://mp.weixin.qq.com/s/1ImVkjdmcllArzPOSksNoA)
2. [Spring 源码第一篇开整！配置文件是怎么加载的？](https://mp.weixin.qq.com/s/OVcBCs7rluNXdKI2bNshQw)
3. [Spring 源码第二弹！XML 文件解析流程](https://mp.weixin.qq.com/s/Rr7FBgau8hT0t4X9XtXdGQ)
4. [Spring 源码第三弹！EntityResolver 是个什么鬼？](https://mp.weixin.qq.com/s/vXD79ucsRjbQWbogrzdq9g)
5. [Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A)
6. [手把手教你搭建 Spring 源码分析环境](https://mp.weixin.qq.com/s/8WnRZtHmstum23Ut5EXAug)
7. [Spring 源码第六弹！松哥和大家聊聊容器的始祖 DefaultListableBeanFactory](https://mp.weixin.qq.com/s/vQatn3w9BvdSdOY05yQa0Q)
8. [Spring 源码解读第七弹！bean 标签的解析](https://mp.weixin.qq.com/s/dDX7ijnhkrMwlkUcCqOlnw)

## 1.解析方法回顾

上篇文章我们最终分析到下面这个方法：

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
复制代码
```

parseBeanDefinitionAttributes 方法用来解析普通属性，我们已经在上篇文章中分析过了，这里不再赘述，今天主要来看看其他几个方法的解析工作。

## 2.Description

首先是 description 的解析，直接通过 DomUtils.getChildElementValueByTagName 工具方法从节点中取出 description 属性的值。这个没啥好说的。

小伙伴们在分析源码时，这些工具方法如果你不确定它的功能，或者想验证它的其他用法，可以通过 IDEA 提供的 Evaluate Expression 功能现场调用该方法，进而验证自己想法，就是下图标出来的那个计算器小图标，点击之后，输入你想执行的代码：



![img](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5pdGJveWh1Yi5jb20vMjAyMC8wNy8yMDIwMDgxNTE4MjExMS5wbmc?x-oss-process=image/format,png)



## 3.parseMetaElements

这个方法主要是解析 meta 属性。前面的视频中已经讲了，这个 meta 属性是保存在 BeanDefinition 中的，也是从 BeanDefinition 中获取的，按照这个思路，来看解析代码就很容易懂了：

```java
public void parseMetaElements(Element ele, BeanMetadataAttributeAccessor attributeAccessor) {
    NodeList nl = ele.getChildNodes();
    for (int i = 0; i < nl.getLength(); i++) {
        Node node = nl.item(i);
        if (isCandidateElement(node) && nodeNameEquals(node, META_ELEMENT)) {
            Element metaElement = (Element) node;
            String key = metaElement.getAttribute(KEY_ATTRIBUTE);
            String value = metaElement.getAttribute(VALUE_ATTRIBUTE);
            BeanMetadataAttribute attribute = new BeanMetadataAttribute(key, value);
            attribute.setSource(extractSource(metaElement));
            attributeAccessor.addMetadataAttribute(attribute);
        }
    }
}
复制代码
```

可以看到，遍历元素，从中提取出 meta 元素的值，并构建出 BeanMetadataAttribute 对象，最后存入 GenericBeanDefinition 对象中。

有小伙伴说不是存入 BeanMetadataAttributeAccessor 中吗？这其实是 GenericBeanDefinition 的父类，BeanMetadataAttributeAccessor 专门用来处理属性的加载和读取，相关介绍可以参考松哥前面的文章：

- [Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A)

## 4.parseLookupOverrideSubElements

这个方法是为了解析出 lookup-method 属性，在前面的视频中松哥已经和大家聊过，lookup-method 可以动态替换运行的方法，按照这个思路，我们来看下这个方法的源码：

```java
public void parseLookupOverrideSubElements(Element beanEle, MethodOverrides overrides) {
    NodeList nl = beanEle.getChildNodes();
    for (int i = 0; i < nl.getLength(); i++) {
        Node node = nl.item(i);
        if (isCandidateElement(node) && nodeNameEquals(node, LOOKUP_METHOD_ELEMENT)) {
            Element ele = (Element) node;
            String methodName = ele.getAttribute(NAME_ATTRIBUTE);
            String beanRef = ele.getAttribute(BEAN_ELEMENT);
            LookupOverride override = new LookupOverride(methodName, beanRef);
            override.setSource(extractSource(ele));
            overrides.addOverride(override);
        }
    }
}
复制代码
```

可以看到，在这里遍历元素，从 lookup-method 属性中，取出来 methodName 和 beanRef 属性，构造出 LookupOverride 然后存入 GenericBeanDefinition 的 methodOverrides 属性中。

存入 GenericBeanDefinition 的 methodOverrides 属性中之后，我们也可以在代码中查看：



![img](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5pdGJveWh1Yi5jb20vMjAyMC8wNy8yMDIwMDgxNTE4NTcxMS5wbmc?x-oss-process=image/format,png)



## 5.parseReplacedMethodSubElements

parseReplacedMethodSubElements 这个方法主要是解析 replace-method 属性的，根据前面视频的讲解，replace-method 可以实现动态替换方法，并且可以在替换时修改方法。

按照这个思路，该方法就很好理解了：

```java
public void parseReplacedMethodSubElements(Element beanEle, MethodOverrides overrides) {
    NodeList nl = beanEle.getChildNodes();
    for (int i = 0; i < nl.getLength(); i++) {
        Node node = nl.item(i);
        if (isCandidateElement(node) && nodeNameEquals(node, REPLACED_METHOD_ELEMENT)) {
            Element replacedMethodEle = (Element) node;
            String name = replacedMethodEle.getAttribute(NAME_ATTRIBUTE);
            String callback = replacedMethodEle.getAttribute(REPLACER_ATTRIBUTE);
            ReplaceOverride replaceOverride = new ReplaceOverride(name, callback);
            // Look for arg-type match elements.
            List<Element> argTypeEles = DomUtils.getChildElementsByTagName(replacedMethodEle, ARG_TYPE_ELEMENT);
            for (Element argTypeEle : argTypeEles) {
                String match = argTypeEle.getAttribute(ARG_TYPE_MATCH_ATTRIBUTE);
                match = (StringUtils.hasText(match) ? match : DomUtils.getTextValue(argTypeEle));
                if (StringUtils.hasText(match)) {
                    replaceOverride.addTypeIdentifier(match);
                }
            }
            replaceOverride.setSource(extractSource(replacedMethodEle));
            overrides.addOverride(replaceOverride);
        }
    }
}
复制代码
```

name 获取到的是要替换的旧方法，callback 则是获取到的要替换的新方法，接下来再去构造 ReplaceOverride 对象。

另外由于 replace-method 内部还可以再配置参数类型，所以在构造完 ReplaceOverride 对象之后，接下来还要去解析 arg-type。

## 6.parseConstructorArgElements

parseConstructorArgElements 这个方法主要是用来解析构造方法的。这个大家日常开发中应该接触的很多。如果小伙伴们对于各种各样的构造方法注入还不太熟悉，可以在微信公众号江南一点雨后台回复 spring5，获取松哥之前录制的免费 Spring 入门教程，里边有讲。

我们来看下构造方法的解析：

```java
public void parseConstructorArgElements(Element beanEle, BeanDefinition bd) {
    NodeList nl = beanEle.getChildNodes();
    for (int i = 0; i < nl.getLength(); i++) {
        Node node = nl.item(i);
        if (isCandidateElement(node) && nodeNameEquals(node, CONSTRUCTOR_ARG_ELEMENT)) {
            parseConstructorArgElement((Element) node, bd);
        }
    }
}
public void parseConstructorArgElement(Element ele, BeanDefinition bd) {
    String indexAttr = ele.getAttribute(INDEX_ATTRIBUTE);
    String typeAttr = ele.getAttribute(TYPE_ATTRIBUTE);
    String nameAttr = ele.getAttribute(NAME_ATTRIBUTE);
    if (StringUtils.hasLength(indexAttr)) {
        try {
            int index = Integer.parseInt(indexAttr);
            if (index < 0) {
                error("'index' cannot be lower than 0", ele);
            }
            else {
                try {
                    this.parseState.push(new ConstructorArgumentEntry(index));
                    Object value = parsePropertyValue(ele, bd, null);
                    ConstructorArgumentValues.ValueHolder valueHolder = new ConstructorArgumentValues.ValueHolder(value);
                    if (StringUtils.hasLength(typeAttr)) {
                        valueHolder.setType(typeAttr);
                    }
                    if (StringUtils.hasLength(nameAttr)) {
                        valueHolder.setName(nameAttr);
                    }
                    valueHolder.setSource(extractSource(ele));
                    if (bd.getConstructorArgumentValues().hasIndexedArgumentValue(index)) {
                        error("Ambiguous constructor-arg entries for index " + index, ele);
                    }
                    else {
                        bd.getConstructorArgumentValues().addIndexedArgumentValue(index, valueHolder);
                    }
                }
                finally {
                    this.parseState.pop();
                }
            }
        }
        catch (NumberFormatException ex) {
            error("Attribute 'index' of tag 'constructor-arg' must be an integer", ele);
        }
    }
    else {
        try {
            this.parseState.push(new ConstructorArgumentEntry());
            Object value = parsePropertyValue(ele, bd, null);
            ConstructorArgumentValues.ValueHolder valueHolder = new ConstructorArgumentValues.ValueHolder(value);
            if (StringUtils.hasLength(typeAttr)) {
                valueHolder.setType(typeAttr);
            }
            if (StringUtils.hasLength(nameAttr)) {
                valueHolder.setName(nameAttr);
            }
            valueHolder.setSource(extractSource(ele));
            bd.getConstructorArgumentValues().addGenericArgumentValue(valueHolder);
        }
        finally {
            this.parseState.pop();
        }
    }
}
复制代码
```

可以看到，构造函数最终在 parseConstructorArgElement 方法中解析。

1. 一开始先去获取 name，index 以及 value 属性，因为构造方法的参数可以指定 name，也可以指定下标。
2. 先去判断 index 是否有值，进而决定按照 index 解析还是按照 name 解析。
3. 无论哪种解析方式，都是通过 parsePropertyValue 方法将 value 解析出来。
4. 解析出来的子元素保存在 ConstructorArgumentValues.ValueHolder 对象中。
5. 如果是通过 index 来解析参数，最终调用 addIndexedArgumentValue 方法保存解析结果，如果是通过 name 来解析参数，最终通过 addGenericArgumentValue 方法来保存解析结果。

## 7.parsePropertyElements

parsePropertyElements 方法用来解析属性注入。

```java
public void parsePropertyElements(Element beanEle, BeanDefinition bd) {
    NodeList nl = beanEle.getChildNodes();
    for (int i = 0; i < nl.getLength(); i++) {
        Node node = nl.item(i);
        if (isCandidateElement(node) && nodeNameEquals(node, PROPERTY_ELEMENT)) {
            parsePropertyElement((Element) node, bd);
        }
    }
}
public void parsePropertyElement(Element ele, BeanDefinition bd) {
    String propertyName = ele.getAttribute(NAME_ATTRIBUTE);
    if (!StringUtils.hasLength(propertyName)) {
        error("Tag 'property' must have a 'name' attribute", ele);
        return;
    }
    this.parseState.push(new PropertyEntry(propertyName));
    try {
        if (bd.getPropertyValues().contains(propertyName)) {
            error("Multiple 'property' definitions for property '" + propertyName + "'", ele);
            return;
        }
        Object val = parsePropertyValue(ele, bd, propertyName);
        PropertyValue pv = new PropertyValue(propertyName, val);
        parseMetaElements(ele, pv);
        pv.setSource(extractSource(ele));
        bd.getPropertyValues().addPropertyValue(pv);
    }
    finally {
        this.parseState.pop();
    }
}
复制代码
```

前面看了那么多，再看这个方法就比较简单了。这里最终还是通过 parsePropertyValue 方法解析出 value，并调用 addPropertyValue 方法来存入相关的值。

## 8.parseQualifierElements

parseQualifierElements 就是用来解析 qualifier 节点的，最终也是保存在对应的属性中。解析过程和前面的类似，我就不再赘述了，我们来看下解析结果：



![img](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5pdGJveWh1Yi5jb20vMjAyMC8wNy8yMDIwMDgxNTIwNTAwOS5wbmc?x-oss-process=image/format,png)



## 9.再谈 BeanDefinition

这里的属性解析完了都是保存在 GenericBeanDefinition 对象中，而该对象将来可以用来构建一个 Bean。

在 Spring 容器中，我们广泛使用的是一个一个的 Bean，BeanDefinition 从名字上就可以看出是关于 Bean 的定义。

事实上就是这样，我们在 XML 文件中配置的 Bean 的各种属性，这些属性不仅仅是和对象相关，Spring 容器还要解决 Bean 的生命周期、销毁、初始化等等各种操作，我们定义的关于 Bean 的生命周期、销毁、初始化等操作总得有一个对象来承载，那么这个对象就是 BeanDefinition。

XML 中定义的各种属性都会先加载到 BeanDefinition 上，然后通过 BeanDefinition 来生成一个 Bean，从这个角度来说，BeanDefinition 和 Bean 的关系有点类似于类和对象的关系。

在 Spring 中，主要有三种类型的 BeanDefinition：

- RootBeanDefinition
- ChildBeanDefinition
- GenericBeanDefinition

在 Spring 中，如果我们为一个 Bean 配置了父 Bean，父 Bean 将被解析为 RootBeanDefinition，子 Bean 被解析为 ChildBeanDefinition，要是没有父 Bean，则被解析为 RootBeanDefinition。

GenericBeanDefinition 是从 Spring2.5 以后新加入的 BeanDefinition 实现类。GenericBeanDefinition 可以动态设置父 Bean，同时兼具 RootBeanDefinition 和 ChildBeanDefinition 的功能。

目前普遍使用的就是 GenericBeanDefinition，所以我们看到前面的解析结果也是保存到 GenericBeanDefinition 中的。

关于 BeanDefinition 的更多信息，小伙伴们可以参考松哥之前的文章：[Spring 源码第四弹！深入理解 BeanDefinition](https://mp.weixin.qq.com/s/X36YBS9WRyScYO9ZtH5v_A)