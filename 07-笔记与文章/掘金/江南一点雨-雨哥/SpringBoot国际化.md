# Spring Boot 国际化踩坑指南

国际化，也叫 i18n，为啥叫这个名字呢？因为国际化英文是 internationalization ，在 i 和 n 之间有 18 个字母，所以叫 i18n。我们的应用如果做了国际化就可以在不同的语言环境下，方便的进行切换，最常见的就是中文和英文之间的切换，国际化这个功能也是相当的常见。

在 Spring 中，就通过 AcceptHeaderLocaleResolver 对国际化提供了支持，开发者通过简单配置，就可以在项目中直接使用国际化功能了。

这一支持，在 Spring Boot 中得到进一步的简化，在 Spring Boot 中，我们也可以通过寥寥数行代码就能方便的实现国际化功能，接下来松哥就来和大家说一说 Spring Boot 中的国际化。

首先，需要给大家先说明一点，项目中的国际化我们往往需要多方面的支持，例如后端做国际化、前端页面也要做国际化，共同搭配，才能真正实现国际化的功能。本文我先来和各位小伙伴们介绍 Spring Boot 中的国际化，后面我们再来介绍 Vue 的国际化，最后，再把这两个结合应用到我们的 vhr 项目中，所以前后一共可能有三篇文章，本文是第一篇。

## 1.基本使用

Spring Boot 和 Spring 一脉相承，对于国际化的支持，默认是通过 AcceptHeaderLocaleResolver 解析器来完成的，这个解析器，默认是通过请求头的 Accept-Language 字段来判断当前请求所属的环境的，进而给出合适的响应。

所以在 Spring Boot 中做国际化，这一块我们可以不用配置，直接就开搞。

首先创建一个普通的 Spring Boot 项目，添加 web 依赖即可。项目创建成功后，默认的国际化配置文件放在 resources 目录下，所以我们直接在该目录下创建四个测试文件，如下：



![img](https://user-gold-cdn.xitu.io/2020/3/5/170a83b5bb4c673c?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



- 我们的 message 文件是直接创建在 resources 目录下的，IDEA 在展示的时候，会多出一个 Resource Bundle，这个大家不用管，千万别手动去创建这个目录。
- messages.properties 这个是默认的配置，其他的则是不同语言环境下的配置，en_US 是英语(美国)，zh_CN 是中文简体，zh_TW 是中文繁体（文末附录里边有一个完整的语言简称表格）。

四个文件创建好之后，第一个默认的我们可以先空着，另外三个分别填入以下内容：

messages_zh_CN.properties

```
user.name=江南一点雨

```

messages_zh_TW.properties

```
user.name=江南壹點雨

```

messages_en_US.properties

```
user.name=javaboy

```

配置完成后，我们就可以直接开始使用了。在需要使用值的地方，直接注入 MessageSource 实例即可。

> 在 Spring 中需要配置的 MessageSource 现在不用配置了，Spring Boot 会通过 `org.springframework.boot.autoconfigure.context.MessageSourceAutoConfiguration` 自动帮我们配置一个 MessageSource 实例。

创建一个 HelloController ，内容如下：

```
@RestController
public class HelloController {
    @Autowired
    MessageSource messageSource;
    @GetMapping("/hello")
    public String hello() {
        return messageSource.getMessage("user.name", null, LocaleContextHolder.getLocale());
    }
}

```

在 HelloController 中我们可以直接注入 MessageSource 实例，然后调用该实例中的 getMessage 方法去获取变量的值，第一个参数是要获取变量的 key，第二个参数是如果 value 中有占位符，可以从这里传递参数进去，第三个参数传递一个 Locale 实例即可，这相当于当前的语言环境。

接下来我们就可以直接去调用这个接口了。

默认情况下，在接口调用时，通过请求头的 Accept-Language 来配置当前的环境，我这里通过 POSTMAN 来进行测试，结果如下：



![img](https://user-gold-cdn.xitu.io/2020/3/5/170a83b5ba3fe951?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



小伙伴们看到，我在请求头中设置了 Accept-Language 为 zh-CN，所以拿到的就是简体中文；如果我设置了 zh-TW，就会拿到繁体中文：



![img](https://user-gold-cdn.xitu.io/2020/3/5/170a83b5ccbde582?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



是不是很 Easy？

## 2.自定义切换

有的小伙伴觉得切换参数放在请求头里边好像不太方便，那么也可以自定义解析方式。例如参数可以当成普通参数放在地址栏上，通过如下配置可以实现我们的需求。

```
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
        interceptor.setParamName("lang");
        registry.addInterceptor(interceptor);
    }
    @Bean
    LocaleResolver localeResolver() {
        SessionLocaleResolver localeResolver = new SessionLocaleResolver();
        localeResolver.setDefaultLocale(Locale.SIMPLIFIED_CHINESE);
        return localeResolver;
    }
}

```

在这段配置中，我们首先提供了一个 SessionLocaleResolver 实例，这个实例会替换掉默认的 AcceptHeaderLocaleResolver，不同于 AcceptHeaderLocaleResolver 通过请求头来判断当前的环境信息，SessionLocaleResolver 将客户端的 Locale 保存到 HttpSession 对象中，并且可以进行修改（这意味着当前环境信息，前端给浏览器发送一次即可记住，只要 session 有效，浏览器就不必再次告诉服务端当前的环境信息）。

另外我们还配置了一个拦截器，这个拦截器会拦截请求中 key 为 lang 的参数（不配置的话是 locale），这个参数则指定了当前的环境信息。

好了，配置完成后，启动项目，访问方式如下：



![img](https://user-gold-cdn.xitu.io/2020/3/5/170a83b5d3c9ab3b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



我们通过在请求中添加 lang 来指定当前环境信息。这个指定只需要一次即可，也就是说，在 session 不变的情况下，下次请求可以不必带上 lang 参数，服务端已经知道当前的环境信息了。

## 3.其他自定义

默认情况下，我们的配置文件放在 resources 目录下，如果大家想自定义，也是可以的，例如定义在 resources/i18n 目录下：



![img](https://user-gold-cdn.xitu.io/2020/3/5/170a83b607e300aa?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



但是这种定义方式系统就不知道去哪里加载配置文件了，此时还需要 application.properties 中进行额外配置(注意这是一个相对路径)：

```
spring.messages.basename=i18n/messages

```

另外还有一些编码格式的配置等，内容如下：

```
spring.messages.cache-duration=3600
spring.messages.encoding=UTF-8
spring.messages.fallback-to-system-locale=true

```

spring.messages.cache-duration 表示 messages 文件的缓存失效时间，如果不配置则缓存一直有效。

spring.messages.fallback-to-system-locale 属性则略显神奇，网上竟然看不到一个明确的答案，后来翻了一会源码才看出端倪。

这个属性的作用在 `org.springframework.context.support.AbstractResourceBasedMessageSource#getDefaultLocale` 方法中生效：

```
protected Locale getDefaultLocale() {
	if (this.defaultLocale != null) {
		return this.defaultLocale;
	}
	if (this.fallbackToSystemLocale) {
		return Locale.getDefault();
	}
	return null;
}

```

从这段代码可以看出，在找不到当前系统对应的资源文件时，如果该属性为 true，则会默认查找当前系统对应的资源文件，否则就返回 null，返回 null 之后，最终又会调用到系统默认的 messages.properties 文件。

## 4.附录

搜刮了一个语言简称表，分享给各位小伙伴：

| 语言               | 简称  |
| :----------------- | :---- |
| 简体中文(中国)     | zh_CN |
| 繁体中文(中国台湾) | zh_TW |
| 繁体中文(中国香港) | zh_HK |
| 英语(中国香港)     | en_HK |
| 英语(美国)         | en_US |
| 英语(英国)         | en_GB |
| 英语(全球)         | en_WW |
| 英语(加拿大)       | en_CA |
| 英语(澳大利亚)     | en_AU |
| 英语(爱尔兰)       | en_IE |
| 英语(芬兰)         | en_FI |
| 芬兰语(芬兰)       | fi_FI |
| 英语(丹麦)         | en_DK |
| 丹麦语(丹麦)       | da_DK |
| 英语(以色列)       | en_IL |
| 希伯来语(以色列)   | he_IL |
| 英语(南非)         | en_ZA |
| 英语(印度)         | en_IN |
| 英语(挪威)         | en_NO |
| 英语(新加坡)       | en_SG |
| 英语(新西兰)       | en_NZ |
| 英语(印度尼西亚)   | en_ID |
| 英语(菲律宾)       | en_PH |
| 英语(泰国)         | en_TH |
| 英语(马来西亚)     | en_MY |
| 英语(阿拉伯)       | en_XA |
| 韩文(韩国)         | ko_KR |
| 日语(日本)         | ja_JP |
| 荷兰语(荷兰)       | nl_NL |
| 荷兰语(比利时)     | nl_BE |
| 葡萄牙语(葡萄牙)   | pt_PT |
| 葡萄牙语(巴西)     | pt_BR |
| 法语(法国)         | fr_FR |
| 法语(卢森堡)       | fr_LU |
| 法语(瑞士)         | fr_CH |
| 法语(比利时)       | fr_BE |
| 法语(加拿大)       | fr_CA |
| 西班牙语(拉丁美洲) | es_LA |
| 西班牙语(西班牙)   | es_ES |
| 西班牙语(阿根廷)   | es_AR |
| 西班牙语(美国)     | es_US |
| 西班牙语(墨西哥)   | es_MX |
| 西班牙语(哥伦比亚) | es_CO |
| 西班牙语(波多黎各) | es_PR |
| 德语(德国)         | de_DE |
| 德语(奥地利)       | de_AT |
| 德语(瑞士)         | de_CH |
| 俄语(俄罗斯)       | ru_RU |
| 意大利语(意大利)   | it_IT |
| 希腊语(希腊)       | el_GR |
| 挪威语(挪威)       | no_NO |
| 匈牙利语(匈牙利)   | hu_HU |
| 土耳其语(土耳其)   | tr_TR |
| 捷克语(捷克共和国) | cs_CZ |
| 斯洛文尼亚语       | sl_SL |
| 波兰语(波兰)       | pl_PL |
| 瑞典语(瑞典)       | sv_SE |
| 西班牙语(智利)     | es_CL |