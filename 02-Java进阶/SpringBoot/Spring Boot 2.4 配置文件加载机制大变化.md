# Spring Boot 2.4 配置文件加载机制大变化

Spring Boot 2.4.0.M2 [刚刚发布](https://spring.io/blog/2020/08/14/spring-boot-2-4-0-m2-is-now-available)，它对 `application.properties` 和 `application.yml` 文件的加载方式进行重构。如果应用程序仅使用单个 `application.properties` 或 `application.yml` 作为配置文件，那么可能感受不到任何区别。但是如果您的应用程序使用更复杂的配置（例如，Spring Cloud 配置中心等），则需要来了解更改的内容以及原因。

## 为什么要进行这些更改

随着最新版本 Spring Boot 发布，Spring 一直在努力提升对 **Kubernetes** 的原生支持。在 Spring Boot 2.3 中，官方想增加 **Kubernetes** Volume 的配置支持但是未能实现。

Volume 配置挂载是 **Kubernetes** 的一项常用功能，其中 `ConfigMap` 指令用于直接在文件系统上显示配置。您可以装载包含多个键和值合并的完整 YAML 文件，也可以使用更简单的目录树格式，其中文件名是键，文件内容是值。

希望同时提供两者的支持，并且能够兼容我们现有的 `application.properties` 和 `application.yml` 。为此需要修改 `ConfigFileApplicationListener` 类。

## ConfigFileApplicationListener 问题

在 Spring Boot 中配置文件加载类 `ConfigFileApplicationListener` 属于比较核心的底层代码，每次维护都是非常的困难。并不是因为代码编写错误或者缺少相关单元测试，而是在添加新功能时，很难解决之前存在的问题。

即：

- 配置文件非常灵活，可以在当前文件启用其他配置文件。
- 文档加载顺序不固定。

以下面的例子来说：

```yaml
security.user.password: usera
---
spring.profiles: local
security.user.password: userb
runlocal: true
---
spring.profiles: !dev
spring.profiles.include: local
security.user.password: userc

```

在这里，我们有一个 [多文档 YAML](https://juejin.im/post/https：//yaml.org/spec/1.2/spec.html#id2760395)文件（一个文件由三个逻辑文档组成，由 `---` 分隔）。

如果使用 `--spring.profile.actives=prod` 运行，那么 `security.user.password` 的值是什么？是否设置 `runlocal` 属性？中间部分文档是否包括在内，因为配置文件在处理时没有激活？

我们经常会遇到关于这个文件处理逻辑的问题，但是每当试图修复它们时，最后带来各种各样的负面问题。

因此，在 Spring boot 2.4 中对 Properties 和 YAML 文件的加载方式进行两个重大更改：

1. 文档将按定义的顺序加载。
2. profiles 激活开关不能被配置在特定环境中。

## 文档排序

从 Spring Boot 2.4 开始，加载 Properties 和 YAML 文件时候会遵循， **在文档中声明排序靠前的属性将被靠后的属性覆盖** 。

这点与 `.properties` 的排序规则相同。我们可以想一想，每次将一个 Value 放入 `Map` ，具有相同 key 的新值放入时，将替换已经存在的 Value。

同理对 Multi-document 的 YAML 文件，较低的排序也将被较高的覆盖：

```yaml
test: "value"
---
test: "overridden-value"

```

## `Properties` 文件支持多文档属性

在 Spring Boot 2.4 中， `Properties` 支持类似 YAML 多文档功能。多文档属性文件使用注释（ `#` ）后跟三个（---）破折号来分隔文档（ *选择使用注释，以使现有的 IDE 正常支持* ）。

例如，上面的 YAML 等效的 properties 为：

```plain
test=value
#---
test=overridden-value

```

## 特定环境激活配置

上述示例实际上没有任何意义,在我们开发过程中更为常见是声明某个属性仅在特定环境生效激活。

在 Spring Boot 2.3 中可以配置 `spring.profiles` 来实现。但在 Spring Boot 2.4 中 **属性更改** 为 `spring.config.activate.on-profile` 。

例如，我们想要 `test` 属性仅仅在 `dev` Profile 激活时覆盖它，则可以使用以下配置：

```yaml
test=value
#---
spring.config.activate.on-profile=dev
test=overridden-value

```

## Profile Activation

使用 `spring.profiles.active` 属性在 `application.properties` 或 `application.yaml` 文件的 **根配置文件** 来激 相关环境文件。

例如，下面这样：

```yaml
test=value
spring.profiles.active=local
#---
spring.config.activate.on-profile=dev
test=overridden value

```

不允许的是将 `spring.profiles.active` 属性与 `spring.config.activate.on-profile` 一起使用。例如，以下文件将引发异常：

```yaml
test=value
#---
spring.config.activate.on-profile=dev
spring.profiles.active=local # will fail
test=overridden value

```

通过这一新限制能使 `application.properties` 和 `application.yml` 文件更加容易理解。使得 Spring Boot 本身更易于管理和维护。

## Profile Groups

Profile Groups 是 Spring Boot 2.4 中的一项新功能，可让您将单个配置文件扩展为多个子配置文件。例如，假设有一组复杂的 `@Configuration` 类，可以使用 `@Profile` 注释有条件地启用它们。使用 `@Profile("proddb")` 开启数据库配置，使用 `@Profile("prodmq")` 开启消息配置等等。

使用多个配置文件可以使我们的代码更易于理解，但是对于部署而言并不是理想的选择。若用户需要同时激活 `proddb` ， `prodmq` ， `prodmetrics` 等。那么 Profile Groups 可让您做到这一点。

您可以在 `application.properties` 或 `application.yml` 文件中定义 `spring.profiles.group，那么开启 prod 则就相当于激活了此组的全部环境` 。例如：

```yaml
spring.profiles.group.prod=proddb,prodmq,prodmetrics

```

## Importing 扩展 Configuration

现在，我们已经解决了配置文件处理的基本问题，我们终于能够考虑我们想要提供的新功能。我们使用 Spring Boot 2.4 提供的主要功能是支持导入其他配置。

对于早期版本的 Spring Boot，很难在 `application.properties` 和 `application.yml` 之外导入其他 `properties` 或 `yaml` 文件。可以使用 `spring.config.additional-location` 属性但它可以处理的文件类型非常有限。

在 Spring Boot 2.4 可以直接在 `application.properties` 或 `application.yml` 文件中使用新的 `spring.config.import` 属性。例如希望导入一个 "忽略的 git" 的 `developer.properties` 文件，以便团队中的任何开发人员都可以快速更改属性：

```yaml
application.name=myapp
spring.config.import=developer.properties

```

甚至可以将 `spring.config.import` 与 `spring.config.activate.on-profile` 结合起来使用。例如，这里 `prod.properties` 仅在 `prod` 配置文件处于激活状态时加载：

```yaml
spring.config.activate.on-profile=prod
spring.config.import=prod.properties

```

**Import** 可以被视为在声明它们的文档下方插入的其他文档。它们 **遵循与常规多文档文件相同的自上而下的顺序：导入仅被导入一次，无论声明了多少次。**

## volume 挂载配置

导入定义使用与 URL 一样语法作为其值。如果您的位置没有前缀，则它被视为常规文件或文件夹。但是，如果您使用 `configtree:` 前缀，则告诉 Spring Boot，您将期望在该位置使用 **Kubernetes** volume 装载的配置树。

例如，您可以在 `application.properties` 配置:

```yaml
spring.config.import=configtree:/etc/config

```

如果您有以下装载的内容：

```plain
etc/
 +- config/
     +- my/
     |  +- application
     +- test

```

将在 Spring `Environment` 中拥有 `my.application` 和 `test` 属性。 `my.application` 的值是 `/etc/config/my/application` 的内容， `test` 的值是 `/etc/config/test` 的内容。

## 根据云平台类型激活

如果只希望 **Volume** 挂载的配置（或该内容的任何属性）在特 **定的云平台上** 处于激活状态，可以使用 `spring.config.activate.on-cloud-platform` 属性。它的工作方式与 `spring.config.activate.on-profile` 类似，但它使用 `CloudPlatform` 的值，而不是配置文件名称。

如果我们想要在部署到 **Kubernetes** 时启用上述配置树，我们可以执行以下操作：

```yaml
spring.config.activate.on-cloud-platform=kubernetes
spring.config.import=configtree:/etc/config

```

## 支持其他位置

`spring.config.import` 属性中指定的位置字符串是完全可插拔的，可以通过编写几个自定义类来扩展，第三方库将对自定义位置提供支持。例如，你能想到的第三方 jar 文件，例如 `archaius://…` ， `vault://…` 或 `zookeeper://…` 。

如果您有兴趣添加其他位置支持，请查看 `org.springframework.boot.context.config` 包 `ConfigDataLocationResolver` 和 `ConfigDataLoader` 的 javadoc。

## 版本回滚

正如上文所描述的，Spring Boot 针对配置文件的功能变更是非常大的。考虑到低版本的兼容性

可以设置 `spring.config.use-legacy-processing=true` 属性即可，恢复到之前版本的文件处理机制。

如果发现关于此处的问题，则需要切换到旧版处理，请 [在 GitHub 上提出问题](https://github.com/spring-projects/spring-boot/issues)，官方将尝试解决该问题。

## 总结

官方希望新的配置数据处理更加好用，并且不会引起太多升级麻烦。如果您想了解更多有关它们的信息，可以查阅更新的 [参考文档](https://docs.spring.io/spring-boot/docs/2.4.0-SNAPSHOT/reference/htmlsingle/#boot-features-external-config-files)。