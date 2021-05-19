[toc]

# 配置MyBatis！

> 本文主要介绍 `MyBatis中的配置详解`

*参考书籍*：【深入浅出MyBatis技术原理与实战】

*MyBatis以封装少、高性能、可优化、高灵活度等特性成为当今最流行的Java互联网持久层框架。*

## 开胃菜

### JDBC 编程

最早之前 Java 程序都是通过 JDBC（Java Data Base Connectivity）连接数据库的。然后我们可以通过 SQL 对数据库进行编程。

*例子*：

![img](https://cbucbm.club/ba83ccff)



*主要步骤为*：

- 注册驱动和数据库信息
- 操作Connection，打开 Statement 对象
- 通过 Statement 执行 SQL，返回结果到 Result 对象
- 使用 ResultSet 读取数据，然后通过代码转化为具体的 POJO 对象
- 关闭数据库连接资源

这么多繁杂的代码，相信我们都忍了很多年，不仅增大了我们的工作量，而且我们需要操作 `Connection`、`Statement`和`ResultSet`等对象，并要准确的关闭它。

### ORM 模型

由于 `JDBC` 编程的种种不愉快，聪明的程序员很快就用一些新的方法取代了，于是 `ORM` 编程模型就出现，不过所有的`ORM`模型都是基于`JDBC`进行封装的，不同的`ORM`模型对`JDBC`封装的强度是不一样的。

**ORM（Object Relational Mapping）对象关系映射**，简单来说，就是数据库的表和简单 Java 对象（POJO）的映射关系模型，它主要解决的是数据库数据和 POJO 对象的相互映射，然后我们通过这层映射关系就可以简单迅速地把数据库表的数据转化为 POJO，以便序员更加容易理解和应用 Java 程序。



![img](https://cbucbm.club/32563503)



### Hibernate

`Hibernate`一问世就成了 Java 世界首选的 ORM 模型，它是建立在 POJO 和 数据库表模型的直接映射关系上的。

`Hibernate` 是建立在若干 POJO 通过 XML 映射文件（或注解）提供的规则映射到数据库表上的。我们可以通过 POJO 直接操作数据库的数据，它提供的是一种全表映射的模型。通过`Hibernate`的配置文件，我们已经不需要编写 SQL 语言，只需要使用 `HQL` （Hibernate Query Langurage）语言就可以了。



![img](https://cbucbm.club/45968fa5)



**hbm.xml**：



![img](https://ftp.bmp.ovh/imgs/2020/08/d5dc15037b6a7e56.png)



这个XML 文件描述的是 POJO 和数据库表之前的映射关系。我们通过这个配置文件，几乎可以不需要编写 SQL 就能操作数据库的记录，你快乐了吗？



每个 POJO 对应一个 hbm.xml ，然后我们通过全局的配置文件`cfg.xml`注册。

**hibernate.cfg.xml**：



![img](https://ftp.bmp.ovh/imgs/2020/08/fb358110fd168424.png)



通过这个配置文件，然后建立 Hibernate 的工厂对象（SessionFactory），用它来做全局对象，产生 Session 接口，就可以操作数据库了。

**HibernateUtil.class**：



![img](https://ftp.bmp.ovh/imgs/2020/08/9d1a961f73db0c6b.png)



**HibernateDemo.class**：



![img](https://ftp.bmp.ovh/imgs/2020/08/44be2251bb471ca0.png)



值得开心的是我们成功的获取到了结果，而且代码量也不像`JDBC`那么繁多，给我们带来的好处也是显而易见的：

- 消除了代码的映射规则，它全部被分离到了**XML**或者**注解**里面去配置
- 无需再管理数据库连接，它也配置在**XML**里面
- 一个会话中，不要操作多个对象，只要操作**Session**对象即可
- 关闭资源只需要关闭一个**Session**便可

通过配置映射文件和数据库连接文件后，Hibernate 就可以通过 Session 操作，消除了大量的代码，提高了编程效率，做一个快乐的程序猿了。



![img](https://ftp.bmp.ovh/imgs/2020/08/a0be66712845d3a5.jpg)



但是！凡事都没有十全十美，人都是善变的，用久就腻了是吧？真是个**渣男**。用着用着，我们就发现了 Hibernate 屏蔽了 SQL，只能够全表映射，如果表的字段不多那倒还好，但是一张表如果有几十到上百个字段（*什么？不可能有这么多！不好意思，那是你没见过~*），而你只需要获取这张表的两三个字段，那岂不是带来了很大的麻烦，万一是个大型网站系统，你这么浪费带宽，那不凉了么。



![img](https://ftp.bmp.ovh/imgs/2020/08/7efc959d9d492795.jpg)



所以，总结 Hibernate 的缺点有如下几个：

- 全表映射带来的不便
- 无法根据不同的条件组装不同的 SQL
- 对多表关联和复杂 SQL 查询支持较差，需要自己写 SQL，返回后，需要自己将数据组装成 POJO
- 不能有效支持存储过程
- 虽然也支持 HQL，但是性能较差，无法做到优化 SQL

*做个开发搬运工容易么，好不容易发现个 Hibernate 可以替代 JDBC，没想到缺点也这么多！这不 Mybatis 就问世了*

### MyBatis

终于来到了今天的主角，`MyBatis`。为了解决 Hibernate 的不足，一个半自动映射的框架 Mybatis 应运而生。之所以是半自动，是因为它需要手动匹配提供 POJO、SQL和映射关系，而全表映射的 Hibernate 只需要提供 POJO 和映射关系便可。多了SQL的映射关系，并不意味着复杂了，相反灵活了很多。

#### 介绍

MyBatis 的前身是 Apache的一个开源项目 iBatis，2010 年这个项目由 apache software foundation 迁移到了 google.code，并且改名为 Mybatis。2013年11月迁移到 Github，所以目前 Mybatis 是由 Github 维护的。

`MyBatis` 包括三个部分：

- SQL
- 映射规则
- POJO

我们可以自己编写 SQL（动态配置），通过配置决定 SQL 映射规则，也能支持存储过程，所以对于一些复杂的和需要优化性能的 SQL 的查询它更加方便。MyBatis 几乎可以做到 JDBC 所能做到的所有事情，MyBatis 具有自动映射功能。



![Mybatis 和 ORM 映射模型](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



#### 演示

**student.xml**：



![img](https://wx2.sbimg.cn/2020/08/14/3k8Nl.png)



**mybatis_config.xml**：



![img](https://wx1.sbimg.cn/2020/08/14/3kxeo.png)



**MybatisUtil.class**：



![img](https://wx2.sbimg.cn/2020/08/14/3kSRm.png)



**MybatisDemo**：



![img](https://wx1.sbimg.cn/2020/08/14/3kTKU.png)



这样便完成了 MyBatis 的使用，SQL 和 映射规则都在 XML 里面进行了分离，也更加灵活，我们可以自由的编写 SQL ，定义映射规则。

### Mybatis 基本构成

- `SqlSessionFactoryBuilder`（构造器）：它会根据配置信息或者代码来生成 SqlSessionFactory（工厂接口）

- `SqlSessionFactory`：依靠工厂来生成 SqlSession（会话）

- `SqlSession`：是一个既可以发送 SQL 去执行并返回结果，也可以获取 Mapper 的接口

- `SQL Mapper`：是有一个 Java 接口和 XML 文件（或注解）构成的，需要给出对应的 SQL 和映射关系，负责发送 SQL 去执行，并返回结果。

  

![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



## 硬菜 之 配置文件详解



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



上面那些标签就是 MyBatis 的全部配置元素

#### 一、properties 标签

`properties` 是一个配置属性的元素，我们可以在配置文件的上下文使用

MyBatis 支持*3*种配置方式：

- property 子元素
- properties 配置文件
- 程序参数传递

**1. property 子元素**

```xml
<properties type="POOLED">
    <property name="driver" value="${driver}"/>
    <property name="url" value="${url}"/>
    <property name="username" value="${username}"/>
    <property name="password" value="${password}"/>
</properties>

```

以上 `${driber}`,`${url }`这些值我们可以通过 `properties`配置文件来配置属性值，达到可以重复使用，也方便统一修改。

**2. jdbc.properties 文件**

```properties
#mysql驱动
jdbc.driver=com.mysql.cj.jdbc.Driver
#数据库地址
jdbc.url=jdbc:mysql://localhost:3306/test?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Hongkong
#用户名
jdbc.username=root
#密码
jdbc.password=123456

```

然后将 `jdbc.properties` 文件放在 *resource* 目录下，然后通过以下配置引入即可

```xml
<properties resource="jdbc.properties"/>

```

**3. 程序参数传递**

我们在实际开发中有时候会对`username` 和 `password` 进行加密，然后我们需要在生成 SqlSessionFactory 之前转为明文，处理方式如下：

```java
InputStream cfgIs = Resources.getResourceAsStream("mybatis_config.xml");
Reader cfgRd = new InputStreamReader(cfgIs);
Properties properties = new Properties();
properties.load(cfgRd);
//解密
properties.setProperty("username",decode(properties.getProperty("username")));
properties.setProperty("password",decode(properties.getProperty("password")));

```

*3 种配置方式之间是存在优先级的*：

1. 在 properties 元素体内指定的属性首先会被读取
2. 再读取 resource 目录下读取的配置文件，覆盖掉已读取的同名属性
3. 最后读取作为方法参数传递的属性，覆盖掉已读取的同名属性

因此优先级如下：

**程序参数传递 > properties 配置文件 > property 子元素**

#### 二、settings 标签

设置（settings）在 MyBatis 中是最复杂的配置，即使不配置，MyBatis 也可以正常工作

*下面是一些常见的设置*

| 设置参数                 | 描述                                                         | 默认值                                  |
| ------------------------ | ------------------------------------------------------------ | --------------------------------------- |
| pecacheEnabled           | 影响所有映射器中配置的缓存全局开关                           | true                                    |
| lazyLoadingEnabled       | 延迟加载的全局开关，开启时，所有关联对象都会延迟加载，特定关联中可以通过 fetchType 属性来覆盖该项的开关状态 | false                                   |
| aggressiveLazyLoading    | 启用时，对任意延迟属性的调用会使带有延迟加载属性的对象完整加载，反之，每种属性都会按需加载 | true                                    |
| userColumnLabel          | 使用列标签代替列名                                           | true                                    |
| useGeneratedKeys         | 允许 JDBC 支持自动生成主键，如果设为 true ，则这个设置强制使用自动生成主键 | true                                    |
| autoMappingBehavior      | 指定 MyBatis 应如何自动映射列到字段或属性；  NONE 表示取消自动映射；  PARTIAL 只会自动映射没有定义嵌套结果集映射的结果集；  FULL 会自动映射任意复杂的结果集（无论是否嵌套） | PARTIAL                                 |
| defaultExecutorType      | 配置默认的执行器  SIMPLE 是普通的执行器；  REUSE 执行器会重用预处理语句（prepared statements）  BATCH 执行器重用语句并执行批量更新 | SIMPLE                                  |
| safeRowBoundsEnabled     | 允许在嵌套语句中使用分页（RowBounds)                         | false                                   |
| mapUnderscoreToCamelCase | 是否开启自动驼峰命名规则映射                                 | false                                   |
| logPrefix                | 指定 MyBatis 增加到日志名称的前缀                            | 没有设置                                |
| logImpl                  | 指定 MyBatis 所用日志的具体实现，未指定时将自动查找 （SLF4J，LOG4J，LOG4J2...） | 没有设置                                |
| proxyFactory             | 指定 MyBatis 创建具有延迟加载能力的对象所用到的代理工具（CGLIB，JAVASSIST） | 版本3.3.0以上是 JAVASSIST，否则是 CGLIB |

**穿插鸡汤时刻**：

> 美酒的酿造需要年头，美食的烹调需要时间，片刻等待，更多美味，更多享受。
>
>  --- 新奥尔良 Antoine 餐厅的菜单

#### 三、typeAliases 标签

别名（typeAliases）是一个指定的名称，当我们遇到的类全限定名过长的时候，我们可以用一个简短的名称去指代它，这个名称我们可以在 MyBatis 上下文中使用。

```xml
<typeAliases>
    <typeAlias type="cbuc.ssm.entity.Student" alias="student"/>
    <!-- 通过自动扫描包自定义别名-->
    <!--<package name="cbuc.ssm.entity"/>-->
</typeAliases>

```

使用 包扫描 配置别名的使用，我们可以使用`@Alias` 注解自定义别名

```java
@Alias("student")
public class Student {}

```

配置了 包扫描 的路径，没有注解 `@Alias` 的MyBatis 也会装载，只是说它将把你的类名的第一个字母变成小写，作为 MyBatis 的别名，要注意出现重名的场景！

#### 四、typeHandler 标签

![img](https://ftp.bmp.ovh/imgs/2020/08/ed30de69ba2f7679.jpg)



这些是 MyBatis 系统定义的，已经可以适用于大部分场景了，如果遇到无法处理的类型，MyBatis 也支持自定义。我们只需要实现 `TypeHandler`接口或者继承 `BaseTypeHandler`类，其中有*4*个抽象方法，我们也需要实现这四个抽象方法，其中：

- `setParameter`：是 PreparedStatement 对象设置参数，它允许我们自己设置变换规则
- `getResult`：则分为 ResultSet 用列名（columnName）或者使用列下标（columnIndex）来获取结果数据，其中也包括了用 CallableStatement（存储过程）来获取结果

*使用例子*：

**MyStringHandler.class**



![img](https://ftp.bmp.ovh/imgs/2020/08/cbe4928842aa130d.png)



在配置文件中注册：

```xml
<typeHandlers>
    <typeHandler javaType="string" jdbcType="VARCHAR" handler="cbuc.ssm.custom.MyStringTypeHandler"/>
</typeHandlers>

```

当 java 参数是 String 类型的时候，我们可以使用 `MyStringTypeHandler` 来处理，然后接下来我们还需要自己告诉 MyBatis 我们不用你的 typeHander 了，我们要使用我们自己的 typeHandler。在 `student.xml` 中修改，如下：

**student.xml**：



![img](https://ftp.bmp.ovh/imgs/2020/08/97694c9071bf94b0.png)



**输出结果**



![img](https://ftp.bmp.ovh/imgs/2020/08/7afe6a4ce6d2bf45.png)



我们引入了 `resultMap`，它提供了映射规则，我们可以通过3种映射来使用`typeHandler`：

- 在`resultMap`中的`result`定义 *jdbcType*和*javaType*，如果和配置文件中 typeHandlers

是一致的，MyBatis 就会使用我们自定义的 typeHandler，**需要在配置中定义**

- 在参数中指定具体的 typeHandler，**不用在配置中定义**
- 在映射集中直接定义具体的 typeHandler，**不用配置中定义**

#### 五、ObjectFactory 标签

当 MyBatis 构建一个结果集返回的时候，都会用 `ObjectFactory`（对象工厂）来构建 POJO。因此我们也可以自定义 `ObjectFactory` 来构建 POJO。例子如下：

**MyObjectFactory.class**：



![img](https://ftp.bmp.ovh/imgs/2020/08/80aeee7a26429bf6.png)



**mybatis_config.xml**：

```xml
<objectFactory type="cbuc.ssm.custom.MyObjectFactory">
    <property name="name" value="MyObjectFactory"/>
</objectFactory>

```

**输出结果**：



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



我们可以在 `create` 和 `setProperties` 方法中定义自己的处理逻辑

#### 六、environments 标签

在实际配置环境中可以注册多个数据源（dataSource）



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800" height="600"></svg>)



- environments 中的`default` 是用来标明默认其中哪个数据源配置
- environment 元素是一个数据源配置的开始，id 是这个数据源的标志
- transactionManager 是配置数据库事务，其中 `type` 有 3 种配置方法
  1. JDBC， 采用 JDBC 的方式管理事务
  2. MANAGED，采用容器方式管理事务
  3. 自定义，可以自定义事务管理方式
- dataSource：MyBatis 提供了 3 种数据源的实现方式
  1. UNPOOLED，非连接池
  2. POOLED，连接池
  3. JNDI

#### 七、mppers 标签

映射器是 MyBatis 最核心的组件

在书写 POJO的 XML时，我们见过了映射器对命名空间的声明，对应的是一个接口的全路径

```xml
<mapper namespace="cbuc.ssm.mapper.StudentMapper"></mapper>

```

在配置文件中，也有映射器的参数，其中引入映射器有以下几种方法：

- 用包名引入映射器

```xml
<mappers>
    <package name="cbuc.ssm.mapper"/>
</mappers>

```

- 用文件路径引入映射器

```xml
<mappers>
    <mapper resource="mapper/student.xml"/>
</mappers>

```

- 用类注册引入映射器

```xml
<mappers>
    <mapper class="cbuc.ssm.mapper.StudentMapper"/>
</mappers>

```

- 用xml绝对路径引入映射器

```xml
<mappers>
    <mapper url="file://cbuc/ssm/mapper/mybatis_config.xml"/>
</mappers>

```

映射器是 MyBatis 最强大的工具，也是我们使用 MyBatis 用的最多的工具，下面将会针对映射器出一篇博文讲解，请感兴趣的同学们关注小菜哦！



![看完不赞，都是坏蛋](https://imgconvert.csdnimg.cn/aHR0cHM6Ly93d3cuNTJkb3V0dS5jbi9zdGF0aWMvdGVtcC9waWMvOWJkNjhkMTUwZjA3ODdjNTYwYTQzOWRhMzU5YTU4MGEucG5n?x-oss-process=image/format,png#pic_center)



> 今天的你多努力一点，明天的你就能少说一句求人的话！