# Spring配置IOC
相关类（演示方便，类体省略）

```
// 接口
public interface IDao {
	...
}
// 接口实现类
public class IDaoImpl implements IDao {
	...
}
// 引用类
public class ServiceImpl {
    ...
}

自动注入
开启注解扫描，
使用 @Component 注解标识组件，为了区分不同类的用途，相应的还可以用 @Repository / @Service / @Controller 注解
使用 @Autowired 或者 @Resource 注解注入依赖对象

// 接口实现类
@Component
public class IDaoImpl implements IDao {
	...
}
// 引用类
@Component
public class ServiceImpl {
	@Autowired //@Resource
    private IDao dao;
    ...
}

<!-- 开启注解扫描 -->
xml配置：<context:component-scan base-package="com.bean"/>
或者
注解：@ComponentScan(basePackages={"com.bean"})
xml配置注入
方式1.构造器注入
// 引用类
public class ServiceImpl {
    private IDaoImpl daoImpl;
    
    //提供构造方法，进行构造器注入
    public ServiceImpl(IDaoImpl daoImpl){
        this.daoImpl= daoImpl;
    }
    ...
}

<!-- xml配置 -->
<bean id="daoImpl" class="com.bean.DaoImpl"/>
<bean class="com.bean.ServiceImpl">
	<constructor-arg index="0" ref="daoImpl"/>
</bean>

方式2.Setter方法注入
// 引用类
public class ServiceImpl {
    private IDaoImpl daoImpl;
    
    //提供setter方法，进行属性注入
    public IDaoImpl getDaoImpl() { return daoImpl; }
    public void setDaoImpl(IDaoImpl daoImpl) { this.daoImpl = daoImpl; }
    ...
}

<!-- xml配置 -->
<bean id="daoImpl" class="com.bean.DaoImpl"/>
<bean class="com.bean.ServiceImpl">
	<property name="daoImpl" ref="daoImpl"/>
</bean>  

方式3.接口注入
类同Setter方法注入，只是依赖属性的类型变成了接口，而非实现类。
下面代码将原来的 IDaoImpl 变成了 IDao

// 引用类
public class ServiceImpl {
    private IDao dao;
    
    //提供setter方法，进行属性注入
    public IDao getDao() { return dao; }
    public void setDao(IDao dao) { this.dao = dao; }
    ...
}

<!-- xml配置 -->
<bean id="daoImpl" class="com.bean.DaoImpl"/>
<bean class="com.bean.ServiceImpl">
	<property name="dao" ref="daoImpl"/>
</bean>  

手动注入
就是手动 new 对象，手动 set

IDao daoImpl = new IDaoImpl();
ServiceImpl service = new ServiceImpl();
service.setDao(daoImpl);
```
