## 【65期】Spring的IOC是啥?有什么好处?

Mingqi [Java面试题精选](javascript:void(0);) *3月23日*

**点击上方“Java面试题精选”，关注公众号**

**面试刷图，查缺补漏**

**>>号外：****往期面试题，10篇为一个单位归置到本公众号菜单栏->面试题，有需要的欢迎翻阅。**

## 设计模式7大原则

为什么会有人说设计模式已死呢，因为spring这些框架帮你做好了类和对象的管理，让你写代码的时候只专注于你实现的功能，而不是设计。先来看看设计模式的7大原则：

- 开放-封闭原则
- 单一职责原则
- 依赖倒转原则
- 最小知识原则
- 接口隔离原则
- 合成/聚合复用原则
- 里氏代换原则，任何基类可以出现的地方，子类一定可以出现

## 依赖倒置

假设我们设计一辆汽车：先设计轮子，然后根据轮子大小设计底盘，接着根据底盘设计车身，最后根据车身设计好整个汽车。这里就出现了一个“依赖”关系：汽车依赖车身，车身依赖底盘，底盘依赖轮子。

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtANdrnrD7lW6HsLupPlKbNhg7uC8nNrUvicmVw3KFfu8Cibb8kY8yq6xg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

这样的设计看起来没问题，但是可维护性却很低。

假设设计完工之后，上司却突然说根据市场需求的变动，要我们把车子的轮子设计都改大一码。这下我们就蛋疼了：因为我们是根据轮子的尺寸设计的底盘，轮子的尺寸一改，底盘的设计就得修改；同样因为我们是根据底盘设计的车身，那么车身也得改，同理汽车设计也得改——整个设计几乎都得改！

我们现在换一种思路。我们先设计汽车的大概样子，然后根据汽车的样子来设计车身，根据车身来设计底盘，最后根据底盘来设计轮子。这时候，依赖关系就倒置过来了：轮子依赖底盘， 底盘依赖车身， 车身依赖汽车。

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

这时候，上司再说要改动轮子的设计，我们就只需要改动轮子的设计，而不需要动底盘，车身，汽车的设计了。这就是依赖倒置原则——把原本的高层建筑依赖底层建筑“倒置”过来，变成底层建筑依赖高层建筑。**高层建筑决定需要什么，底层去实现这样的需求，但是高层并不用管底层是怎么实现的。**这样就不会出现前面的“牵一发动全身”的情况。

## 控制反转（Inversion of Control）

就是依赖倒置原则的一种代码设计的思路。具体采用的方法就是所谓的依赖注入（Dependency Injection）。其实这些概念初次接触都会感到云里雾里的。说穿了，这几种概念的关系大概如下：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtxQ6gMhDatshx9qYnymKE4Rus06uX0ibVnvxSdbeStF2QJiaZHARVnTgw/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

为了理解这几个概念，我们还是用上面汽车的例子。只不过这次换成代码。我们先定义四个Class，车，车身，底盘，轮胎。然后初始化这辆车，最后跑这辆车。代码结构如下：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLts53a0mfzTbaa6Oc3t8jzSmyavFqpUEoQURTTs7iayEOd19XgY1HGFYQ/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

这样，就相当于上面第一个例子，上层建筑依赖下层建筑——每一个类的构造函数都直接调用了底层代码的构造函数。假设我们需要改动一下轮胎（Tire）类，把它的尺寸变成动态的，而不是一直都是30。我们需要这样改：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtMFGym0V69wC8ZR1mNNdrWoDYzxR5D3A0iaopIPYdoT8Pe9pbhjFmgyA/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

由于我们修改了轮胎的定义，为了让整个程序正常运行，我们需要做以下改动：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLticTuOjibnLmajaNcw4rKKYTMoXqPKADhKBod9aOURxX4BIRC7GhnBkBw/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

由此我们可以看到，仅仅是为了修改轮胎的构造函数，这种设计却需要修改整个上层所有类的构造函数！在软件工程中，这样的设计几乎是不可维护的——在实际工程项目中，有的类可能会是几千个类的底层，如果每次修改这个类，我们都要修改所有以它作为依赖的类，那软件的维护成本就太高了。

所以我们需要进行控制反转（IoC），即上层控制下层，而不是下层控制着上层。我们用依赖注入（Dependency Injection）这种方式来实现控制反转。所谓依赖注入，就是把底层类作为参数传入上层类，实现上层类对下层类的“控制”。这里我们用构造方法传递的依赖注入方式重新写车类的定义：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtls8aE7d2Rka27079dJ2UqC4yYscak40hPHEYE0hPovBptO5stzq2ow/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

这里我们再把轮胎尺寸变成动态的，同样为了让整个系统顺利运行，我们需要做如下修改：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtOxYriajx6XGm6iaGksQfXVicEicKAZ8J4dGf8GWp9ibZjMoJ6LPqm4hCCgg/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

看到没？这里我只需要修改轮胎类就行了，不用修改其他任何上层类。这显然是更容易维护的代码。不仅如此，在实际的工程中，这种设计模式还有利于不同组的协同合作和单元测试：比如开发这四个类的分别是四个不同的组，那么只要定义好了接口，四个不同的组可以同时进行开发而不相互受限制；而对于单元测试，如果我们要写Car类的单元测试，就只需要Mock一下Framework类传入Car就行了，而不用把Framework, Bottom, Tire全部new一遍再来构造Car。

这里我们是采用的构造函数传入的方式进行的依赖注入。其实还有另外两种方法：Setter传递和接口传递。这里就不多讲了，核心思路都是一样的，都是为了实现控制反转。

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtxIC3BrygrxRKibxEWUEBwIquB0Ig3WTqdicnMoXkjFr3ScUKvdiaOJRcA/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

## 控制反转容器(IoC Container)

其实上面的例子中，对车类进行初始化的那段代码发生的地方，就是控制反转容器。

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtdqYo7SH5PlKxBo7CgCibCib6AITOpfNicYvLfB3XxYuql4seYdpoJUAHw/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

显然你也应该观察到了，因为采用了依赖注入，在初始化的过程中就不可避免的会写大量的new。这里IoC容器就解决了这个问题。这个容器可以自动对你的代码进行初始化，你只需要维护一个Configuration（可以是xml可以是一段代码），而不用每次初始化一辆车都要亲手去写那一大段初始化的代码。

这是引入IoC Container的第一个好处。IoC Container的第二个好处是：我们在创建实例的时候不需要了解其中的细节。在上面的例子中，我们自己手动创建一个车instance时候，是从底层往上层new的：

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

这个过程中，我们需要了解整个Car/Framework/Bottom/Tire类构造函数是怎么定义的，才能一步一步new/注入。而IoC Container在进行这个工作的时候是反过来的，它先从最上层开始往下找依赖关系，到达最底层之后再往上一步一步new（有点像深度优先遍历）：

![img](https://mmbiz.qpic.cn/mmbiz/8KKrHK5ic6XAEZmWIOqQ92gBBaqKWYdLtqE4McRLP86klTHeiaqibQLFWOcHOYce9o5L1HkRT17Nk1ScQO9Fo25tQ/640?wx_fmt=other&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

IoC Container可以直接隐藏具体的创建实例的细节。

这是我看到的说控制反转最清楚的文章，大家理解的时候不要在乎这些框架，而是这个设计本身，所以从设计模式的原则讲起。

*来源：zhihu.com/question/23277575/answer/169698662*