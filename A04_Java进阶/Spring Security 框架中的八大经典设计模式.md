[toc]

# 盘点 Spring Security 框架中的八大经典设计模式

上次有小伙伴建议，源码分析太枯燥了，要是能够结合设计模式一起来，这样更有助于大家理解 Spring Security 源码，同时还能复习一波设计模式。

因此松哥今天就试着整一篇，和大家来聊一聊 Spring Security 中涉及到的设计模式，不过 Spring Security 中涉及到的设计模式还是非常多的，松哥这里讲几个，剩下的欢迎小伙伴们留言补充。

## 1.模板方法模式

> Template Pattern(模板方法模式)是一个抽象类公开定义了执行它的方法的模板。它的子类可以按需要重写方法实现，但调用将以抽象类中定义的方式进行，这是一种行为型模式。

模板方法方式优点如下：

- 在父类中提取了公共的部分代码，便于代码复用和扩展。
- 部分方法是由子类实现的，子类可以通过扩展方式增加相应的功能，符合开闭原则。

缺点如下：

- 对每个不同的实现都需要定义一个子类，导致类的个数增加，系统更加复杂，设计也更加抽象。
- 父类中的抽象方法由子类实现，子类执行的结果会影响父类的结果，增加了代码理解难度。

介绍完模板方法模式，大家可能大概猜到了 Spring Security 中哪些地方用到模板方法模式了。

我举几个简单的例子。

第一个例子是 AbstractUserDetailsAuthenticationProvider 类的设计。大家都知道这个类是用来做验证的，认证的逻辑在这个方法中都定义好了，但是该类却定义了两个抽象方法：

- retrieveUser 该方法用户从数据源中获取用户对象。
- additionalAuthenticationChecks 该方法用来做额外的校验（登录凭证的校验）

这两个抽象方法是在 DaoAuthenticationProvider 中实现的。DaoAuthenticationProvider 的实现就是从数据库中加载用户，默认检验登录凭证也都是验证密码。

如果你的数据源来自其他地方，或者登录凭证不是密码，那么自定义类继承自 AbstractUserDetailsAuthenticationProvider 并重写它里边的这两个方法即可。

## 2.责任链模式

> Chain of Responsibility Pattern(责任链模式) ，在这种模式中，通常每个接收者都包含对另一个接收者的引用，如果一个对象不能处理该请求，那么它会把相同的请求传给下一个接收者，依此类推。在这个过程中，客户只需要将请求发送到责任链上即可，无须关心请求的处理细节和请求的传递过程，所以责任链将请求的发送者和请求的处理者解耦了。

责任链模式优点如下：

- 降低对象之间的耦合度。
- 增强了系统的可扩展性。
- 当工作流程发生变化，可以动态地改变链内的成员或者调动它们的次序。
- 简化了对象之间的连接，每个对象只需保持一个指向其后继者的引用，不需保持其他所有处理者的引用。
- 责任分担，每个类只需要处理自己该处理的工作，符合类的单一职责原则。

缺点如下：

- 对比较长的职责链，请求的处理可能涉及多个处理对象，系统性能将受到一定影响。
- 职责链建立的合理性要靠客户端来保证，增加了客户端的复杂性。

很明显，Spring Security 中的过滤器链就是一种责任链模式。一个请求到达后，被过滤器链中的过滤器逐个进行处理，过滤器链中的过滤器每个都具有不同的职能并且互不相扰，我们还可以通过 HttpSecurity 来动态配置过滤器链中的过滤器（即添加/删除过滤器链中的过滤器）。

具体的代码在 FilterChainProxy$VirtualFilterChain 中，如下：

那么接下来我们就来看看 VirtualFilterChain：

```
private static class VirtualFilterChain implements FilterChain {
	private final FilterChain originalChain;
	private final List<Filter> additionalFilters;
	private final FirewalledRequest firewalledRequest;
	private final int size;
	private int currentPosition = 0;
	private VirtualFilterChain(FirewalledRequest firewalledRequest,
			FilterChain chain, List<Filter> additionalFilters) {
		this.originalChain = chain;
		this.additionalFilters = additionalFilters;
		this.size = additionalFilters.size();
		this.firewalledRequest = firewalledRequest;
	}
	@Override
	public void doFilter(ServletRequest request, ServletResponse response)
			throws IOException, ServletException {
		if (currentPosition == size) {
			if (logger.isDebugEnabled()) {
				logger.debug(UrlUtils.buildRequestUrl(firewalledRequest)
						+ " reached end of additional filter chain; proceeding with original chain");
			}
			// Deactivate path stripping as we exit the security filter chain
			this.firewalledRequest.reset();
			originalChain.doFilter(request, response);
		}
		else {
			currentPosition++;
			Filter nextFilter = additionalFilters.get(currentPosition - 1);
			if (logger.isDebugEnabled()) {
				logger.debug(UrlUtils.buildRequestUrl(firewalledRequest)
						+ " at position " + currentPosition + " of " + size
						+ " in additional filter chain; firing Filter: '"
						+ nextFilter.getClass().getSimpleName() + "'");
			}
			nextFilter.doFilter(request, response, this);
		}
	}
}
复制代码
```

1. VirtualFilterChain 类中首先声明了 5 个全局属性，originalChain 表示原生的过滤器链，也就是 Web Filter；additionalFilters 表示 Spring Security 中的过滤器链；firewalledRequest 表示当前请求；size 表示过滤器链中过滤器的个数；currentPosition 则是过滤器链遍历时候的下标。
2. doFilter 方法就是 Spring Security 中过滤器挨个执行的过程，如果 `currentPosition == size`，表示过滤器链已经执行完毕，此时通过调用 originalChain.doFilter 进入到原生过滤链方法中，同时也退出了 Spring Security 过滤器链。否则就从 additionalFilters 取出 Spring Security 过滤器链中的一个个过滤器，挨个调用 doFilter 方法。nextFilter.doFilter 就是过滤器链挨个往下走。

关于 FilterChainProxy 的介绍，参见：[深入理解 FilterChainProxy【源码篇】](https://mp.weixin.qq.com/s/EZsChg5YG0TBadU4q_CAnA)

## 3.策略模式

> Strategy Pattern(策略模式)，它定义了一系列算法，将每一个算法封装起来，并让它们可以相互替换。策略模式让算法独立于使用它的客户而变化，也称为政策模式(Policy)。

策略模式的优点：

- 策略模式提供了对“开闭原则”的完美支持，用户可以在不修改原有系统的基础上选择具体的策略，也可以灵活地扩展新的策略。
- 策略模式提供了管理相关的策略的方式。
- 策略模式提供了可以替换继承关系的办法。
- 使用策略模式可以避免使用多重条件转移语句。

策略模式的缺点：

- 客户端必须知道所有的策略类，并自行决定使用哪一个策略类。
- 策略模式将造成产生很多策略类（可以通过使用享元模式在一定程度上减少对象的数量）。

Spring Security 中使用策略模式的地方也有好几个。

第一个就是用户登录信息存储。

在 SecurityContextHolder 中定义登录用户信息存储的方法，就定义了三种不同的策略：

```
public class SecurityContextHolder {
	// ~ Static fields/initializers
	// =====================================================================================

	public static final String MODE_THREADLOCAL = "MODE_THREADLOCAL";
	public static final String MODE_INHERITABLETHREADLOCAL = "MODE_INHERITABLETHREADLOCAL";
	public static final String MODE_GLOBAL = "MODE_GLOBAL";
	public static final String SYSTEM_PROPERTY = "spring.security.strategy";
	private static String strategyName = System.getProperty(SYSTEM_PROPERTY);
	private static SecurityContextHolderStrategy strategy;
}
复制代码
```

用户可以自行选择使用哪一种策略！具体参见：[在 Spring Security 中，我就想从子线程获取用户登录信息，怎么办？](https://mp.weixin.qq.com/s/4dcQ6lohB3sEcnkAXxdZwg)

还有一个就是 session 并发管理。

在 AbstractAuthenticationProcessingFilter#doFilter 方法中，有如下代码：

```
public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
		throws IOException, ServletException {
	//省略
		sessionStrategy.onAuthentication(authResult, request, response);
	//省略
}
复制代码
```

这就是一种策略模式。

Session 并发管理可以参考：

- [什么是会话固定攻击？Spring Boot 中要如何防御会话固定攻击？](https://mp.weixin.qq.com/s/9SaNvVfiivWUIAe6OZgpZQ)
- [集群化部署，Spring Security 要如何处理 session 共享？](https://mp.weixin.qq.com/s/EAacxjaNg8BJRkTkGFLLpQ)

当然，这样的例子还有很多，我就不一一列举了。

## 4.代理模式

> Proxy Pattern(代理模式) ：给某一个对象提供一个代理，并由代理对象控制对原对象的引用，它是一种对象结构型模式。

代理模式的优点：

- 一定程度上降低了系统的耦合度。
- 代理对象可以扩展目标对象的功能。
- 代理对象可以保护目标对象。

缺点：

- 在客户端和真实对象之间增加了代理，可能会导致请求的处理速度变慢。
- 增加了系统复杂度。

代理模式在 Spring Security 中最重要的应用就是 Spring Security 过滤器链接入 Web Filter 的过程，使用了 Spring 提供的 DelegatingFilterProxy，这就是一个典型的代理模式：

```
public class DelegatingFilterProxy extends GenericFilterBean {
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {

		// Lazily initialize the delegate if necessary.
		Filter delegateToUse = this.delegate;
		if (delegateToUse == null) {
			synchronized (this.delegateMonitor) {
				delegateToUse = this.delegate;
				if (delegateToUse == null) {
					WebApplicationContext wac = findWebApplicationContext();
					if (wac == null) {
						throw new IllegalStateException("No WebApplicationContext found: " +
								"no ContextLoaderListener or DispatcherServlet registered?");
					}
					delegateToUse = initDelegate(wac);
				}
				this.delegate = delegateToUse;
			}
		}

		// Let the delegate perform the actual doFilter operation.
		invokeDelegate(delegateToUse, request, response, filterChain);
	}
}
复制代码
```

当然还有其他很多地方也用到代理模式，我就不一一列举了，欢迎小伙伴们留言补充。

## 5.适配器模式

> Adapter Pattern(适配器模式)，大家平时用的手机充电器学名叫做电源适配器，它的作用是把 220V 的电压转为手机可用的 5V 电压。所以适配器模式其实也是类似作用，将一个接口转换成客户希望的另一个接口，适配器模式使接口不兼容的类可以一起工作。适配器模式又分为类适配器模式、对象适配器模式以及接口适配器模式。

适配器模式的优点：

- 解耦，通过引入一个适配器类来重用现有的适配者类，而无须修改原有代码。
- 增加了类的透明性和复用性。
- 具有较好的灵活性和扩展性都。

缺点：

- 由于 Java 不支持多重继承，一次最多只能适配一个适配者类，而且目标抽象类只能为抽象类，不能为具体类，其使用有一定的局限性。

Spring Security 中的适配器模式也是非常多的，例如我们最为常见的 WebSecurityConfigurerAdapter，该类让两个原本不相关的 WebSecurity 和 HttpSecurity 能够在一起工作。

具体参见：[深入理解 WebSecurityConfigurerAdapter【源码篇】](https://juejin.im/post/6855129007869034510)

## 6.建造者模式

> Builder Pattern(建造者模式)是将一个复杂对象的构建与它的表示分离，使得同样的构建过程可以创建不同的对象出来，用户只需要指定复杂对象的类型和内容就可以构建对象，而不需要知道内部的具体构建细节。

建造者模式优点：

- 将产品本身与产品的创建过程解耦，使得相同的创建过程可以创建不同的产品对象，而客户端不需要知道产品内部细节。
- 每一个产品对应一个建造者，用户使用不同的建造者可以创建不同的产品，建造者本身可以轻松修改或者添加。
- 可以更加精细地控制产品的创建过程。

缺点：

- 创建的产品需要有一定的相似性，如果差异过大，则不适合建造者模式。
- 产品本身的复杂度会提高建造者的复杂度。

Spring Security 中对于建造者模式的使用也是非常多，例如典型的 AuthenticationManagerBuilder，它想要建造的对象是 AuthenticationManager，对应的建造方法则是 build。一般建造者模式中建造者类命名以 builder 结尾，而建造方法命名为 build()。

关于 AuthenticationManagerBuilder，参见：[深入理解 AuthenticationManagerBuilder 【源码篇】](https://mp.weixin.qq.com/s/kB4m0YJas9LHuNT8JH5ZmQ) 一文。

## 7.观察者模式

> Observer(观察者模式)指多个对象间存在一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并自动更新，观察者模式也称为发布-订阅模式、模型-视图模式，它是对象行为型模式。

观察者模式优点：

- 降低了目标与观察者之间的耦合关系，两者之间是抽象耦合关系。

缺点：

- 目标与观察者之间的依赖关系并没有完全解除，而且有可能出现循环引用。
- 当观察者对象很多时，程序执行效率降低。

在 Spring 框架中，观察者模式用于实现 ApplicationContext 的事件处理功能。Spring 为我们提供了 ApplicationEvent 类和 ApplicationListener 接口来启用事件处理。Spring 应用程序中的任何 Bean 实现 ApplicationListener 接口，都会接收到 ApplicationEvent 作为事件发布者推送的消息。在这里，事件发布者是主题(Subject) 和实现 ApplicationListener 的 Bean 的观察者(Observer)。

具体到 Spring Security 中，如登录成功事件发布，session 销毁事件等等，都算是观察者模式。

例如 AbstractAuthenticationProcessingFilter#successfulAuthentication 方法：

```
protected void successfulAuthentication(HttpServletRequest request,
		HttpServletResponse response, FilterChain chain, Authentication authResult)
		throws IOException, ServletException {
	if (logger.isDebugEnabled()) {
		logger.debug("Authentication success. Updating SecurityContextHolder to contain: "
				+ authResult);
	}
	SecurityContextHolder.getContext().setAuthentication(authResult);
	rememberMeServices.loginSuccess(request, response, authResult);
	// Fire event
	if (this.eventPublisher != null) {
		eventPublisher.publishEvent(new InteractiveAuthenticationSuccessEvent(
				authResult, this.getClass()));
	}
	successHandler.onAuthenticationSuccess(request, response, authResult);
}
复制代码
```

类似还有很多，如 session 销毁事件等（参见[Spring Security 自动踢掉前一个登录用户，一个配置搞定！](https://mp.weixin.qq.com/s/9f2e4Ua2_fxEd-S9Y7DDtA)），我这里就不一一列举了。

## 8.装饰模式

> Decorator(装饰模式)是指在不改变现有对象结构的情况下，动态地给该对象增加一些额外功能的模式。

装饰模式的优点：

- 可以灵活的扩展一个类的功能。

缺点：

- 增加了许多子类，使程序变得很复杂。

Spring Security 中对于装饰模式也有许多应用。最典型的就是一个请求在通过过滤器链的时候会不停的变，会不停的调整它的功能，通过装饰模式设计出了请求的许多类，例如：

- HeaderWriterRequest
- FirewalledRequest
- StrictHttpFirewall
- SaveToSessionRequestWrapper
- ...

等等，类似的很多