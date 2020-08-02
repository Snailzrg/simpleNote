# Spring AOP示例
本文链接：https://blog.csdn.net/qq_31772441/article/details/99699604
AOP基本概念：
切面（Aspect）：切面是通知和切点的结合。
通知（Advice）：定义了切面是什么以及何时使用。
切点（Pointcut）：定义了切面作用在何处。
…
不多bb，直接开干。

示例：
基本步骤：

启用Aspect自动代理
编写切面逻辑
目标类

```
package com.markix.aop.service;

import org.springframework.stereotype.Service;

@Service
public class ServiceImpl {

    public void testMethod(){
        System.out.println("ServiceImpl testMethod execute.");
    }

}
```
----------------------------------------------------------

切面类

```
package com.markix.aop.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Component
@Aspect
public class ServiceAspect {

    /**
     * 定义切点（定义了切面作用在 何处 ）
     * “注解@Pointcut”的value属性为“切点表达式”
     */
    @Pointcut(value = "execution(* com.markix.aop.service.ServiceImpl.testMethod())")
    public void pointcut() {
    }

    /**
     * 定义通知（定义了切面 是什么 以及 何时使用 ）
     * “注解@Before”体现了“何时使用”（@Before：通知方法会在目标方法调用之前执行；value属性关联切点，支持切点表达式）
     * “方法体”体现了“是什么”，及做什么
     */
    @Before(value = "pointcut()")
    private void beforeMethod() {
        System.out.println("Aspect beforeMethod execute.");
    }

    /**
     * 同上，定义通知
     * （@Around：通知方法将目标方法包裹起来）
     */
    @Around(value = "pointcut()")
    private void aroundMethod(ProceedingJoinPoint joinPoint) {
        try {
            System.out.println("Aspect aroundMethod before target method execute.");
            //目标方法执行
            joinPoint.proceed();
            System.out.println("Aspect aroundMethod after target method execute.");
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        }
    }

    /**
     * 同上
     * （@After：通知方法会在目标方法返回或异常后执行）
     */
    @After(value = "pointcut()")
    private void afterMethod(JoinPoint joinPoint){
        joinPoint.getArgs();
        System.out.println("Aspect afterMethod execute.");
    }

    //同上
    @AfterReturning(value = "pointcut()")
    private void afterReturningMethod(){
        System.out.println("Aspect afterReturningMethod execute.");
    }

    //同上
    @AfterThrowing(value = "pointcut()")
    private void afterThrowingMethod(){
        System.out.println("Aspect afterThrowingMethod execute.");
    }


```
}

--------------------------------------------

配置类

```
package com.markix.aop.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@Configuration
@ComponentScan(basePackages = {
        "com.markix.aop.service",
        "com.markix.aop.aspect"
})
/**
 * 启用Aspcetj自动代理
 * 注解方式：
 * '    @EnableAspectJAutoProxy
 * XML文件配置方式：
 *      xmlns:aop="http://www.springframework.org/schema/aop"
 *      xsi:schemaLocation="http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.2.xsd"
 *      <aop:aspectj-autoproxy />
 */
@EnableAspectJAutoProxy
public class AopConfig {
}
```

-------------------------------------------------

测试类

```
package com.markix.aop.test;

import com.markix.aop.config.AopConfig;
import com.markix.aop.service.ServiceImpl;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes= AopConfig.class)
public class TestClass {

    @Autowired
    private ServiceImpl serviceImpl;

    @Test
    public void test(){
        serviceImpl.testMethod();
    }

}

```

---------------------------------------

POM

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.markix</groupId>
    <artifactId>springcase</artifactId>
    <version>1.0-SNAPSHOT</version>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.1.RELEASE</version>
    </parent>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
        </dependency>
    </dependencies>
</project>
```

---------------------------------------------------------

以上仅简单示例。

其他扩展点：
启用Aspcetj自动代理的两种方式：

注解方式：@EnableAspectJAutoProxy
XML文件配置方式：

```
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop" 
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
       http://www.springframework.org/schema/aop http://www.springframe11rk.org/schema/aop/spring-aop-4.2.xsd">
	
	<!-- 启用Aspcetj自动代理 -->
	<aop:aspectj-autoproxy />
	
</beans>
```

---------------------------------------------------------

对目标方法更细致的操作：

JoinPoint、ProceedingJoinPoint（如afterMethod/aroundMethod方法的参数）可以获取更多关于目标方法的信息进行更细致的操作。
切点表达式：
execution
annotation
within
…
声明切面

注解方式：@Aspect、@Pointcut、@Before、@Around、…
xml配置方式：

```
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop" 
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
       http://www.springframework.org/schema/aop http://www.springframe11rk.org/schema/aop/spring-aop-4.2.xsd">
	
	<!-- 启用Aspcetj自动代理 -->
	<aop:aspectj-autoproxy />
	
    <!-- 切面 -->
    <bean id="arrayList" class="java.util.ArrayList"/>
    <!-- aop配置 -->
    <aop:config>
        <aop:aspect ref="arrayList">
            <aop:pointcut id="pointcut1" expression="execution(* java.util.List.toString())"/>
            <aop:before method="toString" pointcut-ref="pointcut1"/>
            <aop:after method="toString" pointcut-ref="pointcut1"/>
        </aop:aspect>
    </aop:config>

</beans>

```