[toc]

## 再见了 SpringMVC！这个框架有点厉害，甚至干掉了 Servlet！

点击关注 👉 [Java基基](javascript:void(0);) *3天前*

点击上方“Java基基”，选择“设为星标”

做积极的人，而不是积极废人！

源码精品专栏

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

来源：my.oschina.net/u/3953752/blog/2051297

- 前言
- 基于 Servlet 容器的 Web MVC
- 实现 Reactive Streams 的 Reactor
- 又一个 Web 框架？
- 可以脱离 Servlet 容器了？

------

# 前言

对 Java 开发者来说， Spring 发布 5.0 正式版，而新版 Spring 的一大特色，就是 Reactive Web 方案 Web Flux，这是用来替代 Spring Web MVC 的吗？或者，只是终于可以不再基于 Servlet 容器了？

# 基于 Servlet 容器的 Web MVC

身为 Java 开发者，对于 Spring 框架并不陌生。它起源于 2002 年、Rod Johnson 著作《Expert One-on-One J2EE Design and Development》中的 Interface 21 框架，到了 2004 年，推出 Spring 1.0，从 XML 到 3.0 之后，支持 JavaConfig 设定；进一步，在 2014 年时，除了 Spring 4.0 之外，首次发表了Spring Boot，最大的亮点是采用自动组态，令基于 Spring 的快速开发成为可能。

对 Web 开发者来说，Spring 中的 Web MVC 框架，也一直随着 Spring 而成长，然而由于基于 Servlet 容器，早期被批评不易测试（例如：控制器中包含了 Servlet API）。

不过，从实操 Controller 介面搭配 XML 设定，到后来的标注搭配 JavaConfig，Web MVC 使用越来越便利。如果愿意，也可采用渐进的方式，将基于 Servlet API 的 Web 应用程序，逐步重构为几乎没有 Servlet API 的存在，在程序代码层面达到屏蔽 Servlet API 的效果。

由于不少 Java 开发者的 Web 开发经验，都是从 Servlet 容器中累积起来的，在这个时候，Web MVC 框架基于 Servlet API，就会是一项优点。因为，虽然运用 Web MVC 编写程序时，可做到不直接面对 Servlet API，然而，也意味着更强烈地受到 Spring 的约束，有时则是无法在设定或 API 中找到对应方案，有时也因为心智模型还是挂在 Servlet 容器，经验上难以脱离，在搞不出 HttpSession、ServletContext 对应功能时，直接从 HttpSession、ServletContext 下手，毕竟也是个方法。

编写程序时，就算没用到 Servlet API，Web MVC 基于 Servlet 容器仍是事实，因为，底层还是得借助 Servlet 容器的功能，例如 Spring Security，本质上还是基于 Servlet 容器的 Filter 方案。

然而在今日，Servlet 被许多开发者视为陈旧、过时技术的象征，或许是因为这样，在 Java EE 8 宣布推出的这段期间，当在某些场合谈及 Servlet 4.0 之时，总会听到有人提出“Web Flux 可以脱离 Servlet 了”之类的建议。

# 实现 Reactive Streams 的 Reactor

Web Flux 不依赖 Servlet 容器是事实，然而，在谈及 Web Flux 之前，我们必须先知道 Reactor 项目，它是由 Pivotal 公司，也就是目前 Spring 的拥有者推出，实现了 Reactive Streams 规范，用来支持 Reactive Programming 的实作品。

既然是实现了 Reactive Streams 规范，开发者必然会想到的是 RxJava/RxJava 2，或者是 Java 9 的 Flow API。这也意谓着，在能使用 Web Flux 之前，开发者必须对于 Reactive Programming 典范，有所认识。

开发者这时有疑问了，Spring 为何不直接基于 RxJava 2，而是打造专属的 Reactive Streams 项目呢？

就技术而言，Reactor 是在 Java 8 的基础上开发，并全面拥抱 Java 8 之后的新 API，像是 Lambda 相关介面、新日期与时间 API 等，这意谓着，项目如果还是基于 Java 7 或更早版本，就无法使用 Reactor。

在 API 层面，RxJava 2 有着因为历史发展脉络的原因，不得不保留一些令人容易困惑或混淆的型态或操作，而 Reactor 在这方面，都有着明确的对应 API 来取代，然而，却也提供与 RxJava 2（甚至是 Flow API）间的转换。

另一方面，Reactor 较直觉易用，例如最常介绍的 Mono 与 Flux，实现了 Reactive Streams 的 Publisher界面，并简化了信息发布，让开发者在许多场合，不用处理 Subscriber 和 Subscription 的细节（当然，这些在 Reactor 也予以实现）。而在 Spring Web Flux 中，Mono 与 Flux 也是主要的操作对象。想知道如何使用Mono与Flux，可以参考〈使用 Reactor 进行反应式编程〉

# 又一个 Web 框架？

到了 Spring 5，在 Reactor 的基础上，新增了 Web Flux 作为 Reactive Web 的方案，我们在许多介绍文件的简单示例，例如〈使用 Spring 5 的 WebFlux 开发反应式 Web 应用〉，就看到当中使用了 Flux、Mono 来示范，而且，程序的代码看起来就像是 Spring MVC。

这是因为 Web Flux 提供了基于 Java 注解的方式，有许多 Web MVC 中使用的标注，也拿来用在 Web Flux 之中，让熟悉 Web MVC 的开发者也容易理解与上手 Web Flux，然而，这不过就是新的 Web 框架吗？

实际上，当然不是如此。Web Flux 并不依赖 Web MVC，而且它是基于 Reactor，本质属于非同步、非阻断、Reactive Programming 的心智模型，也因此，如果打算将 Web Flux 运行在 Servlet 容器之上，必须是支持 Servlet 3.1 以上，因为才有非阻断输入输出的支持，虽然 Web Flux 的 API 在某些地方，确实提供了阻断的选项，若单纯只是试着将基于 Web MVC 的应用程序，改写为套用 Web Flux，并不会有任何益处，反而会穷于应付如何在 Web Flux 实现对应的方案。

例如，此时，Spring Security 显然就不能用了，毕竟是 Spring 基于 Servlet 的安全方案，开发者必须想办法套用 Spring Security Reactive；而且，在储存方案上，也不是直接采用 Spring Data，而是 Spring Data Reactive 等。

就算能套用相关的设定与 API，要能获得 Web Flux 的益处，应用程序中相关的元件，也必须全面检视，重新设计为非阻断、基于 Reactive Programming 方式，这或许才是最困难、麻烦的部份。

除了基于 Java 注解的方式，让熟悉 Web MVC 的开发者容易理解之外，Web Flux 还提供了基于函数式的设计与组态方式。

实际上，在运用 RxJava 2/Reacto r等 Reactive Streams 的实操时，我们也都必须熟悉函数式的思考方式，才能充分掌握，这点在 Web Flux 并不例外。

# 可以脱离 Servlet 容器了？

Servlet 容器是个旧时代的象征，如果能够屏蔽 Servlet 容器或相关 API，许多开发者应该都会很开心，可以少一层抽象，不必使用肥肥的 Servlet 容器，当然会是使用 Web Flux 时附带的优点，然而，如果只是为了屏蔽 Servlet，其实，早就有其他技术选择存在。

基于 Servlet 一路发展过来的 Web MVC，虽然目前在某些地方可以安插一些函数式的设计，然而，本质上不变的部分在于，在技术堆叠中所隐含的，仍是一个基于同步、阻断式、命令式的心智模型。如果在这样的堆叠中，开发者老是因为想要实现非同步、非阻断、Reactive、函数式而感到不快，Web Flux 也许才会是可考虑的方案，而不单只是用来作为脱离 Servlet 容器，Web MVC 的替代品。

整体而言，Web Flux 还算是新技术，也还有待时间验证可行性，如果只是为了想用 Web Flux 来取代 Web MVC，或者更小一点的野心，只是想要能脱离 Servlet 容器，最好在采取行动之前，全面检视一下，确认自身或团队成员是否准备好接受 Web Flux 的心智模型，或者真的存在着对应的应用场景吧。