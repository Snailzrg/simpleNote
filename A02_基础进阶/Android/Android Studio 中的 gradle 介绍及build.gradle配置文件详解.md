# Android Studio 中的 gradle 介绍及build.gradle配置文件详解                              

不同于 Eclispse，Android  Studio 是采用 Gradle 来构建项目的，Gradle 是一个非常先进强大的项目构建工具，它使用了一种基于 Groovy  领域的特定语言（DSL）来声明项目设置，摒弃了基于 XML（如 Ant 和 Maven）的各种繁琐的配置，今天我们就来一起探讨 Android  Studio 中强大的项目构建工具 Gradle

\###**一.gradle 是什么？**

gradle是一个基于Apache Ant和Apache Maven概念的项目自动化建构工具,它使用一种基于Groovy的特定领域语言(DSL)来声明项目设置抛弃了基于XML的各种繁琐配置，使的它更简洁，灵活而且gradle完全兼容maven和ivy 
 打开Android Studio内置的终端，在输入如下命令查看gradle版本：

> gradlew -v

![这里写图片描述](https://img-blog.csdn.net/20180813142834308?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

### 二、通过gradle来导入jar包

每个module都有一个build.gradle文件，它其实是对应module的配置文件。关于build.gradle文件中具体内容的含义，我们将在最后一段进行讲解。 
 打开当前项目的Project Stucture，切换到dependencies标签下 
 ![这里写图片描述](https://img-blog.csdn.net/20180813143429455?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
 可以通过如图所示的三种方式添加对应的jar包：

- 第一种是Library dependency,是从http://bintray.com/bintray/jcenter这个中央仓库上扒下来的

  ![这里写图片描述](https://img-blog.csdn.net/20180813144924429?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

  - 第二种是jar，是在libs文件下放入的jar包 
     ![这里写图片描述](https://img-blog.csdn.net/20180813145044687?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 第三种是module，自行导入或者新建的module 
   ![这里写图片描述](https://img-blog.csdn.net/20180813145107243?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
   添加响应的jar包后，在App这个module的build.gradle文件中显示如下 
   ![这里写图片描述](https://img-blog.csdn.net/20180813145406144?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

### 三、签名打包的两种方式



1. 方式1：通过Android Studio进行签名：选择菜单栏”Build-Generate signed apk”，可以通过添加jks文件或者新建jsk，然后进行打签名包； 
    ![这里写图片描述](https://img-blog.csdn.net/20180813150413723?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
    2.方式2：通过命令行的方式进行签名： 
    ![这里写图片描述](https://img-blog.csdn.net/20180813150748447?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
    配置完成后在build,gradle显示如下，然后执行菜单栏的”build-clean Project”，紧接着在命令行Terminal输入如下命令： 



> gradlew assembleRelease   
>   ![这里写图片描述](https://img-blog.csdn.net/20180813150900433?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
>   也可以通过点击gradle进行打包 
>   ![这里写图片描述](https://img-blog.csdn.net/20180813151253427?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

### 四、build.gradle详解

![这里写图片描述](https://img-blog.csdn.net/20180813151608369?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L211cmFuZmVp/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
 1）工程目录下的 build.gradle 文件

```
buildscript {

    //构建过程依赖的仓库
    repositories {
        //代码托管仓库
        jcenter()
    }
    dependencies {
        //Gradle 插件及使用版本
        classpath 'com.android.tools.build:gradle:2.3.0'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

//这里面配置整个项目依赖的仓库,这样每个module就不用配置仓库了
allprojects {
    repositories {
        //代码托管仓库，可以引用 jcenter() 上任何的开源项目
        jcenter()
    }
}
// 运行gradle clean时，执行此处定义的task。
// 该任务继承自Delete，删除根目录中的build目录。
// 相当于执行Delete.delete(rootProject.buildDir)
task clean(type: Delete) {
    delete rootProject.buildDir
}12345678910111213141516171819202122232425262728
```

2)某个Mode中的build.gradle文件

```
apply plugin: 'com.android.application' //表示是一个应用程序的模块，可独立运行
//apply plugin: 'com.android.library' //表示是一个依赖库，不能独立运行
android {
//程序在编译的时候会检查lint，有任何错误提示会停止build，我们可以关闭这个开关
    lintOptions {
        abortOnError false  
        //即使报错也不会停止打包
        checkReleaseBuilds false  
        //打包release版本的时候进行检测
    }

    compileSdkVersion 25   //指定项目的编译版本
    buildToolsVersion "25.0.1"//指定项目构建工具的版本;其中包括了打包工具aapt、dx等等
    defaultConfig {
        applicationId "com.hhqy.learnndk2" //指定包名
        minSdkVersion 14//指定最低的兼容的Android系统版本
        targetSdkVersion 25//指定你的目标版本，表示你在该Android系统版本已经做过充分的测试
        versionCode 1   //版本号
        versionName "1.0"   //版本名称
        multiDexEnabled true  
        //当方法数超过65535(方法的索引使用的是一个short值，
        //而short最大值是65535)的时候允许打包成多个dex文件，动态加载dex。这里面坑很深啊
    }
    buildTypes { //指定生成安装文件的配置，常有两个子包:release,debug，注：直接运行的都是debug安装文件
        release { //用于指定生成正式版安装文件的配置
            minifyEnabled false     //指定是否对代码进行混淆，true表示混淆
            //指定混淆时使用的规则文件，proguard-android.txt指所有项目通用的混淆规则，proguard-rules.pro当前项目特有的混淆规则
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
dependencies { //指定当前项目的所有依赖关系：本地依赖、库依赖、远程依赖
    compile fileTree(dir: 'libs', include: ['*.jar'])//本地依赖
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    compile 'com.android.support:appcompat-v7:25.0.1'//远程依赖，com.android.support是域名部分，appcompat-v7是组名称，25.0.1是版本号
    compile project(':hello')//库依赖
    testCompile 'junit:junit:4.12'  //声明测试用列库
    compile 'com.android.support.constraint:constraint-layout:1.0.0-alpha7'
}
//声明是要使用谷歌服务框架
apply plugin: 'com.google.gms.google-services'

//使用maven仓库。android有两个标准的library文件服务器，一个jcenter一个maven。两者毫无关系。
//jcenter有的maven可能没有，反之亦然。
//如果要使用jcenter的话就把mavenCentral()替换成jcenter()
repositories {
    mavenCentral()
```