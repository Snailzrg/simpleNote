[TOC]

# Gradle笔记-Gradle基础

# Gradle 基础

## Gradle 构建生命周期

- 初始化阶段：解析整个工程中所有 Project，构建所有 Project 对应的 Project 对象
- 配置阶段：解析所有 Project 对象中的 Task，构建 Task 拓扑图
- 执行阶段：执行具体的 Task 以及依赖的 Task

## 监听 Gradle 构建生命周期

监听生命周期常用 API： beforeEvaluate {}：完成初始化阶段之后，配置阶段开始之前 afterEvaluate {}：完成配置阶段之后，执行阶段开始之前 gradle.buildFinished {}：Gradle 构建执行完成之后 gradle.beforeProject {}：作用等同于 beforeEvaluate gradle.afterProject {}：作用等同于 afterEvaluate

自定义监听： gradle.addListener() gradle.addBuildListener() gradle.addProjectEvaluationListener()

## Project

### Project 基础

每一个 Project 都对应一个 build.gradle 文件； 类似 Groovy Script 文件，每一个 Groovy Script 文件，都会被编译器编译成 Script 类； 同样，每一个 build.gradle 文件，都会被 Gradle 编译成 Project 类； 所以，build.gradle 中所有的代码，本质上是写在一个 Project 类内部，并最终被执行；

### Project 相关 API

build.gradle 中所有的代码，都是在配置阶段执行； 在 Task 中的代码，才会在执行阶段执行；

```
// 获取所有项目
getAllprojects()
// 获取所有子项目
getSubprojects()
// 获取根项目
getRootProject()
// 获取父项目
getParent()

// 对指定名称的 Project 进行操作，相当于在 app 项目的 build.gradle 文件中写代码
project('app') { Project project ->
    group 'com.demo'
    version '0.0.1.1'
    println '---app---'
    println project.group
    println project.version
}

// 为所有project添加配置，包括根project本身
allprojects {
    group 'com.demo'
    version '0.0.1.1'
}

// 为所有子project添加配置
subprojects {
    group 'com.demo'
    version '0.0.1.1'
}
复制代码
```

### Project 属性相关 API

Project 重要属性：

```
// 默认 build 文件名称；正因为该属性，所以所有的 Project 都用 build.gradle 文件来进行构建
String DEFAULT_BUILD_FILE = "build.gradle";
// Project 和 Task 路径名的层次结构分隔符
String PATH_SEPARATOR = ":";
// 默认 build 文件保存路径
String DEFAULT_BUILD_DIR_NAME = "build";
//gradle 的 properties 文件
String GRADLE_PROPERTIES = "gradle.properties";
复制代码
```

扩展属性使用方式 1： 除了上述常用的重要属性，gradle 也支持自定义扩展属性； 扩展属性可以定义在本身 Project 中，也可以定义在 rootProject 中； subProject 中会继承 rootProject 中的所有属性，subProject 因此能直接使用定义在 rootProject 中的属性；

```
// rootProject 定义扩展属性
ext {
    sdkVersion = 28
    constraintlayout = 'androidx.constraintlayout:constraintlayout:1.1.3'
}

//  subProject 中使用
compileSdkVersion sdkVersion
implementation constraintlayout
复制代码
```

扩展属性使用方式 2： 也可以单独将所有扩展属性，写到一个专门保存扩展属性的 gradle 文件中； 比如如下 myext.gradle 文件

```
// myext.gradle 文件
ext {
    android = [
            sdkVersion: 28
    ]
    constraintlayout = 'androidx.constraintlayout:constraintlayout:1.1.3'
}
复制代码
```

使用时，在 rootProject 中引入 myext.gradle，然后在 subProject 中使用；

```
// rootProject 引入 myext.gradle
apply from:this.file('myext.gradle')

// subProject 中使用
compileSdkVersion rootProject.ext.android.sdkVersion
implementation constraintlayout
复制代码
```

扩展属性使用方式 3： 扩展属性也可以定义在 gradle.properties 文件中，然后所有 Project 都可以使用；

```
// gradle.properties 文件中定义
myCompileSdkVersion = 28

// Project 中使用
compileSdkVersion myCompileSdkVersion.toInteger()
复制代码
```

### Project 文件相关 API

路径获取

```
// 根项目的路径
getRootDir()
// 当前项目的build路径
getBuildDir()
// 当前项目的路径
getProjectDir()
复制代码
```

文件操作

```
// 相对路径获取文件
this.getContent('myext.gradle')
def getContent(String path) {
    try {
        // 传入当前project文件夹的相对路径
        def file = file(path)
        def files = files(path)
        println file.text
    } catch (GradleException e) {
        println 'file path error'
    }
}

// 复制文件
copy {
    from file('myext.gradle')
    into project('app').getProjectDir()
}

copy {
    from file('build/outputs/apk/')
    into getRootProject().getBuildDir().path + '/apk/'
    exclude {
        // 排除不需要copy的文件
    }
    rename {
        // 对文件进行重命名
    }
}

// 文件树进行遍历
fileTree('build/outputs/apk/') { FileTree fileTree ->
    fileTree.visit { FileTreeElement element ->
        println 'element file name:' + element.file.name
    }
}
复制代码
```

### Project 依赖相关 API

Project 中的 buildscript

```
buildscript {
    // 配置工程的仓库地址
    repositories {
        jcenter()
        mavenCentral()
        // 本地maven仓库
        mavenLocal()
        // 私有maven仓库
        maven {
            name 'mavendemo'
            url 'http://mavendemo.com'
            credentials {
                username = 'joe'
                password = 'secret'
            }
        }
    }
    // 配置 build.gradle 本身所需的依赖
    // 与 Project.dependencies 不同，buildscript 中的 dependencies 依赖使用关键字 classpath
    dependencies {
        classpath 'com.android.tools.build:gradle:3.6.0'
    }
}
复制代码
```

Project 中的 dependencies

```
// 项目代码中所需的依赖
dependencies {
    // 配置本地 fileTree/file/files 依赖
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    // 配置远程依赖
    implementation 'androidx.appcompat:appcompat:1.1.0'
    // 配置本地项目依赖
    implementation project('app') {
        // 排除指定 module 依赖
        exclude module: 'support-v4'
        // 排除指定 group 依赖
        exclude group: 'com.android.support'
        // 是否允许传递依赖
        transitive false
    }
}
复制代码
```

### Project 外部命令执行 API

exec 执行外部命令

```
// 执行外部命令
task(name: 'apkcopy') {
    doLast { // 执行阶段时执行
        def srcPath = this.getBuildDir().path + '/outputs/apk/'
        def desPath = 'Users/Administrator/Downloads'
        def command = "mv -f ${srcPath} ${desPath}"
        exec {
            executable 'bash'
            args '-c',command
        }
    }
}
复制代码
```

## Task

### Task 的定义

```
// 通过Task函数创建Task
task myTask {
    // 配置阶段执行
    println 'myTask do something'
    // 执行阶段执行：task 操作列表的开头执行
    doFirst {
        println 'myTask doFirst'
    }
    // 执行阶段执行：task 操作列表的结尾执行
    doLast {
        println 'myTask doLast'
    }
}
myTask.doFirst {
    // 先执行外部 doFirst，再执行内部 doFirst
    println 'myTask doFirst2'
}

// 通过TaskContainer创建Task
tasks.create('myTask2') {
    println 'myTask2 do something'
}
复制代码
```

### Task 的属性配置

```
// 配置Task相关属性
task myTask3(group: 'demo', description: 'myTask3') {
    println 'myTask3 do something'
}

task myTask4 {
    setGroup('demo')
    setDescription('myTask4')
    println 'myTask4 do something'
}
复制代码
```

### Task 的依赖与执行顺序

dependsOn 简单使用

```
// taskDemo2依赖于taskDemo1执行
task taskDemo1 {
    doLast {
        println 'doLast taskDemo1'
    }
}
task taskDemo2 {
    dependsOn(taskDemo1)
    doLast {
        println 'doLast taskDemo2'
    }
}
复制代码
```

dependsOn 进阶使用

```
task lib1 {
    doLast {
        println 'doLast lib1'
    }
}
task lib2 {
    doLast {
        println 'doLast lib2'
    }
}
task nolib {
    doLast {
        println 'doLast nolib'
    }
}
// myDemo2 任务依赖 lib Task
task myDemo2 {
    // lib Task 必须要在 myDemo2 之前声明
    dependsOn this.tasks.findAll { Task task ->
        return task.name.startsWith('lib')
    }
    doLast {
        println 'doLast myDemo2'
    }
}
复制代码
```

mustRunAfter 使用

```
task taskSort1{
    doLast {
        println 'doLast taskSort1'
    }
}
task taskSort2{
    // 在指定任务之后才执行
    mustRunAfter taskSort1
    doLast {
        println 'doLast taskSort2'
    }
}
task taskSort3{
    mustRunAfter taskSort2
    doLast {
        println 'doLast taskSort3'
    }
}
复制代码
```

### Task 挂接到生命周期

挂接到 build 生命周期

```
// 通过 doLast 挂接到 build 方法之后
afterEvaluate {
    def myBuild = getTasks().getByName('build')
    if (myBuild == null) {
        println 'myBuild null error'
        return
    }
    myBuild.doLast {
        println 'myBuild doLast'
    }
}

// finalizedBy 的使用
task frontTask {
    doLast {
        println 'doLast frontTask'
    }
}
task backTask {
    // 在backTask任务执行之后执行frontTask
    finalizedBy frontTask
    doLast {
        println 'doLast backTask'
    }
}

// 通过 finalizedBy 挂接到 build 方法之后
task buildMyLog {
    doLast {
        println 'doLast buildMyLog'
    }
}
afterEvaluate {
    def myBuild = getTasks().getByName('build')
    // 在myBuild任务执行之后执行buildMyLog
    myBuild.finalizedBy buildMyLog
}
复制代码
```

### Task 的类型

Task 常用类型

```
// 删除任务
task myDel(type: Delete) {
    delete 'uglyFolder', 'uglyFile'
}
// 拷贝任务
task myCopy(type: Copy) {
    from 'src/main/doc'
    into 'build/target/doc'
}
// 执行任务
task myExec(type:Exec) {
    workingDir '../tomcat/bin'
    //on windows:
    commandLine 'cmd', '/c', 'stop.bat'
    //on linux
    commandLine './stop.sh'
}
复制代码
```

## 其他模块

### Settings

gradle 初始化中的 Settings 类：org.gradle.api.initialization.Settings Settings 重要属性：String DEFAULT_SETTINGS_FILE = "settings.gradle"; 该属性使得 settings.gradle 文件中的操作，最终会对应到 Settings 类 常用方法：include 决定哪些项目要加入构建

### SourceSet

Android 中的 AndroidSourceSet 类：com.android.build.gradle.api.AndroidSourceSet SourceSets 中默认必须拥有 main/test 两个 SourceSet，因此会在 SourceSets 中配置 main 闭包；

```
sourceSets.getByName('main') {}
sourceSets.main {}
sourceSets { main {} }
复制代码
```

上面都是对 main 这个 SourceSet 进行配置，其代码是等效的；

```
// 指定源代码文件被Gradle编译的路径
android {
    sourceSets {
        main {
            manifest.srcFile 'AndroidManifest.xml'
            java.srcDirs = ['src']
            resources.srcDirs = ['src']
            aidl.srcDirs = ['src']
            renderscript.srcDirs = ['src']
            // 修改 res 资源目录；允许多个res文件夹
            res.srcDirs = ['src/main/res',
                            'src/main/res-nfc',
                            'src/main/res-camera']
            // 修改 assets 文件存放位置
            assets.srcDirs = ['assets']
            // 修改 so 库存放位置
            jniLibs.srcDirs = ['libs']
        }
}
复制代码
```

sourceSets 的属性详解：

java 属性：设置 java 代码的存放位置

```
main {
    java {
        // 存在的java代码路径
        srcDirs = [
                'src/main/java',
                'src/main/myDemo/exclude'
        ]
        // 针对我们设置的 “srcDirs” 文件夹路径，设置将哪些类不进行编译打包
        excludes = ['myDemo/*.java']
        // 针对我们设置的 “srcDirs” 文件夹路径，设置将哪些类进行编译打包;默认情况下该属性的值为**/*.java
        includes = ["com/myDemo/MainActivity.java"]
    }
}
复制代码
```

assets 属性：设置 assets 的存放位置

```
assets.srcDirs 'src/main/assets', 'src/main/myAssets'
复制代码
```

aidl 属性：设置 aidl 的存放位置

```
aidl.srcDirs 'src/main/aidl', 'src/main/myAidl'
复制代码
```

jni 属性：设置 jni 的存放位置

```
jni.srcDirs 'src/main/jni','src/main/myJni'
复制代码
```

jniLibs 属性：设置 jniLibs 的存放位置

```
jniLibs.srcDirs 'libs','mylibs'
复制代码
```

manifest 属性：设置 manifest 的存放位置

```
manifest.srcFile 'src/main/MyManifest.xml'
复制代码
```

res 属性：设置 res 的存放位置

```
res.srcDirs 'src/main/res', 'src/main/res-debug'
复制代码
```

setRoot 方法：设置了 setRoot ，则 gradle 会在我们设置的同级目录下找资源

```
main {
    // 如果我们的代码都在同一个目录下，可以用setRoot进行设置，
    // 设置了 setRoot 之后，gradle的编译只会在同级目录下找资源，
    // 例如：只会在 src/mypath/java 找java代码
    // 会忽略 java.srcDirs 设置的路径
    setRoot 'src/mypath'

    // 这个会忽略
    java.srcDirs 'src/main/java'
}
复制代码
```

### Plugin

Plugin 本质上是对 Task 的封装，将所需要执行的 Task 编写成一个插件，然后通过插件来执行插件中包含的任务； 这里以本地创建 buildSrc 文件夹的方式来自定义插件；

```
1-在根 build.gradle 的同级目录下，创建 buildSrc 文件夹；
注：buildSrc 文件夹是 gradle 默认的自定义插件目录；如果有 buildSrc 文件夹存在，在 build 项目时，会优先构建 buildSrc 中的内容；
2-创建 buildSrc 文件夹后，rebuild 工程，会在 buildSrc 中自动创建内容；
3-在 buildSrc 文件夹中创建 build.gradle，通过 sourceSets 指定代码目录；
4-在 buildSrc 文件夹中创建 src/main/groovy 目录，在该目录中编写 Plugin/ProjectExtension/Task；
注：自定义 Plugin 可以直接通过 project.task('taskname')创建任务,也可以通过 project.task('taskname',type: MyTask)继承已经写好的任务；
5-在 buildSrc 文件夹中创建 src/main/resources 目录，在 resources 目录下创建目录 META-INF/gradle-plugins 目录，目录中创建 properties 文件，编写插件全类名；
6-在 project 中的 build.gradle 中使用插件 apply plugin: 'com.myplugin'
复制代码
```

Plugin 参考资料： [blog.csdn.net/u010982507/…](https://blog.csdn.net/u010982507/article/details/104875115) [juejin.im/post/684490…](https://juejin.im/post/6844903977327263751)

### Android Gradle 插件

参考资料： [blog.csdn.net/lyz_zyx/art…](https://blog.csdn.net/lyz_zyx/article/details/83385746) [www.jianshu.com/p/c11862136…](https://www.jianshu.com/p/c11862136abf)

*参考资料* 慕课网 《Gradle3.0 自动化项目构建技术精讲+实战》


作者：xinychan_juejin
链接：https://juejin.cn/post/6858423839970459655
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。