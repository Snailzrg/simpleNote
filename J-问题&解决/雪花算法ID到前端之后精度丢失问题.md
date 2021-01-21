最近公司的一个项目组要把以前的单体应用进行为服务拆分，表的ID主键使用Mybatis plus默认 的雪花算法来生成。



快下班的时候，小伙伴跑过来找我，：“快给我看看这问题，卡这卡了小半天了！”。连拉带拽，连哄带骗的把我拉到他的电脑前面。这位小伙伴在我看来技术不算是大牛，但经验也很丰富了。他都卡了半天的问题，应该不是小问题，如果我一时半会搞不定，真的是耽误我下班了，所以我很不情愿的在他的位置坐了下来。

## 一、现象是这样的

下面我把异常的现象给大家描述一下，小伙伴建了一张表，表的主键是id BigINT，用来存储雪花算法生成的ID，嗯，这个没有问题！

```
CREATE TABLE user
(
    id BIGINT(20) NOT NULL COMMENT '主键ID',
        #其他字段省略
);
复制代码
```

使用Long 类型对应数据库ID数据。嗯，也没有问题，雪花算法生成的就是一串数字，Long类型属于标准答案！

```
@Data
public class User {
    private Long id;
//其他成员变量省略
复制代码
```

在后端下断点。看到数据响应以JSON响应给前端，正常

```
{
id：1297873308628307970,
//其他属性省略
}
复制代码
```

最后，这条数据返回给前端，前端接收到之后，修改这条数据，后端再次接收回来。奇怪的问题出现了：**后端重新接收回来的id变成了：12978733086283000000，不再是1297873308628307970**

## 二、分析问题

我的第一感觉是，开发小伙伴把数据给搞混了，张冠李戴了，把XXX的对象ID放到了YYY对象的ID上。所以，就按照代码从前端到后端、从后端到前端调试跟踪了一遍。

从代码的逻辑角度上没有任何问题。这时，我有点烦躁了，真的是耽误我下班了！但开工没有回头箭，既然坐下来了就得帮他解决，不然以后这队伍怎么带？想到这我又静下心来，开始思考。

```
1297873308628300000 ---> 1297873308628307970
复制代码
```

这两个数长得还挺像的，似乎是被四舍五入了。此时脑袋里面冒出一个想法，是精度丢失了么？哪里能导致精度丢失？

- 服务端都是Long类型的id，不可能丢失
- 前端是什么类型，JSON字符串转js对象，接收Long类型的是number

上网查了一下Number精度是16位（雪花ID是19位的），So：JS的Number数据类型导致的精度丢失。问题是找到了！ 小伙伴投来敬佩的眼光，5分钟就把这问题发现了。可是发现了有什么用？得解决问题啊！

## 三、解决问题

开发小伙伴说：那我把所有的数据库表设计，id字段由Long类型改成String类型吧。我问他你有多少张表？他说100多张吧。

- 100多张表还有100多个实体类需要改
- 还有各种使用到实体类的Service层要改
- Service等改完Controller层要改
- 关键的是String和Long都是常用类型，他还不敢批量替换

小伙伴拿起电话打算订餐，说今晚的加班是无法避免了。我想了想说：你最好别改，**String做ID查询性能会下降**，我再想想！后端A到前端B出现精度丢失，要么改前端，要么改后端，要么……  。“哎哎，你等等先别订餐，后端A到前端B你用的什么做的序列化？”  小伙伴告诉我说使用的是Jackson，这就好办了，Jackson我熟悉啊！

------

**解决思路：后端的ID(Long)  ==> Jackson(Long转String) ==> 前端使用String类型的ID,前端使用js string精度就不会丢失了。** 那前端再把String类型的19位数字传回服务端的时候，可以用Long接收么？当然可以，这是Spring反序列化参数接收默认支持的行为。

------

最终方案就是：**前端用String类型的雪花ID保持精度，后端及数据库继续使用Long(BigINT)类型不影响数据库查询执行效率。**

剩下的问题就是：在Spring Boot应用中，使用Jackson进行JSON序列化的时候怎么将Long类型ID转成String响应给前端。方案如下：

```
@Configuration
public class JacksonConfig {

  @Bean
  @Primary
  @ConditionalOnMissingBean(ObjectMapper.class)
  public ObjectMapper jacksonObjectMapper(Jackson2ObjectMapperBuilder builder)
  {
    ObjectMapper objectMapper = builder.createXmlMapper(false).build();

    // 全局配置序列化返回 JSON 处理
    SimpleModule simpleModule = new SimpleModule();
    //JSON Long ==> String
    simpleModule.addSerializer(Long.class, ToStringSerializer.instance);
    objectMapper.registerModule(simpleModule);
    return objectMapper;
  }

}
复制代码
```

小伙伴放下电话， 再次投来敬佩眼光。“走吧，一起下班！”我和小伙伴说，小伙伴一路上一直问我你是怎么学习的？我冠冕堂皇的说了一些多想多学多问之类的话。 其实我心里在想：我是一个懒人，但我不能说。能躺着绝不坐着，能自动绝不手动，能打车绝不自己开车。第一次就把事情做对，才是省时省力做好的方法！这么多年的“懒”，决定了我需要去思考更多的“捷径”，思考“捷径”的过程是我不断进阶的诀窍！ **勤奋的人是社会的生产力，而懒人是社会的创造力！**

## 欢迎关注我的博客，里面有很多精品合集

- 本文转载注明出处（必须带连接，不能只转文字）：[字母哥博客](http://www.zimug.com)。

**觉得对您有帮助的话，帮我点赞、分享！您的支持是我不竭的创作动力！** 。另外，笔者最近一段时间输出了如下的精品内容，期待您的关注。 

- [《手摸手教你学Spring Boot2.0》](https://www.kancloud.cn/hanxt/springboot2/content)
- [《Spring Security-JWT-OAuth2一本通》](https://www.kancloud.cn/hanxt/springsecurity/content)
- [《实战前后端分离RBAC权限管理系统》](https://www.kancloud.cn/hanxt/vue-spring/content)
- [《实战SpringCloud微服务从青铜到王者》](https://www.kancloud.cn/hanxt/springcloud/content)
- [《VUE深入浅出系列》](https://www.kancloud.cn/hanxt/vuejs2/content)


作者：zimug
链接：https://juejin.im/post/6864692212442398728
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。