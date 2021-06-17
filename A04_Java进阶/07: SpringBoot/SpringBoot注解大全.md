[toc]



## SpringBoot注解大全

- [原创 | Java 2020 超神之路，很肝~](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&chksm=fa496f8ecd3ee698f4954c00efb80fe955ec9198fff3ef4011e331aa37f55a6a17bc8c0335a8&scene=21#wechat_redirect)
- [中文详细注释的开源项目](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486264&idx=1&sn=475ac3f1ef253a33daacf50477203c80&chksm=fa497489cd3efd9f7298f5da6aad0c443ae15f398436aff57cb2b734d6689e62ab43ae7857ac&scene=21#wechat_redirect)
- [RPC 框架 Dubbo 源码解析](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247484647&idx=1&sn=9eb7e47d06faca20d530c70eec3b8d5c&chksm=fa497b56cd3ef2408f807e66e0903a5d16fbed149ef7374021302901d6e0260ad717d903e8d4&scene=21#wechat_redirect)
- [网络应用框架 Netty 源码解析](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247485054&idx=2&sn=9f3b85f7b8454634da6c5c2ded9b4dba&chksm=fa4979cfcd3ef0d9d2dd92d8d1bd8f1553abc6e2095a5d743e0b2c2afe4955ea2bbbd7a4b79d&token=55862109&lang=zh_CN&scene=21#wechat_redirect)
- [消息中间件 RocketMQ 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486256&idx=1&sn=81daccd3fcd2953456c917630636fb26&chksm=fa497481cd3efd97d9239f5eab060e49dea9876a6046eadba0effb878d2fb51f3ba5733e4c0b&scene=21#wechat_redirect)
- [数据库中间件 Sharding-JDBC 和 MyCAT 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486257&idx=1&sn=4d3c9c675f8833157641a2e0b48e498c&chksm=fa497480cd3efd96fe17975b0b8b141e87fd0a62673e6a30b501460de80b3eb997056f09de08&scene=21#wechat_redirect)
- [作业调度中间件 Elastic-Job 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486258&idx=1&sn=ae5665ae9c3002b53f87cab44948a096&chksm=fa497483cd3efd950514da5a37160e7fd07f0a96f39265cf7ba3721985e5aadbdcbe7aafc34a&scene=21#wechat_redirect)
- [分布式事务中间件 TCC-Transaction 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486259&idx=1&sn=b023cf3dbf97e5da59db2f4ee632f5a6&chksm=fa497482cd3efd9402d71469f71863f71a6998b27e12ca2e00446b8178d79dcef0721d8e570a&scene=21#wechat_redirect)
- [Eureka 和 Hystrix 源码解析](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486260&idx=1&sn=8f14c0c191d6f8df6eb34202f4ad9708&chksm=fa497485cd3efd93937143a648bc1b530bc7d1f6f8ad4bf2ec112ffe34dee80b474605c22db0&scene=21#wechat_redirect)
- [Java 并发源码](http://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247486261&idx=1&sn=bd69f26aadfc826f6313ffbb95e44ee5&chksm=fa497484cd3efd92352d6fb3d05ccbaebca2fafed6f18edbe5be70c99ba088db5c8a7a8080c1&scene=21#wechat_redirect)

来源：cnblogs.com/tanwei81/p/6814022.html

- 一、注解(annotations)列表
- 二、注解(annotations)详解
- 三、JPA注解
- 四、springMVC相关注解
- 五、全局异常处理

------

# 一、注解(annotations)列表

**@SpringBootApplication**：包含了@ComponentScan、@Configuration和@EnableAutoConfiguration注解。其中@ComponentScan让spring Boot扫描到Configuration类并把它加入到程序上下文。

**@Configuration** 等同于spring的XML配置文件；使用Java代码可以检查类型安全。

**@EnableAutoConfiguration** 自动配置。

**@ComponentScan** 组件扫描，可自动发现和装配一些Bean。

**@Component**可配合CommandLineRunner使用，在程序启动后执行一些基础任务。

**@RestController**注解是@Controller和@ResponseBody的合集,表示这是个控制器bean,并且是将函数的返回值直 接填入HTTP响应体中,是REST风格的控制器。

**@Autowired**自动导入。

**@PathVariable**获取参数。

**@JsonBackReference**解决嵌套外链问题。

**@RepositoryRestResourcepublic**配合spring-boot-starter-data-rest使用。

# 二、注解(annotations)详解

**@SpringBootApplication**：申明让spring boot自动给程序进行必要的配置，这个配置等同于：@Configuration ，@EnableAutoConfiguration 和 @ComponentScan 三个配置。

```
package com.example.myproject;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication // same as @Configuration @EnableAutoConfiguration @ComponentScan
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

**@****ResponseBody**：表示该方法的返回结果直接写入HTTP response body中，一般在异步获取数据时使用，用于构建RESTful的api。在使用@RequestMapping后，返回值通常解析为跳转路径，加上@responsebody后返回结果不会被解析为跳转路径，而是直接写入HTTP response body中。比如异步获取json数据，加上@responsebody后，会直接返回json数据。该注解一般会配合@RequestMapping一起使用。示例代码：

```
@RequestMapping(“/test”)
@ResponseBody
public String test(){
    return”ok”;
}
```

**@Controller**：用于定义控制器类，在spring 项目中由控制器负责将用户发来的URL请求转发到对应的服务接口（service层），一般这个注解在类中，通常方法需要配合注解@RequestMapping。示例代码：

```
@Controller
@RequestMapping(“/demoInfo”)
publicclass DemoController {
    @Autowired
    private DemoInfoService demoInfoService;

    @RequestMapping("/hello")
    public String hello(Map<String,Object> map){
        System.out.println("DemoController.hello()");
        map.put("hello","from TemplateController.helloHtml");
        //会使用hello.html或者hello.ftl模板进行渲染显示.
        return"/hello";
    }
}
```

**@RestController**：用于标注控制层组件(如struts中的action)，@ResponseBody和@Controller的合集。示例代码：

```
package com.kfit.demo.web;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(“/demoInfo2”)
publicclass DemoController2 {

    @RequestMapping("/test")
    public String test(){
        return"ok";
    }
}
```

**@RequestMapping**：提供路由信息，负责URL到Controller中的具体函数的映射。

**@EnableAutoConfiguration**：Spring Boot自动配置（auto-configuration）：尝试根据你添加的jar依赖自动配置你的Spring应用。例如，如果你的classpath下存在HSQLDB，并且你没有手动配置任何数据库连接beans，那么我们将自动配置一个内存型（in-memory）数据库”。你可以将@EnableAutoConfiguration或者@SpringBootApplication注解添加到一个@Configuration类上来选择自动配置。如果发现应用了你不想要的特定自动配置类，你可以使用@EnableAutoConfiguration注解的排除属性来禁用它们。

**@ComponentScan**：表示将该类自动发现扫描组件。个人理解相当于，如果扫描到有@Component、@Controller、@Service等这些注解的类，并注册为Bean，可以自动收集所有的Spring组件，包括@Configuration类。我们经常使用@ComponentScan注解搜索beans，并结合@Autowired注解导入。可以自动收集所有的Spring组件，包括@Configuration类。我们经常使用@ComponentScan注解搜索beans，并结合@Autowired注解导入。如果没有配置的话，Spring Boot会扫描启动类所在包下以及子包下的使用了@Service,@Repository等注解的类。

**@Configuration**：相当于传统的xml配置文件，如果有些第三方库需要用到xml文件，建议仍然通过@Configuration类作为项目的配置主类——可以使用@ImportResource注解加载xml配置文件。

**@Import**：用来导入其他配置类。

**@ImportResource**：用来加载xml配置文件。

**@Autowired**：自动导入依赖的bean

**@Service**：一般用于修饰service层的组件

**@Repository**：使用@Repository注解可以确保DAO或者repositories提供异常转译，这个注解修饰的DAO或者repositories类会被ComponetScan发现并配置，同时也不需要为它们提供XML配置项。

**@Bean**：用@Bean标注方法等价于XML中配置的bean。

**@Value**：注入Spring boot application.properties配置的属性的值。示例代码：

```
@Value(value = “#{message}”)
private String message;
```

**@Inject**：等价于默认的@Autowired，只是没有required属性；

**@****Component**：泛指组件，当组件不好归类的时候，我们可以使用这个注解进行标注。

**@Bean**:相当于XML中的,放在方法的上面，而不是类，意思是产生一个bean,并交给spring管理。

**@AutoWired**：自动导入依赖的bean。byType方式。把配置好的Bean拿来用，完成属性、方法的组装，它可以对类成员变量、方法及构造函数进行标注，完成自动装配的工作。当加上（required=false）时，就算找不到bean也不报错。

**@Qualifier**：当有多个同一类型的Bean时，可以用@Qualifier(“name”)来指定。与@Autowired配合使用。@Qualifier限定描述符除了能根据名字进行注入，但能进行更细粒度的控制如何选择候选者，具体使用方式如下：

```
@Autowired
@Qualifier(value = “demoInfoService”)
private DemoInfoService demoInfoService;
```

**@Resource(name=”name”,type=”type”)**：没有括号内内容的话，默认byName。与@Autowired干类似的事。

# 三、JPA注解

**@Entity**：@Table(name=”“)：表明这是一个实体类。一般用于jpa这两个注解一般一块使用，但是如果表名和实体类名相同的话，@Table可以省略

**@MappedSuperClass**:用在确定是父类的entity上。父类的属性子类可以继承。

**@****NoRepositoryBean**:一般用作父类的repository，有这个注解，spring不会去实例化该repository。

**@Column**：如果字段名与列名相同，则可以省略。

**@Id**：表示该属性为主键。

**@GeneratedValue(strategy = GenerationType.SEQUENCE,generator = “repair_seq”)**：表示主键生成策略是sequence（可以为Auto、IDENTITY、native等，Auto表示可在多个数据库间切换），指定sequence的名字是repair_seq。

**@SequenceGeneretor(name = “repair_seq”, sequenceName = “seq_repair”, allocationSize = 1)**：name为sequence的名称，以便使用，sequenceName为数据库的sequence名称，两个名称可以一致。

**@Transient**：表示该属性并非一个到数据库表的字段的映射,ORM框架将忽略该属性。如果一个属性并非数据库表的字段映射,就务必将其标示为@Transient,否则,ORM框架默认其注解为@Basic。@Basic(fetch=FetchType.LAZY)：标记可以指定实体属性的加载方式

**@JsonIgnore**：作用是json序列化时将Java bean中的一些属性忽略掉,序列化和反序列化都受影响。

**@JoinColumn（name=”loginId”）**:一对一：本表中指向另一个表的外键。一对多：另一个表指向本表的外键。

**@OneToOne、@OneToMany、@ManyToOne**：对应hibernate配置文件中的一对一，一对多，多对一。

# 四、springMVC相关注解

**@RequestMapping**：@RequestMapping(“/path”)表示该控制器处理所有“/path”的UR L请求。RequestMapping是一个用来处理请求地址映射的注解，可用于类或方法上。 用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径。该注解有六个属性：**params**:指定request中必须包含某些参数值是，才让该方法处理。**headers**:指定request中必须包含某些指定的header值，才能让该方法处理请求。**value**:指定请求的实际地址，指定的地址可以是URI Template 模式**method**:指定请求的method类型， GET、POST、PUT、DELETE等**consumes**:指定处理请求的提交内容类型（Content-Type），如application/json,text/html;**produces**:指定返回的内容类型，仅当request请求头中的(Accept)类型中包含该指定类型才返回

**@RequestParam**：用在方法的参数前面。 @RequestParam String a =request.getParameter(“a”)。

**@PathVariable**:路径变量。如

```
RequestMapping(“user/get/mac/{macAddress}”)
public String getByMacAddress(@PathVariable String macAddress){
    //do something;
}
```

参数与大括号里的名字一样要相同。

# 五、全局异常处理

**@ControllerAdvice**：包含@Component。可以被扫描到。统一处理异常。

**@ExceptionHandler（Exception.class）**：用在方法上面表示遇到这个异常就执行以下方法。







# [ 1.SpringBoot/spring](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@SpringBootApplication:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

包含@Configuration、@EnableAutoConfiguration、@ComponentScan通常用在主类上；

### [@Repository:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用于标注数据访问组件，即DAO组件；

### [@Service:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用于标注业务层组件；

### [@RestController:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用于标注控制层组件(如struts中的action)，包含@Controller和@ResponseBody；

### [@Controller:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用于标注是控制层组件，需要返回页面时请用@Controller而不是@RestController；

### [@Component:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

泛指组件，当组件不好归类的时候，我们可以使用这个注解进行标注；

### [@ResponseBody:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

表示该方法的返回结果直接写入HTTP response body中，一般在异步获取数据时使用，在使用@RequestMapping后，返回值通常解析为跳转路径，

加上@responsebody后返回结果不会被解析为跳转路径，而是直接写入HTTP response body中；比如异步获取json数据，加上@responsebody后，会直接返回json数据；

### [@RequestBody:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

参数前加上这个注解之后，认为该参数必填。表示接受json字符串转为对象 List等；

### [@ComponentScan:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

组件扫描。个人理解相当于，如果扫描到有@Component @Controller @Service等这些注解的类，则把这些类注册为bean*；

### [@Configuration:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

指出该类是 Bean 配置的信息源，相当于XML中的，一般加在主类上；

### [@Bean:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

相当于XML中的,放在方法的上面，而不是类，意思是产生一个bean,并交给spring管理；

### [@EnableAutoConfiguration:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

让 Spring Boot 根据应用所声明的依赖来对 Spring 框架进行自动配置，一般加在主类上；

### [@AutoWired:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

byType方式。把配置好的Bean拿来用，完成属性、方法的组装，它可以对类成员变量、方法及构造函数进行标注，完成自动装配的工作；

当加上（required=false）时，就算找不到bean也不报错；

### [@Qualifier:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

当有多个同一类型的Bean时，可以用@Qualifier(“name”)来指定。与@Autowired配合使用；

### [@Resource(name=”name”,type=”type”)：](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

没有括号内内容的话，默认byName。与@Autowired干类似的事；

### [@RequestMapping:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

RequestMapping是一个用来处理请求地址映射的注解，可用于类或方法上。用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径；

> 该注解有六个属性:
>
> params:指定request中必须包含某些参数值是，才让该方法处理。
>
> headers:指定request中必须包含某些指定的header值，才能让该方法处理请求。
>
> value:指定请求的实际地址，指定的地址可以是URI Template 模式
>
> method:指定请求的method类型， GET、POST、PUT、DELETE等
>
> consumes:指定处理请求的提交内容类型（Content-Type），如application/json,text/html;
>
> produces:指定返回的内容类型，仅当request请求头中的(Accept)类型中包含该指定类型才返回。

### [@GetMapping、@PostMapping等:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

相当于@RequestMapping（value=”/”，method=RequestMethod.Get\Post\Put\Delete等） 。是个组合注解；

### [@RequestParam:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在方法的参数前面。相当于 request.getParameter()；

### [@PathVariable:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

路径变量。如 RequestMapping(“user/get/mac/{macAddress}”) ；

```
public String getByMacAddress(@PathVariable(“macAddress”) String macAddress) {
    //do something;
}
```

参数与大括号里的名字相同的话，注解后括号里的内容可以不填。

# [2. Jpa](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@Entity:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@Table(name=”“):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

表明这是一个实体类。一般用于jpa ，这两个注解一般一块使用，但是如果表名和实体类名相同的话，@Table可以省略；

### [@MappedSuperClass:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在确定是父类的entity上。父类的属性子类可以继承；

### [@NoRepositoryBean:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

一般用作父类的repository，有这个注解，spring不会去实例化该repository；

### [@Column:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

如果字段名与列名相同，则可以省略；

### [@Id:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

表示该属性为主键；

### [@GeneratedValue(strategy=GenerationType.SEQUENCE,generator = “repair_seq”):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

表示主键生成策略是sequence（可以为Auto、IDENTITY、native等，Auto表示可在多个数据库间切换），指定sequence的名字是repair_seq；

### [@SequenceGenerator(name = “repair_seq”, sequenceName = “seq_repair”, allocationSize = 1):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

name为sequence的名称，以便使用，sequenceName为数据库的sequence名称，两个名称可以一致；

### [@Transient:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

表示该属性并非一个到数据库表的字段的映射,ORM框架将忽略该属性.

如果一个属性并非数据库表的字段映射,就务必将其标示为@Transient,否则,ORM框架默认其注解为@Basic；

### [@Basic(fetch=FetchType.LAZY):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

标记可以指定实体属性的加载方式；

### [@JsonIgnore:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

作用是json序列化时将java bean中的一些属性忽略掉,序列化和反序列化都受影响；

### [@JoinColumn(name=”loginId”):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

一对一：本表中指向另一个表的外键。

一对多：另一个表指向本表的外键。

### [@OneToOne](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@OneToMany](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@ManyToOne:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

对应Hibernate配置文件中的一对一，一对多，多对一。

# [3. 全局异常处理](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@ControllerAdvice:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

包含@Component。可以被扫描到。统一处理异常；

### [@ExceptionHandler(Exception.class):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在方法上面表示遇到这个异常就执行以下方法。

# [4. SpringCloud](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

### [@EnableEurekaServer:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在springboot启动类上，表示这是一个eureka服务注册中心；

### [@EnableDiscoveryClient:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在springboot启动类上，表示这是一个服务，可以被注册中心找到；

### [@LoadBalanced:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

开启负载均衡能力；

### [@EnableCircuitBreaker:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在启动类上，开启断路器功能；

### [@HystrixCommand(fallbackMethod=”backMethod”):](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在方法上，fallbackMethod指定断路回调方法；

### [@EnableConfigServer:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

用在启动类上，表示这是一个配置中心，开启Config Server；

### [@EnableZuulProxy:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

开启zuul路由，用在启动类上；

### [@SpringCloudApplication:](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247487551&idx=1&sn=18f64ba49f3f0f9d8be9d1fdef8857d9&scene=21#wechat_redirect)

包含

@SpringBootApplication

@EnableDiscovertyClient

@EnableCircuitBreaker

分别是SpringBoot注解、注册服务中心Eureka注解、断路器注解。对于SpringCloud来说，这是每一微服务必须应有的三个注解，所以才推出了@SpringCloudApplication这一注解集合。## *1.SpringBoot/spring *