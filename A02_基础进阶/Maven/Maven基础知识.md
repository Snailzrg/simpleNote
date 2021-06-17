[toc]



## 一：init

###  mvn clean -s  D:setting.xml

### mvn install -s  D:setting.xml



## 二：POM解释

> **POM 是 Project Object Model 的缩写，即项目对象模型。**
>
> 参考文档：[maven 官方文档之 pom](https://maven.apache.org/pom.html)

- **project** - `project` 是 pom.xml 中描述符的根。
- **modelVersion** - `modelVersion` 指定 pom.xml 符合哪个版本的描述符。maven 2 和 3 只能为 4.0.0。

一般 jar 包被识别为： `groupId:artifactId:version` 的形式。

```
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.zrgick</groupId>
    <artifactId>eureka-rule</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>eureka-rule</name>
    <description>Demo project for Spring Boot</description>
```



### 2.1: maven 坐标

**在 maven 中，根据 `groupId`、`artifactId`、`version` 组合成 `groupId:artifactId:version` 来唯一识别一个 jar 包。**

- **groupId** - 团体、组织的标识符。团体标识的约定是，它以创建这个项目的组织名称的逆向域名(reverse domain name)开头。一般对应着 java 的包结构。

- **artifactId** - 单独项目的唯一标识符。比如我们的 tomcat、commons 等。不要在 artifactId 中包含点号(.)。

- version

   \- 一个项目的特定版本。

  - maven 有自己的版本规范，一般是如下定义 major version、minor version、incremental version-qualifier ，比如 1.2.3-beta-01。要说明的是，maven 自己判断版本的算法是 major、minor、incremental 部分用数字比较，qualifier 部分用字符串比较，所以要小心 alpha-2 和 alpha-15 的比较关系，最好用 alpha-02 的格式。

  - maven 在版本管理时候可以使用几个特殊的字符串 SNAPSHOT、LATEST、RELEASE。比如 

    ```
    1.0-SNAPSHOT
    ```

    。各个部分的含义和处理逻辑如下说明：

    - **SNAPSHOT** - 这个版本一般用于开发过程中，表示不稳定的版本。
    - **LATEST** - 指某个特定构件的最新发布，这个发布可能是一个发布版，也可能是一个 snapshot 版，具体看哪个时间最后。
    - **RELEASE** ：指最后一个发布版。

- **packaging** - 项目的类型，描述了项目打包后的输出，默认是 jar。常见的输出类型为：pom, jar, maven-plugin, ejb, war, ear, rar, par。



### 2.2:  依赖配置

#### 2.2.1: dependencies

```
 <dependencies>
    <dependency>
     <groupId>org.apache.maven</groupId>
      <artifactId>maven-embedder</artifactId>
      <version>2.0</version>
      <type>jar</type>
      <scope>test</scope>
      <optional>true</optional>
      <exclusions>
        <exclusion>
          <groupId>org.apache.maven</groupId>
          <artifactId>maven-core</artifactId>
        </exclusion>
      </exclusions>
    </dependency>
    ...
  </dependencies>
```

- **groupId**, **artifactId**, **version** - 和基本配置中的 `groupId`、`artifactId`、`version` 意义相同。

- **type** - 对应 `packaging` 的类型，如果不使用 `type` 标签，maven 默认为 jar。

- scope

   \- 此元素指的是任务的类路径（编译和运行时，测试等）以及如何限制依赖关系的传递性。有 5 种可用的限定范围：

  - **compile** - 如果没有指定 `scope` 标签，maven 默认为这个范围。编译依赖关系在所有 classpath 中都可用。此外，这些依赖关系被传播到依赖项目。
  - **provided** - 与 compile 类似，但是表示您希望 jdk 或容器在运行时提供它。它只适用于编译和测试 classpath，不可传递。
  - **runtime** - 此范围表示编译不需要依赖关系，而是用于执行。它是在运行时和测试 classpath，但不是编译 classpath。
  - **test** - 此范围表示正常使用应用程序不需要依赖关系，仅适用于测试编译和执行阶段。它不是传递的。
  - **system** - 此范围与 provided 类似，除了您必须提供明确包含它的 jar。该 artifact 始终可用，并且不是在仓库中查找。

- **systemPath** - 仅当依赖范围是系统时才使用。否则，如果设置此元素，构建将失败。该路径必须是绝对路径，因此建议使用 `propertie` 来指定特定的路径，如$ {java.home} / lib。由于假定先前安装了系统范围依赖关系，maven 将不会检查项目的仓库，而是检查库文件是否存在。如果没有，maven 将会失败，并建议您手动下载安装。

- **optional** - `optional` 让其他项目知道，当您使用此项目时，您不需要这种依赖性才能正常工作。

- **exclusions** - 包含一个或多个排除元素，每个排除元素都包含一个表示要排除的依赖关系的 `groupId` 和 `artifactId`。与可选项不同，可能或可能不会安装和使用，排除主动从依赖关系树中删除自己。

#### 2.2.2: dependencyManagement

`dependencyManagement` 是表示依赖 jar 包的声明。即你在项目中的 `dependencyManagement` 下声明了依赖，maven 不会加载该依赖，`dependencyManagement` 声明可以被子 POM 继承。

`dependencyManagement` 的一个使用案例是当有父子项目的时候，父项目中可以利用 `dependencyManagement` 声明子项目中需要用到的依赖 jar 包，之后，当某个或者某几个子项目需要加载该依赖的时候，就可以在子项目中 `dependencies` 节点只配置 `groupId` 和 `artifactId` 就可以完成依赖的引用。

`dependencyManagement` 主要是为了统一管理依赖包的版本，确保所有子项目使用的版本一致，类似的还有`plugins`和`pluginManagement`。

#### 2.2.3: parent

maven 支持继承功能。子 POM 可以使用 `parent` 指定父 POM ，然后继承其配置。

```
  <parent>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>my-parent</artifactId>
    <version>2.0</version>
    <relativePath>../my-parent</relativePath>
  </parent>

```

- **relativePath** - 注意 `relativePath` 元素。在搜索本地和远程存储库之前，它不是必需的，但可以用作 maven 的指示符，以首先搜	索给定该项目父级的路径。

#### 2.2.4: modules

子模块列表

```
  <modules>
    <module>my-project</module>
    <module>another-project</module>
    <module>third-project/pom-example.xml</module>
  </modules>
```

#### 2.2.5: properties

属性列表。定义的属性可以在 pom.xml 文件中任意处使用。使用方式为 `${propertie}` 。

```
<project>
  ...
  <properties>
    <maven.compiler.source>1.7<maven.compiler.source>
    <maven.compiler.target>1.7<maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
  </properties>
  ...
</project>
```



### 2.3: 构建配置

#### 2.3.1: build

build 可以分为 "project build" 和 "profile build"。

```
  <build>...</build>

  <profiles>
    <profile>
      <!-- "Profile Build" contains a subset of "Project Build"s elements -->
      <build>...</build>
    </profile>
  </profiles>
```

基本构建配置：

```
<build>
  <defaultGoal>install</defaultGoal>
  <directory>${basedir}/target</directory>
  <finalName>${artifactId}-${version}</finalName>
  <filters>
    <filter>filters/filter1.properties</filter>
  </filters>
  ...
</build>
```

**defaultGoal** : 默认执行目标或阶段。如果给出了一个目标，它应该被定义为它在命令行中（如 jar：jar）。如果定义了一个阶段（如安装），也是如此。

**directory** ：构建时的输出路径。默认为：`${basedir}/target` 。

**finalName** ：这是项目的最终构建名称（不包括文件扩展名，例如：my-project-1.0.jar）

**filter** ：定义 `* .properties` 文件，其中包含适用于接受其设置的资源的属性列表（如下所述）。换句话说，过滤器文件中定义的“name = value”对在代码中替换$ {name}字符串。

#### 2.3.2: resources

资源的配置。资源文件通常不是代码，不需要编译，而是在项目需要捆绑使用的内容。

```
  <build>
    ...
    <resources>
      <resource>
        <targetPath>META-INF/plexus</targetPath>
        <filtering>false</filtering>
        <directory>${basedir}/src/main/plexus</directory>
        <includes>
          <include>configuration.xml</include>
        </includes>
        <excludes>
          <exclude>**/*.properties</exclude>
        </excludes>
      </resource>
    </resources>
    <testResources>
      ...
    </testResources>
    ...
  </build>
```

- **resources**: 资源元素的列表，每个资源元素描述与此项目关联的文件和何处包含文件。
- **targetPath**: 指定从构建中放置资源集的目录结构。目标路径默认为基本目录。将要包装在 jar 中的资源的通常指定的目标路径是 META-INF。
- **filtering**: 值为 true 或 false。表示是否要为此资源启用过滤。请注意，该过滤器 `* .properties` 文件不必定义为进行过滤 - 资源还可以使用默认情况下在 POM 中定义的属性（例如$ {project.version}），并将其传递到命令行中“-D”标志（例如，“-Dname = value”）或由 properties 元素显式定义。过滤文件覆盖上面。
- **directory**: 值定义了资源的路径。构建的默认目录是`${basedir}/src/main/resources`。
- **includes**: 一组文件匹配模式，指定目录中要包括的文件，使用*作为通配符。
- **excludes**: 与 `includes` 类似，指定目录中要排除的文件，使用*作为通配符。注意：如果 `include` 和 `exclude` 发生冲突，maven 会以 `exclude` 作为有效项。
- **testResources**: `testResources` 与 `resources` 功能类似，区别仅在于：`testResources` 指定的资源仅用于 test 阶段，并且其默认资源目录为：`${basedir}/src/test/resources` 。

#### 2.3.3: plugins

```
  <build>
    ...
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>2.6</version>
        <extensions>false</extensions>
        <inherited>true</inherited>
        <configuration>
          <classifier>test</classifier>
        </configuration>
        <dependencies>...</dependencies>
        <executions>...</executions>
      </plugin>
    </plugins>
  </build>
</project>
```

- **groupId**, **artifactId**, **version** ：和基本配置中的 `groupId`、`artifactId`、`version` 意义相同。
- **extensions** ：值为 true 或 false。是否加载此插件的扩展名。默认为 false。
- **inherited** ：值为 true 或 false。这个插件配置是否应该适用于继承自这个插件的 POM。默认值为 true。
- **configuration** - 这是针对个人插件的配置，这里不扩散讲解。
- **dependencies** ：这里的 `dependencies` 是插件本身所需要的依赖。
- **executions** ：需要记住的是，插件可能有多个目标。每个目标可能有一个单独的配置，甚至可能将插件的目标完全绑定到不同的阶段。执行配置插件的目标的执行。
  - **id**: 执行目标的标识。
  - **goals**: 像所有多元化的 POM 元素一样，它包含单个元素的列表。在这种情况下，这个执行块指定的插件目标列表。
  - **phase**: 这是执行目标列表的阶段。这是一个非常强大的选项，允许将任何目标绑定到构建生命周期中的任何阶段，从而改变 maven 的默认行为。
  - **inherited**: 像上面的继承元素一样，设置这个 false 会阻止 maven 将这个执行传递给它的子代。此元素仅对父 POM 有意义。
  - **configuration**: 与上述相同，但将配置限制在此特定目标列表中，而不是插件下的所有目标。

```
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-antrun-plugin</artifactId>
        <version>1.1</version>
        <executions>
          <execution>
            <id>echodir</id>
            <goals>
              <goal>run</goal>
            </goals>
            <phase>verify</phase>
            <inherited>false</inherited>
            <configuration>
              <tasks>
                <echo>Build Dir: ${project.build.directory}</echo>
              </tasks>
            </configuration>
          </execution>
        </executions>

      </plugin>
    </plugins>
  </build>
```

#### 2.3.4: pluginManagement

与 `dependencyManagement` 很相似，在当前 POM 中仅声明插件，而不是实际引入插件。子 POM 中只配置 `groupId` 和 `artifactId` 就可以完成插件的引用，且子 POM 有权重写 pluginManagement 定义。

它的目的在于统一所有子 POM 的插件版本。

#### 2.3.5: directories

```
 <build>
    <sourceDirectory>${basedir}/src/main/java</sourceDirectory>
    <scriptSourceDirectory>${basedir}/src/main/scripts</scriptSourceDirectory>
    <testSourceDirectory>${basedir}/src/test/java</testSourceDirectory>
    <outputDirectory>${basedir}/target/classes</outputDirectory>
    <testOutputDirectory>${basedir}/target/test-classes</testOutputDirectory>
    ...
  </build>
```

目录元素集合存在于 `build` 元素中，它为整个 POM 设置了各种目录结构。由于它们在配置文件构建中不存在，所以这些不能由配置文件更改。

如果上述目录元素的值设置为绝对路径（扩展属性时），则使用该目录。否则，它是相对于基础构建目录：`${basedir}`。

#### 2.3.6 extensions

扩展是在此构建中使用的 artifacts 的列表。它们将被包含在运行构建的 classpath 中。它们可以启用对构建过程的扩展（例如为 Wagon 传输机制添加一个 ftp 提供程序），并使活动的插件能够对构建生命周期进行更改。简而言之，扩展是在构建期间激活的 artifacts。扩展不需要实际执行任何操作，也不包含 Mojo。因此，扩展对于指定普通插件接口的多个实现中的一个是非常好的。

```
 <build>
    ...
    <extensions>
      <extension>
        <groupId>org.apache.maven.wagon</groupId>
        <artifactId>wagon-ftp</artifactId>
        <version>1.0-alpha-3</version>
      </extension>
    </extensions>
    ...
  </build>
```

#### 2.3.7: reporting

报告包含特定针对 `site` 生成阶段的元素。某些 maven 插件可以生成 `reporting` 元素下配置的报告，例如：生成 javadoc 报告。`reporting` 与 `build` 元素配置插件的能力相似。明显的区别在于：在执行块中插件目标的控制不是细粒度的，报表通过配置 `reportSet` 元素来精细控制。而微妙的区别在于 `reporting` 元素下的 `configuration` 元素可以用作 `build` 下的 `configuration` ，尽管相反的情况并非如此（ `build` 下的 `configuration` 不影响 `reporting` 元素下的 `configuration` ）。

另一个区别就是 `plugin` 下的 `outputDirectory` 元素。在报告的情况下，默认输出目录为 `${basedir}/target/site`。

```
  <reporting>
    <plugins>
      <plugin>
        ...
        <reportSets>
          <reportSet>
            <id>sunlink</id>
            <reports>
              <report>javadoc</report>
            </reports>
            <inherited>true</inherited>
            <configuration>
              <links>
                <link>http://java.sun.com/j2se/1.5.0/docs/api/</link>
              </links>
            </configuration>
          </reportSet>
        </reportSets>
      </plugin>
    </plugins>
  </reporting>
```

### 2.4: 项目信息

项目信息相关的这部分标签**都不是必要的**，也就是说完全可以不填写。

它的作用仅限于描述项目的详细信息。

下面的示例是项目信息相关标签的清单：

```
  <!-- 项目信息 begin -->

  <!--项目名-->
  <name>maven-notes</name>

  <!--项目描述-->
  <description>maven 学习笔记</description>

  <!--项目url-->
  <url>https://github.com/dunwu/maven-notes</url>

  <!--项目开发年份-->
  <inceptionYear>2017</inceptionYear>

  <!--开源协议-->
  <licenses>
    <license>
      <name>Apache License, Version 2.0</name>
      <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>
      <distribution>repo</distribution>
      <comments>A business-friendly OSS license</comments>
    </license>
  </licenses>

  <!--组织信息(如公司、开源组织等)-->
  <organization>
    <name>...</name>
    <url>...</url>
  </organization>

  <!--开发者列表-->
  <developers>
    <developer>
      <id>victor</id>
      <name>Zhang Peng</name>
      <email>forbreak at 163.com</email>
      <url>https://github.com/dunwu</url>
      <organization>...</organization>
      <organizationUrl>...</organizationUrl>
      <roles>
        <role>architect</role>
        <role>developer</role>
      </roles>
      <timezone>+8</timezone>
      <properties>...</properties>
    </developer>
  </developers>

  <!--代码贡献者列表-->
   <contributors>
    <contributor>
      <!--标签内容和<developer>相同-->
    </contributor>
  </contributors>

  <!-- 项目信息 end -->

  ...
```

这部分标签都非常简单，基本都能做到顾名思义，且都属于可有可无的标签，所以这里仅简单介绍一下：

- **name** - 项目完整名称
- **description** - 项目描述
- **url** - 一般为项目仓库的 host
- **inceptionYear** - 开发年份
- **licenses** - 开源协议
- **organization** - 项目所属组织信息
- **developers** - 项目开发者列表
- **contributors** - 项目贡献者列表，`<contributor>` 的子标签和 `<developer>` 的完全相同。



### 2.5: 环境配置

#### 2.5.1: issueManagement

这定义了所使用的缺陷跟踪系统（Bugzilla，TestTrack，ClearQuest 等）。虽然没有什么可以阻止插件使用这些信息的东西，但它主要用于生成项目文档。

```
  <issueManagement>
    <system>Bugzilla</system>
    <url>http://127.0.0.1/bugzilla/</url>
  </issueManagement>
```

#### 2.5.2: ciManagement

CI 构建系统配置，主要是指定通知机制以及被通知的邮箱。

```
  <ciManagement>
    <system>continuum</system>
    <url>http://127.0.0.1:8080/continuum</url>
    <notifiers>
      <notifier>
        <type>mail</type>
        <sendOnError>true</sendOnError>
        <sendOnFailure>true</sendOnFailure>
        <sendOnSuccess>false</sendOnSuccess>
        <sendOnWarning>false</sendOnWarning>
        <configuration><address>continuum@127.0.0.1</address></configuration>
      </notifier>
    </notifiers>
  </ciManagement>
```

#### 2.5.3: mailingLists

邮件列表

```
  <mailingLists>
    <mailingList>
      <name>User List</name>
      <subscribe>user-subscribe@127.0.0.1</subscribe>
      <unsubscribe>user-unsubscribe@127.0.0.1</unsubscribe>
      <post>user@127.0.0.1</post>
      <archive>http://127.0.0.1/user/</archive>
      <otherArchives>
        <otherArchive>http://base.google.com/base/1/127.0.0.1</otherArchive>
      </otherArchives>
    </mailingList>
  </mailingLists>
```

#### 2.5.3: scm

SCM（软件配置管理，也称为源代码/控制管理或简洁的版本控制）。常见的 scm 有 svn 和 git 。

```
  <scm>
    <connection>scm:svn:http://127.0.0.1/svn/my-project</connection>
    <developerConnection>scm:svn:https://127.0.0.1/svn/my-project</developerConnection>
    <tag>HEAD</tag>
    <url>http://127.0.0.1/websvn/my-project</url>
  </scm>
```

#### 2.5.4: prerequisites

POM 执行的预设条件。

```
  <prerequisites>
    <maven>2.0.6</maven>
  </prerequisites>
```

#### 2.5.5: repositories

`repositories` 是遵循 Maven 存储库目录布局的 artifacts 集合。默认的 Maven 中央存储库位于https://repo.maven.apache.org/maven2/上。

```
  <repositories>
    <repository>
      <releases>
        <enabled>false</enabled>
        <updatePolicy>always</updatePolicy>
        <checksumPolicy>warn</checksumPolicy>
      </releases>
      <snapshots>
        <enabled>true</enabled>
        <updatePolicy>never</updatePolicy>
        <checksumPolicy>fail</checksumPolicy>
      </snapshots>
      <id>codehausSnapshots</id>
      <name>Codehaus Snapshots</name>
      <url>http://snapshots.maven.codehaus.org/maven2</url>
      <layout>default</layout>
    </repository>
  </repositories>
  <pluginRepositories>
    ...
  </pluginRepositories>
```

#### 2.5.6: pluginRepositories

与 `repositories` 差不多。

```
  <distributionManagement>
    ...
    <downloadUrl>http://mojo.codehaus.org/my-project</downloadUrl>
    <status>deployed</status>
  </distributionManagement>
```

#### 2.5.7: distributionManagement

它管理在整个构建过程中生成的 artifact 和支持文件的分布。从最后的元素开始：

```
  <distributionManagement>
    ...
    <downloadUrl>http://mojo.codehaus.org/my-project</downloadUrl>
    <status>deployed</status>
  </distributionManagement>
```

- **repository** - 与 `repositories` 相似
- **site** - 站点信息
- **relocation** - 项目迁移位置

#### 2.5.8: profiles

`activation` 是一个 `profile` 的关键。配置文件的功能来自于在某些情况下仅修改基本 POM 的功能。这些情况通过 `activation` 元素指定。

```
  <profiles>
    <profile>
      <id>test</id>
      <activation>
        <activeByDefault>false</activeByDefault>
        <jdk>1.5</jdk>
        <os>
          <name>Windows XP</name>
          <family>Windows</family>
          <arch>x86</arch>
          <version>5.1.2600</version>
        </os>
        <property>
          <name>sparrow-type</name>
          <value>African</value>
        </property>
        <file>
          <exists>${basedir}/file2.properties</exists>
          <missing>${basedir}/file1.properties</missing>
        </file>
      </activation>
      ...
    </profile>
  </profiles>
```



## 三：maven scope属性值设置含义

1、枚举各个属性值的含义

compile，缺省值，适用于所有阶段，会打包进项目。
provided，类似compile，期望JDK、容器或使用者会提供这个依赖。
runtime，只在运行时使用，如JDBC驱动，适用运行和测试阶段。
test，只在测试时使用，用于编译和运行测试代码。不会随项目发布。
system，类似provided，需要显式提供包含依赖的jar，Maven不会在Repository中查找它。
2、其它类型的属性值都比较容易理解，这里重点比较一下compile和runtime之间的区别：

（1）先描述一个简单的例子：模块A依赖X，此时X的scope设置的值为runtime;

（2）另一模块B依赖A，则B在编译时不会依赖X（编译时不会有任何问题）;

如果原先X的scope设置为compile，则说明在编译的时B需要显示的调用X的相关类，在maven依赖中最常见的设置为runtime的依赖是JDBC，主要原因是由于jdbc中对驱动类的配置是采用反射的机制在配置文件中配置了class-name;





## 四：后记（pom详解）

>

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0http://maven.apache.org/maven-v4_0_0.xsd">
    <!--父项目的坐标。如果项目中没有规定某个元素的值，那么父项目中的对应值即为项目的默认值。 坐标包括group ID，artifact ID和 version。-->
    <parent>
        <!--被继承的父项目的构件标识符-->
        <artifactId/>
        <!--被继承的父项目的全球唯一标识符-->
        <groupId/>
        <!--被继承的父项目的版本-->
        <version/>
        <!-- 父项目的pom.xml文件的相对路径。相对路径允许你选择一个不同的路径。默认值是../pom.xml。Maven首先在构建当前项目的地方寻找父项 目的pom，其次在文件系统的这个位置（relativePath位置），然后在本地仓库，最后在远程仓库寻找父项目的pom。-->
        <relativePath/>
    </parent>
    <!--声明项目描述符遵循哪一个POM模型版本。模型本身的版本很少改变，虽然如此，但它仍然是必不可少的，这是为了当Maven引入了新的特性或者其他模型变更的时候，确保稳定性。-->
    <modelVersion>4.0.0</modelVersion>
    <!--项目的全球唯一标识符，通常使用全限定的包名区分该项目和其他项目。并且构建时生成的路径也是由此生成， 如com.mycompany.app生成的相对路径为：/com/mycompany/app-->
    <groupId>asia.banseon</groupId>
    <!-- 构件的标识符，它和group ID一起唯一标识一个构件。换句话说，你不能有两个不同的项目拥有同样的artifact ID和groupID；在某个 特定的group ID下，artifact ID也必须是唯一的。构件是项目产生的或使用的一个东西，Maven为项目产生的构件包括：JARs，源 码，二进制发布和WARs等。-->
    <artifactId>banseon-maven2</artifactId>
    <!--项目产生的构件类型，例如jar、war、ear、pom。插件可以创建他们自己的构件类型，所以前面列的不是全部构件类型-->
    <packaging>jar</packaging>
    <!--项目当前版本，格式为:主版本.次版本.增量版本-限定版本号-->
    <version>1.0-SNAPSHOT</version>
    <!--项目的名称, Maven产生的文档用-->
    <name>banseon-maven</name>
    <!--项目主页的URL, Maven产生的文档用-->
    <url>http://www.baidu.com/banseon</url>
    <!-- 项目的详细描述, Maven 产生的文档用。  当这个元素能够用HTML格式描述时（例如，CDATA中的文本会被解析器忽略，就可以包含HTML标 签）， 不鼓励使用纯文本描述。如果你需要修改产生的web站点的索引页面，你应该修改你自己的索引页文件，而不是调整这里的文档。-->
    <description>A maven project to study maven.</description>
    <!--描述了这个项目构建环境中的前提条件。-->
    <prerequisites>
        <!--构建该项目或使用该插件所需要的Maven的最低版本-->
        <maven/>
    </prerequisites>
    <!--项目的问题管理系统(Bugzilla, Jira, Scarab,或任何你喜欢的问题管理系统)的名称和URL，本例为 jira-->
    <issueManagement>
        <!--问题管理系统（例如jira）的名字，-->
        <system>jira</system>
        <!--该项目使用的问题管理系统的URL-->
        <url>http://jira.baidu.com/banseon</url>
    </issueManagement>
    <!--项目持续集成信息-->
    <ciManagement>
        <!--持续集成系统的名字，例如continuum-->
        <system/>
        <!--该项目使用的持续集成系统的URL（如果持续集成系统有web接口的话）。-->
        <url/>
        <!--构建完成时，需要通知的开发者/用户的配置项。包括被通知者信息和通知条件（错误，失败，成功，警告）-->
        <notifiers>
            <!--配置一种方式，当构建中断时，以该方式通知用户/开发者-->
            <notifier>
                <!--传送通知的途径-->
                <type/>
                <!--发生错误时是否通知-->
                <sendOnError/>
                <!--构建失败时是否通知-->
                <sendOnFailure/>
                <!--构建成功时是否通知-->
                <sendOnSuccess/>
                <!--发生警告时是否通知-->
                <sendOnWarning/>
                <!--不赞成使用。通知发送到哪里-->
                <address/>
                <!--扩展配置项-->
                <configuration/>
            </notifier>
        </notifiers>
    </ciManagement>
    <!--项目创建年份，4位数字。当产生版权信息时需要使用这个值。-->
    <inceptionYear/>
    <!--项目相关邮件列表信息-->
    <mailingLists>
        <!--该元素描述了项目相关的所有邮件列表。自动产生的网站引用这些信息。-->
        <mailingList>
            <!--邮件的名称-->
            <name>Demo</name>
            <!--发送邮件的地址或链接，如果是邮件地址，创建文档时，mailto: 链接会被自动创建-->
            <post>banseon@126.com</post>
            <!--订阅邮件的地址或链接，如果是邮件地址，创建文档时，mailto: 链接会被自动创建-->
            <subscribe>banseon@126.com</subscribe>
            <!--取消订阅邮件的地址或链接，如果是邮件地址，创建文档时，mailto: 链接会被自动创建-->
            <unsubscribe>banseon@126.com</unsubscribe>
            <!--你可以浏览邮件信息的URL-->
            <archive>http:/hi.baidu.com/banseon/demo/dev/</archive>
        </mailingList>
    </mailingLists>
    <!--项目开发者列表-->
    <developers>
        <!--某个项目开发者的信息-->
        <developer>
            <!--SCM里项目开发者的唯一标识符-->
            <id>HELLO WORLD</id>
            <!--项目开发者的全名-->
            <name>banseon</name>
            <!--项目开发者的email-->
            <email>banseon@126.com</email>
            <!--项目开发者的主页的URL-->
            <url/>
            <!--项目开发者在项目中扮演的角色，角色元素描述了各种角色-->
            <roles>
                <role>Project Manager</role>
                <role>Architect</role>
            </roles>
            <!--项目开发者所属组织-->
            <organization>demo</organization>
            <!--项目开发者所属组织的URL-->
            <organizationUrl>http://hi.baidu.com/banseon</organizationUrl>
            <!--项目开发者属性，如即时消息如何处理等-->
            <properties>
                <dept>No</dept>
            </properties>
            <!--项目开发者所在时区， -11到12范围内的整数。-->
            <timezone>-5</timezone>
        </developer>
    </developers>
    <!--项目的其他贡献者列表-->
    <contributors>
        <!--项目的其他贡献者。参见developers/developer元素-->
        <contributor>
            <name/><email/><url/><organization/><organizationUrl/><roles/><timezone/><properties/>
        </contributor>
    </contributors>
    <!--该元素描述了项目所有License列表。 应该只列出该项目的license列表，不要列出依赖项目的 license列表。如果列出多个license，用户可以选择它们中的一个而不是接受所有license。-->
    <licenses>
        <!--描述了项目的license，用于生成项目的web站点的license页面，其他一些报表和validation也会用到该元素。-->
        <license>
            <!--license用于法律上的名称-->
            <name>Apache 2</name>
            <!--官方的license正文页面的URL-->
            <url>http://www.baidu.com/banseon/LICENSE-2.0.txt</url>
            <!--项目分发的主要方式：
              repo，可以从Maven库下载
              manual， 用户必须手动下载和安装依赖-->
            <distribution>repo</distribution>
            <!--关于license的补充信息-->
            <comments>A business-friendly OSS license</comments>
        </license>
    </licenses>
    <!--SCM(Source Control Management)标签允许你配置你的代码库，供Maven web站点和其它插件使用。-->
    <scm>
        <!--SCM的URL,该URL描述了版本库和如何连接到版本库。欲知详情，请看SCMs提供的URL格式和列表。该连接只读。-->
        <connection>
            scm:svn:http://svn.baidu.com/banseon/maven/banseon/banseon-maven2-trunk(dao-trunk)
        </connection>
        <!--给开发者使用的，类似connection元素。即该连接不仅仅只读-->
        <developerConnection>
            scm:svn:http://svn.baidu.com/banseon/maven/banseon/dao-trunk
        </developerConnection>
        <!--当前代码的标签，在开发阶段默认为HEAD-->
        <tag/>
        <!--指向项目的可浏览SCM库（例如ViewVC或者Fisheye）的URL。-->
        <url>http://svn.baidu.com/banseon</url>
    </scm>
    <!--描述项目所属组织的各种属性。Maven产生的文档用-->
    <organization>
        <!--组织的全名-->
        <name>demo</name>
        <!--组织主页的URL-->
        <url>http://www.baidu.com/banseon</url>
    </organization>
    <!--构建项目需要的信息-->
    <build>
        <!--该元素设置了项目源码目录，当构建项目的时候，构建系统会编译目录里的源码。该路径是相对于pom.xml的相对路径。-->
        <sourceDirectory/>
        <!--该元素设置了项目脚本源码目录，该目录和源码目录不同：绝大多数情况下，该目录下的内容 会被拷贝到输出目录(因为脚本是被解释的，而不是被编译的)。-->
        <scriptSourceDirectory/>
        <!--该元素设置了项目单元测试使用的源码目录，当测试项目的时候，构建系统会编译目录里的源码。该路径是相对于pom.xml的相对路径。-->
        <testSourceDirectory/>
        <!--被编译过的应用程序class文件存放的目录。-->
        <outputDirectory/>
        <!--被编译过的测试class文件存放的目录。-->
        <testOutputDirectory/>
        <!--使用来自该项目的一系列构建扩展-->
        <extensions>
            <!--描述使用到的构建扩展。-->
            <extension>
                <!--构建扩展的groupId-->
                <groupId/>
                <!--构建扩展的artifactId-->
                <artifactId/>
                <!--构建扩展的版本-->
                <version/>
            </extension>
        </extensions>
        <!--当项目没有规定目标（Maven2 叫做阶段）时的默认值-->
        <defaultGoal/>
        <!--这个元素描述了项目相关的所有资源路径列表，例如和项目相关的属性文件，这些资源被包含在最终的打包文件里。-->
        <resources>
            <!--这个元素描述了项目相关或测试相关的所有资源路径-->
            <resource>
                <!-- 描述了资源的目标路径。该路径相对target/classes目录（例如${project.build.outputDirectory}）。举个例 子，如果你想资源在特定的包里(org.apache.maven.messages)，你就必须该元素设置为org/apache/maven /messages。然而，如果你只是想把资源放到源码目录结构里，就不需要该配置。-->
                <targetPath/>
                <!--是否使用参数值代替参数名。参数值取自properties元素或者文件里配置的属性，文件在filters元素里列出。-->
                <filtering/>
                <!--描述存放资源的目录，该路径相对POM路径-->
                <directory/>
                <!--包含的模式列表，例如**/*.xml.-->
                <includes/>
                <!--排除的模式列表，例如**/*.xml-->
                <excludes/>
            </resource>
        </resources>
        <!--这个元素描述了单元测试相关的所有资源路径，例如和单元测试相关的属性文件。-->
        <testResources>
            <!--这个元素描述了测试相关的所有资源路径，参见build/resources/resource元素的说明-->
            <testResource>
                <targetPath/><filtering/><directory/><includes/><excludes/>
            </testResource>
        </testResources>
        <!--构建产生的所有文件存放的目录-->
        <directory/>
        <!--产生的构件的文件名，默认值是${artifactId}-${version}。-->
        <finalName/>
        <!--当filtering开关打开时，使用到的过滤器属性文件列表-->
        <filters/>
        <!--子项目可以引用的默认插件信息。该插件配置项直到被引用时才会被解析或绑定到生命周期。给定插件的任何本地配置都会覆盖这里的配置-->
        <pluginManagement>
            <!--使用的插件列表 。-->
            <plugins>
                <!--plugin元素包含描述插件所需要的信息。-->
                <plugin>
                    <!--插件在仓库里的group ID-->
                    <groupId/>
                    <!--插件在仓库里的artifact ID-->
                    <artifactId/>
                    <!--被使用的插件的版本（或版本范围）-->
                    <version/>
                    <!--是否从该插件下载Maven扩展（例如打包和类型处理器），由于性能原因，只有在真需要下载时，该元素才被设置成enabled。-->
                    <extensions/>
                    <!--在构建生命周期中执行一组目标的配置。每个目标可能有不同的配置。-->
                    <executions>
                        <!--execution元素包含了插件执行需要的信息-->
                        <execution>
                            <!--执行目标的标识符，用于标识构建过程中的目标，或者匹配继承过程中需要合并的执行目标-->
                            <id/>
                            <!--绑定了目标的构建生命周期阶段，如果省略，目标会被绑定到源数据里配置的默认阶段-->
                            <phase/>
                            <!--配置的执行目标-->
                            <goals/>
                            <!--配置是否被传播到子POM-->
                            <inherited/>
                            <!--作为DOM对象的配置-->
                            <configuration/>
                        </execution>
                    </executions>
                    <!--项目引入插件所需要的额外依赖-->
                    <dependencies>
                        <!--参见dependencies/dependency元素-->
                        <dependency>
                            ......
                        </dependency>
                    </dependencies>
                    <!--任何配置是否被传播到子项目-->
                    <inherited/>
                    <!--作为DOM对象的配置-->
                    <configuration/>
                </plugin>
            </plugins>
        </pluginManagement>
        <!--使用的插件列表-->
        <plugins>
            <!--参见build/pluginManagement/plugins/plugin元素-->
            <plugin>
                <groupId/><artifactId/><version/><extensions/>
                <executions>
                    <execution>
                        <id/><phase/><goals/><inherited/><configuration/>
                    </execution>
                </executions>
                <dependencies>
                    <!--参见dependencies/dependency元素-->
                    <dependency>
                        ......
                    </dependency>
                </dependencies>
                <goals/><inherited/><configuration/>
            </plugin>
        </plugins>
    </build>
    <!--在列的项目构建profile，如果被激活，会修改构建处理-->
    <profiles>
        <!--根据环境参数或命令行参数激活某个构建处理-->
        <profile>
            <!--构建配置的唯一标识符。即用于命令行激活，也用于在继承时合并具有相同标识符的profile。-->
            <id/>
            <!--自动触发profile的条件逻辑。Activation是profile的开启钥匙。profile的力量来自于它
            能够在某些特定的环境中自动使用某些特定的值；这些环境通过activation元素指定。activation元素并不是激活profile的唯一方式。-->
            <activation>
                <!--profile默认是否激活的标志-->
                <activeByDefault/>
                <!--当匹配的jdk被检测到，profile被激活。例如，1.4激活JDK1.4，1.4.0_2，而!1.4激活所有版本不是以1.4开头的JDK。-->
                <jdk/>
                <!--当匹配的操作系统属性被检测到，profile被激活。os元素可以定义一些操作系统相关的属性。-->
                <os>
                    <!--激活profile的操作系统的名字-->
                    <name>Windows XP</name>
                    <!--激活profile的操作系统所属家族(如 'windows')-->
                    <family>Windows</family>
                    <!--激活profile的操作系统体系结构 -->
                    <arch>x86</arch>
                    <!--激活profile的操作系统版本-->
                    <version>5.1.2600</version>
                </os>
                <!--如果Maven检测到某一个属性（其值可以在POM中通过${名称}引用），其拥有对应的名称和值，Profile就会被激活。如果值
                字段是空的，那么存在属性名称字段就会激活profile，否则按区分大小写方式匹配属性值字段-->
                <property>
                    <!--激活profile的属性的名称-->
                    <name>mavenVersion</name>
                    <!--激活profile的属性的值-->
                    <value>2.0.3</value>
                </property>
                <!--提供一个文件名，通过检测该文件的存在或不存在来激活profile。missing检查文件是否存在，如果不存在则激活
                profile。另一方面，exists则会检查文件是否存在，如果存在则激活profile。-->
                <file>
                    <!--如果指定的文件存在，则激活profile。-->
                    <exists>/usr/local/hudson/hudson-home/jobs/maven-guide-zh-to-production/workspace/</exists>
                    <!--如果指定的文件不存在，则激活profile。-->
                    <missing>/usr/local/hudson/hudson-home/jobs/maven-guide-zh-to-production/workspace/</missing>
                </file>
            </activation>
            <!--构建项目所需要的信息。参见build元素-->
            <build>
                <defaultGoal/>
                <resources>
                    <resource>
                        <targetPath/><filtering/><directory/><includes/><excludes/>
                    </resource>
                </resources>
                <testResources>
                    <testResource>
                        <targetPath/><filtering/><directory/><includes/><excludes/>
                    </testResource>
                </testResources>
                <directory/><finalName/><filters/>
                <pluginManagement>
                    <plugins>
                        <!--参见build/pluginManagement/plugins/plugin元素-->
                        <plugin>
                            <groupId/><artifactId/><version/><extensions/>
                            <executions>
                                <execution>
                                    <id/><phase/><goals/><inherited/><configuration/>
                                </execution>
                            </executions>
                            <dependencies>
                                <!--参见dependencies/dependency元素-->
                                <dependency>
                                    ......
                                </dependency>
                            </dependencies>
                            <goals/><inherited/><configuration/>
                        </plugin>
                    </plugins>
                </pluginManagement>
                <plugins>
                    <!--参见build/pluginManagement/plugins/plugin元素-->
                    <plugin>
                        <groupId/><artifactId/><version/><extensions/>
                        <executions>
                            <execution>
                                <id/><phase/><goals/><inherited/><configuration/>
                            </execution>
                        </executions>
                        <dependencies>
                            <!--参见dependencies/dependency元素-->
                            <dependency>
                                ......
                            </dependency>
                        </dependencies>
                        <goals/><inherited/><configuration/>
                    </plugin>
                </plugins>
            </build>
            <!--模块（有时称作子项目） 被构建成项目的一部分。列出的每个模块元素是指向该模块的目录的相对路径-->
            <modules/>
            <!--发现依赖和扩展的远程仓库列表。-->
            <repositories>
                <!--参见repositories/repository元素-->
                <repository>
                    <releases>
                        <enabled/><updatePolicy/><checksumPolicy/>
                    </releases>
                    <snapshots>
                        <enabled/><updatePolicy/><checksumPolicy/>
                    </snapshots>
                    <id/><name/><url/><layout/>
                </repository>
            </repositories>
            <!--发现插件的远程仓库列表，这些插件用于构建和报表-->
            <pluginRepositories>
                <!--包含需要连接到远程插件仓库的信息.参见repositories/repository元素-->
                <pluginRepository>
                    <releases>
                        <enabled/><updatePolicy/><checksumPolicy/>
                    </releases>
                    <snapshots>
                        <enabled/><updatePolicy/><checksumPolicy/>
                    </snapshots>
                    <id/><name/><url/><layout/>
                </pluginRepository>
            </pluginRepositories>
            <!--该元素描述了项目相关的所有依赖。 这些依赖组成了项目构建过程中的一个个环节。它们自动从项目定义的仓库中下载。要获取更多信息，请看项目依赖机制。-->
            <dependencies>
                <!--参见dependencies/dependency元素-->
                <dependency>
                    ......
                </dependency>
            </dependencies>
            <!--不赞成使用. 现在Maven忽略该元素.-->
            <reports/>
            <!--该元素包括使用报表插件产生报表的规范。当用户执行“mvn site”，这些报表就会运行。 在页面导航栏能看到所有报表的链接。参见reporting元素-->
            <reporting>
                ......
            </reporting>
            <!--参见dependencyManagement元素-->
            <dependencyManagement>
                <dependencies>
                    <!--参见dependencies/dependency元素-->
                    <dependency>
                        ......
                    </dependency>
                </dependencies>
            </dependencyManagement>
            <!--参见distributionManagement元素-->
            <distributionManagement>
                ......
            </distributionManagement>
            <!--参见properties元素-->
            <properties/>
        </profile>
    </profiles>
    <!--模块（有时称作子项目） 被构建成项目的一部分。列出的每个模块元素是指向该模块的目录的相对路径-->
    <modules/>
    <!--发现依赖和扩展的远程仓库列表。-->
    <repositories>
        <!--包含需要连接到远程仓库的信息-->
        <repository>
            <!--如何处理远程仓库里发布版本的下载-->
            <releases>
                <!--true或者false表示该仓库是否为下载某种类型构件（发布版，快照版）开启。 -->
                <enabled/>
                <!--该元素指定更新发生的频率。Maven会比较本地POM和远程POM的时间戳。这里的选项是：always（一直），daily（默认，每日），interval：X（这里X是以分钟为单位的时间间隔），或者never（从不）。-->
                <updatePolicy/>
                <!--当Maven验证构件校验文件失败时该怎么做：ignore（忽略），fail（失败），或者warn（警告）。-->
                <checksumPolicy/>
            </releases>
            <!-- 如何处理远程仓库里快照版本的下载。有了releases和snapshots这两组配置，POM就可以在每个单独的仓库中，为每种类型的构件采取不同的 策略。例如，可能有人会决定只为开发目的开启对快照版本下载的支持。参见repositories/repository/releases元素 -->
            <snapshots>
                <enabled/><updatePolicy/><checksumPolicy/>
            </snapshots>
            <!--远程仓库唯一标识符。可以用来匹配在settings.xml文件里配置的远程仓库-->
            <id>banseon-repository-proxy</id>
            <!--远程仓库名称-->
            <name>banseon-repository-proxy</name>
            <!--远程仓库URL，按protocol://hostname/path形式-->
            <url>http://192.168.1.169:9999/repository/</url>
            <!-- 用于定位和排序构件的仓库布局类型-可以是default（默认）或者legacy（遗留）。Maven 2为其仓库提供了一个默认的布局；然 而，Maven 1.x有一种不同的布局。我们可以使用该元素指定布局是default（默认）还是legacy（遗留）。-->
            <layout>default</layout>
        </repository>
    </repositories>
    <!--发现插件的远程仓库列表，这些插件用于构建和报表-->
    <pluginRepositories>
        <!--包含需要连接到远程插件仓库的信息.参见repositories/repository元素-->
        <pluginRepository>
            ......
        </pluginRepository>
    </pluginRepositories>
 
    <!--该元素描述了项目相关的所有依赖。 这些依赖组成了项目构建过程中的一个个环节。它们自动从项目定义的仓库中下载。要获取更多信息，请看项目依赖机制。-->
    <dependencies>
        <dependency>
            <!--依赖的group ID-->
            <groupId>org.apache.maven</groupId>
            <!--依赖的artifact ID-->
            <artifactId>maven-artifact</artifactId>
            <!--依赖的版本号。 在Maven 2里, 也可以配置成版本号的范围。-->
            <version>3.8.1</version>
            <!-- 依赖类型，默认类型是jar。它通常表示依赖的文件的扩展名，但也有例外。一个类型可以被映射成另外一个扩展名或分类器。类型经常和使用的打包方式对应， 尽管这也有例外。一些类型的例子：jar，war，ejb-client和test-jar。如果设置extensions为 true，就可以在 plugin里定义新的类型。所以前面的类型的例子不完整。-->
            <type>jar</type>
            <!-- 依赖的分类器。分类器可以区分属于同一个POM，但不同构建方式的构件。分类器名被附加到文件名的版本号后面。例如，如果你想要构建两个单独的构件成 JAR，一个使用Java 1.4编译器，另一个使用Java 6编译器，你就可以使用分类器来生成两个单独的JAR构件。-->
            <classifier></classifier>
            <!--依赖范围。在项目发布过程中，帮助决定哪些构件被包括进来。欲知详情请参考依赖机制。
                - compile ：默认范围，用于编译
                - provided：类似于编译，但支持你期待jdk或者容器提供，类似于classpath
                - runtime: 在执行时需要使用
                - test:    用于test任务时使用
                - system: 需要外在提供相应的元素。通过systemPath来取得
                - systemPath: 仅用于范围为system。提供相应的路径
                - optional:   当项目自身被依赖时，标注依赖是否传递。用于连续依赖时使用-->
            <scope>test</scope>
            <!--仅供system范围使用。注意，不鼓励使用这个元素，并且在新的版本中该元素可能被覆盖掉。该元素为依赖规定了文件系统上的路径。需要绝对路径而不是相对路径。推荐使用属性匹配绝对路径，例如${java.home}。-->
            <systemPath></systemPath>
            <!--当计算传递依赖时， 从依赖构件列表里，列出被排除的依赖构件集。即告诉maven你只依赖指定的项目，不依赖项目的依赖。此元素主要用于解决版本冲突问题-->
            <exclusions>
                <exclusion>
                    <artifactId>spring-core</artifactId>
                    <groupId>org.springframework</groupId>
                </exclusion>
            </exclusions>
            <!--可选依赖，如果你在项目B中把C依赖声明为可选，你就需要在依赖于B的项目（例如项目A）中显式的引用对C的依赖。可选依赖阻断依赖的传递性。-->
            <optional>true</optional>
        </dependency>
    </dependencies>
    <!--不赞成使用. 现在Maven忽略该元素.-->
    <reports></reports>
    <!--该元素描述使用报表插件产生报表的规范。当用户执行“mvn site”，这些报表就会运行。 在页面导航栏能看到所有报表的链接。-->
    <reporting>
        <!--true，则，网站不包括默认的报表。这包括“项目信息”菜单中的报表。-->
        <excludeDefaults/>
        <!--所有产生的报表存放到哪里。默认值是${project.build.directory}/site。-->
        <outputDirectory/>
        <!--使用的报表插件和他们的配置。-->
        <plugins>
            <!--plugin元素包含描述报表插件需要的信息-->
            <plugin>
                <!--报表插件在仓库里的group ID-->
                <groupId/>
                <!--报表插件在仓库里的artifact ID-->
                <artifactId/>
                <!--被使用的报表插件的版本（或版本范围）-->
                <version/>
                <!--任何配置是否被传播到子项目-->
                <inherited/>
                <!--报表插件的配置-->
                <configuration/>
                <!--一组报表的多重规范，每个规范可能有不同的配置。一个规范（报表集）对应一个执行目标 。例如，有1，2，3，4，5，6，7，8，9个报表。1，2，5构成A报表集，对应一个执行目标。2，5，8构成B报表集，对应另一个执行目标-->
                <reportSets>
                    <!--表示报表的一个集合，以及产生该集合的配置-->
                    <reportSet>
                        <!--报表集合的唯一标识符，POM继承时用到-->
                        <id/>
                        <!--产生报表集合时，被使用的报表的配置-->
                        <configuration/>
                        <!--配置是否被继承到子POMs-->
                        <inherited/>
                        <!--这个集合里使用到哪些报表-->
                        <reports/>
                    </reportSet>
                </reportSets>
            </plugin>
        </plugins>
    </reporting>
    <!-- 继承自该项目的所有子项目的默认依赖信息。这部分的依赖信息不会被立即解析,而是当子项目声明一个依赖（必须描述group ID和 artifact ID信息），如果group ID和artifact ID以外的一些信息没有描述，则通过group ID和artifact ID 匹配到这里的依赖，并使用这里的依赖信息。-->
    <dependencyManagement>
        <dependencies>
            <!--参见dependencies/dependency元素-->
            <dependency>
                ......
            </dependency>
        </dependencies>
    </dependencyManagement>
    <!--项目分发信息，在执行mvn deploy后表示要发布的位置。有了这些信息就可以把网站部署到远程服务器或者把构件部署到远程仓库。-->
    <distributionManagement>
        <!--部署项目产生的构件到远程仓库需要的信息-->
        <repository>
            <!--是分配给快照一个唯一的版本号（由时间戳和构建流水号）？还是每次都使用相同的版本号？参见repositories/repository元素-->
            <uniqueVersion/>
            <id>banseon-maven2</id>
            <name>banseon maven2</name>
            <url>file://${basedir}/target/deploy</url>
            <layout/>
        </repository>
        <!--构件的快照部署到哪里？如果没有配置该元素，默认部署到repository元素配置的仓库，参见distributionManagement/repository元素-->
        <snapshotRepository>
            <uniqueVersion/>
            <id>banseon-maven2</id>
            <name>Banseon-maven2 Snapshot Repository</name>
            <url>scp://svn.baidu.com/banseon:/usr/local/maven-snapshot</url>
            <layout/>
        </snapshotRepository>
        <!--部署项目的网站需要的信息-->
        <site>
            <!--部署位置的唯一标识符，用来匹配站点和settings.xml文件里的配置-->
            <id>banseon-site</id>
            <!--部署位置的名称-->
            <name>business api website</name>
            <!--部署位置的URL，按protocol://hostname/path形式-->
            <url>
                scp://svn.baidu.com/banseon:/var/www/localhost/banseon-web
            </url>
        </site>
        <!--项目下载页面的URL。如果没有该元素，用户应该参考主页。使用该元素的原因是：帮助定位那些不在仓库里的构件（由于license限制）。-->
        <downloadUrl/>
        <!--如果构件有了新的group ID和artifact ID（构件移到了新的位置），这里列出构件的重定位信息。-->
        <relocation>
            <!--构件新的group ID-->
            <groupId/>
            <!--构件新的artifact ID-->
            <artifactId/>
            <!--构件新的版本号-->
            <version/>
            <!--显示给用户的，关于移动的额外信息，例如原因。-->
            <message/>
        </relocation>
        <!-- 给出该构件在远程仓库的状态。不得在本地项目中设置该元素，因为这是工具自动更新的。有效的值有：none（默认），converted（仓库管理员从 Maven 1 POM转换过来），partner（直接从伙伴Maven 2仓库同步过来），deployed（从Maven 2实例部 署），verified（被核实时正确的和最终的）。-->
        <status/>
    </distributionManagement>
    <!--以值替代名称，Properties可以在整个POM中使用，也可以作为触发条件（见settings.xml配置文件里activation元素的说明）。格式是<name>value</name>。-->
    <properties/>
</project>
```

